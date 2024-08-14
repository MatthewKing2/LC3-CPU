`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
// Define timescales for simulation: <time_unit> / <time_precision> 
`timescale 1 ns / 10 ps
    // The ` is a complier directive that is sim specific (icarus verilog)

// Define our testbench
module register_file_tb();    // Note no IO

    // Internal Singals
    wire out;

    // Storage elements 
    reg     clk = 0;
    reg     rst = 0;

    // Simulation time: 10,000 * 1ns = 10us 
    localparam  DURATION = 3000;

    // Generate fake clock singal 
    // Runs in parelle to everything forever
    always begin 
        // 12MHz = 1/(2*Xns) where 2Xns is 1 clk cycle
        // 12*10^6 = 1/(2*X * 10^-9)
        // X = 41.67
        #41.667

        // Toggle clock line 
        clk = ~clk;
    end

    // Instantiate and Test UUT     
    //------------------------------------------------------------------------------
    register_file UUT( 
        .i_CLK(clk),
        .i_LD_REG(r_LD_REG),
        .i_DR_Addr(r_DR_Addr),      // Desintation Register Address
        .i_SR1_Addr(r_SR1_Addr),     // Source Register #1 Address
        .i_SR2_Addr(r_SR2_Addr),     // Source Register #2 Address
        .i_bus(r_bus),
        .o_SR1(w_SR1_OUT),
        .o_SR2(w_SR2_OUT)
    );

    // Registers
    reg             r_LD_REG    = 0;
    reg [2: 0]      r_DR_Addr   = 3'b000;      // Desintation Register Address
    reg [2: 0]      r_SR1_Addr  = 3'b000;     // Source Register #1 Address
    reg [2: 0]      r_SR2_Addr  = 3'b000;     // Source Register #2 Address
    reg [15: 0]     r_bus       = 16'h0000;
    wire [15: 0]    w_SR1_OUT   = 16'h0000;
    wire [15: 0]    w_SR2_OUT   = 16'h0000;

    initial begin
        #(10*41.667)   

        // Test 1: Write Value to a DR  -- YES!
        r_bus <= 16'h000F;
        r_LD_REG <= 1'b1;
        r_DR_Addr <= 3'b001;

        #(2*41.667)   
        r_bus <= 16'h0000;
        r_LD_REG <= 1'b0;
        r_DR_Addr <= 3'b000;
        
        #(2*41.667)

        // Test 1.5: Write Value to a DR on same edge  -- YES!
        #41.667
        r_bus <= 16'h00F0;
        r_LD_REG <= 1'b1;
        r_DR_Addr <= 3'b100;

        #(2*41.667)   
        r_bus <= 16'h0000;
        r_LD_REG <= 1'b0;
        r_DR_Addr <= 3'b000;
        
        #(2*41.667)   
        #41.667

        // Test 2: Read Value from SR1 -- Yes
        #(2*41.667)   
        r_SR1_Addr <= 3'b001;
        #(2*41.667)   
        r_SR1_Addr <= 3'b000;

        // Test 2.1: Read Value from SR1 on same edge -- Yes
        #41.667
        r_SR1_Addr <= 3'b100;
        #(2*41.667) 
        r_SR1_Addr <= 3'b000;
        #41.667

        // Test 3: Read Value from SR2 -- Yes
        #(2*41.667)   
        r_SR2_Addr <= 3'b001;

        #(2*41.667)   
        r_SR2_Addr <= 3'b000;

        // Test 3.1: Read Value from SR2 on same edge -- Yes
        #41.667
        r_SR2_Addr <= 3'b100;
        #(2*41.667)   
        r_SR2_Addr <= 3'b000;

        // Test 3.2: Read Value from SR1 and SR2 on same edge -- Yes
        #41.667
        r_SR1_Addr <= 3'b001;
        r_SR2_Addr <= 3'b100;
        #(2*41.667) 
        r_SR1_Addr <= 3'b000;
        r_SR2_Addr <= 3'b000;
        #41.667

        // Test 4: Reading and writing at the same time - Yes and No
            // Have to wait 1clk before reading a new write
        #(2*41.667)   
        r_bus <= 16'h1111;
        r_LD_REG <= 1'b1;
        r_DR_Addr <= 3'b111;
        #(2*41.667)   
        r_bus <= 16'h0000;
        r_LD_REG <= 1'b0;
        r_DR_Addr <= 3'b000;
        #(6*41.667)   
        #41.667
        r_bus <= 16'hF000;
        r_LD_REG <= 1'b1;
        r_DR_Addr <= 3'b111;
        r_SR2_Addr <= 3'b111;
        r_SR1_Addr <= 3'b111;
        #(2*41.667)   
        r_bus <= 16'h0000;
        r_LD_REG <= 1'b0;
        r_DR_Addr <= 3'b000;
        #(2*41.667)   
        r_SR2_Addr <= 3'b000;
        r_SR1_Addr <= 3'b000;
    end
    //------------------------------------------------------------------------------


    integer idx; // Use an integer for the loop counter

    // Run and Output simulation to .vcd file 
    initial begin
        $dumpfile(`DUMPSTR(`VCD_OUTPUT));
        $dumpvars(0, register_file_tb);
            // 0 = Dump all vars (including sub-mods)

        for (idx = 0; idx < 8; idx = idx + 1) 
            $dumpvars(0, UUT.memory[idx]); // Loop over the array

        // Wait for sim to complete
        #(DURATION)

        // Notify the end of simulation
        $display("Finished!");
        $finish;

    end

endmodule
