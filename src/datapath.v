
//------------------------------------------------------------------------------
// Module: Data Path
// Logic: Clocked and Combinational
// Description: This is the Top Module that implements all other modules. This 
//              Includes: The Global Bus, Memory, the ALU and Register File, 
//              the PC and PC Mux, the MAR Mux, Condition Codes, the IR and the
//              Control Logic that implements this microarchitecture's FSM.
//------------------------------------------------------------------------------

module datapath (
    input wire i_CLK, 
    input wire i_Reset
    );

    // Init wires to connect modules
    wire [15:0] w_CPU_Bus;
    wire [15:0] w_Adder_Out;
    wire [15:0] w_PC_Out;
    wire [2: 0] w_NZP_Out;
    wire [15:0] w_SR1_Out;
    wire [15:0] w_MarMux_Out;
    wire [15:0] w_MDR_Out;
    wire [15:0] w_ProcessingUnit_Out;

    // Control what is on CPU bus (gates) 
    assign w_CPU_Bus =  (w_GateMarMux_Control)  ? w_MarMux_Out :
                        (w_GatePC_Control)      ? w_PC_Out :
                        (w_GateALU_Control)     ? w_ProcessingUnit_Out :
                        (w_GateMarMux_Control)  ? w_MarMux_Out :
                        (w_GateMDR_Control)     ? w_MDR_Out :
                        16'hFFFF;   // Default to 65535 or -1

    // IR is only logic without its own module 
    reg [15:0] r_IR;
    always @(posedge i_CLK) begin
        if(w_LD_IR_Control)
            r_IR <= w_CPU_Bus;
    end


    // Init Sub-Modules 
    // ************************************************************************************

    // Processing Unit (Register File + ALU)
    // -------------------------------------------------- 
    processing_unit ProcessingUnit(
        .i_CLK(i_CLK),
        .i_Reset(i_Reset),
        .i_LD_REG(w_LD_REG_Control),               
        .i_ALUK(w_ALUK_Control),
        .i_IR_11_9(r_IR[11:9]),     // For DR Mux
        .i_IR_8_6(r_IR[8:6]),       // For DR Mux and SR1 Mux
        .i_IR_2_0(r_IR[2:0]),       // For SR2 
        .i_SR1MUX(w_SR1MUX_Control),// Mux select for SR1
        .i_DRMUX(w_DRMUX_Control),  // Mux select for DR 
        .i_IR_5(r_IR[5]),           // Control for Mux
        .i_IR_4_0(r_IR[4:0]),       // Immediate 5
        .i_bus(w_CPU_Bus),          
        .o_SR1_Out(w_SR1_Out),      // Output to the Adder Mux Module
        .o_ToBus(w_ProcessingUnit_Out)
    );


    // Memory (pending)
    // -------------------------------------------------- 
    memory_control MemoryControler(
        .i_CLK(i_CLK), 
        .i_LD_MDR(w_LD_MDR_Control),
        .i_LD_MAR(w_LD_MAR_Control),
        .i_RW(w_R_W_Control),
        .i_MIO_EN(w_MIO_EN_Control),
        .i_Bus(w_CPU_Bus),
        .o_Bus(w_MDR_Out),
        .o_Ready_Bit(w_Ready_Bit)
    );

    // PC 
    // -------------------------------------------------- 
    pc PC(
        .i_CLK(i_CLK),
        .i_Reset(i_Reset),
        .i_LD_PC_Control(w_LD_PC_Control),
        .i_PCMUX_Control(w_PCMUX_Control),
        .i_Bus(w_CPU_Bus),
        .i_Addr(w_Adder_Out),   // From Addr Muxs Module 
        .o_PC(w_PC_Out)         // Goes to BUS and Addr1Mux
    );

    // NZP
    // -------------------------------------------------- 
    nzp NZPConditionCodes(
        .i_CLK(i_CLK),
        .i_LD_CC_Control(w_LD_CC_Control),
        .i_Bus(w_CPU_Bus),
        .o_NZP(w_NZP_Out)    // Goes to Control Logic
    );

    // Adder Mux
    // -------------------------------------------------- 
    adder_muxs AdderMuxs(
        .i_Addr1MuxControl(w_ADDR1MUX_Control),
        .i_Addr2MuxControl(w_ADDR2MUX_Control),
        .i_IR_10_0(r_IR[10:0]),
        .i_PC(w_PC_Out),
        .i_SR1_Out(w_SR1_Out),
        .o_AdderMuxs(w_Adder_Out)  // Goes to PC module
    );

    // Mar Mux 
    // -------------------------------------------------- 
    mar_mux MarMux(
        .i_MarMuxControl(w_MARMUX_Control),
        .i_IR_7_0(r_IR[7:0]),
        .i_Address(w_Adder_Out),    // From Adder Mux Output
        .o_MarMux(w_MarMux_Out)     // Goes to Bus
    );

    // Control Logic
    // -------------------------------------------------- 
    control_logic ControlLogic (
        .i_CLK(i_CLK),
        // From Datapath: 
        .i_IR(r_IR),
        .i_Ready_Bit(w_Ready_Bit), 
        .i_NZP(w_NZP_Out),
        .i_Reset(i_Reset),
        // Load Registers
        .o_LD_MAR(w_LD_MAR_Control), 
        .o_LD_MDR(w_LD_MDR_Control), 
        .o_LD_IR(w_LD_IR_Control),    
        .o_LD_REG(w_LD_REG_Control),      
        .o_LD_CC(w_LD_CC_Control),       
        .o_LD_PC(w_LD_PC_Control),        
        .o_LD_Priv(w_LD_Priv_Control),          // Not in use yet
        .o_LD_SavedSSP(w_LD_SavedSSP_Control),  // Not in use yet
        .o_LD_SavedUSP(w_LD_SavedUSP_Control),  // Not in use yet
        .o_LD_Vector(w_LD_Vector_Control),      // Not in use yet    
        .o_LD_Priority(w_LD_Priority_Control),  // Not in use yet 
        .o_LD_ACV(w_LD_ACV_Control),            // Not in use yet     
        // Control What data goes onto CPU Bus 
        .o_GatePC(w_GatePC_Control), 
        .o_GateMDR(w_GateMDR_Control), 
        .o_GateALU(w_GateALU_Control), 
        .o_GateMarMux(w_GateMarMux_Control), 
        .o_GateVector(w_GateVector_Control),        // Not in use yet 
        .o_GatePC_minus1(w_GatePC_minus1_Control),  // Not in use yet 
        .o_GateSRP(w_GateSRP_Control),              // Not in use yet 
        .o_GateSP(w_GateSP_Control),                // Not in use yet 
        // Mux Control Signals
        .o_PCMUX(w_PCMUX_Control), 
        .o_DRMUX(w_DRMUX_Control), 
        .o_SR1MUX(w_SR1MUX_Control), 
        .o_ADDR1MUX(w_ADDR1MUX_Control), 
        .o_ADDR2MUX(w_ADDR2MUX_Control), 
        .o_SPMUX(w_SPMUX_Control),          // Not in use yet
        .o_MARMUX(w_MARMUX_Control), 
        .o_TableMUX(w_TableMUX_Control),    // Not in use yet
        .o_VectorMUX(w_VectorMUX_Control),  // Not in use yet 
        .o_PSRMUX(w_PSRMUX_Control),        // Not in use yet 
        // ALU Control 
        .o_ALUK(w_ALUK_Control), 
        // Memory Control 
        .o_MIO_EN(w_MIO_EN_Control), 
        .o_R_W(w_R_W_Control), 
        // Privilege Control
        .o_Set_Priv(w_Set_Priv_Control)     // Not in use yet
    );
    // ************************************************************************************


    // Control Signal wires to connect modules to the control store
    // -------------------------------------------------- 
    wire w_Ready_Bit;
    wire w_NZ_Control;
    // Load Registers
    wire w_LD_MAR_Control;
    wire w_LD_MDR_Control;
    wire w_LD_IR_Control;    
    wire w_LD_REG_Control;      
    wire w_LD_CC_Control;       
    wire w_LD_PC_Control;        
    wire w_LD_Priv_Control;          // Not in use yet
    wire w_LD_SavedSSP_Control;      // Not in use yet
    wire w_LD_SavedUSP_Control;      // Not in use yet
    wire w_LD_Vector_Control;        // Not in use yet    
    wire w_LD_Priority_Control;      // Not in use yet 
    wire w_LD_ACV_Control;           // Not in use yet     
    // Control What data goes onto CPU Bus 
    wire w_GatePC_Control; 
    wire w_GateMDR_Control; 
    wire w_GateALU_Control; 
    wire w_GateMarMux_Control; 
    wire w_GateVector_Control;       // Not in use yet 
    wire w_GatePC_minus1_Control;    // Not in use yet 
    wire w_GateSRP_Control;          // Not in use yet 
    wire w_GateSP_Control;           // Not in use yet 
    wire [1:0] w_PCMUX_Control; 
    wire [1:0] w_DRMUX_Control; 
    wire [1:0] w_SR1MUX_Control; 
    wire [0:0] w_ADDR1MUX_Control; 
    wire [1:0] w_ADDR2MUX_Control; 
    wire [1:0] w_SPMUX_Control;    // Not in use yet
    wire [0:0] w_MARMUX_Control; 
    wire [0:0] w_TableMUX_Control; // Not in use yet
    wire [1:0] w_VectorMUX_Control;// Not in use yet 
    wire [0:0] w_PSRMUX_Control;   // Not in use yet 
    // ALU Control 
    wire [1:0] w_ALUK_Control; 
    // Memory Control 
    wire w_MIO_EN_Control; 
    wire w_R_W_Control; 
    // Privilege Control
    wire o_Set_Priv_Control;          // Not in use yet

endmodule
