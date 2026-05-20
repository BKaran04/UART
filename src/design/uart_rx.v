`timescale 1ns / 1ps
module uart_rx #(
    parameter WORD_LEN = 8
)(
    input                     sys_rst_l,
    input                     uart_clk,
    input                     uart_REC_dataH,
    output reg [WORD_LEN-1:0] rec_dataH,
    output reg                rec_readyH,
    output reg                rec_busy
);

reg [WORD_LEN-1:0]           rx_shift_reg;
reg [($clog2(WORD_LEN)-1):0] rx_bit_counter;
reg [3:0]                    rx_baud_counter;

reg [7:0] delay_pipe;

always @(posedge uart_clk or negedge sys_rst_l)
begin
    if(!sys_rst_l)
        delay_pipe <= 8'hFF;
    else
        delay_pipe <= {uart_REC_dataH, delay_pipe[5:1]};
end

reg uart_REC_dataH_sync;

always @(posedge uart_clk or negedge sys_rst_l)
begin
    if(!sys_rst_l)
    begin
        uart_REC_dataH_sync  <= 1'b1;
    end
    else
    begin
        uart_REC_dataH_sync <= delay_pipe[0];
    end
end

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] rx_state;

always @(posedge uart_clk or negedge sys_rst_l)
begin
    if(!sys_rst_l)
    begin
        rec_dataH       <= 0;
        rec_readyH      <= 1'b0;
        rec_busy        <= 1'b0;
        rx_baud_counter <= 0;
        rx_shift_reg    <= 0;
        rx_bit_counter  <= 0;
        rx_state        <= IDLE;
    end
    else
    begin
        rec_readyH <= 1'b0;
        case(rx_state)
        IDLE:
        begin
            rec_busy <= 1'b0;
            if(uart_REC_dataH_sync == 1'b0)
            begin
                rx_baud_counter <= 0;
                rx_bit_counter  <= 0;
                rec_busy        <= 1'b1;
                rx_state        <= START;
            end
        end

        START:
        begin
            rx_baud_counter <= rx_baud_counter + 1;
            if(rx_baud_counter == 4'd7)
            begin
                if(uart_REC_dataH_sync == 1'b0)
                begin
                    rx_baud_counter <= 0;
                    rx_state        <= DATA;
                end
                else
                begin
                    rec_busy <= 1'b0;
                    rx_state <= IDLE;
                end
            end
        end

        DATA:
        begin
            rx_baud_counter <= rx_baud_counter + 1;
            if(rx_baud_counter == 4'd7)
            begin
                rx_shift_reg <= {uart_REC_dataH_sync, rx_shift_reg[WORD_LEN-1:1]};
                rec_dataH    <= {uart_REC_dataH_sync, rx_shift_reg[WORD_LEN-1:1]};
            end
            if(rx_baud_counter == 4'd15)
            begin
                rx_baud_counter <= 0;
                if(rx_bit_counter == WORD_LEN - 1)
                begin
                    rx_bit_counter <= 0;
                    rx_state       <= STOP;
                end
                else
                begin
                    rx_bit_counter <= rx_bit_counter + 1;
                end
            end
        end
        STOP:
        begin
            rx_baud_counter <= rx_baud_counter + 1;
            if(rx_baud_counter == 4'd15)
            begin
                rx_baud_counter <= 0;
                rec_busy        <= 1'b0;
                if(uart_REC_dataH_sync == 1'b1)
                begin
                    rec_readyH <= 1'b1;
                end
                else
                begin
                    rec_dataH <= 0;
                end
                rx_state <= IDLE;
            end
        end
        endcase
    end
end

endmodule
