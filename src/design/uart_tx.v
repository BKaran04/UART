`timescale 1ns/1ps
module uart_tx #(parameter WORD_LEN=8)
(
input wire sys_rst_l,
input wire xmitH,
input wire [WORD_LEN-1:0] xmit_dataH,
input wire uart_clk,
output reg uart_XMIT_dataH,
output reg xmit_doneH,
output reg xmit_active
);
reg [WORD_LEN-1:0] tx_shift_reg;
reg [($clog2(WORD_LEN)-1):0] tx_bit_counter;
reg [3:0] tx_baud_counter;
localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;
reg [1:0] tx_state;
always @(posedge uart_clk or negedge sys_rst_l)
begin
if(!sys_rst_l)
begin
    uart_XMIT_dataH <= 1'b1;
    xmit_doneH <= 1'b0;
    xmit_active <= 1'b0;
    tx_baud_counter <= 0;
    tx_shift_reg <= 0;
    tx_bit_counter <= 0;
    tx_state <= IDLE;
end
else
begin
    xmit_doneH <= 1'b0;
    case(tx_state)
    IDLE:
    begin
        uart_XMIT_dataH <= 1'b1;
        xmit_active <= 1'b0;
        if(xmitH)
        begin
            tx_shift_reg <= xmit_dataH;
            tx_bit_counter <= 0;
            tx_baud_counter <= 0;
            xmit_active <= 1'b1;
            tx_state <= START;
        end
    end
    START:
    begin
        uart_XMIT_dataH <= 1'b0;
        tx_baud_counter <= tx_baud_counter + 1;
        if(tx_baud_counter == 4'd15)
        begin
            tx_baud_counter <= 0;
            tx_state <= DATA;
        end
    end
    DATA:
    begin
        uart_XMIT_dataH <= tx_shift_reg[0];
        tx_baud_counter <= tx_baud_counter + 1;
        if(tx_baud_counter == 4'd15)
        begin
            tx_baud_counter <= 0;
            tx_shift_reg <= tx_shift_reg >> 1;
            if(tx_bit_counter == WORD_LEN-1)
            begin
                tx_bit_counter <= 0;
                tx_state <= STOP;
            end
            else
            begin
                tx_bit_counter <= tx_bit_counter + 1;
            end
        end
    end
    STOP:
    begin
        uart_XMIT_dataH <= 1'b1;
        tx_baud_counter <= tx_baud_counter + 1;
        if(tx_baud_counter == 4'd15)
        begin
            tx_baud_counter <= 0;
            xmit_doneH <= 1'b1;
            xmit_active <= 1'b0;
            tx_state <= IDLE;
        end
    end
    endcase
end
end
endmodule
