
//------------------------------------------------------------------------------
// Module: register_file
// Description: A set of registers (R0 to R7) in the LC-3 that store data and provide 
//              input values for the ALU during operations.
// Note: Writing happens on the positive clock edge, but reading is not clocked.
//       Values can be read at any time - this is a key feature of this microarchitecture
//       that allows for the reading and writing to the register file in one clock cycle.
//------------------------------------------------------------------------------

module register_file #( 
    parameter       INIT_FILE   = "")(   // Default to NULL (inits no values into memory)
    input   wire                i_CLK,
    input   wire                i_Reset,
    // From Control Store:
    input   wire                i_LD_REG,
    // From Register Muxs
    input   wire    [2: 0]      i_DR_Addr,      // Destination Register Address
    input   wire    [2: 0]      i_SR1_Addr,     // Source Register #1 Address
    input   wire    [2: 0]      i_SR2_Addr,     // Source Register #2 Address
    // From the datapath Bus 
    input   wire    [15: 0]      i_bus,
    // Outputs
    output  reg     [15: 0]      o_SR1,
    output  reg     [15: 0]      o_SR2);

    localparam AddrBusSize = 3;
    localparam NumElements = 8;
    localparam ElementSize = 16;

    //------------------------------------------------------------------------------
    // Memory Declaration
    //------------------------------------------------------------------------------
    reg [ElementSize-1: 0] memory [NumElements];

    //------------------------------------------------------------------------------
    // Read/Write Operations
    //------------------------------------------------------------------------------
    always @(*) begin // Change values when control signals change
        o_SR1 <= memory[i_SR1_Addr];
        o_SR2 <= memory[i_SR2_Addr];
    end

    always @(posedge i_CLK) begin
        if(i_LD_REG)
            memory[i_DR_Addr] <= i_bus;
        // Note: even though i_LD_REG will change on the posedge of the clock
        // This logic will use the "old" value. (in theory)
    end

    // Reset all values to 0 when reset line
    integer i;
    always @(posedge i_Reset) begin
        for (i = 0; i < NumElements; i = i + 1)
            memory[i] <= 16'b0;
    end 

endmodule
