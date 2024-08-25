
//------------------------------------------------------------------------------
// Module: control_store
// Description: Special memory that stores microinstructions, each consisting of 
//              control signals needed to manage the data path and "create" the 
//              states of the Finite State Machine. There are 64 total states and
//              52 control signals per state. 10 control signals are used to 
//              determine the next state and 42 are used in the datapath to
//              implement the state's behavior.
// Note: Not all states have been implemented yet.
//------------------------------------------------------------------------------

module control_store #( 
    parameter       INIT_FILE   = "../ControlSignals/output.txt", 
    parameter       AddrBusSize = 6,
    parameter       NumElements = 64,
    parameter       ElementSize = 52)(   
    input   wire                            i_CLK,
    input   wire                            i_read_en,
    input   wire    [AddrBusSize-1: 0]      i_read_addr,
    output  reg     [ElementSize-1: 0]      o_read_data);

    //------------------------------------------------------------------------------
    // Memory Declaration
    // Description: Declares the block RAM memory array with the specified size and 
    //              element width. The synthesizer assumes the use of block RAM based 
    //              on this declaration. The array is defined with a size of NumElements
    //              and each element is ElementSize bits wide.
    // Note: This declaration notation does not use 2^AddrBusSize to determine the
    //       number of elements. You must specific the exact number of elements.
    //------------------------------------------------------------------------------
    reg [ElementSize-1: 0] memory [NumElements];

    //------------------------------------------------------------------------------
    // Read/Write Operations
    // Description: Handles memory read operations on the rising edge of the
    //              clock signal. If the read enable signal (i_read_en) is asserted, 
    //              data is read from the specified address (i_read_addr) and provided 
    //              on the output (o_read_data).
    //------------------------------------------------------------------------------
    always @(posedge i_CLK) begin
        if(i_read_en) begin 
            o_read_data <= memory[i_read_addr];
        end
    end

    //------------------------------------------------------------------------------
    // Memory Initialization
    // Description: Initializes the memory contents from a file specified by INIT_FILE.
    //              This block uses the $readmemb system function to load binary data into 
    //              the memory. Initialization is only performed if INIT_FILE is specified.
    // Note: This is a rare case where initial blocks work in synthesizable Verilog.
    //------------------------------------------------------------------------------
    initial if (INIT_FILE) begin
        $readmemb(INIT_FILE, memory);
    end

endmodule