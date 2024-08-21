`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1 ns / 10 ps

module datapath_tb();

    // Storage elements 
    reg     clk = 0;

    localparam  DURATION = 2500000;

    always begin 
        #40
        clk = ~clk;
    end


    // Instantiate and Test UUT     
    //------------------------------------------------------------------------------
    datapath UUT( 
        .i_CLK(clk),
        .i_Reset(r_Reset)
    );

    // Registers (for testing)
    // reg [15:0]  r_IR            = 16'h0000;
    // reg         r_Ready_Bit     = 1'b0;
    // reg [2:0]   r_NZP           = 3'b000;
    reg         r_Reset         = 3'b0; // Needs to go high for 1/4 a clk cycle on the negative edge of the clock

    // The Testing:
    //------------------------------------------------------------------------------
    initial begin
        // Testing Add instruction:

        #(10*40)   
        r_Reset <= 1'b1;
        #(40)
        r_Reset <= 1'b0;
        // #(20)

    end 
    //------------------------------------------------------------------------------


    integer idx; // Use an integer for the loop counter
    integer idx2; // Use an integer for the loop counter
    integer idx3; // Use an integer for the loop counter

    // Run and Output simulation to .vcd file 
    initial begin
        $dumpfile(`DUMPSTR(`VCD_OUTPUT));
        $dumpvars(0, datapath_tb);
            // 0 = Dump all vars (including sub-mods)

        $dumpvars(0, UUT.ControlLogic.ControlStore.memory[18]); // Loop over the array

        for (idx = 0; idx < 8; idx = idx + 1) 
            $dumpvars(0, UUT.ProcessingUnit.register_file_module.memory[idx]); // Loop over the array
        for (idx2 = 12288; idx2 < (12288+200); idx2 = idx2 + 1) 
            $dumpvars(0, UUT.MemoryControler.Memory.memory[idx2]); // Loop over the array

        $dumpvars(0, UUT.MemoryControler.Memory.memory[12544]); // Loop over the array
        $dumpvars(0, UUT.MemoryControler.Memory.memory[12545]); // Loop over the array
        $dumpvars(0, UUT.MemoryControler.Memory.memory[12546]); // Loop over the array

        $dumpvars(0, UUT.MemoryControler.Memory.memory[12800]); // Loop over the array
        $dumpvars(0, UUT.MemoryControler.Memory.memory[12801]); // Loop over the array

        for (idx3 = 12880; idx3 < (12880+15); idx3 = idx3 + 1) 
            $dumpvars(0, UUT.MemoryControler.Memory.memory[idx3]); // Loop over the array

        // Wait for sim to complete
        #(DURATION)

        // Notify the end of simulation
        $display("Finished!");
        $finish;

    end

endmodule


