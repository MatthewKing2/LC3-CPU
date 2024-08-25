
//------------------------------------------------------------------------------
// Module: microsequencer
// Logic: Combinational and Clocked 
// Description: Responsible for determining the address of the next microinstruction 
//              in the Control Store, effectively controlling the sequence of states 
//              in the state machine. 
//------------------------------------------------------------------------------

module microsequencer ( 
    input   wire                i_CLK,
    input   wire                i_Reset,
    // From Control Store:
    input   wire    [5: 0]      i_j_field,
    input   wire    [2: 0]      i_COND_bits,
    input   wire                i_IRD,
    input   wire                i_LD_BEN,
    // From Memory IO:
    input   wire                i_R_Bit,
    // From Data Path:
    input   wire    [6: 0]      i_IR_15_9,
    input   wire    [2: 0]      i_NZP,
    input   wire                i_ACV,
    input   wire                i_PSR_15,
    // From Interrupt Control:
    input   wire                i_INT,
    output  wire     [5: 0]      o_AddressNextState);


    // Different MUX select line values for Microsequencer 
    parameter ACV   = 3'b110;
    parameter INT   = 3'b101;
    parameter PSR15 = 3'b100;
    parameter BEN   = 3'b010;
    parameter R     = 3'b001;
    parameter IR11  = 3'b011;
    wire      w_BEN = (i_IR_15_9[0] && i_NZP[0]) || // P
                      (i_IR_15_9[1] && i_NZP[1]) || // Z
                      (i_IR_15_9[2] && i_NZP[2]);   // N


    // Set up Branch Enable Register 
    reg r_BEN;
    always @(posedge i_CLK) begin
        r_BEN <= w_BEN;
    end
    wire w_BEN_Reg;
    assign w_BEN_Reg = r_BEN;


    // The Actual Microsequencer (big fancy mux)
    // ---------------------------------------------------------------
    assign o_AddressNextState = (i_Reset)                   ?   16'h0012 :
                                (i_IRD)                     ?   {2'b00, i_IR_15_9[6:3]} :
                             // (i_COND_bits == ACV)        ?   {          i_ACV,      5'b00000}   | i_j_field:
                             // (i_COND_bits == INT)        ?   {1'b0,     i_INT,      4'b0000}    | i_j_field:
                             // (i_COND_bits == PSR15)      ?   {2'b00,    i_PSR_15,   3'b000}     | i_j_field:
                                (i_COND_bits == BEN)        ?   {3'b000,   w_BEN_Reg,  2'b00}      | i_j_field: 
                                (i_COND_bits == R)          ?   {4'b0000,  i_R_Bit,    1'b0}       | i_j_field:
                                (i_COND_bits == IR11)       ?   {5'b00000, i_IR_15_9[2]}           | i_j_field:
                                i_j_field;  // Default Case

endmodule