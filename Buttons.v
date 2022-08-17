`timescale 1ns / 1ps

module CALCULATOR (input clk, rst, add, subtract, divide, multiply, show, [3:0] buttons, output reg [6:0] bcd, reg dot, reg [3:0] sel);

wire syn1, syn2, syn3, syn4, deb1, deb2, deb3, deb4, Edge1, Edge2, Edge3, Edge4;
reg [3:0] Num1, Num2, Num3, Num4;
wire clk_div;
reg Neg, Error;

initial Neg = 0;
initial Error = 0;

clockDivider #(50000) M10 (clk, rst, clk_div);

synchronizer S1 (buttons[0], clk_div, rst, syn1);
Debouncer D1 (syn1, clk_div, rst, deb1);
RisingEdge R1 (clk_div, rst, deb1, Edge1);

synchronizer S2 (buttons[1], clk_div, rst, syn2);
Debouncer D2 (syn2, clk_div, rst, deb2);
RisingEdge R2 (clk_div, rst, deb2, Edge2);

synchronizer S3 (buttons[2], clk_div, rst, syn3);
Debouncer D3 (syn3, clk_div, rst, deb3);
RisingEdge R3 (clk_div, rst, deb3, Edge3);

synchronizer S4 (buttons[3], clk_div, rst, syn4);
Debouncer D4 (syn4, clk_div, rst, deb4);
RisingEdge R4 (clk_div, rst, deb4, Edge4);

always @(posedge(clk_div) or posedge (rst))
begin
    if (rst) begin    
        Num1 <= 0;
        Num2 <= 0;
        Num3 <= 0;
        Num4 <= 0;    
    end
else begin 
    if (Edge1) Num1 <= ( Num1 == 9)? 0 : Num1 + 1;
    else if (Edge2) Num2 <= ( Num2 == 9)? 0 : Num2 + 1;
    else if (Edge3) Num3 <= ( Num3 == 9)? 0 : Num3 + 1;
    else if (Edge4) Num4 <= ( Num4 == 9)? 0 : Num4 + 1;    
end
end

reg [1:0] count;
wire [6:0] num_dec1, num_dec2, num_dec3, num_dec4;

BCD M11 (Num1 , num_dec1);
BCD M12 (Num2 , num_dec2);
BCD M13 (Num3 , num_dec3);
BCD M14 (Num4 , num_dec4);

wire [6:0] N1, N2;

assign N2 = Num2*10 + Num1;
assign N1 = Num4*10 + Num3;

reg [13:0] Output;

initial Output = 0;

parameter [1:0] A=2'b10;

wire add_edge, subtract_edge, multiply_edge, divide_edge;

RisingEdge R11 (clk_div, rst, add, add_edge);
RisingEdge R12 (clk_div, rst, subtract, subtract_edge);
RisingEdge R13 (clk_div, rst, multiply, multiply_edge);
RisingEdge R14 (clk_div, rst, divide, divide_edge);

always @(posedge(clk_div) or posedge (rst))
begin
    if (rst) Output <= 0;
    else begin
        if (add_edge)
        begin
        Output <= N1 + N2;
        Neg = 0; Error <= 0;
        end
        else if (subtract_edge)
        begin 
            if ( N1 >= N2) begin Output <= N1 - N2; Neg = 0; Error <= 0; end
            else begin Output <= N2 - N1; Neg <= 1; Error <= 0; end
        end
        else if (divide_edge) 
        begin 
            if (N2 == 0) begin Error = 1; Neg <= 0; end
            else begin Output <= (A*N1+N2)/(A*N2); Error <= 0; Neg <=0; end
        end
        else if (multiply_edge == 1)
        begin Output <= N1* N2; Error <= 0; Neg <=0; end
        else begin Output <= Output; Error <= Error; Neg <=Neg; end
      end
end

wire [3:0] O1, O2, O3, O4;

assign O4 = Error ? 11: Output % 10;
assign O3 = Error ? 11:(Output / 10) % 10;
assign O2 = Error ? 11: Neg ? 10 : (Output / 100) % 10;
assign O1 = Error ? 11: Neg ? 12 : (Output / 1000);


wire [6:0] O1_D, O2_D,O3_D, O4_D;

BCD EN1 (O1, O1_D);
BCD EN2 (O2, O2_D);
BCD EN3 (O3, O3_D);
BCD EN4 (O4, O4_D);

always @(posedge (clk_div) or posedge (rst))
begin
    if (rst) begin 
    bcd <= 7'b0000001;
    sel <= 4'b0000;
    count <= 0;
    end
    else begin
      count <= count +1;      
    if (!show) begin
        if ( count == 0 )
         begin    
         sel <= 4'b1110;
         bcd <= num_dec1;
         dot <= 1;
         end
        if ( count == 1 )
          begin    
          sel <= 4'b1101;
          bcd <= num_dec2;
          dot <= 1;
          end
        if ( count == 2 )
            begin    
            sel <= 4'b1011;
            bcd <= num_dec3;
            dot <= 0;
            end
        if ( count == 3 )
          begin    
          sel <= 4'b0111;
          bcd <= num_dec4;
          dot <= 1;
          end  
  end
  else if (show) begin
      if ( count == 0 )    
       begin    
       sel <= 4'b1110;
       bcd <= O4_D;
       dot <= 1;
       end
      if ( count == 1 )
        begin    
        sel <= 4'b1101;
        bcd <= O3_D;
        dot <= 1;
        end
      if ( count == 2 )
          begin    
          sel <= 4'b1011;
          bcd <= O2_D;
          dot <= 1;
          end
      if ( count == 3 )
        begin    
        sel <= 4'b0111;
        bcd <= O1_D;
        dot <= 1;
        end  
  end 
  end                         
end

endmodule