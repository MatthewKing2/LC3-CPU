
//------------------------------------------------------------------------------
// Module: microsequencer
// Logic: Combinational (not clocked, execpt for BEN register)
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
    // From Interupt Control:
    input   wire                i_INT,
    output  wire     [5: 0]      o_AddressNextState);


    // Different MUX select line values for Microsequncer 
    parameter ACV   = 3'b110;
    parameter INT   = 3'b101;
    parameter PSR15 = 3'b100;
    parameter BEN   = 3'b010;
    parameter R     = 3'b001;
    parameter IR11  = 3'b011;
    wire      w_BEN = (i_IR_15_9[0] && i_NZP[0]) || 
                      (i_IR_15_9[1] && i_NZP[1]) || 
                      (i_IR_15_9[2] && i_NZP[2]);


    // Set up Branch Enable Register 
    reg r_BEN;
    always @(posedge i_CLK) begin
        r_BEN <= w_BEN;
    end
    wire w_BEN_Reg;
    assign w_BEN_Reg = r_BEN;


    // The Actual Microsequncer (big fancy mux)
    // ---------------------------------------------------------------
    // always @(*) begin   // @ any "input" change, update value
    //     if (i_Reset)
    //         o_AddressNextState = 16'h0012; // State 18 (Start of FSM)
    //     else if(i_IRD)
    //         o_AddressNextState = {2'b00, i_IR_15_9[6:3]};
    //     else begin
    //         case (i_COND_bits)
    //             ACV:    o_AddressNextState = {          i_ACV,      5'b00000}   | i_j_field;
    //             INT:    o_AddressNextState = {1'b0,     i_INT,      4'b0000}    | i_j_field;
    //             PSR15:  o_AddressNextState = {2'b00,    i_PSR_15,   3'b000}     | i_j_field;
    //             BEN:    o_AddressNextState = {3'b000,   w_BEN_Reg,  2'b00}      | i_j_field;
    //             R:      o_AddressNextState = {4'b0000,  i_R_Bit,    1'b0}       | i_j_field;
    //             IR11:   o_AddressNextState = {5'b00000, i_IR_15_9[2]}           | i_j_field;
    //             default:o_AddressNextState =                                      i_j_field;
    //         endcase 
    //     end
    // end

    assign o_AddressNextState = (i_Reset)                   ?   16'h0012 :
                                (i_IRD)                     ?   {2'b00, i_IR_15_9[6:3]} :
                                // (i_COND_bits == ACV)        ?   {          i_ACV,      5'b00000}   | i_j_field:
                                // (i_COND_bits == INT)        ?   {1'b0,     i_INT,      4'b0000}    | i_j_field:
                                // (i_COND_bits == PSR15)      ?   {2'b00,    i_PSR_15,   3'b000}     | i_j_field:
                                (i_COND_bits == BEN)        ?   {3'b000,   w_BEN_Reg,  2'b00}      | i_j_field: 
                                (i_COND_bits == R)          ?   {4'b0000,  i_R_Bit,    1'b0}       | i_j_field:
                                // (i_COND_bits == IR11)       ?   {5'b00000, i_IR_15_9[2]}           | i_j_field:
                                i_j_field;  // Default Case

endmodule