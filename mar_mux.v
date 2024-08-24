
//------------------------------------------------------------------------------
// Module: Mar Mux
// Logic: Combinational (not clocked)
// Description: Multiplexer that selects the source of the address to be loaded 
//              into the Memory Address Register (MAR) during the execution of 
//              load, store, or TRAP instructions. It chooses between an address 
//              derived from the Program Counter (PC) or a base register, and a 
//              zero-extended trap vector for service calls, depending on the 
//              specific instruction being executed.
//------------------------------------------------------------------------------

module mar_mux ( 
    // From Control Store:
    input   wire                i_MarMuxControl,
    // From Data Path:
    input   wire    [7: 0]      i_IR_7_0,
    input   wire    [15:0]      i_Address,
    // Output to Bus
    output  wire    [15:0]      o_MarMux
    );

    // Zero Extended IR[7:0] 
    wire    [15:0]  w_IR_ZEXT; 
    assign w_IR_ZEXT = {8'h00, i_IR_7_0};

    // Mar Mux
    assign o_MarMux = (i_MarMuxControl) ? i_Address : w_IR_ZEXT;

endmodule