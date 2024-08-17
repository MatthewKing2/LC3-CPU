
//------------------------------------------------------------------------------
// Module: PC 
// Logic: Clocked and Combinational
// Note: The control signals are combinational, but PC IS a register, and is 
//       therefore clocked on the positive edge of the clock
//------------------------------------------------------------------------------

module pc ( 
    input   wire                i_CLK,
    // From Control Store:
    input   wire                i_LD_PC_Control,
    input   wire    [1: 0]      i_PCMUX_Control,
    // From Data Path:
    input   wire    [15:0]      i_Bus,
    input   wire    [15:0]      i_Addr,
    // Ouptput to Bus
    output  wire    [15:0]      o_PC // Goes to BUS and Addr1Mux
    );


    // The PC Register
    // --------------------------------------------------
    reg [15:0] r_PC
    assign o_PC = r_PC;

    always @ (posedge i_CLK) begin
        if(i_LD_PC_Control)
            r_PC <= w_PC_Mux_Out;
    end
    // --------------------------------------------------


    // PC Mux 
    // --------------------------------------------------
    parameter PC1   = 2'b00;    
    parameter BUS   = 2'b01;
    parameter ADDER = 2'b10;
    parameter CATCH = 2'b11; // Catch case (should never happen)

    // Set up PC+1 value (input)
    wire [15:0] w_PC_Plus1; 
    assign w_PC_Plus1 = r_PC + 1;

    wire [15:0] w_PC_Mux_Out;
    (* parallel_case *) // Treat cases as mutally exclusive 
    always @(*) begin   // @ any "input" change, update value
        case (i_PCMUX_Control)
            PC1:    w_PC_Mux_Out = w_PC_Plus1;
            BUS:    w_PC_Mux_Out = i_Bus;
            ADDER:  w_PC_Mux_Out = i_Addr;
            CATCH:  w_PC_Mux_Out = 16'h0000;    // Catch all = 0
        endcase 
    end
    // ----------------------------------------------------


endmodule

