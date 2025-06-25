library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity proc is
    generic (
        -- 16 bit data
        RAM_WIDTH : integer := 16;
        RAM_DEPTH : integer := 32
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        
        -- Write to imem
        wr_en_IMEM : in std_logic;
        wr_data_IMEM : in std_logic_vector(RAM_WIDTH - 1 downto 0);
        
        -- Read from dmem
        rd_en_DMEM : in std_logic;
        rd_valid_DMEM : out std_logic;
        rd_data_DMEM : out std_logic_vector(RAM_WIDTH - 1 downto 0)
    );
end proc;

architecture rtl of proc is
    -- Pipeline record type for each stage
    type pipe_type is record
        
		  instr : std_logic_vector(15 downto 0);  -- Current instruction
        valid : std_logic;                      -- Instruction is valid
        pc    : integer; 								-- PC value for this instruction, this is just for simplicity in RTL simulation, actually no significance for operation

    end record;

    -- Pipeline registers for each stage
    signal if_stage_reg : pipe_type;
    signal id_stage_reg : pipe_type;
    signal ex_stage_reg : pipe_type;
    signal mem_stage_reg : pipe_type;
    signal wb_stage_reg : pipe_type;
    
    -- Signals for memory and datapath connections
    signal rd_en_IMEM : std_logic;
    signal rd_valid_IMEM : std_logic;
    signal imem_out, dmem_out : std_logic_vector(RAM_WIDTH - 1 downto 0);
    signal wr_dmem_data : std_logic_vector(RAM_WIDTH - 1 downto 0);
    signal wr_en_DMEM, rf_wr_en : std_logic;
    signal mux_alua_sel : std_logic;
    signal mux_alub_sel : std_logic_vector(1 downto 0);
    signal dest_mux_sel : std_logic;
    signal rd_en_DMEM_sig : std_logic;
    
    -- Program counter and instruction tracking
    signal pc_current : std_logic_vector(15 downto 0);  -- Current PC from PC component
    signal pc_next : std_logic_vector(15 downto 0);     -- Next PC from PC component
	 signal pc_num  : integer;
    signal cpu_started : std_logic := '0';
    
    -- JRI instruction detection and handling
    signal is_jri_detected : std_logic := '0';  -- Flag to indicate JRI detection (from ID stage)
    signal is_jri_active : std_logic := '0';    -- Flag to control PC component (set in falling edge process)
    signal is_jri_if : std_logic := '0';        -- Flag to detect JRI in IF stage
    signal regA_data_for_jri : std_logic_vector(15 downto 0);
    signal jri_imm_for_pc : std_logic_vector(8 downto 0);
    signal insert_nop : std_logic := '0';       -- Flag to insert NOP after JRI
    
    -- Stall and hazard signals
    signal stall_pipeline : std_logic := '0';
    
    -- Control signals for WB stage
    signal wb_rf_wr_en : std_logic := '0';
    signal wb_dest_mux_sel : std_logic := '0';
    
    -- Components of the processor
    component ring_buffer is
        generic (
            RAM_WIDTH : integer := 16;
            RAM_DEPTH : integer := 32
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
        
            -- Write port
            wr_en : in std_logic;
            wr_data : in std_logic_vector(RAM_WIDTH - 1 downto 0);
        
            -- Read port
            rd_en : in std_logic;
            rd_valid : out std_logic;
            rd_data : out std_logic_vector(RAM_WIDTH - 1 downto 0);
        
            -- Flags
            empty : out std_logic;
            empty_next : out std_logic;
            full : out std_logic;
            full_next : out std_logic;
        
            -- The number of elements in the FIFO
            fill_count : out integer range RAM_DEPTH - 1 downto 0
        );
    end component;
    
    component datapath is
        port(
            clk, reset          : in std_logic;
            instr               : in std_logic_vector(15 downto 0);
            rf_wr_en            : in std_logic;
            mux_alua_sel        : in std_logic;
            mux_alub_sel        : in std_logic_vector(1 downto 0);
            dest_mux_sel        : in std_logic;
            dmem_data_write     : out std_logic_vector(15 downto 0);
            dmem_data_read      : in std_logic_vector(15 downto 0);
            R0, R1, R2, R3, R4, R5, R6, R7 : out std_logic_vector(15 downto 0); -- Debug
            pc_jri              : out std_logic_vector(15 downto 0);
            jri_regA_data       : out std_logic_vector(15 downto 0);
            jri_immediate       : out std_logic_vector(8 downto 0)  
        );
    end component;

    component PC_Component is
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            is_jri          : in std_logic;
            regA_data       : in std_logic_vector(15 downto 0);
            jri_imm         : in std_logic_vector(8 downto 0);
				start				 : in std_logic;
            pc_current      : out std_logic_vector(15 downto 0);
            pc_next         : out std_logic_vector(15 downto 0)
        );
    end component;

begin
  	   -- Detecting JRI in IF stage based on opcode bits (15 downto 12)
			is_jri_if <= '1' when if_stage_reg.valid = '1' and if_stage_reg.instr(15 downto 12) = "0111" else '0';
	 
      -- Always read from IMEM when not in reset, not stalled, and not inserting NOP
			rd_en_IMEM <= '0' when imem_out(15 downto 12) = "0111" else -- for detecting right at the rising edge, verify this: assign @(K Sri Charan Raj)
							  '1' when rst = '0' and stall_pipeline = '0' and insert_nop = '0' else
							  '0';

    
    -- Connect DMEM output to processor output
    rd_data_DMEM <= dmem_out;
    
    -- Connect WB stage control signals to datapath
    rf_wr_en <= wb_rf_wr_en;
    dest_mux_sel <= wb_dest_mux_sel;
    
	 pc_num <= to_integer(unsigned(pc_current));

    PC_inst: PC_Component
        port map(
            clk => clk,
            rst => rst,
            is_jri => is_jri_active,
            regA_data => regA_data_for_jri,
            jri_imm => jri_imm_for_pc,
				start   => rd_valid_IMEM,
            pc_current => pc_current,
            pc_next => pc_next
        );

    IMEM: ring_buffer
        port map(
            clk          => clk,
            rst          => rst,
            wr_en        => wr_en_IMEM,
            wr_data      => wr_data_IMEM,
            rd_en        => rd_en_IMEM,
            rd_valid     => rd_valid_IMEM,
            rd_data      => imem_out,
            empty        => open,
            empty_next   => open,
            full         => open,
            full_next    => open,
            fill_count   => open    
        );

    DMEM: ring_buffer
        port map(
            clk          => clk,
            rst          => rst,
            wr_en        => wr_en_DMEM,
            wr_data      => wr_dmem_data,
            rd_en        => rd_en_DMEM_sig,
            rd_valid     => rd_valid_DMEM,
            rd_data      => dmem_out,
            empty        => open,
            empty_next   => open,
            full         => open,
            full_next    => open,
            fill_count   => open
        );

    Datapath_inst: datapath
        port map(
            clk             => clk, 
            reset           => rst,         
            instr           => id_stage_reg.instr,  -- Use ID stage instruction
            rf_wr_en        => rf_wr_en,            -- ctrl sig
            mux_alua_sel    => mux_alua_sel,        -- ctrl sig
            mux_alub_sel    => mux_alub_sel,        -- ctrl sig
            dest_mux_sel    => dest_mux_sel,        -- ctrl sig
            dmem_data_write => wr_dmem_data,        -- datapath output - for sw
            dmem_data_read  => dmem_out,            -- datapath input  - for lw
            pc_jri          => open,                -- Not used anymore
            jri_regA_data   => regA_data_for_jri,   
            jri_immediate   => jri_imm_for_pc       
        );
  
    -- Pipeline stage advancement process
    process(clk, rst)
    begin
        if rst = '1' then
            -- Initializing all pipeline registers
            if_stage_reg.valid <= '0';
            if_stage_reg.instr <= (others => '0');
            if_stage_reg.pc <= 0;
            
            id_stage_reg.valid <= '0';
            id_stage_reg.instr <= (others => '0');
            id_stage_reg.pc <= 0;
            
            ex_stage_reg.valid <= '0';
            ex_stage_reg.instr <= (others => '0');
            ex_stage_reg.pc <= 0;
            
            mem_stage_reg.valid <= '0';
            mem_stage_reg.instr <= (others => '0');
            mem_stage_reg.pc <= 0;
            
            wb_stage_reg.valid <= '0';
            wb_stage_reg.instr <= (others => '0');
            wb_stage_reg.pc <= 0;
            
            cpu_started <= '0';
            stall_pipeline <= '0';
            -- insert_nop <= '0';
            -- is_jri_detected <= '0';
            
        elsif rising_edge(clk) then
            -- WB Stage processing
            if wb_stage_reg.valid = '1' then
                -- Clearing the valid bit after WB completion
                wb_stage_reg.valid <= '0';
            end if;
            
            -- Pipeline register updates
            wb_stage_reg <= mem_stage_reg;
            mem_stage_reg <= ex_stage_reg;
            ex_stage_reg <= id_stage_reg;

            -- ID to IF stage
            id_stage_reg <= if_stage_reg;
            
            -- Fetching new instruction if CPU started, not stalled, and not inserting NOP
            if stall_pipeline = '0'  then
                if insert_nop = '1' then
                    -- Inserting NOP instruction
                    if_stage_reg.instr <= (others => '0');
                    if_stage_reg.valid <= '0';
                    if_stage_reg.pc <= to_integer(unsigned(pc_current))+1;

                elsif cpu_started = '1' and rd_valid_IMEM = '1' then
                    -- Fetching next instruction
                    if_stage_reg.instr <= imem_out;
                    if_stage_reg.valid <= '1';
                    if_stage_reg.pc <= to_integer(unsigned(pc_current))+1;
                elsif rd_valid_IMEM = '1' and cpu_started = '0' then
                    -- First instruction - start CPU
                    cpu_started <= '1';
                    if_stage_reg.instr <= imem_out;
                    if_stage_reg.valid <= '1';
                    if_stage_reg.pc <= to_integer(unsigned(pc_current))+1;
                end if;
            end if;
            
            -- Resetting stall signal at the end of the cycle
            stall_pipeline <= '0';
        end if;
    end process;
    
    -- JRI activation process (at falling edge to prepare for PC update)
    process(clk)
    begin
        if falling_edge(clk) then
            -- Default is not active
            is_jri_active <= '0';
				-- Clearing the insert_nop flag after inserting one NOP
            insert_nop <= '0';            
            -- Activate is_jri_active when JRI is detected in IF stage
            -- This allows PC component to calculate the target address, before the next rising edge, check for JRI in IF stage and set insert_nop immediately
				if is_jri_if = '1' then
                insert_nop <= '1';
                is_jri_detected <= '1';
            else
                is_jri_detected <= '0';
            end if;
				
            if is_jri_detected = '1' then
                is_jri_active <= '1';
            end if;
				
        end if;
    end process;

    -- Control signal generation process
    process(clk)
    begin
        if falling_edge(clk) then
            -- Default control signals
            mux_alua_sel <= '0';
            mux_alub_sel <= "00";
            wr_en_DMEM <= '0';
            rd_en_DMEM_sig <= '0';
            
            -- Generating control signals based on current pipeline stage
            
            -- ID Stage: Register file read
            if id_stage_reg.valid = '1' then
                -- Extract opcode from the instruction
                case id_stage_reg.instr(15 downto 12) is
                    -- LW instruction (opcode 0000)
                    when "0000" =>
                        mux_alua_sel <= '1';  -- Use regA for address base
                        
                    -- SW instruction (opcode 0001)
                    when "0001" =>
                        mux_alua_sel <= '1';  -- Use regA for address base
                        
                    -- ADD instruction (opcode 0010)
                    when "0010" =>
                        mux_alua_sel <= '0' ;  -- Use regB for ALU
                        mux_alub_sel <= "00";  -- Use regC for ALU
                        
                    -- SUB instruction (opcode 0011)
                    when "0011" =>
                        mux_alua_sel <= '0';  -- Use regB for ALU
                        mux_alub_sel <= "00";  -- Use regC for ALU
                        
                    -- MUL instruction (opcode 0100)
                    when "0100" =>
                        mux_alua_sel <= '0';  -- Use regB for ALU
                        mux_alub_sel <= "00";  -- Use regC for ALU
                        
                    -- ADDI instruction (opcode 0101)
                    when "0101" =>
                        mux_alua_sel <= '0';  -- Use regB for ALU
                        mux_alub_sel <= "01";  -- Use sign-extended immediate
                        
                    -- SLL instruction (opcode 0110)
                    when "0110" =>
                        mux_alua_sel <= '0';  -- Use regB for ALU
                        mux_alub_sel <= "00";  -- Use regC for shift amount
                        
                    -- JRI instruction (opcode 0111)
                    when "0111" =>
                        mux_alua_sel <= '1';  -- Use regA for jump address base
                        mux_alub_sel <= "10";  -- Use JRI immediate value
                        
                    when others => null;
                end case;
            end if;
            
            -- EX Stage: ALU operations
            if ex_stage_reg.valid = '1' then
                case ex_stage_reg.instr(15 downto 12) is
                    -- LW instruction (opcode 0000)
                    when "0000" =>
                        rd_en_DMEM_sig <= '1';  -- Read from memory
                        
                    -- SW instruction (opcode 0001)
                    when "0001" =>
                        wr_en_DMEM <= '1';  -- Write to memory FOR SW INSTR
                        
                    when others => null;
                end case;
            end if;
            
            -- MEM Stage: Memory operations
            if mem_stage_reg.valid = '1' then
                case mem_stage_reg.instr(15 downto 12) is
                    -- LW instruction (opcode 0000)
                    when "0000" =>
                        wb_rf_wr_en <= '1';
                        wb_dest_mux_sel <= '0';  -- Select memory data
                        
                    -- SW instruction (opcode 0001)
                    when "0001" =>
                        wb_rf_wr_en <= '0';  
                        wb_dest_mux_sel <= '0';
                        
                    -- ALU operations
                    when "0010" | "0011" | "0100" | "0101" | "0110" =>
                        wb_rf_wr_en <= '1';  
                        wb_dest_mux_sel <= '1';  -- Select ALU result
                        
                    when others => 
                        wb_rf_wr_en <= '0';
                        wb_dest_mux_sel <= '1'; 
                end case;
            else
                wb_rf_wr_en <= '0';
                wb_dest_mux_sel <= '0';    
            end if;
        end if;
    end process;
end architecture;