
//------------------------------------------------------------------------------
// Module: Mar Mux
// Logic: Combinational (not clocked)
// Explanation from textbook: 
    // 5.6.1.5 The MARMUX
    // As you know, memory is accessed by supplying the address to the MAR. The
    // MARMUX controls which of two sources will supply the MAR with the appropriate address during the execution of a load, a store, or a TRAP instruction. The
    // right input to the MARMUX is obtained by adding either the incremented PC or
    // a base register to zero or a literal value supplied by the IR. Whether the PC or a
    // base register and what literal value depends on which opcode is being processed.
    // The control signal ADDR1MUX specifies the PC or base register. The control
    // signal ADDR2MUX specifies which of four values is to be added. The left input
    // to MARMUX provides the zero-extended trapvector, which is needed to invoke
    // service calls, and will be discussed in detail in Chapter 9.
//------------------------------------------------------------------------------

module mar_mux ( 
    // From Control Store:
    input   wire                i_MarMuxControl,
    // From Data Path:
    input   wire    [7: 0]      i_IR_7_0,
    input   wire    [15:0]      i_Address,
    // Ouptput to Bus
    output  wire    [15:0]      o_MarMux
    );

    // Zero Extended IR[7:0] 
    wire    [15:0]  w_IR_ZEXT; 
    assign w_IR_ZEXT = {8'h00, i_IR_7_0};

    // Mar Mux
    assign o_MarMux = (i_MarMuxControl) ? w_IR_ZEXT : i_Address;

endmodule