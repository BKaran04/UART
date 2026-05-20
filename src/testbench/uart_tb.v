`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2026 12:21:42 PM
// Design Name: 
// Module Name: uart_tx_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for Micro-UART (uart_baud + uart_tx + uart_rx)
//              Simple loopback: uart_XMIT_dataH -> uart_REC_dataH
//              8-tick delay pipeline is inside uart_rx design
//              Timing diagram sequence: 0xAA -> 0x55 -> 0xFF
// 
// Dependencies: uart_baud.v, uart_tx.v, uart_rx.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module uart_tb;

// ============================================================
// Parameters
// ============================================================
parameter WORD_LEN  = 8;
parameter XTAL_CLK  = 50_000_000;
parameter baud_rate = 2400;

// ============================================================
// Signals
// ============================================================
reg                  sys_clk;
reg                  sys_rst_l;
reg                  xmitH;
reg  [WORD_LEN-1:0]  xmit_data;

wire                 uart_clk;
wire                 uart_XMIT_dataH;
wire                 xmit_doneH;
wire                 xmit_active;
wire [WORD_LEN-1:0]  rec_dataH;
wire                 rec_readyH;
wire                 rec_busy;

uart_top #(.WORD_LEN(WORD_LEN),
           .XTAL_CLK(XTAL_CLK),
           .baud_rate(baud_rate))
UART_TOP (.sys_clk(sys_clk),.sys_rst_l(sys_rst_l),.xmitH(xmitH),.xmit_data(xmit_data),
          .uart_clk(uart_clk),.uart_XMIT_dataH(uart_XMIT_dataH),.xmit_doneH(xmit_doneH),
          .xmit_active(xmit_active),.rec_dataH(rec_dataH),.rec_readyH(rec_readyH),.rec_busy(rec_busy));

// ============================================================
// Test Sequence
// ============================================================
initial
begin
    sys_clk = 0;
    forever #10 sys_clk = ~sys_clk;
end
initial
begin
    //----------------------------------------------------
    // Initial values
    //----------------------------------------------------
    sys_rst_l  = 0;
    xmitH      = 0;
    xmit_data  = 8'h00;

    //----------------------------------------------------
    // Apply reset
    //----------------------------------------------------
    #200;
    sys_rst_l = 1;

    //----------------------------------------------------
    // Wait for system to stabilise
    //----------------------------------------------------
    #1000;

    //----------------------------------------------------
    // Transmission 1 : 0xAA
    //----------------------------------------------------
    /*@(posedge uart_clk);
    xmit_data = 8'h50;
    xmitH     = 1'b1;
    @(posedge uart_clk);
    xmitH     = 1'b0;

    wait(rec_readyH);
    $display("TIME=%0t | Received Data 1 = 0x%02h (expected 0xAA)", $time, rec_dataH);

    //----------------------------------------------------
    // Transmission 2 : 0x55
    //----------------------------------------------------
    @(posedge uart_clk);
    xmit_data = 8'h98;
    xmitH     = 1'b1;
    @(posedge uart_clk);
    xmitH     = 1'b0;

    wait(rec_readyH);
    $display("TIME=%0t | Received Data 2 = 0x%02h (expected 0x55)", $time, rec_dataH);

    //----------------------------------------------------
    // Transmission 3 : 0xFF
    //----------------------------------------------------
    @(posedge uart_clk);
    xmit_data = 8'h90;
    xmitH     = 1'b1;
    @(posedge uart_clk);
    xmitH     = 1'b0;

    wait(rec_readyH);
    $display("TIME=%0t | Received Data 3 = 0x%02h (expected 0xFF)", $time, rec_dataH);*/
    
    @(posedge uart_clk);
    xmit_data = 8'hA5;
    xmitH     = 1'b1;
    @(posedge uart_clk);
    xmitH     = 1'b0;

    wait(rec_readyH);
    $display("TIME=%0t | Received Data 3 = 0x%02h (expected 0xFF)", $time, rec_dataH);

    //----------------------------------------------------
    // Wait then finish
    //----------------------------------------------------
    #1000000;
    $finish;
end

// ============================================================
// Monitor
// ============================================================
initial
begin
    $monitor("TIME=%0t | TX=%b | TX_DONE=%b | TX_ACTIVE=%b | RX_READY=%b | RX_DATA=0x%02h | RX_BUSY=%b",
              $time,
              uart_XMIT_dataH,
              xmit_doneH,
              xmit_active,
              rec_readyH,
              rec_dataH,
              rec_busy);
end

endmodule
