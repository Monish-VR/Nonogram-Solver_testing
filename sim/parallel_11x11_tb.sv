`default_nettype none
`timescale 1ns / 1ps

`define status(OPT1, OPT2, KNOWNS, SOL) \
$display("option1: %b \n", OPT1); \
$display("option2: %b \n", OPT2); \
$display("knows: \n %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", KNOWNS[0], KNOWNS[1], KNOWNS[2], KNOWNS[3], KNOWNS[4], KNOWNS[5], KNOWNS[6], KNOWNS[7], KNOWNS[8], KNOWNS[9], KNOWNS[10]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", KNOWNS[11], KNOWNS[12], KNOWNS[13], KNOWNS[14], KNOWNS[15], KNOWNS[16], KNOWNS[17], KNOWNS[18], KNOWNS[19], KNOWNS[20], KNOWNS[21]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", KNOWNS[22], KNOWNS[23], KNOWNS[24], KNOWNS[25], KNOWNS[26], KNOWNS[27], KNOWNS[28], KNOWNS[29], KNOWNS[30], KNOWNS[31], KNOWNS[32]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", KNOWNS[33], KNOWNS[34], KNOWNS[35], KNOWNS[36], KNOWNS[37], KNOWNS[38], KNOWNS[39], KNOWNS[40], KNOWNS[41], KNOWNS[42], KNOWNS[43]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", KNOWNS[44], KNOWNS[45], KNOWNS[46], KNOWNS[47], KNOWNS[48], KNOWNS[49], KNOWNS[50], KNOWNS[51], KNOWNS[52], KNOWNS[53], KNOWNS[54]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", KNOWNS[55], KNOWNS[56], KNOWNS[57], KNOWNS[58], KNOWNS[59], KNOWNS[60], KNOWNS[61], KNOWNS[62], KNOWNS[63], KNOWNS[64], KNOWNS[65]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", KNOWNS[66], KNOWNS[67], KNOWNS[68], KNOWNS[69], KNOWNS[70], KNOWNS[71], KNOWNS[72], KNOWNS[73], KNOWNS[74], KNOWNS[75], KNOWNS[76]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", KNOWNS[77], KNOWNS[78], KNOWNS[79], KNOWNS[80], KNOWNS[81], KNOWNS[82], KNOWNS[83], KNOWNS[84], KNOWNS[85], KNOWNS[86], KNOWNS[87]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", KNOWNS[88], KNOWNS[89], KNOWNS[90], KNOWNS[91], KNOWNS[92], KNOWNS[93], KNOWNS[94], KNOWNS[95], KNOWNS[96], KNOWNS[97], KNOWNS[98]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", KNOWNS[99], KNOWNS[100], KNOWNS[101], KNOWNS[102], KNOWNS[103], KNOWNS[104], KNOWNS[105], KNOWNS[106], KNOWNS[107], KNOWNS[108], KNOWNS[109]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", KNOWNS[110], KNOWNS[111], KNOWNS[112], KNOWNS[113], KNOWNS[114], KNOWNS[115], KNOWNS[116], KNOWNS[117], KNOWNS[118], KNOWNS[119], KNOWNS[120]); \
$display("sol: \n %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", SOL[0], SOL[1], SOL[2], SOL[3], SOL[4], SOL[5], SOL[6], SOL[7], SOL[8], SOL[9], SOL[10]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", SOL[11], SOL[12], SOL[13], SOL[14], SOL[15], SOL[16], SOL[17], SOL[18], SOL[19], SOL[20], SOL[21]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", SOL[22], SOL[23], SOL[24], SOL[25], SOL[26], SOL[27], SOL[28], SOL[29], SOL[30], SOL[31], SOL[32]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", SOL[33], SOL[34], SOL[35], SOL[36], SOL[37], SOL[38], SOL[39], SOL[40], SOL[41], SOL[42], SOL[43]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", SOL[44], SOL[45], SOL[46], SOL[47], SOL[48], SOL[49], SOL[50], SOL[51], SOL[52], SOL[53], SOL[54]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", SOL[55], SOL[56], SOL[57], SOL[58], SOL[59], SOL[60], SOL[61], SOL[62], SOL[63], SOL[64], SOL[65]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", SOL[66], SOL[67], SOL[68], SOL[69], SOL[70], SOL[71], SOL[72], SOL[73], SOL[74], SOL[75], SOL[76]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", SOL[77], SOL[78], SOL[79], SOL[80], SOL[81], SOL[82], SOL[83], SOL[84], SOL[85], SOL[86], SOL[87]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", SOL[88], SOL[89], SOL[90], SOL[91], SOL[92], SOL[93], SOL[94], SOL[95], SOL[96], SOL[97], SOL[98]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", SOL[99], SOL[100], SOL[101], SOL[102], SOL[103], SOL[104], SOL[105], SOL[106], SOL[107], SOL[108], SOL[109]); \
$display(" %b  %b  %b  %b  %b  %b  %b  %b  %b  %b  %b \n", SOL[110], SOL[111], SOL[112], SOL[113], SOL[114], SOL[115], SOL[116], SOL[117], SOL[118], SOL[119], SOL[120]); \

module parallel_11x11_tb;

    logic clk;
    logic rst;
    logic started;
    logic [15:0] new_op1;
    logic [15:0] new_op2;
    logic [15:0] option1;
    logic [15:0] option2;
    logic valid_in;
    logic next;
    logic [21:0] [6:0] old_options_amnt;
    logic [120:0] assigned; 
    logic put_back_to_FIFO; 
    logic solved;
    logic [120:0] known;

    logic read_from_fifo1;
    logic read_from_fifo2;
    logic back_to_fifo1;
    logic back_to_fifo2;

    parrallel_solver uut (
        .clk(clk),
        .rst(rst),
        .started(started),
        .option_r(option1),
        .option_c(option2),
        .num_rows(4'd11),
        .num_cols(4'd11),
        .old_options_amnt(old_options_amnt),

        .read_from_fifo_r(read_from_fifo1),
        .read_from_fifo_c(read_from_fifo2),
        
        .assigned(assigned),
        .known(known),
        .new_option_r(new_op1),
        .new_option_c(new_op2),
        .put_back_to_FIFO_r(back_to_fifo1),  
        .put_back_to_FIFO_c(back_to_fifo2), 
        .solved(solved)
    );

    always begin
        #5;
        clk = !clk;
    end
    initial begin
        $dumpfile("parallel_11x11.vcd");
        $display("Starting Sim Solver");
        clk = 0;
        rst = 0;
        valid_in = 0;
        #5;
        rst = 1;
        #10;
        rst = 0;
        started = 0;

        //BOARD :
        // 1 1 1 1 1 1 1 1 1 1 1
        // 1 0 1 1 1 1 1 1 1 0 1
        // 1 1 0 1 1 1 1 1 0 1 1
        // 1 1 1 0 1 1 1 0 1 1 1
        // 1 1 1 1 0 1 0 1 1 1 1 
        // 1 1 1 1 1 0 1 1 1 1 1 
        // 1 1 1 1 0 1 0 1 1 1 1 
        // 1 1 1 0 1 1 1 0 1 1 1
        // 1 1 0 1 1 1 1 1 0 1 1 
        // 1 0 1 1 1 1 1 1 1 0 1
        // 1 1 1 1 1 1 1 1 1 1 1 

        //row 1: 11111111111
        //row 2: 10111111101
        //row 3: 11011111011
        //row 4: 11101110111
        //row 5: 11110101111
        //row 6: 11111011111
        //row 7: 11110101111
        //row 8: 11101110111
        //row 9: 11011111011
       //row 10: 10111111101
       //row 11: 11111111111
        //col 1: 11111111111
        //col 2: 10111111101
        //col 3: 11011111011
        //col 4: 11101110111
        //col 5: 11110101111
        //col 6: 11111011111
        //col 7: 11110101111
        //col 8: 11101110111
        //col 9: 11011111011
       //col 10: 10111111101
       //col 11: 11111111111       

        $display("just started");
      
        option1 = 0; //first line index
        option2 = 11;
        valid_in = 1;
        old_options_amnt[0] = 1; 
        old_options_amnt[1] = 1; 
        old_options_amnt[2] = 1;
        old_options_amnt[3] = 1;
        old_options_amnt[4] = 1;
        old_options_amnt[5] = 1;
        old_options_amnt[6] = 1; 
        old_options_amnt[7] = 1; 
        old_options_amnt[8] = 1;
        old_options_amnt[9] = 1;
        old_options_amnt[10] = 1;
        old_options_amnt[11] = 1;
        old_options_amnt[12] = 1; 
        old_options_amnt[13] = 1; 
        old_options_amnt[14] = 1;
        old_options_amnt[15] = 1;
        old_options_amnt[16] = 1;
        old_options_amnt[17] = 1;
        old_options_amnt[18] = 1; 
        old_options_amnt[19] = 1; 
        old_options_amnt[20] = 1;
        old_options_amnt[21] = 1;
        #10;
        started = 1;
        #10;
        started = 0;
        #10;
        `status(option1, option2 ,known,assigned);
        #10;
        option1 = 11'b11111111111; //row 1 opt 1
        option2 = 11'b11111111111; //col 1 opt 1
        valid_in = 1;
        #20;
        `status(option1, option2 ,known,assigned);

        option1 = 1; //row 2 line index
        option2 = 12; //col 2 line index
        valid_in = 1;
        `status(option1, option2, known,assigned);
        #10;
        option1 = 11'b10111111101; //row 3 opt 1
        option2 = 11'b10111111101;
        valid_in = 1;
        #20;
        `status(option1, option2, known,assigned);        

        option1 = 2; //row 3 line ind (==2)
        option2 = 13;
        valid_in = 1;
        `status(option1, option2, known,assigned);
        #10;
        option1 = 11'b11011111011; //row 3 opt 1
        option2 = 11'b11011111011;
        valid_in = 1;
        #20;
        `status(option1, option2, known,assigned);

        option1 = 3; //row 4 line ind 
        option2 = 14;
        valid_in = 1;
        `status(option1, option2, known,assigned);
        #10;
        option1 = 11'b11101110111; //row 4 opt 1 
        option2 = 11'b11101110111;
        valid_in = 1;
        #20;
        `status(option1, option2, known, assigned);
        // should assign cells [1][0] and [2][0] to be known

        option1 = 4; //row 5 line ind
        option2 = 15;
        valid_in = 1;
        `status(option1, option2,known, assigned);
        #10;
        option1 = 11'b11110101111; //row 5 first opt
        option2 = 11'b11110101111;
        valid_in = 1;
        #20;
        `status(option1, option2, known, assigned);

        option1 = 5; //row 6 line ind 
        option2 = 16;
        valid_in = 1;
        `status(option1, option2, known, assigned);
        #10;
        option1 = 11'b11111011111; //row 6 opt 1
        option2 = 11'b11111011111;
        valid_in = 1;
        #20;
        `status(option1, option2, known, assigned);

        option1 = 6; //row 7 line ind 
        option2 = 17;
        valid_in = 1;
        `status(option1, option2, known, assigned);
        #10;
        option1 = 11'b11110101111; //row 7 opt 1
        option2 = 11'b11110101111;
        valid_in = 1;
        #20;
        `status(option1, option2, known, assigned);

        option1 = 7  ; //row 8 line ind 
        option2 = 18;
        valid_in = 1;
        `status(option1, option2, known, assigned);
        #10;
        option1 = 11'b11101110111; //row 8 opt 1
        option2 = 11'b11101110111;
        valid_in = 1;
        #20;
        `status(option1, option2, known, assigned);

        option1 = 8; //row 9 line ind 
        option2 = 19;
        valid_in = 1;
        `status(option1, option2, known, assigned);
        #10;
        option1 = 11'b11011111011; //row 9 opt 1
        option2 = 11'b11011111011;
        valid_in = 1;
        #20;
        `status(option1, option2, known, assigned);

        option1 = 9; //row 10 line ind
        option2 = 20;
 
        valid_in = 1;
        `status(option1, option2, known, assigned);
        #10;
        option1 = 11'b10111111101; //row 10 opt 1
        option2 = 11'b10111111101;
        valid_in = 1;
        #20;
        `status(option1, option2, known, assigned);

        option1 = 10; //row 11 line ind 
        option2 = 21;
        valid_in = 1;
        `status(option1, option2, known, assigned);
        #10;
        option1 = 11'b11111111111; //row 1 1opt 1
        option2 = 11'b11111111111;
        valid_in = 1;
        #20;
        `status(option1, option2, known, assigned);

        $display("is solved? %b",solved);
        #10;
        $display("restarted");
        rst = 1;
        #10;
        rst = 0;
        #10;

        $display("is solved? %b",solved);
        #10
        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype wire
