`timescale 1ns/1ps
module uart_top #(parameter WORD_LEN  = 8,
                  parameter XTAL_CLK  = 50_000_000,
                  parameter baud_rate = 2400)
(input                  sys_clk,
input                 sys_rst_l,
input                  xmitH,
input  [WORD_LEN-1:0]  xmit_data,

output                 uart_clk,
output                 uart_XMIT_dataH,
output                 xmit_doneH,
output                 xmit_active,
output [WORD_LEN-1:0]  rec_dataH,
output                 rec_readyH,
output                 rec_busy);

// ============================================================
// DUT : Baud Generator
// ============================================================
uart_baud #(
    .XTAL_CLK (XTAL_CLK),
    .baud_rate (baud_rate)
) BAUD_GEN (
    .sys_clk  (sys_clk),
    .sys_rst_l(sys_rst_l),
    .uart_clk (uart_clk)
);

// ============================================================
// DUT : UART Transmitter
// ============================================================
uart_tx #(
    .WORD_LEN(WORD_LEN)
) TX (
    .sys_rst_l      (sys_rst_l),
    .xmitH          (xmitH),
    .xmit_data      (xmit_data),
    .uart_clk       (uart_clk),
    .uart_XMIT_dataH(uart_XMIT_dataH),
    .xmit_doneH     (xmit_doneH),
    .xmit_active    (xmit_active)
);

// ============================================================
// DUT : UART Receiver
// uart_REC_dataH directly connected to uart_XMIT_dataH
// 8-tick delay pipeline is inside uart_rx
// ============================================================
uart_rx #(
    .WORD_LEN(WORD_LEN)
) RX (
    .sys_rst_l      (sys_rst_l),
    .uart_clk       (uart_clk),
    .uart_REC_dataH (uart_XMIT_dataH),
    .rec_dataH      (rec_dataH),
    .rec_readyH     (rec_readyH),
    .rec_busy       (rec_busy)
);

endmodule
