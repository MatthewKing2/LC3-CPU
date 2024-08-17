`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
// Define timescales for simulation: <time_unit> / <time_precision> 
`timescale 1 ns / 10 ps
    // The ` is a complier directive that is sim specific (icarus verilog)

// Define our testbench
module processing_unit_tb();    // Note no IO

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
        #40

        // Toggle clock line 
        clk = ~clk;
    end

    // Instantiate and Test UUT     
    //------------------------------------------------------------------------------
    processing_unit UUT( 
        .i_CLK(clk),
        .i_LD_REG(r_LD_REG),    // If value should be loaded into DR
        .i_ALUK(r_ALUK),        // What ALU operation to do
        .i_IR_11_9(r_IR[11:9]), // For DR Mux
        .i_IR_8_6(r_IR[8:6]),   // For DR Mux and SR1 Mux
        .i_IR_2_0(r_IR[2:0]),   // For SR2 
        .i_SR1MUX(r_SR1_Addr),  // Mux select for SR1
        .i_DRMUX(r_DRMUX),    // Mux select for DR 
        .i_IR_5(r_IR[5]),       // Control for Mux
        .i_IR_4_0(r_IR[4:0]),   // Immediate 5
        .i_bus(w_bus_in),          // Bus for loading values into registers
        .o_ToBus(w_bus_out)         // Output to the bus (top mod gates it)
    );

    // Registers
    reg [15: 0]     r_IR        = 16'h0000;
    reg [1:0]       r_ALUK      = 2'b00;      // Desintation Register Address
    reg             r_LD_REG    = 0;
    reg [2: 0]      r_DRMUX   = 2'b00;      // Desintation Register Address
    reg [2: 0]      r_SR1_Addr  = 2'b00;     // Source Register #1 Address

    reg [15: 0]     r_bus_testing       = 16'h0000;
    wire[15: 0]     w_bus_in;
    wire[15: 0]     w_bus_out;
    reg             r_Gate_ALU = 0;
    assign w_bus_in = r_Gate_ALU ? w_bus_out : r_bus_testing; 


    // always (@w_bus) begin
    //     r_bus <= w_bus;
    // end

    // Theory: 
        // 1) B/c the DR does not change values, the 


    initial begin
        #(11*40)   
        // Set up 
        // r_DRMUX       <= 2'b11;
        r_Gate_ALU      <= 0;

        #(2*40)   

        // Test 1: Write Value to a DR  -- YES!
        //-----------------------------------------------------
        r_IR            <= 16'b0000111000000000;        // DR = R7
        r_DRMUX         <= 2'b00;
        r_bus_testing   <= 16'h000F;                    // Write F
        r_LD_REG        <= 1'b1;                        // Load the DR

        #(2*40)   
        r_IR            <= 16'h0000;        
        r_DRMUX         <= 2'b11;
        r_bus_testing   <= 16'h0000;
        r_LD_REG        <= 1'b0;
        #(6*40)   


        // Test 2: Read Value from SR1 (pass through ALU) -- Yes 
        //-----------------------------------------------------
        r_SR1_Addr  <= 2'b01;                   // Use IR[8:6] as address for SR1 Output register
        r_IR        <= 16'b0000000111000000;    // SR1 Out = R7
        r_ALUK      <= 2'b11;                   // Pass A (SR1 Out)

        #(2*40)
        r_IR        <= 16'h0000;        
        r_SR1_Addr  <= 2'b00;
        r_ALUK      <= 2'b00;

        #(6*40)   


        // Test 3: Add Values from R1 and R2 (and output to bus) -- Yes
        //-----------------------------------------------------
        r_ALUK      <= 2'b11;   // (set to wrong value to test adding later)

        // Load R1 with 3
        r_DRMUX         <= 2'b00;                           // Means Dr = IR[11:9]
        r_IR            <= 16'b0000001000000000;            // DR = R1
        r_bus_testing   <= 16'h0003;                        // Write 3
        r_LD_REG        <= 1'b1;                            // Write to Reg file

        #(2*40)   // Wait 1clk

        // Load R2 with 4
        r_DRMUX         <= 2'b00;                           // Means Dr = IR[11:9]
        r_IR            <= 16'b0000010000000000;            // DR = R2
        r_bus_testing   <= 16'h0004;                        // Write 4
        r_LD_REG        <= 1'b1;                            // Write to Reg file

        #(2*40)   // Wait 1clk

        // Send R1 and R2 to ALU to be added
        r_LD_REG    <= 1'b0;                        // Don't write to register file
        r_SR1_Addr  <= 2'b01;                       // Use IR[8:6] as address for SR1 Output register
        r_IR        <= 16'b0000000001000010;        // SR2 Out Address = IR[2:0]
            // SR2Out = R2, SR1 Out = R1
            // IR[5] = 0 meaning Pass SR2OUt through SR2 Mux
        r_ALUK      <= 2'b00;   // Means add

        #(2*40)   // Wait 1clk 

        // Reset signals
        r_LD_REG    <= 1'b0;   
        r_SR1_Addr  <= 2'b00;  
        r_IR        <= 16'h0000;
        r_ALUK      <= 2'b11;   // Wrong sinal for next test 

        // Note: it is acting as expected 
        //     3 and 4 are written on the neg clk edge 
        //     3 and 4 are sent to the ALU on the neg clk edge 
        //     3+4 = 7 appears on the ALU out bus 
        //     However, when ALU changes to 11, ALU out bus becomes 3 (pass A)
        //     Therefore, the 7 only appears for 1/2 clk cycle
        //     This may or may not work
        
        // #(6*40)   

        // Test 4: Addition -- Yes and No (failed RX <- RX + imm5)
        //-----------------------------------------------------
        // Note: SOLVED - used 2nd solution
        // Note: this test failed when I tried to do R1 <- R1 + R2 
        // Since the register file is "updates" on the negative clock edge
        // and when the input bus changes, and the alu is not clocked, 
        // When R1 gets its new value it is imediatly sent back in the alu 
        // This is a problem because it creates an infinate loop where R1 
        // incriments forever and we can not determine its state 
        // There are 2 possible solutions :
        //  1) Clock the ALU so it can only output values once. This would 
        //      prevent the alu for infinatly updateing R1 
        //  2) Make is so the register file only outputs values to the ALU
        //      on the negative edge of the clk cycle. This would prevent 
        //      the new R1 value from going through the ALU and infinatly
        //      updateing itself
        #(2*40)   
        // Control Signals
        r_Gate_ALU  <= 1'b1;                        // Let Processing unit write to bus (and therefore be its own input)
        r_ALUK      <= 2'b00;                       // Add 
        r_LD_REG    <= 1'b1;                        // Write to DR 
        r_SR1_Addr  <= 2'b01;                       // IR[8:6] = address for SR1 Output register
        r_DRMUX     <= 2'b00;                       // Use IR[11:9] as address for DR  
        // Datapath Stuff
                         //add|DR|SR1|0|SR2
        r_IR        <= 16'b0001011001000010;        // R3 <- R1 + R2 
        #(2*40)   
        r_IR        <= 16'b0001100001000011;        // R4 <- R1 + R3 
        #(2*40)   
        r_IR        <= 16'b0001011100000011;        // R3 <- R4 + R3 
        #(2*40)   
        r_IR        <= 16'b0001111100000011;        // R7 <- R4 + R3 
        #(2*40)   
        r_IR        <= 16'b0001100100000111;        // R4 <- R4 + R7 
        #(2*40)   
        r_IR        <= 16'b0001000010101000;        // R0 <- R2 + 8
        #(2*40)   
        r_IR        <= 16'b0001111010100011;        // R7 <- R2 + 3
        #(2*40)   
        r_IR        <= 16'b0001001001101000;        // R1 <- R1 + 8 < ---- No longer an Issue here!!!!

        // Rest Singals
        #(2*40)   
        r_Gate_ALU  <= 1'b0;    
        r_ALUK      <= 2'b11;   
        r_LD_REG    <= 1'b0;    
        r_SR1_Addr  <= 2'b00;   
        r_DRMUX     <= 2'b00;  
        r_IR        <= 16'h0000;

        // #(6*40)   

    end // Note: the last line can not be a #wait amount otherwise the program kys
    //------------------------------------------------------------------------------


    integer idx; // Use an integer for the loop counter

    // Run and Output simulation to .vcd file 
    initial begin
        $dumpfile(`DUMPSTR(`VCD_OUTPUT));
        $dumpvars(0, processing_unit_tb);
            // 0 = Dump all vars (including sub-mods)

        for (idx = 0; idx < 8; idx = idx + 1) 
            $dumpvars(0, UUT.register_file_module.memory[idx]); // Loop over the array

        // Wait for sim to complete
        #(DURATION)

        // Notify the end of simulation
        $display("Finished!");
        $finish;

    end

endmodule
