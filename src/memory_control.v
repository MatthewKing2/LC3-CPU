
//------------------------------------------------------------------------------
// Module: Memory Control
// Description: Controls this the Memory that stores both instructions and data. 
//              Memory is accessed by using the Memory Address Register (MAR) to 
//              specify the location and the Memory Data Register (MDR) to either 
//              retrieve data from or store data to that location, depending on 
//              whether a load or store operation is being performed.
//------------------------------------------------------------------------------

module memory_control (
    input wire i_CLK, 

    // Control Signals
    input wire          i_LD_MDR,
    input wire          i_LD_MAR,
    input wire          i_RW,
    input wire          i_MIO_EN,

    // From Data Path: 
    input wire  [15:0]  i_Bus,

    // Output 
    output wire [15:0]  o_Bus,
    output wire         o_Ready_Bit
    );

    // Output of Memory wire
    wire [15:0] w_Memory_Out;

    // MDR and MAR Registers
    // ---------------------------
    reg [15:0] r_MDR;
    reg [15:0] r_MAR;
    assign o_Bus = r_MDR; // Output MDR onto CPU bus (gated by top mod)

    always @(posedge i_CLK) begin
        if(i_LD_MDR)
            r_MDR <= w_Feed_MDR;
        if(i_LD_MAR)
            r_MAR <= i_Bus;
    end
    // ---------------------------


    // Bus or Memory Mux (to MDR)
    wire [15:0] w_Feed_MDR;
    assign w_Feed_MDR = (i_MIO_EN) ? w_Memory_Out : i_Bus;


    // Address Control Logic
    // Uses MIO and RW to know when to read / write what
    // ------------------------------------
    wire w_Write = (i_MIO_EN && i_RW) ? 1'b1 : 1'b0;
    wire w_Read = (i_MIO_EN && ~i_RW) ? 1'b1 : 1'b0;


    // Init Sub Module 
    memory #(
        .INIT_FILE("../Programs/AssemblySortingAlgorithm.mem"),
        .AddrBusSize(16),    
        .NumElements(65535),  
        .ElementSize(16)
        ) Memory(   
        .i_CLK(i_CLK),
        .i_write_en(w_Write),
        .i_read_en(w_Read),
        .i_write_addr(r_MAR),
        .i_read_addr(r_MAR),
        .i_write_data(r_MDR),
        .o_Ready_Bit(o_Ready_Bit),
        .o_read_data(w_Memory_Out)
    );


endmodule