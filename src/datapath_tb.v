
//------------------------------------------------------------------------------
// Module: Data Path Test Bench
// Description: Shows the LC3's execution of a provided program provided. The only 
//              input to the UUT is a reset pulse that resets the control logic of 
//              the LC3 to its starting state (state 18).
// Note: Currently the program provided is a simple sorting algorithms, so the 
//       memory locations of the array to be sorted are dumped to the .vcd file 
//       so their changes can be viewed.
//------------------------------------------------------------------------------

`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1 ns / 10 ps

module datapath_tb();

    // Set up CLK and Sim Duration
    //------------------------------------------------------------------------------
    localparam  DURATION = 2500000;
    reg     clk = 0;
    always begin 
        #40
        clk = ~clk;
    end

    // Instantiate UUT     
    //------------------------------------------------------------------------------
    datapath UUT( 
        .i_CLK(clk),
        .i_Reset(r_Reset)
    );

    // Testing:
    //------------------------------------------------------------------------------
    reg r_Reset = 3'b0; 
    initial begin
        // Pulse the Reset line to clean restart the LC3 to state 18
        #(10*40)   
        r_Reset <= 1'b1;
        #(40)
        r_Reset <= 1'b0;
    end 

    // Run and Output simulation to .vcd file 
    //------------------------------------------------------------------------------
    integer idx; // Loop Counter for Dumping Memory
    initial begin
        $dumpfile(`DUMPSTR(`VCD_OUTPUT));
        $dumpvars(0, datapath_tb); // 0 = Dump all vars (including sub-mods)

        // Dump Register File
        for (idx = 0; idx < 8; idx = idx + 1) 
            $dumpvars(0, UUT.ProcessingUnit.register_file_module.memory[idx]);

        // Dump Array that gets sorted by Assembly Program 
        for (idx = 12880; idx < (12880+10); idx = idx + 1) 
            $dumpvars(0, UUT.MemoryControler.Memory.memory[idx]);

        // Wait for sim to complete
        #(DURATION)

        // Notify the end of simulation
        $display("Finished!");
        $finish;
    end

endmodule
