
// //------------------------------------------------------------------------------
// // Module: microsequencer
// // Logic: Combinational (not clocked)
// //------------------------------------------------------------------------------

// module microsequencer #( 
//     // From Control Store:
//     input   wire    [5: 0]      i_j_field,
//     input   wire    [2: 0]      i_COND_bits,
//     input   wire    [5: 0]      i_IRD,
//     // From Memory IO:
//     input   wire                i_R_Bit,
//     // From Data Path:
//     input   wire    [6: 0]      i_IR_15_9,
//     input   wire    [2: 0]      i_NZP,
//     input   wire                i_ACV,
//     input   wire                i_PSR_15,
//     // From Interupt Control:
//     input   wire                i_INT,
//     output  reg     [5: 0]      o_AddressNextState);


//     parameter ACV   = 3'b110;
//     parameter INT   = 3'b101;
//     parameter PSR15 = 3'b100;
//     parameter BEN   = 3'b010;
//     parameter R     = 3'b001;
//     parameter IR11  = 3'b011;
//     wire      BEN   = (i_IR_15_9[0] && i_NZP[0]) || 
//                       (i_IR_15_9[1] && i_NZP[1]) || 
//                       (i_IR_15_9[2] && i_NZP[2]);

//     if(IRD) begin
//        case (i_COND_bits)
//         ACV:    o_AddressNextState[5] = i_ACV           || i_j_field[5];
//         INT:    o_AddressNextState[5] = i_INT           || i_j_field[4];
//         PSR15:  o_AddressNextState[5] = i_PSR_15        || i_j_field[3];
//         BEN:    o_AddressNextState[5] = BEN             || i_j_field[2];
//         R:      o_AddressNextState[5] = i_R_Bit         || i_j_field[1];
//         IR11:   o_AddressNextState[5] = i_IR_15_9[2]    || i_j_field[0];
//        endcase 
//     end
//     else begin
//         o_
//         ddressNextState = {2'b00, i_IR_15_9[6:3]};
//     end


// endmodule