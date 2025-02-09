`timescale 1ns / 1ps
`default_nettype none

module top_level (
    input wire clk_100mhz,
    input wire btnc,
    input wire rx,

    output logic tx,
    output logic [7:0] bits,
    output logic [2:0] stat
);
    
    localparam MAX_ROWS = 11;  // HARDCODED for 11x11
    localparam MAX_COLS = 11;  // HARDCODED for 11x11
    localparam LARGEST_DIM = (MAX_ROWS > MAX_COLS)? MAX_ROWS : MAX_COLS;
    localparam MAX_NUM_OPTIONS = 84; // HARDCODED for 11x11

    localparam RECEIVE = 0;
    localparam SOLVE = 1;
    localparam TRANSMIT = 2;

    localparam CYCLES = 50_000_000;
    localparam MAX_BYTE = 255;
    localparam COUNTER_WIDTH = $clog2(CYCLES);

    logic rst;
    logic [COUNTER_WIDTH - 1: 0] counter;
    logic [7:0] transmit_data, received_data, display_value;
    logic receive_done, transmit_valid, transmit_done, next_line;
    logic fifo_write, parse_write, solve_write, solve_next;
    logic [1:0] state;
    logic [15:0] fifo_in, fifo_out, parse_line, solve_line;
    logic fifo_empty, fifo_full;
    logic parsed, solved, assembled, unsolvable;
    logic [$clog2(MAX_ROWS) - 1:0] m [2:0];
    logic [$clog2(MAX_COLS) - 1:0] n [2:0];
    logic [MAX_ROWS + MAX_COLS - 1:0] [$clog2(MAX_NUM_OPTIONS) - 1:0] options_per_line;
    logic [MAX_ROWS + MAX_COLS - 1:0] [$clog2(MAX_NUM_OPTIONS) - 1:0] options_per_line_cols;
    logic [1:0] [(MAX_ROWS * MAX_COLS) - 1:0] solution;
    logic [(MAX_ROWS * MAX_COLS) - 1:0] knowns;
    logic clk_50mhz;
    logic [2:0] flag;
    logic fifo_rst;
    logic row;

    assign stat = {state, fifo_empty};
    assign rst = btnc;
    assign fifo_rst = rst || solved;
    assign bits = display_value;
    assign fifo_write = (state == RECEIVE) ? parse_write : solve_write;
    assign fifo_in = (state == RECEIVE) ? parse_line : solve_line;

    clk_wiz_50 divider (
        .clk_in1(clk_100mhz),
        .clk_out1(clk_50mhz)
    );

    uart_rx receiver(
        .clk(clk_50mhz),
        .rst(rst),
        .axiid(rx),

        .axiov(receive_done),
        .axiod(received_data)
    );

    parser parse (
        .clk(clk_50mhz),
        .rst(rst),
        .valid_in(receive_done),
        .byte_in(received_data),

        .board_done(parsed),
        .write_ready(parse_write),
        .line(parse_line),
        .options_per_line(options_per_line),
        .options_per_line_cols(options_per_line_cols),
        .n(n[0]),
        .m(m[0]),
        .flag(flag),
        .row(row)
    );

    fifo_11_by_11 fifo (
        .clk(clk_50mhz),
        .srst(fifo_rst),
        .din(fifo_in),
        .wr_en(fifo_write),
        .rd_en(solve_next),
        .dout(fifo_out),
        .full(fifo_full),
        .empty(fifo_empty)
    );

    ila_0 ila (
        .clk(clk_50mhz),
        .probe0(receive_done),
        .probe1(received_data),
        .probe2(parsed),
        .probe3(parse_write),
        .probe4(parse_line),
        .probe5(options_per_line),
        .probe6(m[0]),
        .probe7(n[0]),
        .probe8(stat),
        .probe9(fifo_write),
        .probe10(next_line),
        .probe11(solve_next),
        .probe12(solve_line),
        .probe13(solution[0]),
        .probe14(solve_write),
        .probe15(solved),
        .probe16(rst),
        .probe17(fifo_full),
        .probe18(fifo_empty),
        .probe19(btnc),
        .probe20(m[1]),
        .probe21(n[1]),
        .probe22(m[2]),
        .probe23(n[2])
    ); 

    solver sol (
        .clk(clk_50mhz),
        .rst(rst),
        .started(parsed),
        .option(fifo_out),
        .num_rows(m[1]),
        .num_cols(n[1]),
        .old_options_amnt(options_per_line),
        .all_options_remaining(options_per_line_cols), // Corrected assignment
        .new_line(solve_next),
        .new_option(solve_line),
        .assigned(solution[0]),  
        .known(knowns),
        .put_back_to_FIFO(solve_write),
        .solved(solved),
        .unsolvable(unsolvable) // Fix: properly handle unsolvable cases
    );

    assembler assemble (
        .clk(clk_50mhz),
        .rst(rst),
        .valid_in(solved),
        .transmit_done(transmit_done),
        .solution(solution[1]),
        .n(n[2]),
        .m(m[2]),

        .send(transmit_valid),
        .byte_out(transmit_data),
        .done(assembled)
    );

    logic [2:0] uart_tx_signal;
    uart_tx transmitter (
        .clk(clk_50mhz),
        .rst(rst),
        .axiiv(transmit_valid),
        .axiid(transmit_data),

        .axiod(tx),
        .done(transmit_done),
        .state(uart_tx_signal)
    );

    always_ff @(posedge clk_50mhz) begin
        if (rst) begin
            counter <= 0;
            state <= RECEIVE;
            display_value <= 0;
        end else begin
            if (receive_done) 
                display_value <= received_data;
            else if (transmit_done) 
                display_value <= transmit_data;
            
            solution[1] <= solution[0];
            n[1] <= n[0];       
            n[2] <= n[1];
            m[1] <= m[0];
            m[2] <= m[1];

            $display("State: %d, receive_done: %b, parsed: %b, fifo_empty: %b, fifo_full: %b, m[0]: %d, n[0]: %d",
                 state, receive_done, parsed, fifo_empty, fifo_full, m[0], n[0]);

            case(state)
                RECEIVE: state <= (parsed) ? SOLVE : RECEIVE;
                SOLVE: state <= (solved) ? TRANSMIT : SOLVE;
                TRANSMIT: state <= (assembled) ? RECEIVE : TRANSMIT;
            endcase
        end
    end

endmodule
