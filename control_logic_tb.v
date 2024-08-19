`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1 ns / 10 ps

module control_logic_tb();

    // Storage elements 
    reg     clk = 0;

    localparam  DURATION = 3000;

    always begin 
        #40
        clk = ~clk;
    end


    // Instantiate and Test UUT     
    //------------------------------------------------------------------------------
    control_logic UUT( 
        .i_CLK(clk),
        .i_IR(r_IR),
        .i_Ready_Bit(r_Ready_Bit), 
        .i_NZP(r_NZP),
        .i_Reset(r_Reset),
        // Note: Missing Interupt, Prioirty, and Privilege inputs 
        .o_LD_MAR(), 
        .o_LD_MDR(), 
        .o_LD_IR(),    
        .o_LD_REG(),       // This is reg file
        .o_LD_CC(),        // I called this NZP reg
        .o_LD_PC(),        
        .o_LD_Priv(),          // Not in use yet
        .o_LD_SavedSSP(),      // Not in use yet
        .o_LD_SavedUSP(),      // Not in use yet
        .o_LD_Vector(),        // Not in use yet    
        .o_LD_Priority(),      // Not in use yet 
        .o_LD_ACV(),           // Not in use yet     
        .o_GatePC(), 
        .o_GateMDR(), 
        .o_GateALU(), 
        .o_GateMarMux(), 
        .o_GateVector(),       // Not in use yet 
        .o_GatePC_minus1(),    // Not in use yet 
        .o_GateSRP(),          // Not in use yet 
        .o_GateSP(),           // Not in use yet 
        .o_PCMUX(), 
        .o_DRMUX(), 
        .o_SR1MUX(), 
        .o_ADDR1MUX(), 
        .o_ADDR2MUX(), 
        .o_SPMUX(),    // Not in use yet
        .o_MARMUX(), 
        .o_TableMUX(), // Not in use yet
        .o_VectorMUX(),// Not in use yet 
        .o_PSRMUX(),   // Not in use yet 
        .o_ALUK(), 
        .o_MIO_EN(), 
        .o_R_W(), 
        .o_Set_Priv()        // Not in use yet
    );

    // Registers (for testing)
    reg [15:0]  r_IR            = 16'h0000;
    reg         r_Ready_Bit     = 1'b0;
    reg [2:0]   r_NZP           = 3'b000;
    reg         r_Reset         = 3'b0; // Needs to go high for 1/4 a clk cycle on the negative edge of the clock

    // The Testing:
    //------------------------------------------------------------------------------
    initial begin
        // Testing Add instruction:
        r_IR  <= 16'h1000; // Add

        #(10*40)   
        r_Reset <= 1'b1;
        #(40)
        r_Reset <= 1'b0;
        // #(20)

        #(6*80) // Wait 6clk cycles
        r_Ready_Bit <= 1'b1;
        #(80) 
        r_Ready_Bit <= 1'b0;

    end 
    //------------------------------------------------------------------------------



    // Run and Output simulation to .vcd file 
    initial begin
        $dumpfile(`DUMPSTR(`VCD_OUTPUT));
        $dumpvars(0, control_logic_tb);
            // 0 = Dump all vars (including sub-mods)

        $dumpvars(0, UUT.ControlStore.memory[18]); // Loop over the array

        // Wait for sim to complete
        #(DURATION)

        // Notify the end of simulation
        $display("Finished!");
        $finish;

    end

endmodule

