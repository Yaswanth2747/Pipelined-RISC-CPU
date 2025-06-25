library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
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
            -- New outputs for PC_Component
            jri_regA_data       : out std_logic_vector(15 downto 0);  -- Register A data for JRI
            jri_immediate       : out std_logic_vector(8 downto 0)    -- 9-bit immediate for JRI
        );
end entity;

architecture path of datapath is

    -- Components Declaration
    component SE6 is
        port (input : in std_logic_vector(5 downto 0); output : out std_logic_vector(15 downto 0));
    end component;

    component SE9 is
        port (input : in std_logic_vector(8 downto 0); output : out std_logic_vector(15 downto 0));
    end component;
     
    -- Mux components
    component mux4 is
        port (
            input0, input1, input2, input3 : in std_logic_vector(15 downto 0);
            sel                            : in std_logic_vector(1 downto 0);
            output                         : out std_logic_vector(15 downto 0)
        );
    end component;

    component mux2 is
        port (
            input0, input1 : in std_logic_vector(15 downto 0);
            sel            : in std_logic;
            output         : out std_logic_vector(15 downto 0)
        );
    end component;
    
    component mux2x1_3bit is
    port (
        a    : in  std_logic_vector(2 downto 0);
        b    : in  std_logic_vector(2 downto 0);
        sel  : in  std_logic;
        y    : out std_logic_vector(2 downto 0)
    );
    end component;

    component Register1 is
        port (
            input         : in std_logic_vector(15 downto 0);
            write_en, clk : in std_logic;
            output        : out std_logic_vector(15 downto 0)
        );
    end component;

    component Register_File is
        port (
            RF_A1, RF_A2, RF_A3            : in std_logic_vector(2 downto 0);
            RF_D3               	       : in std_logic_vector(15 downto 0);
            RF_D1, RF_D2        	       : out std_logic_vector(15 downto 0);
            clk, RF_write       	       : in std_logic;
            R0, R1, R2, R3, R4, R5, R6, R7 : out std_logic_vector(15 downto 0)
        );
    end component;

    component ALU is 
        port (
            A, B   : in std_logic_vector(15 downto 0);
            opcode : in std_logic_vector(3 downto 0);
            C      : out std_logic_vector(15 downto 0);
            z_flag : out std_logic
        );
    end component;

    component TR1 is
        port (
            clk      : in std_logic;
            instr    : in std_logic_vector(15 downto 0);
            opcode   : out std_logic_vector(3 downto 0);
            regA     : out std_logic_vector(2 downto 0);
            regB     : out std_logic_vector(2 downto 0);
            regC     : out std_logic_vector(2 downto 0);
            addi_imm : out std_logic_vector(5 downto 0);
            jri_imm  : out std_logic_vector(8 downto 0)
        );
    end component;

    component TR2 is
        port (
            clk                 : in std_logic;
            opcode_in           : in std_logic_vector(3 downto 0);
            ALU_A               : in std_logic_vector(15 downto 0);
            ALU_B               : in std_logic_vector(15 downto 0);
            regA_in             : in std_logic_vector(2 downto 0);
            opcode_buffer_out   : out std_logic_vector(3 downto 0);
            ALU_IN_A            : out std_logic_vector(15 downto 0);
            ALU_IN_B            : out std_logic_vector(15 downto 0);
            regA_buffer_out     : out std_logic_vector(2 downto 0)
        );
    end component;
    
    component TR3 is
        port (
            clk                     : in std_logic;
            opcode                  : in std_logic_vector(3 downto 0);
            ALU_output              : in std_logic_vector(15 downto 0);
            sw_data                 : in std_logic_vector(15 downto 0);
            regA_in                 : in std_logic_vector(2 downto 0);
            opcode_buffer_out       : out std_logic_vector(3 downto 0);
            ALU_output_buffer_out   : out std_logic_vector(15 downto 0);
            sw_data_buffered        : out std_logic_vector(15 downto 0);
            regA_buffer_out         : out std_logic_vector(2 downto 0)
        );
    end component;
    
    component TR4 is
        port (
            clk                     : in std_logic;
            DMEM_READ_DATA          : in std_logic_vector(15 downto 0);
            ALU_output_t3           : in std_logic_vector(15 downto 0);
            regA_addr               : in std_logic_vector(2 downto 0);
            DMEM_READ_DATA_buffer   : out std_logic_vector(15 downto 0);
            regA_addr_buffer        : out std_logic_vector(2 downto 0);
            ALU_output_buffer_out   : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Internal signals
    signal opcode : std_logic_vector(3 downto 0);
    signal opcode_buffer1, opcode_buffer2 : std_logic_vector(3 downto 0);
    signal regA_addr, regB_addr, regC_addr: std_logic_vector(2 downto 0);
    signal regB_A_addr : std_logic_vector(2 downto 0);
    signal regB_data, regC_data : std_logic_vector(15 downto 0);
    signal RF_D3 : std_logic_vector(15 downto 0);
    signal RF_write: std_logic;
    signal Dest_mux_sel_sg: std_logic;
    signal jri_mux_sel : std_logic;
    signal SE6_input : std_logic_vector(5 downto 0);
    signal SE6_output : std_logic_vector(15 downto 0);
    signal SE9_input : std_logic_vector(8 downto 0);
    signal SE9_output : std_logic_vector(15 downto 0);
    signal ALU_input_A : std_logic_vector(15 downto 0);
    signal ALU_input_B : std_logic_vector(15 downto 0);
    signal ALU_output : std_logic_vector(15 downto 0);
    signal z_flag : std_logic;
    signal dmem_read_sg : std_logic_vector(15 downto 0);
    signal sw_data_buffer: std_logic_vector(15 downto 0);
    signal dmem_data_write_sg, dmem_data_read_sg : std_logic_vector(15 downto 0);
    signal regA_addr_buffer1, regA_addr_buffer2, regA_addr_buffer3 : std_logic_vector(2 downto 0);
    signal ALU_output_buffer2, ALU_output_buffer3 : std_logic_vector(15 downto 0);
    signal Alu_in2 : std_logic_vector(15 downto 0);
    signal ALU_in_sel: std_logic_vector(1 downto 0); 
    
    -- Signals for JRI detection and handling
    --signal regA_data : std_logic_vector(15 downto 0);
    signal jri_imm : std_logic_vector(8 downto 0);
    
begin

    -- TR1 instruction decoder
    TR1_inst : TR1
        port map (
            clk => clk,
            instr => instr,
            opcode => opcode,
            regA => regA_addr,
            regB => regB_addr,
            regC => regC_addr,
            addi_imm => SE6_input,
            jri_imm => jri_imm  -- Now directly connecting to our internal signal for JRI
        );

    -- Sign Extenders
    SE6_inst : SE6
        port map (input => SE6_input, output => SE6_output);

    SE9_inst : SE9
        port map (input => jri_imm, output => SE9_output);

    -- Register File
    Register_File_inst : Register_File
        port map (
            RF_A1 => regB_A_addr,
            RF_A2 => regC_addr,
            RF_A3 => regA_addr_buffer3,
            RF_D3 => RF_D3,
            RF_D1 => regB_data, -- gives RegA data for JRI, sw
            RF_D2 => regC_data,
            clk => clk,
            RF_write => RF_write,
            R0 => R0, R1 => R1, R2 => R2, R3 => R3, 
            R4 => R4, R5 => R5, R6 => R6, R7 => R7
        );
        
    -- MUX 2-to-1 for JRI or regB selection, also used for store.    
    -- Calling this MUX_ALU_A: Control Signal -> mux_alua_sel(1 bit)
    mux_jri_inst : mux2x1_3bit
        port map (
            a   => regB_addr,   -- For almost every instr except for JRI
            b   => regA_addr,   -- For JRI instr
            sel => jri_mux_sel,
            y   => regB_A_addr
        );

    -- mux4_inst : mux4  For ALU second input selection
    -- Calling this MUX_ALU_B: Control Signal -> mux_alub_sel(2 bit)
    alu_mux: mux4
        port map (
            input0 => regC_data,    -- For usual ALU operations
            input1 => SE6_output,   -- For ADDI Instruction
            input2 => SE9_output,   -- For JRI Instruction
            input3 => regC_data,    -- not used
            sel    => ALU_in_sel,
            output => Alu_in2
        );
    
    -- TR2
    TR2_inst : TR2
        port map (
            clk => clk,
            opcode_in => opcode,
            ALU_A => regB_data,
            ALU_B => Alu_in2,
            regA_in => regA_addr,
            opcode_buffer_out => opcode_buffer1,
            ALU_IN_A => ALU_input_A,
            ALU_IN_B => ALU_input_B,
            regA_buffer_out => regA_addr_buffer1
        );
          
    -- ALU
    ALU_inst : ALU
        port map (
            A => ALU_input_A,
            B => ALU_input_B,
            opcode => opcode_buffer1,
            C => ALU_output,
            z_flag => z_flag
        );

    -- TR3
    TR3_inst : TR3
        port map (
            clk => clk,
            opcode => opcode_buffer1,
            ALU_output => ALU_output,
            sw_data => ALU_input_A,
            regA_in => regA_addr_buffer1,
            opcode_buffer_out => opcode_buffer2,
            ALU_output_buffer_out => ALU_output_buffer2,
            sw_data_buffered => sw_data_buffer,
            regA_buffer_out => regA_addr_buffer2
        );

    -- TR4
    TR4_inst : TR4
        port map (
            clk => clk,
            DMEM_READ_DATA => dmem_data_read_sg,
            ALU_output_t3 => ALU_output_buffer2,
            regA_addr => regA_addr_buffer2,
            DMEM_READ_DATA_buffer => dmem_read_sg,
            regA_addr_buffer => regA_addr_buffer3,
            ALU_output_buffer_out => ALU_output_buffer3
        );

    -- MUX 2-to-1 Destination Mux
    -- Calling this MUX_WB: Control Signal -> dest_mux_sel(1 bit)
    mux2_inst : mux2
        port map (
            input0 => dmem_read_sg,         -- For storing after load
            input1 => ALU_output_buffer3,   -- ALU operations
            sel => Dest_mux_sel_sg,
            output => RF_D3
        );
          
    -- assignments
    dmem_data_write   <= sw_data_buffer;  -- Data that has to be written to DMEM for store instructions
    dmem_data_read_sg <= dmem_data_read;  -- Data read from DMEM for LOAD instructions
    pc_jri            <= ALU_output_buffer2; -- Legacy connection maintained for compatibility
    
    -- New connections for PC_Component
    jri_regA_data     <= regB_data;       -- Register A data for JRI
    jri_immediate     <= jri_imm;         -- 9-bit immediate value for JRI
    
    -- Control Signals from proc.vhdl for Entire Datapath   
    RF_write          <= rf_wr_en;        -- 1-bit enable for RF write
    jri_mux_sel       <= mux_alua_sel;    -- 1-bit sel line for ALU-A
    ALU_in_sel        <= mux_alub_sel;    -- 2-bit sel line for ALU-B
    Dest_mux_sel_sg   <= dest_mux_sel;    -- 1-bit sel line for destination selection
    
end architecture;