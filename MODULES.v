`timescale 1ns / 1ps

module synchronizer (input signal, clk, rst, output reg newsig);
reg Q;
always@(posedge(clk), posedge(rst))
begin
    if (rst) Q <= 0;
    else begin
        Q <= signal;
        newsig <= Q;
    end
    end
endmodule

module Debouncer (input button, clk, rst, output reg sig);

reg Q1, Q2, Q3;
always@(posedge(clk), posedge(rst))
begin
    if (rst) Q1 <= 0;
    else begin
    Q1 <= button;
    Q2 <= Q1;
    Q3 <= Q2;
    end
sig <= Q1 & Q2 &3;

end
endmodule

module BCD (bcd, seg);
input [3:0] bcd;
output reg[6:0] seg;
always @(bcd)
begin
    case (bcd) 
        0 : seg = 7'b0000001;
        1 : seg = 7'b1001111;
        2 : seg = 7'b0010010;
        3 : seg = 7'b0000110;
        4 : seg = 7'b1001100;
        5 : seg = 7'b0100100;
        6 : seg = 7'b0100000;
        7 : seg = 7'b0001111;
        8 : seg = 7'b0000000;
        9 : seg = 7'b0000100;
        10: seg = 7'b1111110;
        11: seg = 7'b0110000;
        12: seg = 7'b1111111;
    endcase
end  
endmodule


module  clockDivider #(parameter n = 5000000) (input clk, rst, output reg clk_out);
reg [31:0] count; 
always @ (posedge(clk), posedge(rst)) begin

    if (rst == 1'b1)
        count <= 32'b0;
    else if (count == n-1)
        count <= 32'b0;
    else
        count <= count +1;
end
always @ (posedge(clk)) begin 

     if (count == n-1)
         clk_out <= ~clk_out;
    else
         clk_out <= clk_out;

end
endmodule


module RisingEdge (input clk, rst, button, output out);
reg [1:0] state, nextState;
parameter [1:0] A=2'b00, B=2'b01, C=2'b10; 
always @ (button or state)
    case (state)
    A: if (button) nextState = B;
     else nextState = A;
    B: if (button) nextState = C;
     else nextState = A;
    C: if (button) nextState = C;
     else nextState = A;
endcase

always @ (posedge clk, posedge(rst)) begin
    if (rst)
    state <= A;
    else
    state <= nextState;
end
assign out = (state == B);
endmodule