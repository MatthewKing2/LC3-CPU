
//------------------------------------------------------------------------------
// Module: memory
// Description: A parameterizable block RAM module for FPGA designs. This module 
//              implements a read/write memory with configurable address bus size,
//              number of elements, and element size. It supports initialization 
//              from a file and handles read and write operations based on control signals.
//------------------------------------------------------------------------------

module memory #( 
    parameter       INIT_FILE   = "",   // Default to NULL (inits no values into memory)
    parameter       AddrBusSize = 9,    
    parameter       NumElements = 512,  
    parameter       ElementSize = 8)(   
    input   wire                            i_CLK,
    // Enable Signals
    input   wire                            i_write_en,
    input   wire                            i_read_en,
    // Addresses
    input   wire    [AddrBusSize-1: 0]      i_write_addr,
    input   wire    [AddrBusSize-1: 0]      i_read_addr,
    // Data
    input   wire    [ElementSize-1: 0]      i_write_data,
    output  reg                             o_Ready_Bit, // Set when successfully read / written
    output  reg     [ElementSize-1: 0]      o_read_data);

    //------------------------------------------------------------------------------
    // Memory Declaration
    //------------------------------------------------------------------------------
    reg [ElementSize-1: 0] memory [NumElements];

    //------------------------------------------------------------------------------
    // Read/Write Operations
    //------------------------------------------------------------------------------
    reg delayed_ready_bit = 0;
    always @(posedge i_CLK) begin
        if(i_write_en) begin 
            memory[i_write_addr] <= i_write_data;
            o_Ready_Bit <= 1'b1; 
        end
        if(i_read_en) begin 
            o_read_data <= memory[i_read_addr];
            // o_Ready_Bit <= 1'b1; 
            delayed_ready_bit <= 1'b1;
        end
        if(~i_read_en && ~i_write_en)
            o_Ready_Bit <= 1'b0; 
        if(delayed_ready_bit) begin
            delayed_ready_bit <= 1'b0;
            o_Ready_Bit <= 1'b1; 
        end

    end

    //------------------------------------------------------------------------------
    // Memory Initialization
    //------------------------------------------------------------------------------
    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE, memory);
    end

endmodule