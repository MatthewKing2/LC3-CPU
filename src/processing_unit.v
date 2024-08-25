
//------------------------------------------------------------------------------
// Module: processing_unit
// Description: Implements the register file, ALU, and MUXs that control register
//              file inputs and outputs, and what two operands the ALU operates on.
//------------------------------------------------------------------------------


module processing_unit ( 
    input   wire                i_CLK,
    input   wire                i_Reset,
    // Inputs for Reg File 
    input   wire                i_LD_REG,   // If value should be loaded into DR
    // Inputs for ALU 
    input   wire    [1:0]       i_ALUK,     // What ALU operation to do
    // Inputs for SR1 and DR Mux
    input   wire    [2:0]       i_IR_11_9,  // For DR Mux
    input   wire    [2:0]       i_IR_8_6,   // For DR Mux and SR1 Mux
    input   wire    [2:0]       i_IR_2_0,   // For SR2 
    input   wire    [1:0]       i_SR1MUX,   // Mux select for SR1
    input   wire    [1:0]       i_DRMUX,    // Mux select for DR 
    // Inputs for SR2 Mux
    input   wire                i_IR_5,     // Control for Mux
    input   wire    [4:0]       i_IR_4_0,   // Immediate 5
    // Bus Control and I/O
    input   wire    [15: 0]     i_bus,      // Bus for loading values into registers
    output  wire    [15: 0]     o_SR1_Out,  // Output to the Adder Mux Module
    output  wire    [15: 0]     o_ToBus);   // Output to the bus (top mod gates it)


    //-------------------------------------------------------
    // MUXs 
    //-------------------------------------------------------

    // SR1 Mux
    // Note: Determines register for SR1 output of Register File
    reg    [2:0]   w_SR1MUX_Out;
    always @(*) begin   // @ any "input" change, update value
        case(i_SR1MUX)
            2'b00: w_SR1MUX_Out = i_IR_11_9;    // Bits [11:9] of IR, represents DR address
            2'b01: w_SR1MUX_Out = i_IR_8_6;     // Bits [8:6] of IR, represents SR1 address
            2'b10: w_SR1MUX_Out = 3'b110;       // R6
            default: w_SR1MUX_Out = 3'b000;     // Defaults to 0
        endcase
    end


    // SR2 Mux
    // Note: Determines an input for the ALU (either SR2 from reg file output, or a sign 
    //       extended immediate 5 value)
    reg     [15:0]  w_SR2MUX_Out;
    wire    [15:0]  w_SR2_Out;              // SR2 Output from Reg File
    wire    [15:0]  w_Imm5_SEXT;            // Sign Extended Immediate 5 value
        assign w_Imm5_SEXT = (i_IR_4_0[4]) ? {11'b11111111111, i_IR_4_0} : {11'b00000000000, i_IR_4_0};

    always @(*) begin // @ any "input" change, update value
        case(i_IR_5)
            1'b0: w_SR2MUX_Out = w_SR2_Out;     // SR2 from register file  
            1'b1: w_SR2MUX_Out = w_Imm5_SEXT;   // Immediate 5 (from IR)
        endcase
    end

    // DR Mux
    // Note: Determines which register is the destination register in register file 
    reg    [2:0]   w_DRMUX_Out;
    always @(*) begin // @ any "input" change, update value
        case(i_DRMUX)
            2'b00: w_DRMUX_Out = i_IR_11_9 /* 3'b001*/;    // Bits [11:9] of IR, represents DR address
            2'b01: w_DRMUX_Out = 3'b111;       // R7 
            2'b10: w_DRMUX_Out = 3'b110;       // R6
            default: w_DRMUX_Out = 3'b000;      // Defaults to 0
        endcase
    end

    //-------------------------------------------------------
    // SubModule Instantiations
    //-------------------------------------------------------

    wire [15:0] w_SR1_Out; // Connects SR1 Out (from reg file) to ALU
    assign o_SR1_Out = w_SR1_Out;   // SR1 Out is also used by Adder Module

    register_file #(.INIT_FILE())
        register_file_module(
        .i_CLK(i_CLK),
        .i_Reset(i_Reset),
        .i_LD_REG(i_LD_REG),
        .i_DR_Addr(w_DRMUX_Out),    // Destination Register Address
        .i_SR1_Addr(w_SR1MUX_Out),  // Source Register #1 Address
        .i_SR2_Addr(i_IR_2_0),      // Source Register #2 Address
        .i_bus(i_bus),
        .o_SR1(w_SR1_Out),
        .o_SR2(w_SR2_Out)
    );

    alu alu_module(
        .i_ALUK(i_ALUK),
        .i_SR2_Out(w_SR2MUX_Out),   // sr2 mux's output
        .i_RegFile_Out(w_SR1_Out),  // Register File's Output 
        .o_ToBus(o_ToBus)           // Output (goes to bus)
    );


endmodule