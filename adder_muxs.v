
//------------------------------------------------------------------------------
// Module: Adder Muxs
// Logic: Combinational (not clocked)
//------------------------------------------------------------------------------

module adder_muxs ( 
    // From Control Store:
    input   wire                i_Addr1MuxControl,
    input   wire    [1: 0]      i_Addr2MuxControl,
    // From Data Path:
    input   wire    [10:0]     i_IR_10_0,
    input   wire    [15:0]     i_PC,
    input   wire    [15:0]     i_SR1_Out,
    // Ouptput to Bus
    output  wire    [15:0]      o_AdderMuxs
    );

    // Sign Extended IR[5:0] 
    wire    [15:0]  w_IR_5_0_SEXT; 
    assign w_IR_5_0_SEXT = (i_IR_10_0[5]) ? {11'b11111111111, i_IR_10_0[4:0]} : {11'b00000000000, i_IR_10_0[4:0]};

    // Sign Extended IR[8:0] 
    wire    [15:0]  w_IR_8_0_SEXT; 
    assign w_IR_8_0_SEXT = (i_IR_10_0[8]) ? {8'b11111111, i_IR_10_0[7:0]} : {8'b00000000, i_IR_10_0[7:0]};

    // Sign Extended IR[10:0] 
    wire    [15:0]  w_IR_10_0_SEXT; 
    assign w_IR_10_0_SEXT = (i_IR_10_0[10]) ? {6'b111111, i_IR_10_0[9:0]} : {6'b000000, i_IR_10_0[9:0]};


    // Addr 1 Mux (0 = PC, 1 = SR1)
    // ----------------------------------------------------
    wire [15:0] w_Addr1_Mux_Out;
    assign w_Addr1_Mux_Out = (i_Addr1MuxControl) ? i_SR1_Out : i_PC;
    // ----------------------------------------------------


    // Addr 2 Mux 
    // ----------------------------------------------------
    parameter ZERO          = 2'b00;    
    parameter offset6       = 2'b01;
    parameter PCoffset9     = 2'b10;
    parameter PCoffset11    = 2'b11;

    wire [15:0] w_Addr2_Mux_Out;
    assign w_Addr2_Mux_Out =    (i_Addr2MuxControl == ZERO)         ? 16'h0000 : 
                                (i_Addr2MuxControl == offset6)      ? w_IR_5_0_SEXT : 
                                (i_Addr2MuxControl == PCoffset9)    ? w_IR_8_0_SEXT : 
                                (i_Addr2MuxControl == PCoffset11)   ? w_IR_10_0_SEXT : 
                                16'hFFFF; // Never reached

    // ----------------------------------------------------


    // The actual Adder part 
    // ----------------------------------------------------
    assign o_AdderMuxs = w_Addr1_Mux_Out + w_Addr2_Mux_Out;
    // ----------------------------------------------------

endmodule
