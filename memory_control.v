
module memory_control (
    input wire i_CLK, 

    // Control Signals
    input wire          i_LD_MDR,
    input wire          i_LD_MAR,
    input wire          i_RW,
    input wire          i_MIO_EN,

    // From Datapath: 
    input wire  [15:0]  i_Bus,

    // Output 
    output wire [15:0]  o_Bus,
    output wire         o_Ready_Bit
    );

    // Output of memeory wire
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
        .INIT_FILE("programs/test1.txt"),
        .AddrBusSize(16),    
        .NumElements(64),  
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