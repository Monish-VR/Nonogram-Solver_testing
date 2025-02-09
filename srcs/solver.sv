`timescale 1ns / 1ps
`default_nettype none

module solver #(parameter MAX_ROWS = 11, parameter MAX_COLS = 11, parameter MAX_NUM_OPTIONS=84)(
    input wire clk,
    input wire rst,
    input wire started,
    input wire [15:0] option,
    input wire [$clog2(MAX_ROWS) - 1:0] num_rows,
    input wire [$clog2(MAX_COLS) - 1:0] num_cols,
    input wire [MAX_ROWS + MAX_COLS - 1:0] [$clog2(MAX_NUM_OPTIONS)-1:0] old_options_amnt,
    input wire [$clog2(MAX_NUM_OPTIONS)-1:0] all_options_remaining,
    
    output logic new_line,
    output logic [15:0] new_option,
    output logic [(MAX_ROWS * MAX_COLS) - 1:0] assigned,
    output logic [(MAX_ROWS * MAX_COLS) - 1:0] known,
    output logic put_back_to_FIFO,
    output logic solved,
    output logic unsolvable
);

localparam IDLE = 0, NEXT_LINE_INDEX = 1, ONE_OPTION = 2, MULTIPLE_OPTIONS = 3, WRITE = 4;
logic [2:0] state, state_prev;
localparam LARGEST_DIM = (MAX_ROWS > MAX_COLS)? MAX_ROWS : MAX_COLS;

logic [MAX_ROWS + MAX_COLS - 1:0] [6:0] options_amnt; 
logic [2:0][$clog2(MAX_ROWS + MAX_COLS) - 1:0] line_index, new_index;
logic [$clog2(MAX_ROWS * MAX_COLS) - 1:0] base_index, sol_index;
logic row, first;
logic valid_in_simplify;
logic [$clog2(MAX_NUM_OPTIONS) - 1:0] options_left;
logic [$clog2(MAX_NUM_OPTIONS) - 1:0] net_valid_opts;
logic simp_valid;
logic one_option_case;
logic [$clog2(MAX_NUM_OPTIONS)-1:0] net_option_amnt;
logic [LARGEST_DIM-1:0] curr_assign, curr_known;
logic [LARGEST_DIM-1:0] always1, always0;
logic [MAX_COLS-1:0] cols_all_known;
logic [$clog2(MAX_COLS) - 1:0] num_known_cols;
logic [(MAX_ROWS * MAX_COLS) - 1:0] known_t, assigned_t;

assign row = line_index[0] < num_rows;

// Transpose logic
always_comb begin
    for (integer m = 0; m < MAX_ROWS; m = m + 1) begin
        for (integer n = 0; n < MAX_COLS; n = n + 1) begin
            known_t[n * MAX_ROWS + m] = known[m * MAX_COLS + n];
            assigned_t[n * MAX_ROWS + m] = assigned[m * MAX_COLS + n];
        end
    end
end

// Extract line data
always_comb begin
    if (row) begin
        curr_assign = assigned[MAX_COLS * new_index +: MAX_COLS];
        curr_known = known[MAX_COLS * new_index +: MAX_COLS];
    end else begin
        curr_assign = assigned_t[MAX_ROWS * (new_index - num_rows) +: MAX_ROWS];
        curr_known = known_t[MAX_ROWS * (new_index - num_rows) +: MAX_ROWS];
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        unsolvable <= 0;
        known <= 0;
        assigned <= 0;
        net_option_amnt <= 0;
        solved <= 0;
        state <= IDLE;
        first <= 1;
        new_index <= 0;
        options_amnt <= 0;
        line_index <= 0;
        base_index <= 0;
        new_line <= 0;
        new_option <= 0;
        put_back_to_FIFO <= 0;
    end else begin
        case (state)
            IDLE: begin
                if (started) begin
                    new_line <= 1;
                    options_amnt <= old_options_amnt;
                    net_option_amnt <= all_options_remaining;
                    unsolvable <= 0;
                    known <= 0;
                    assigned <= 0;
                    state <= NEXT_LINE_INDEX;
                end
                solved <= 0;
                first <= 1;
            end
            
            NEXT_LINE_INDEX: begin
                if (num_known_cols == num_cols) begin
                    solved <= 1;
                    state <= IDLE;
                    new_line <= 0;
                    put_back_to_FIFO <= 0;
                end else begin
                    if (!first) begin 
                        options_amnt[line_index[2]] <= net_valid_opts;
                        net_option_amnt <= net_option_amnt - (options_amnt[line_index[2]] - net_valid_opts);
                    end 
                    if (options_amnt[option] > 0) begin
                        state <= (options_amnt[option] == 1) ? ONE_OPTION : MULTIPLE_OPTIONS;
                    end
                    if (net_option_amnt == 0) unsolvable <= 1;
                    options_left <= options_amnt[option];
                    new_index <= option;
                    line_index[0] <= option;
                    put_back_to_FIFO <= 1;
                    new_option <= option;
                    net_valid_opts <= 0;
                    always1 <= '1;
                    always0 <= '1;
                    new_line <= 1;
                    first <= 0;
                end
            end
            
            MULTIPLE_OPTIONS: begin
                if (((curr_assign ^ option) & curr_known) > 0) put_back_to_FIFO <= 0;
                else begin
                    new_option <= option;
                    net_valid_opts <= net_valid_opts + 1;
                    always1 <= always1 & option;
                    always0 <= always0 & ~option;
                    put_back_to_FIFO <= 1;
                end
                options_left <= options_left - 1;
                state <= (options_left == 1) ? WRITE : MULTIPLE_OPTIONS;
                new_line <= options_left > 1;
            end
            
            ONE_OPTION: begin
                put_back_to_FIFO <= 0;
                always1 <= always1 & option;
                always0 <= always0 & ~option;
                options_left <= 0;
                net_option_amnt <= net_option_amnt - 1;
                state <= WRITE;
                new_line <= 0;
            end
            
            WRITE: begin
                new_line <= 1;
                base_index = (row) ? (MAX_COLS * line_index[1]) : (line_index[1] - num_rows);
                for (integer i = 0; i < LARGEST_DIM; i = i + 1) begin
                    if (always1[i]) begin 
                        known[base_index + i] <= 1; 
                        assigned[base_index + i] <= 1;
                    end
                    if (always0[i]) begin 
                        known[base_index + i] <= 1; 
                        assigned[base_index + i] <= 0;
                    end
                end
                state <= NEXT_LINE_INDEX;
                put_back_to_FIFO <= 0;
            end
        endcase
    end
    state_prev <= state;
end

endmodule

`default_nettype wire
