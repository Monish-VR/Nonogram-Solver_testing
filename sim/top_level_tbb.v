` timescale 1ns/1ps
module top_level_tbb;
    
    logic clk_100mhz;
    logic btnc;
    logic rx;
    logic tx;
    logic [7:0] bits;
    logic [2:0] stat;
    
    // Clock generation
    always #5 clk_100mhz = ~clk_100mhz; // 100MHz clock
    
    // Instantiate DUT (Device Under Test)
    top_level dut (
        .clk_100mhz(clk_100mhz),
        .btnc(btnc),
        .rx(rx),
        .tx(tx),
        .bits(bits),
        .stat(stat)
    );
    
    // Testbench process
    initial begin
        // Initialize signals
        clk_100mhz = 0;
        btnc = 1;
        rx = 1; // UART idle state
        
        // Apply reset
        #20 btnc = 1;
        #50 btnc = 0;
        
        // Simulate UART reception (send 0xA5 byte)
        send_uart_byte(8'hA5);
        
        // Wait for processing
        #500000;
        
        // Simulate another byte reception
        send_uart_byte(8'h3C);
        
        // Observe results
        #1000000;
        
        // End simulation
        $finish;
    end
    
    // Task to send a byte via UART
    task send_uart_byte(input [7:0] data);
        integer i;
        
        // Start bit
        rx = 0;
        #104166; // Wait one baud period (assuming 9600 baud at 100MHz)
        
        // Data bits (LSB first)
        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];
            $monitor("Time1=%0t rx1=%b bits1=%h stat1=%b", $time, rx, bits, stat);
            #104166;
        end
        
        // Stop bit
        rx = 1;
        #104166;
    endtask
    


    // Monitor
    initial begin
        $monitor("Time2=%0t rx2=%b bits2=%h stat2=%b", $time, rx, bits, stat);
    end

endmodule
