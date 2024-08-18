
//------------------------------------------------------------------------------
// Module: Data Path
// Note: This is the top mod 
// Logic: Clocked and Combinational
//------------------------------------------------------------------------------

module datapath (input CLK /* from pcf */);

    // Init wires to connect modules
    wire [15:0] w_CPU_Bus;
    wire [15:0] w_Adder_Out;
    wire [15:0] w_PC_Out;
    wire [2: 0] w_NZP_Out;
    wire [15:0] w_SR1_Out;
    wire [15:0] w_MarMux_Out;
    wire [15:0] w_ProcessingUnit_Out;

    // Control what is on CPU bus (gates) 
    assign w_CPU_Bus =  (w_GateMarMux_Control)  ? w_MarMux_Out :
                        (w_GatePC_Control)      ? w_PC_Out :
                        (w_GateALU_Control)     ? w_ProcessingUnit_Out :
                        (w_GateMarMux_Control)  ? w_MarMux_Out :
                        (w_GateMDR_Control)     ? 16'hFFFF : // Havent set up memeory yet
                        16'hFFFF;   // Default to 65535 or -1

    // IR is only logic without its own module 
    reg [16:0] r_IR;
    always @(posedge CLK) begin
        if(w_LD_IR_Control)
            r_IR <= w_CPU_Bus;
    end




    // Init Sub-Modules 
    // ************************************************************************************

    // Processing Unit (Register File + ALU)
    // -------------------------------------------------- 
    processing_unit ProcessingUnit(
        .i_CLK(CLK),
        .i_LD_REG(w_LD_REG_Control),                // If value should be loaded into DR
        .i_ALUK(w_ALUK_Control),                  // What ALU operation to do
        .i_IR_11_9(r_IR[11:9]),     // For DR Mux
        .i_IR_8_6(r_IR[8:6]),       // For DR Mux and SR1 Mux
        .i_IR_2_0(r_IR[2:0]),       // For SR2 
        .i_SR1MUX(w_SR1MUX_Control),                // Mux select for SR1
        .i_DRMUX(w_DRMUX_Control),                 // Mux select for DR 
        .i_IR_5(r_IR[5]),           // Control for Mux
        .i_IR_4_0(r_IR[4:0]),       // Immediate 5
        .i_bus(w_CPU_Bus),                   // Bus for loading values into registers
        .o_SR1_Out(w_SR1_Out);               // Output to the Adder Mux Module
        .o_ToBus(w_ProcessingUnit_Out)                  // Output to the bus (top mod gates it)
    );


    // Memory (pending)
    // -------------------------------------------------- 

    // PC 
    // -------------------------------------------------- 
    pc PC(
        .i_CLK(CLK),
        .i_LD_PC_Control(w_LD_PC_Control),
        .i_PCMUX_Control(w_PCMUX_Control),
        .i_Bus(w_CPU_Bus),
        .i_Addr(w_Adder_Out),  // From Addr Muxs Module 
        .o_PC(w_PC_Out)     // Goes to BUS and Addr1Mux
    );

    // NZP
    // -------------------------------------------------- 
    nzp NZPConditionCodes(
        .i_CLK(CLK),
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
        .i_Address(w_Adder_Out),   // From Adder Mux Output
        .o_MarMux(w_MarMux_Out)     // Goes to Bus
    );

    // Control Logic
    // -------------------------------------------------- 
    control_logic ControlLogic (
        .i_CLK(CLK),
        // From Datapath: 
        .i_IR(r_IR),
        .i_Ready_Bit(w_Ready_Bit_Control), 
        .i_NZP(w_NZP_Control),
        // Load Registers
        .o_LD_MAR(w_LD_MAR_Control), 
        .o_LD_MDR(w_LD_MDR_Control), 
        .o_LD_IR(w_LD_IR_Control),    
        .o_LD_REG(w_LD_REG_Control),      
        .o_LD_CC(w_LD_CC_Control),       
        .o_LD_PC(w_LD_PC_Control),        
        .o_LD_Priv(w_LD_Priv_Control),          // Not in use yet
        .o_LD_SavedSSP(w_LD_SavedSSP_Control),      // Not in use yet
        .o_LD_SavedUSP(w_LD_SavedUSP_Control),      // Not in use yet
        .o_LD_Vector(w_LD_Vector_Control),        // Not in use yet    
        .o_LD_Priority(w_LD_Priority_Control),      // Not in use yet 
        .o_LD_ACV(w_LD_ACV_Control),           // Not in use yet     
        // Control What data goes onto CPU Bus 
        .o_GatePC(w_GatePC_Control), 
        .o_GateMDR(w_GateMDR_Control), 
        .o_GateALU(w_GateALU_Control), 
        .o_GateMarMux(w_GateMarMux_Control), 
        .o_GateVector(w_GateVector_Control),       // Not in use yet 
        .o_GatePC_minus1(w_GatePC_minus1_Control),    // Not in use yet 
        .o_GateSRP(w_GateSRP_Control),          // Not in use yet 
        .o_GateSP(w_GateSP_Control),           // Not in use yet 
        // Mux Control Signals
        .o_PCMUX(w_PCMUX_Control), 
        .o_DRMUX(w_DRMUX_Control), 
        .o_SR1MUX(w_SR1MUX_Control), 
        .o_ADDR1MUX(w_ADDR1MUX_Control), 
        .o_ADDR2MUX(w_ADDR2MUX_Control), 
        .o_SPMUX(w_SPMUX_Control),           // Not in use yet
        .o_MARMUX(w_MARMUX_Control), 
        .o_TableMUX(w_TableMUX_Control),        // Not in use yet
        .o_VectorMUX(w_VectorMUX_Control),       // Not in use yet 
        .o_PSRMUX(w_PSRMUX_Control),          // Not in use yet 
        // ALU Control 
        .o_ALUK(w_ALUK_Control), 
        // Memeory Control 
        .o_MIO_EN(w_MIO_EN_Control), 
        .o_R_W(w_R_W_Control), 
        // Priviledge Control
        .o_Set_Priv(w_Set_Priv_Control)          // Not in use yet
    );
    // ************************************************************************************


    // Control Signal wires 


    wire w_Ready_Bit_Control;
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
    // Mux Control Signals
    wire w_PCMUX_Control; 
    wire w_DRMUX_Control; 
    wire w_SR1MUX_Control; 
    wire w_ADDR1MUX_Control; 
    wire w_ADDR2MUX_Control; 
    wire w_SPMUX_Control;           // Not in use yet
    wire w_MARMUX_Control; 
    wire w_TableMUX_Control;        // Not in use yet
    wire w_VectorMUX_Control;       // Not in use yet 
    wire w_PSRMUX_Control;          // Not in use yet 
    // ALU Control 
    wire w_ALUK_Control; 
    // Memeory Control 
    wire w_MIO_EN_Control; 
    wire w_R_W_Control; 
    // Priviledge Control
    wire o_Set_Priv_Control;          // Not in use yet


endmodule