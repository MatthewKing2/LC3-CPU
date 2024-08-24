
//------------------------------------------------------------------------------
// Module: alu
// Logic: Combinational (not clocked)
// Description: Performing arithmetic and logic operations on two inputs, so the
//              result can be stored in a register and its condition codes (negative, 
//              zero, or positive) determined. Inputs are come from registers or 
//              an immediate value based on the instruction register (IR).
//------------------------------------------------------------------------------

module alu (
    // From Control Store:
    input   wire    [1: 0]      i_ALUK,
    // Operands
    input   wire    [15: 0]      i_SR2_Out,     // SR2 Mux's Output
    input   wire    [15: 0]      i_RegFile_Out, // Register File's Output 
    // Output
    output  reg     [15: 0]      o_ToBus);      // Output (goes to bus)

    parameter ADD       = 2'b00;
    parameter AND       = 2'b01;
    parameter NOT       = 2'b10;
    parameter PASS_A    = 2'b11;


    always @(*) begin // @ any "input" change, update value
        case(i_ALUK)
            ADD:    o_ToBus = i_SR2_Out + i_RegFile_Out;    // 2's compliment addition (Note: no over/underflow detection)
            AND:    o_ToBus = i_SR2_Out & i_RegFile_Out;    // Bitwise AND 
            NOT:    o_ToBus = ~i_RegFile_Out;               // Bitwise NOT
            PASS_A: o_ToBus = i_RegFile_Out;                // Pass along register file value
        endcase
    end

endmodule