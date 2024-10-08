
//------------------------------------------------------------------------------
// Module: PC 
// Logic: Clocked and Combinational
// Description: The Program Counter (PC) holds the address of the next instruction 
//              to be fetched and is updated during the instruction cycle. The PC 
//              Mux (PCMUX) is a multiplexer that selects the source for updating 
//              the PC, choosing between the incremented PC, a branch target 
//              address, or an address from the global bus, depending on the 
//              instruction being executed.
//------------------------------------------------------------------------------

module pc ( 
    input   wire                i_CLK,
    input   wire                i_Reset,
    // From Control Store:
    input   wire                i_LD_PC_Control,
    input   wire    [1: 0]      i_PCMUX_Control,
    // From Data Path:
    input   wire    [15:0]      i_Bus,
    input   wire    [15:0]      i_Addr,
    // Output to Bus
    output  wire    [15:0]      o_PC // Goes to BUS and Addr1Mux
    );


    // The PC Register
    // --------------------------------------------------
    wire [15:0] w_PC_Mux_Out;   // Output of PC Mux

    reg [15:0] r_PC;
    assign o_PC = r_PC;

    // Reset is only set during the low part of the clock signal
    // It is phase shifted by 1/2 clock cycle 
    // Therefore, the PC should change on the positive edge of the reset
    // Which is the negative edge of the clock cycle
    always @ (posedge i_CLK, posedge i_Reset) begin
        if(i_Reset)
            r_PC <= 16'h3000;   // Starting address for instructions
        else if(i_LD_PC_Control)
            r_PC <= w_PC_Mux_Out;
    end
    // --------------------------------------------------


    // PC Mux 
    // --------------------------------------------------
    // Set up PC+1 value (input)
    wire [15:0] w_PC_Plus1; 
    assign w_PC_Plus1 = r_PC + 1;

    parameter PC1   = 2'b00;    
    parameter BUS   = 2'b01;
    parameter ADDER = 2'b10;

    assign w_PC_Mux_Out =   (i_PCMUX_Control == PC1)    ? w_PC_Plus1 :
                            (i_PCMUX_Control == BUS)    ? i_Bus :
                            (i_PCMUX_Control == ADDER)  ? i_Addr :
                            16'h0000;
    // ----------------------------------------------------

endmodule

