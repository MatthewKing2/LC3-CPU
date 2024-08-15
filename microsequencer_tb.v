`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1 ns / 10 ps

module microsequencer_tb();    // Note no IO

    reg     clk = 0;
    reg     rst = 0;

    // Simulation time: 10,000 * 1ns = 10us 
    localparam  DURATION = 3000;

    // CLk
    always begin 
        #41.667
        clk = ~clk;
    end

    // Instantiate and Test UUT     
    //------------------------------------------------------------------------------
    microsequencer UUT( 
        .i_j_field(r_j_field),
        .i_COND_bits(r_COND_bits),
        .i_IRD(r_IRD),
        .i_R_Bit(r_R_Bit),
        .i_IR_15_9(r_IR_15_9),
        .i_NZP(r_NZP),
        .i_ACV(r_ACV),
        .i_PSR_15(r_PSR_15),
        .i_INT(r_INT),
        .o_AddressNextState(w_AddressNextState)
    );

    // Registers
    reg     [5: 0]      r_j_field;
    reg     [2: 0]      r_COND_bits;
    reg     [5: 0]      r_IRD;
    reg                 r_R_Bit;
    reg     [6: 0]      r_IR_15_9;
    reg     [2: 0]      r_NZP;
    reg                 r_ACV;
    reg                 r_PSR_15;
    reg                 r_INT;
    wire    [5: 0]      w_AddressNextState;



    initial begin
        // Set up - go to state 18
        r_IRD       <= 0;           // No Branch
        r_COND_bits <= 3'b000;      // Look for NO singal
        r_j_field   <= 6'b010010;   // Base Case = State 18
        #(10*41.667)   

        // State 18 (start)
        #(2*41.667)   
        // "Outside Singals"
        r_INT       <= 0;
        // Figure out next state: 
        r_IRD       <= 0;           // No Branch
        r_COND_bits <= 3'b101;      // Look for INT singal
        r_j_field   <= 6'b100001;   // Base Case = State 33
        // Datapath Control Singals:
            // Pending

        // State 33 (ACV check)
        #(2*41.667)   
        // "Outside Singals"
        r_ACV       <= 0;
        // Figure out next state: 
        r_IRD       <= 0;           // No Branch
        r_COND_bits <= 3'b110;      // Look for ACV singal
        r_j_field   <= 6'b011100;   // Base Case = State 28
        // Datapath Control Singals:
            // Pending

        // State 28 (load instruction into MDR)
        #(2*41.667)   
        // "Outside Singals"
        r_R_Bit     <= 0;
        // Figure out next state: 
        r_IRD       <= 0;           // No Branch
        r_COND_bits <= 3'b001;      // Look for R singal
        r_j_field   <= 6'b011100;   // Base Case = State 28 (itself)
        // Testing Ready bit 
        #(4*41.667)   
        r_R_Bit         <= 1; // Finally read from memeory, move to state 28+2 = 30
        // Datapath Control Singals:
            // Pending

        // State 30 (Load MDR into IR)
        #(2*41.667)   
        // "Outside Singals"
        // Figure out next state: 
        r_IRD       <= 0;           // No Branch
        r_COND_bits <= 3'b000;      // Look for NO singal
        r_j_field   <= 6'b100000;   // Base Case = State 32
        // Datapath Control Singals:
            // Pending

        // State 32 (branch on opcode)
        #(2*41.667)   
        // "Outside Singals"
        r_NZP       <= 3'b111;      // Unconditional Branch
        r_IR_15_9   <= 6'b0001000;  // Add, NZP = 000 (therefore BEN does not get set)
        // Figure out next state: 
        r_IRD       <= 1;           // YES Branch
        r_COND_bits <= 3'b000;      // Look for NO singal
        r_j_field   <= 6'b010010;   // Base Case = DOES NOT MATTER
        // Datapath Control Singals:
            // Pending

        // State 1 (add)
        #(2*41.667)   
        // "Outside Singals"
        // NAN
        // Figure out next state: 
        r_IRD       <= 0;           // No Branch
        r_COND_bits <= 3'b000;      // Look for NO singal
        r_j_field   <= 6'b010010;   // Base Case = State 18
        // Datapath Control Singals:
            // Pending


    end // Note: the last line can not be a #wait amount otherwise the program kys
    //------------------------------------------------------------------------------



    // Run and Output simulation to .vcd file 
    initial begin
        $dumpfile(`DUMPSTR(`VCD_OUTPUT));
        $dumpvars(0, microsequencer_tb);

        // Wait for sim to complete
        #(DURATION)

        // Notify the end of simulation
        $display("Finished!");
        $finish;

    end

endmodule
