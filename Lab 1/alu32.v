`timescale 1ns / 1ps

/**
    This program creates an ALU that uses a look-ahead carry adder structure rather than ripple-carry (parallel) adder.
**/

module alu32 (d, Cout, V, a, b, Cin, S);
   output[31:0] d;
   output Cout, V;
   input [31:0] a, b;
   input Cin;
   input [2:0] S;
   
   wire [31:0] c, g, p;
   wire gout, pout;
   
   //Instantiating the ALU cell
   alu_cell mycell[31:0] (
      .d(d),
      .g(g),
      .p(p),
      .a(a),
      .b(b),
      .c(c),
      .S(S)
   );
   
   //Instantiating the LAC
   lac5 lac(
      .c(c),
      .gout(gout),
      .pout(pout),
      .Cin(Cin),
      .g(g),
      .p(p)
   );

   //Instantiating the overflow detector
   overflow ov(
      .Cout(Cout),
      .V(V),
      .g(gout),
      .p(pout),
      .c31(c[31]),
      .Cin(Cin)
   );   
  
endmodule


module alu_cell (d, g, p, a, b, c, S);
   output d, g, p;
   input a, b, c;
   input [2:0] S;      
   reg g,p,d,cint,bint;
     
   always @(a,b,c,S,p,g) begin 
     bint = S[0] ^ b;
     g = a & bint; //getting the generator bit
     p = a ^ bint; //getting the propogator bit
     cint = S[1] & c; //getting the carry in bit
    
      if(S[2]==0)
         begin
             d = p ^ cint; //handles XOR, XNOR, addition and subtraction
         end
         
      else if(S[2]==1)
          begin
             if((S[1]==0) & (S[0]==0)) begin
                d = a | b; //handles A OR B
                end
             else if ((S[1]==0) & (S[0]==1)) begin
                d = ~(a | b); //handles A NOR B
                end
             else if ((S[1]==1) & (S[0]==0)) begin
                d = a & b; //handles A AND B
                end   
             else
                d = 0;
                end
       end             
endmodule


module overflow (Cout, V, g, p, c31, Cin);
   output Cout, V;
   input g, p, c31, Cin;
   
   assign Cout = g|(p&Cin); //gets the Carry out bit based on the generator and propogator bit
   assign V = Cout^c31; //finds out whether or not the overflow bit is set high
endmodule

//creates the root for the LAC tree
module lac(c, gout, pout, Cin, g, p);

   output [1:0] c;
   output gout;
   output pout;
   input Cin;
   input [1:0] g;
   input [1:0] p;

   assign c[0] = Cin;
   assign c[1] = g[0] | ( p[0] & Cin );
   assign gout = g[1] | ( p[1] & g[0] );
   assign pout = p[1] & p[0];
	
endmodule

//creates the first tree for the LAC
module lac2 (c, gout, pout, Cin, g, p);
   output [3:0] c;
   output gout, pout;
   input Cin;
   input [3:0] g, p;
   
   wire [1:0] cint, gint, pint;
   
   lac leaf0(
      .c(c[1:0]),
      .gout(gint[0]),
      .pout(pint[0]),
      .Cin(cint[0]),
      .g(g[1:0]),
      .p(p[1:0])
   );
   
   lac leaf1(
      .c(c[3:2]),
      .gout(gint[1]),
      .pout(pint[1]),
      .Cin(cint[1]),
      .g(g[3:2]),
      .p(p[3:2])
   );
   
   lac root(
      .c(cint),
      .gout(gout),
      .pout(pout),
      .Cin(Cin),
      .g(gint),
      .p(pint)
   );
endmodule   

//creates the next row of the tree for the LAC
module lac3 (c, gout, pout, Cin, g, p);
   output [7:0] c;
   output gout, pout;
   input Cin;
   input [7:0] g, p;
   
   wire [1:0] cint, gint, pint;
   
   lac2 leaf0(
      .c(c[3:0]),
      .gout(gint[0]),
      .pout(pint[0]),
      .Cin(cint[0]),
      .g(g[3:0]),
      .p(p[3:0])
   );
   
   lac2 leaf1(
      .c(c[7:4]),
      .gout(gint[1]),
      .pout(pint[1]),
      .Cin(cint[1]),
      .g(g[7:4]),
      .p(p[7:4])
   );
   
   lac root(
      .c(cint),
      .gout(gout),
      .pout(pout),
      .Cin(Cin),
      .g(gint),
      .p(pint)
   );
endmodule
      
//creates the 4th row of the LAC tree
module lac4 (c, gout, pout, Cin, g, p);
   output [15:0] c;
   output gout, pout;
   input Cin;
   input [15:0] g, p;
   
   wire [1:0] cint, gint, pint;
   
   lac3 leaf0(
       .c(c[7:0]),
       .gout(gint[0]),
       .pout(pint[0]),
       .Cin(cint[0]),
       .g(g[7:0]),
       .p(p[7:0])
   );
   
   lac3 leaf1(
       .c(c[15:8]),
       .gout(gint[1]),
       .pout(pint[1]),
       .Cin(cint[1]),
       .g(g[15:8]),
       .p(p[15:8])
   );
   
   lac root(
      .c(cint),
      .gout(gout),
      .pout(pout),
      .Cin(Cin),
      .g(gint),
      .p(pint)
   );
endmodule
      
//puts everything together for the LAC tree
module lac5 (c, gout, pout, Cin, g, p);
   output [31:0] c;
   output gout, pout;
   input Cin;
   input [31:0] g, p;
   
   wire [1:0] cint, gint, pint;
   
   lac4 leaf0(
       .c(c[15:0]),
       .gout(gint[0]),
       .pout(pint[0]),
       .Cin(cint[0]),
       .g(g[15:0]),
       .p(p[15:0])
   );
   
   lac4 leaf1(
       .c(c[31:16]),
       .gout(gint[1]),
       .pout(pint[1]),
       .Cin(cint[1]),
       .g(g[31:16]),
       .p(p[31:16])
   );
   
   lac root(
      .c(cint),
      .gout(gout),
      .pout(pout),
      .Cin(Cin),
      .g(gint),
      .p(pint)
   );
endmodule
      
