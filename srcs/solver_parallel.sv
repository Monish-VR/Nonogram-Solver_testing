
`timescale 1ns / 1ps
`default_nettype none

//NOTE: this will not work with an unsolvable board. Always1 and always0 may contradict and then you will try to write 
// two different values to the same location in assigned. Unsure what iverilog would do but would be bad
//I figured maybe this would just be an input constraint that this doesn't happen but now I'm unclear given 
// we also had this for the non-parallel version but there is an unsolvable testbench. 
//Would you prefer we check for this?
module parallel_solver #(parameter MAX_ROWS = 11, parameter MAX_COLS = 11, parameter MAX_NUM_OPTIONS=84)(
        //TODO: confirm sizes for everything
        input wire clk,
        input wire rst,
        input wire started, //indicates board has been parsed, ready to solve
        input wire [15:0] option_r, 
        input wire [15:0] option_c,
        input wire [$clog2(MAX_ROWS) - 1:0] num_rows,
        input wire [$clog2(MAX_COLS) - 1:0] num_cols,
        //@Nina, @Veronica -We may have to divide this:
        input wire [MAX_ROWS + MAX_COLS - 1:0] [$clog2(MAX_NUM_OPTIONS)-1:0] old_options_amnt,  //[0:2*SIZE] [6:0]
        input wire [MAX_ROWS + MAX_COLS - 1:0] [$clog2(MAX_NUM_OPTIONS)-1:0] old_options_amnt_c,
        //TODOI:  unsure if there would be issues with accessing it twice witihn the same clock cycle
            //idk if you'd like one for rows and one for columns seperately

        output logic read_from_fifo_r,
        output logic read_from_fifo_c,
        output logic [15:0] new_option_r,
        output logic [15:0] new_option_c,
        output logic [(MAX_ROWS * MAX_COLS) - 1:0] assigned,  //changed to 1D array for correct indexing
        output logic [(MAX_ROWS * MAX_COLS) - 1:0] known,      // changed to 1D array for correct indexing
        output logic put_back_to_FIFO_r,  //boolean- do we need to push to fifo
        output logic put_back_to_FIFO_c,  //boolean- do we need to push to fifo

        output logic solved //1 when solution is good
    );
    localparam IDLE = 0;
    localparam NEXT_LINE_INDEX = 1;
    localparam ONE_OPTION = 2;
    localparam MULTIPLE_OPTIONS = 3;
    localparam WRITE = 4;

    logic [2:0] state1, state_prev1;
    logic [2:0] state2, state_prev2;

    localparam LARGEST_DIM = (MAX_ROWS > MAX_COLS)? MAX_ROWS : MAX_COLS;
    logic [MAX_ROWS + MAX_COLS - 1:0] [6:0] options_amnt;// options_amnt2; 
    logic [MAX_ROWS + MAX_COLS - 1:0] [6:0] options_amnt_c;// options_amnt2; 
    
    logic [2:0][$clog2(MAX_ROWS + MAX_COLS) - 1:0] line_index1, new_index1;
    logic [2:0][$clog2(MAX_ROWS + MAX_COLS) - 1:0] line_index2, new_index2;
    logic [$clog2(MAX_ROWS * MAX_COLS) - 1:0]  base_index1, base_index2, sol_index;
    logic first1, first2;
    logic valid_in_simplify;

    logic [$clog2(MAX_NUM_OPTIONS) - 1:0] options_left1; //options left to get from the fifo
    logic [$clog2(MAX_NUM_OPTIONS) - 1:0] net_valid_opts1; //how many valid options we checked
    logic [$clog2(MAX_NUM_OPTIONS) - 1:0] options_left2; //options left to get from the fifo
    logic [$clog2(MAX_NUM_OPTIONS) - 1:0] net_valid_opts2; //how many valid options we checked

    logic simp_valid; //out put valid for simplify

    logic one_option_case1;
    logic one_option_case2;

    //TODO: be consistent on naming- I like the 1,2 division to generalize to more FIFO's but 
    //if you prefer r,c then everything here sohuld be changed to that
    logic [LARGEST_DIM-1:0] curr_assign1; //one line input of assigned input to simplify
    logic [LARGEST_DIM-1:0] curr_known1; //one line input of known input to simplif
    logic [LARGEST_DIM-1:0] curr_assign2; //one line input of assigned input to simplify
    logic [LARGEST_DIM-1:0] curr_known2; //one line input of known input to simplif

    logic [LARGEST_DIM-1:0] always1_1;// a and b
    logic [LARGEST_DIM-1:0] always0_1;
    logic [LARGEST_DIM-1:0] always1_2;// a and b
    logic [LARGEST_DIM-1:0] always0_2;

    logic [MAX_COLS-1:0] cols_all_known;
    logic [$clog2(MAX_COLS) - 1:0] num_known_cols;

    logic  [(MAX_ROWS * MAX_COLS) - 1:0] known_t; //transpose
    logic  [(MAX_ROWS * MAX_COLS) - 1:0] assigned_t; //transpose
    // logic assign_r, assign_c; //when 1, assign row and then the col, potentially just assign row and then assign col

    //TRANSPOSING:
    genvar m; //rows
    genvar n; //cols
    for(m = 0; m < MAX_ROWS; m = m + 1) begin
        for(n = 0; n < MAX_COLS; n = n + 1) begin
            assign known_t[n*MAX_ROWS + m] = known[m*MAX_COLS + n];
            assign assigned_t[n*MAX_ROWS + m] = assigned[m*MAX_COLS + n];
        end
    end

//Grab the line from relevant known and assigned blocks

    always_comb begin
        //gets relevant line from assigned and known
        curr_assign1 = assigned[MAX_COLS*new_index1 +: MAX_COLS];
        curr_known1 = known[MAX_COLS*new_index1 +: MAX_COLS];
        curr_assign2 = assigned_t[MAX_ROWS*(new_index2 - num_rows) +: MAX_ROWS];
        curr_known2 = known_t[MAX_ROWS*(new_index2 - num_rows) +: MAX_ROWS];
        
        cols_all_known = '1;
        num_known_cols = 0;
        sol_index = 0;
        for (integer i = 0; i < MAX_ROWS; i = i + 1)begin
            if (i < num_rows)begin
                cols_all_known = cols_all_known & known[sol_index +: MAX_COLS];
                sol_index = sol_index + MAX_COLS;
            end
        end
        for (integer j = 0; j < MAX_COLS; j = j + 1)begin
            if(cols_all_known[j] && j < num_cols) num_known_cols = num_known_cols + 1;
        end
    end
    
    always_ff @(posedge clk)begin
        if(rst)begin
            known <= 0;
            assigned <= 0;
            net_valid_opts1 <=0;
            net_valid_opts2 <=0;
            solved <= 0;
            state1 <= IDLE;
            state2 <= IDLE;
            first1 <= 1;
            first2 <= 1;
            new_index1 <= 0;
            new_index2 <= 0;
            options_amnt <= 0;
            options_amnt_c<=0;
            line_index1 <= 0;
            line_index2 <= 0;
            base_index1<= 0;
            base_index2<= 0;
            read_from_fifo_r<= 0;
            read_from_fifo_c<= 0;
            new_option_r<= 0;
            new_option_c<= 0;
            put_back_to_FIFO_r<=0;
            put_back_to_FIFO_c<=0;    
        end else 
        //if we are only treating this as the 2-FIFO case (one with rows and one with columns),
        // we can simplify the row column logic
            case(state1)
                IDLE: begin
                    if (started)begin
                        read_from_fifo_r <= 1;
                        options_amnt <= old_options_amnt;
                        state1 <= NEXT_LINE_INDEX;
                        known <= 0;
                        assigned <= 0;
                    end
                    solved <= 0;
                    first1 <= 1;
                end
                NEXT_LINE_INDEX: begin
                    if (num_known_cols == num_cols)begin
                        //victory check
                        solved <= 1;
                        state1 <= IDLE;
                        read_from_fifo_r <= 0;
                        put_back_to_FIFO_r <= 0;
                    end else begin
                        if(!first1) options_amnt[line_index1[2]] <= net_valid_opts1;
                        if (options_amnt[option_r] > 0) begin
                            state1 <= (options_amnt[option_r]==0)? NEXT_LINE_INDEX : (options_amnt[option_r] == 1)? ONE_OPTION : MULTIPLE_OPTIONS;
                        end
                        options_left1 <= options_amnt[option_r];
                        new_index1 <= option_r;
                        line_index1[0] <= option_r;
                        put_back_to_FIFO_r <= 1;
                        new_option_r <= option_r;
                        net_valid_opts1 <= 0;
                        always1_1 <= '1;
                        always0_1 <= '1;
                        put_back_to_FIFO_r <= 1;
                        read_from_fifo_r <= 1;
                        first1 <= 0;
                    end
                end
                MULTIPLE_OPTIONS: begin
                    //check to see if it contradicts known info
                    if (((curr_assign1 ^ option_r) & curr_known1) > 0) put_back_to_FIFO_r <= 0;
                    else begin
                        //if it doesn't contradict, update values accordingly
                        new_option_r <= option_r;
                        net_valid_opts1 <= net_valid_opts1 + 1;
                        always1_1 <= always1_1 & option_r;
                        always0_1 <= always0_1 & ~option_r;
                        put_back_to_FIFO_r <= 1;
                    end
                    options_left1 <= options_left1 - 1;
                    state1 <= (options_left1 - 1 == 0)? WRITE : MULTIPLE_OPTIONS;
                    read_from_fifo_r <= (options_left1 > 1);
                end
                ONE_OPTION: begin
                    //if there is only one option, it must be that this is the correct option
                    put_back_to_FIFO_r <= 0;
                    net_valid_opts1 <= 0;
                    always1_1 <= always1_1 & option_r;//TODO: I think this unessessary
                    always0_1 <= always0_1 & ~option_r;
                    options_left1 <= 0;
                    state1 <= WRITE;//TODO: I think this may be overkill
                    read_from_fifo_r <= 0;
                end
                WRITE: begin
                    read_from_fifo_r <= 0;
                    // check if specific bits of always1 or always0 are 1, if so assign it to known and assigned accordingly
                    base_index1 = MAX_COLS*line_index1[1];
                    for(integer i = 0; i < MAX_COLS; i = i + 1) begin
                        if(i < num_cols) begin
                            if (always1_1[i] == 1) begin 
                                known[base_index1 + i] <= 1;
                                assigned[base_index1+ i] <= 1;
                            end
                            if (always0_1[i] == 1) begin 
                                known[base_index1 + i] <= 1; 
                                assigned[base_index1 + i] <= 0;
                            end
                        end
                    end
                    state1 <= NEXT_LINE_INDEX;
                    put_back_to_FIFO_r <= 0;
                end
            endcase
            case(state2)
                IDLE: begin
                    if (started)begin
                        read_from_fifo_c <= 1;
                        options_amnt_c <= old_options_amnt_c;
                        state2 <= NEXT_LINE_INDEX;
                    end
                    first2 <= 1;
                end
                NEXT_LINE_INDEX: begin
                    if (num_known_cols == num_cols)begin
                        //victory check
                        // solved <= 1;
                        state2 <= IDLE;
                        read_from_fifo_c <= 0;
                        put_back_to_FIFO_c <= 0;
                    end else begin
                        if(!first2) options_amnt_c[line_index2[2]] <= net_valid_opts2;
                            if (options_amnt_c[option_c] > 0) begin
                            state2 <= (options_amnt_c[option_c]==0)? NEXT_LINE_INDEX : (options_amnt_c[option_c] == 1)? ONE_OPTION : MULTIPLE_OPTIONS;
                        end
                        options_left2 <= options_amnt_c[option_c];
                        new_index2 <= option_c;
                        line_index2[0] <= option_c;
                        put_back_to_FIFO_c <= 1;
                        new_option_c <= option_c;
                        net_valid_opts2 <= 0;
                        always1_2 <= '1;
                        always0_2 <= '1;
                        put_back_to_FIFO_c <= 1;
                        read_from_fifo_c <= 1;
                        first2 <= 0;
                    end
                end
                MULTIPLE_OPTIONS: begin
                    //check to see if it contradicts known info
                    if (((curr_assign2 ^ option_c) & curr_known2) > 0) put_back_to_FIFO_c <= 0;
                    else begin
                        //if it doesn't contradict, update values accordingly
                        new_option_c <= option_c;
                        net_valid_opts2 <= net_valid_opts2 + 1;
                        always1_2 <= always1_2 & option_c;
                        always0_2 <= always0_2 & ~option_c;
                        put_back_to_FIFO_c <= 1;
                    end
                    options_left2 <= options_left2 - 1;
                    state2 <= (options_left2 - 1 == 0)? WRITE : MULTIPLE_OPTIONS;
                    read_from_fifo_c <= (options_left2 > 1);
                end
                ONE_OPTION: begin
                    //if there is only one option, it must be that this is the correct option
                    put_back_to_FIFO_c <= 0;
                    net_valid_opts2 <= 0;
                    always1_2 <= always1_2 & option_c;//TODO: I think this unessessary
                    always0_2 <= always0_2 & ~option_c;
                    options_left2 <= 0;
                    state2 <= WRITE;//TODO: I think this may be overkill
                    read_from_fifo_c <= 0;
                end
                WRITE: begin
                    if (state1==WRITE) begin
                        state2 <= WRITE;
                        read_from_fifo_c <= 0;
                        put_back_to_FIFO_c <= 0;
                    end else begin
                        state2 <= NEXT_LINE_INDEX;
                        read_from_fifo_c <= 1;
                        // check if specific bits of always1 or always0 are 1, if so assign it to known and assigned accordingly
                        base_index2 = (line_index2[1] - num_rows);
                        for(integer j = 0; j < MAX_ROWS; j = j + 1) begin
                            if(j < num_rows) begin
                                if (always1_2[j]) begin 
                                    known[base_index2] <= 1; 
                                    assigned[base_index2] <= 1;
                                end
                                if (always0_2[j]) begin 
                                    known[base_index2] <= 1; 
                                    assigned[base_index2] <= 0;
                                end
                            end
                            base_index2 += MAX_COLS;
                        end
                        state2 <= NEXT_LINE_INDEX;
                        put_back_to_FIFO_c <= 0;
                    end
                end
            endcase
        //end
        //pipelining
        state_prev1 <= state1;
        if(state_prev1 != state1)begin
            line_index1[1] <= line_index1[0];
            line_index1[2] <= line_index1[1];
        end
        state_prev2 <= state2;
        if(state_prev2 != state2)begin
            line_index2[1] <= line_index2[0];
            line_index2[2] <= line_index2[1];
        end
    end

endmodule

`default_nettype wire
 
