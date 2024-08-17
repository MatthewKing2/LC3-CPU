
//------------------------------------------------------------------------------
// Module: register_file
// Note: This is clocked logic, but depends on the control store being acesses first
//       for this reason, it is not implimted as block ram (b/c the control store is)
//       This is implimted as distributed ram by the sythesis tool.
// Note: May want to test unclocked (b/c it may not need to be, but could have erros)
//------------------------------------------------------------------------------

module register_file #( 
    parameter       INIT_FILE   = "")(   // Default to NULL (initalizes no values into memory)
    input   wire                i_CLK,
    // From Control Store:
    input   wire                i_LD_REG,
    // From Register Muxs
    input   wire    [2: 0]      i_DR_Addr,      // Desintation Register Address
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

    //------------------------------------------------------------------------------
    // Memory Initialization
    // Description: Initializes the memory contents from a file specified by INIT_FILE.
    //              This block uses the $readmemb system function to load binary data into 
    //              the memory. Initialization is only performed if INIT_FILE is specified.
    // Note: This is a rare case where inital blocks work in synthesizable verilog.
    //------------------------------------------------------------------------------
    // initial if (INIT_FILE) begin
    //     $readmemb(INIT_FILE, memory);
    // end

endmodule