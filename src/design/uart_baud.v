`timescale 1ns / 1ps
module uart_baud #(
    parameter XTAL_CLK  = 50_000_000,
    parameter baud_rate = 2400
)(
    input      sys_clk,
    input      sys_rst_l,
    output reg uart_clk
);

localparam integer CLK_DIV = XTAL_CLK / (baud_rate * 16 * 2);
localparam integer CW      = $clog2(CLK_DIV);

reg [CW-1:0] counter;

always @(posedge sys_clk or negedge sys_rst_l)
begin
    if(!sys_rst_l)
    begin
        uart_clk <= 0;
        counter  <= 0;
    end
    else if(counter == CLK_DIV - 1)
    begin
        counter  <= 0;
        uart_clk <= ~uart_clk;
    end
    else
    begin
        counter <= counter + 1;
    end
end

endmodule
