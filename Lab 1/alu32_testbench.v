`timescale 1ns/10ps     // THIS DEFINES A UNIT TIME FOR THE TEST BENCH AND ITS PRECISION //
module alu32_testbench();

reg [31:0] a, b;       // DECLARING I/O PORTS AND ALSO INTERNAL WIRES //
wire [31:0] d;
reg [2:0] S, Stm[0:81];
reg Cin;
reg [31:0] dontcare, str[0:81], ref[0:81], stma[0:81], stmb[0:81];
reg Vstr[0:81], Vref[0:81], Coutstm[0:81], Coutstr[0:81], Coutref[0:81], Cinstm[0:81];

integer ntests, error, k, i;  // VARIABLES NOT RELATED TO ALU I/O , BUT REQUIRED FOR TESTBENCH //

alu32 dut(.a(a), .b(b), .d(d), .Cin(Cin), .Cout(Cout), .V(V), .S(S));  // DECLARES THE MODULE BEING TESTED ALONG WITH ITS I/O PORTS //

   
   //////////////////////////////////////////  			 //////////////////////////////////////////
  ///////// EXPECTED VALUES ////////////////			//////////    INPUTS TO ALU      /////////
 //////////////////////////////////////////		       //////////////////////////////////////////
 

initial begin     //LOADING THE TEST REGISTERS WITH INPUTS AND EXPECTED VALUES//
// ------------------------------------------------------------ ORIGINAL TESTS ------------------------------------------------------------- //
ref[0] = 32'h00000000; Vref[0] = 0; Coutref[0] = 0;		Stm[0] = 3'b100; stma[0] = 32'h00000000; stmb[0] = 32'h00000000; Cinstm[0] = 0;      // Test or     //
ref[1] = 32'h00000000; Vref[1] = 0; Coutref[1] = 0;		Stm[1] = 3'b100; stma[1] = 32'h00000000; stmb[1] = 32'h00000000; Cinstm[1] = 0;
ref[2] = 32'hFFFFFFFF; Vref[2] = 0; Coutref[2] = 0;		Stm[2] = 3'b010; stma[2] = 32'hFFFFFFFF; stmb[2] = 32'h00000000; Cinstm[2] = 0;      // Test Carry  //
ref[3] = 32'h00000000; Vref[3] = 0; Coutref[3] = 1;     	Stm[3] = 3'b010; stma[3] = 32'hFFFFFFFF; stmb[3] = 32'h00000000; Cinstm[3] = 1;
ref[4] = 32'h7FFFFFFF; Vref[4] = 0; Coutref[4] = 0;     	Stm[4] = 3'b010; stma[4] = 32'h7FFFFFFF; stmb[4] = 32'h00000000; Cinstm[4] = 0;
ref[5] = 32'h80000000; Vref[5] = 1; Coutref[5] = 0;   		Stm[5] = 3'b010; stma[5] = 32'h7FFFFFFF; stmb[5] = 32'h00000000; Cinstm[5] = 1;
ref[6] = 32'h00100166; Vref[6] = 1'bx; Coutref[6] = 1'bx;	Stm[6] = 3'b000; stma[6] = 32'hF01010CA; stmb[6] = 32'hF00011AC; Cinstm[6] = 0;      //  Test xor   //
ref[7] = 32'h0EEF9997; Vref[7] = 1'bx; Coutref[7] = 1'bx;	Stm[7] = 3'b001; stma[7] = 32'hF101CBA9; stmb[7] = 32'h0011ADC1; Cinstm[7] = 0;      //  Test xnor  //
ref[8] = 32'h0000FFFF; Vref[8] = 1'bx; Coutref[8] = 1'bx;	Stm[8] = 3'b110; stma[8] = 32'hFFFFFFFF; stmb[8] = 32'h0000FFFF; Cinstm[8] = 0;      //  Test and   //
ref[9] = 32'hF111EFE9; Vref[9] = 1'bx; Coutref[9] = 1'bx;	Stm[9] = 3'b100; stma[9] = 32'hF101CBA9; stmb[9] = 32'h0011ADC1; Cinstm[9] = 0;      //  Test or    //
ref[10] = 32'h64424220;	Vref[10] = 1'bx; Coutref[10] = 1'bx;	Stm[10] = 3'b010; stma[10] = 32'h31312020; stmb[10] = 32'h33112200; Cinstm[10] = 0;  //  Test add   //
ref[11] = 32'h64424221;	Vref[11] = 1'bx; Coutref[11] = 1'bx;	Stm[11] = 3'b011; stma[11] = 32'h31312020; stmb[11] = 32'hCCEEDDFF; Cinstm[11] = 1;  //  Test sub   //
ref[12] = 32'h00000001;	Vref[12] = 1'bx; Coutref[12] = 1'bx;	Stm[12] = 3'b010; stma[12] = 32'h00000000; stmb[12] = 32'h00000000; Cinstm[12] = 1;  //  Test Carry //
ref[13] = 32'h0000000F;	Vref[13] = 1'bx; Coutref[13] = 1'bx;	Stm[13] = 3'b010; stma[13] = 32'h0000000F; stmb[13] = 32'h00000000; Cinstm[13] = 0;
ref[14] = 32'h00000010;	Vref[14] = 1'bx; Coutref[14] = 1'bx;	Stm[14] = 3'b010; stma[14] = 32'h0000000F; stmb[14] = 32'h00000000; Cinstm[14] = 1;
ref[15] = 32'h000000FF;	Vref[15] = 1'bx; Coutref[15] = 1'bx;	Stm[15] = 3'b010; stma[15] = 32'h000000FF; stmb[15] = 32'h00000000; Cinstm[15] = 0;
ref[16] = 32'h00000100;	Vref[16] = 1'bx; Coutref[16] = 1'bx;	Stm[16] = 3'b010; stma[16] = 32'h000000FF; stmb[16] = 32'h00000000; Cinstm[16] = 1;
ref[17] = 32'h00000FFF;	Vref[17] = 1'bx; Coutref[17] = 1'bx;	Stm[17] = 3'b010; stma[17] = 32'h00000FFF; stmb[17] = 32'h00000000; Cinstm[17] = 0;
ref[18] = 32'h00001000;	Vref[18] = 1'bx; Coutref[18] = 1'bx;	Stm[18] = 3'b010; stma[18] = 32'h00000FFF; stmb[18] = 32'h00000000; Cinstm[18] = 1;
ref[19] = 32'h0000FFFF;	Vref[19] = 1'bx; Coutref[19] = 1'bx;	Stm[19] = 3'b010; stma[19] = 32'h0000FFFF; stmb[19] = 32'h00000000; Cinstm[19] = 0;
ref[20] = 32'h00010000; Vref[20] = 1'bx; Coutref[20] = 1'bx;	Stm[20] = 3'b010; stma[20] = 32'h0000FFFF; stmb[20] = 32'h00000000; Cinstm[20] = 1;
ref[21] = 32'h000FFFFF; Vref[21] = 1'bx; Coutref[21] = 1'bx;	Stm[21] = 3'b010; stma[21] = 32'h000FFFFF; stmb[21] = 32'h00000000; Cinstm[21] = 0;
ref[22] = 32'h00100000;	Vref[22] = 1'bx; Coutref[22] = 1'bx;	Stm[22] = 3'b010; stma[22] = 32'h000FFFFF; stmb[22] = 32'h00000000; Cinstm[22] = 1;
ref[23] = 32'h00FFFFFF;	Vref[23] = 1'bx; Coutref[23] = 1'bx;	Stm[23] = 3'b010; stma[23] = 32'h00FFFFFF; stmb[23] = 32'h00000000; Cinstm[23] = 0;
ref[24] = 32'h01000000;	Vref[24] = 1'bx; Coutref[24] = 1'bx;	Stm[24] = 3'b010; stma[24] = 32'h00FFFFFF; stmb[24] = 32'h00000000; Cinstm[24] = 1;
ref[25] = 32'h0FFFFFFF;	Vref[25] = 1'bx; Coutref[25] = 1'bx;	Stm[25] = 3'b010; stma[25] = 32'h0FFFFFFF; stmb[25] = 32'h00000000; Cinstm[25] = 0;
ref[26] = 32'h10000000;	Vref[26] = 1'bx; Coutref[26] = 1'bx;	Stm[26] = 3'b010; stma[26] = 32'h0FFFFFFF; stmb[26] = 32'h00000000; Cinstm[26] = 1;
ref[27] = 32'h00000000; Vref[27] = 1'bx; Coutref[27] = 1'bx;	Stm[27] = 3'b101; stma[27] = 32'hFFFFFFFF; stmb[27] = 32'h0000FFFF; Cinstm[27] = 0;  //  Test nor  //
ref[28] = 32'hx; Vref[28] = 0; Coutref[28] = 0;			Stm[28] = 3'b010; stma[28] = 32'h00000000; stmb[28] = 32'h00000000; Cinstm[28] = 0;  //  Test Cout, V // 
ref[29] = 32'hx; Vref[29] = 0; Coutref[29] = 1;			Stm[29] = 3'b010; stma[29] = 32'hFFFFFFFF; stmb[29] = 32'hFFFFFFFF; Cinstm[29] = 0;
ref[30] = 32'hx; Vref[30] = 1; Coutref[30] = 1;			Stm[30] = 3'b010; stma[30] = 32'h80000000; stmb[30] = 32'h80000000; Cinstm[30] = 0;
ref[31] = 32'hx; Vref[31] = 1; Coutref[31] = 0;			Stm[31] = 3'b010; stma[31] = 32'h40000000; stmb[31] = 32'h40000000; Cinstm[31] = 0;
// ------------------------------------------------------------- ADDED TESTS ------------------------------------------------------------- //
//Testing OR more in depth
ref[32] = 32'hFFFFFFFF; Vref[32] = 0; Coutref[32] = 0;      Stm[32] = 3'b100; stma[32] = 32'h00000000; stmb[32] = 32'hFFFFFFFF; Cinstm[32] = 0; //testing 0 OR 1 is 1
ref[33] = 32'h11111111; Vref[33] = 0; Coutref[32] = 0;      Stm[33] = 3'b100; stma[33] = 32'h01010101; stmb[33] = 32'h10101010; Cinstm[33] = 0; //testing 1 OR 1 is 1
ref[34] = 32'h11111111; Vref[34] = 0; Coutref[32] = 0;      Stm[34] = 3'b100; stma[34] = 32'h01010101; stmb[34] = 32'h10101010; Cinstm[34] = 0; //testing 1 OR 1 is 1
ref[35] = 32'hFFFFFFFF; Vref[35] = 0; Coutref[35] = 0;      Stm[35] = 3'b100; stma[35] = 32'hFFFFFFFF; stmb[35] = 32'h00000000; Cinstm[35] = 0; //testing 1 OR 0 is 1

//Testing NOR more in depth
ref[36] = 32'hFFFFFFFF; Vref[36] = 1'bx; Coutref[36] = 1'bx;      Stm[36] = 3'b101; stma[36] = 32'h00000000; stmb[36] = 32'h00000000; Cinstm[36] = 0; //testing 0 NOR 0 is 1
ref[37] = 32'hEEEEEEEE; Vref[37] = 1'bx; Coutref[37] = 1'bx;      Stm[37] = 3'b101; stma[37] = 32'h10101010; stmb[37] = 32'h01010101; Cinstm[37] = 0; //testing both 1 NOR 0 is 0 and 0 NOR 1 is 0 and 0 NOR 0 is 1

//Testing add in more depth
ref[38] = 32'h11111111; Vref[38] = 1'b0; Coutref[38] = 1'b0;      Stm[38] = 3'b010; stma[38] = 32'h00000000; stmb[38] = 32'h11111111; Cinstm[38] = 0; //testing 0 + 1 is 1
ref[39] = 32'hx; Vref[39] = 1'b0; Coutref[39] = 1'b1;      Stm[39] = 3'b010; stma[39] = 32'hFFFFFFFF; stmb[39] = 32'h00000001; Cinstm[39] = 0; //testing 1 + 1 is 0, Cout is 1, OV is 0
ref[40] = 32'hx; Vref[40] = 1'b0; Coutref[40] = 1'b1;      Stm[40] = 3'b010; stma[40] = 32'hFFFFFFFF; stmb[40] = 32'h10000000; Cinstm[40] = 0; //testing 1 + 1 is 0, Cout is 1, OV is 0
ref[41] = 32'h13579BDF; Vref[41] = 1'b0; Coutref[41] = 1'b0;       Stm[41] = 3'b010; stma[41] = 32'h01234567; stmb[41] = 32'h12345678; Cinstm[41] = 0; //testing 1 + 1 is 0, Cout is 1, OV is 0
ref[42] = 32'hFFFFFFFF; Vref[42] = 1'b0; Coutref[42] = 1'b0;        Stm[42] = 3'b010; stma[42] = 32'hFFFFFFFF; stmb[42]=32'h00000000; Cinstm[42] = 0; //testing 1 + 0 is 1
ref[43] = 32'h00000000; Vref[43] = 1'b0; Coutref[43] = 1'b1;        Stm[43] = 3'b010; stma[43] = 32'hFFFFFFFF; stmb[43]=32'h00000000; Cinstm[43] = 1; //1 + 0 + 1 (Cin) is 0 with Carry out of 1
ref[44] = 32'h00000001; Vref[44] = 1'b0; Coutref[44] = 1'b1;        Stm[44] = 3'b010; stma[44] = 32'hFFFFFFFF; stmb[44]=32'h00000001; Cinstm[44] = 1; //1 + 1 + 1 (cin) is 1 with Cout of 1 
ref[45] = 32'hx; Vref[45] = 1'b1; Coutref[45] = 1'b0;        Stm[45] = 3'b010; stma[45] = 32'h40000000; stmb[45]=32'h40000000; Cinstm[45] = 1; //testing overflow with carry ins
ref[46] = 32'hx; Vref[46] = 1'b1; Coutref[46] = 1'b1;        Stm[46] = 3'b010; stma[46] = 32'h80000000; stmb[46]=32'h80000000; Cinstm[46] = 1;

//Testing Subtract in more depth
ref[47] = 32'hFFFFFFFF; Vref[47] = 1'b0; Coutref[47] = 1'b0;        Stm[47] = 3'b011; stma[47] = 32'h00000001; stmb[47]=32'h00000001; Cinstm[47] = 0; //testing 1 - 1 = 0
ref[48] = 32'h00000001; Vref[48] = 1'b0; Coutref[48] = 1'b1;        Stm[48] = 3'b011; stma[48] = 32'h00000001; stmb[48]=32'h00000000; Cinstm[48] = 1; //testing 1 - 0 - 1  (cin) = 0
ref[49] = 32'h00000000; Vref[49] = 1'b0; Coutref[49] = 1'b1;        Stm[49] = 3'b011; stma[49] = 32'h00000001; stmb[49]=32'h00000001; Cinstm[49] = 1; //testing 1 - 1 - 1 (cin) = 0, cout = 1
ref[50] = 32'hFFFFFFFE; Vref[50] = 1'b0; Coutref[50] = 1'b0;        Stm[50] = 3'b011; stma[50] = 32'h0FFFFFFF; stmb[50]=32'h10000000; Cinstm[50] = 0; //testing big pos number minus big neg number does not give overflow 
ref[51] = 32'hFDCBA987; Vref[51] = 1'b0; Coutref[51] = 1'b0;        Stm[51] = 3'b011; stma[51] = 32'h10000000; stmb[51]=32'h12345678; Cinstm[51] = 0; //testing subtraction in more depth
ref[52] = 32'hx; Vref[52] = 1'b0; Coutref[52] = 1'b1;        Stm[52] = 3'b011; stma[52] = 32'h10000000; stmb[52]=32'h0FFFFFFF; Cinstm[52] = 0; //testing carry out for subtraction

//Testing XOR in more depth
ref[53] = 32'h11000000; Vref[53] = 1'bx; Coutref[53] = 1'bx;        Stm[53] = 3'b000; stma[53] = 32'h10000000; stmb[53]=32'h01000000; Cinstm[53] = 0; //testing 1 XOR 0 is 1
ref[54] = 32'h00000000; Vref[54] = 1'bx; Coutref[54] = 1'bx;        Stm[54] = 3'b000; stma[54] = 32'h11111111; stmb[54]=32'h11111111; Cinstm[54] = 0; //testing 1 XOR 1 is 0
ref[55] = 32'h00000000; Vref[55] = 1'bx; Coutref[55] = 1'bx;        Stm[55] = 3'b000; stma[55] = 32'h00000000; stmb[55]=32'h00000000; Cinstm[55] = 0; //testing 0 XOR 0 is 0
ref[56] = 32'h11111111; Vref[56] = 1'bx; Coutref[56] = 1'bx;        Stm[56] = 3'b000; stma[56] = 32'h10101010; stmb[56]=32'h01010101; Cinstm[56] = 0; //testing 0 XOR 1 is 1 & 1 XOR 0 is 1
ref[57] = 32'h95511559; Vref[57] = 1'bx; Coutref[57] = 1'bx;        Stm[57] = 3'b000; stma[57] = 32'h12345678; stmb[57]=32'h87654321; Cinstm[57] = 0; //testing XOR in more depth
ref[58] = 32'h10000001; Vref[58] = 1'bx; Coutref[58] = 1'bx;        Stm[58] = 3'b000; stma[58] = 32'h00000001; stmb[58]=32'h10000000; Cinstm[58] = 0; //testing XOR in more depth
ref[59] = 32'h11010110; Vref[59] = 1'bx; Coutref[59] = 1'bx;        Stm[59] = 3'b000; stma[59] = 32'h11111100; stmb[59]=32'h00101010; Cinstm[59] = 0; //testing XOR in more depth

//Testing XNOR in more depth
ref[60] = 32'hEEFFFFFF; Vref[60] = 1'bx; Coutref[60] = 1'bx;        Stm[60] = 3'b001; stma[60] = 32'h10000000; stmb[60]=32'h01000000; Cinstm[60] = 0; //testing 1 XNOR 0 is 0
ref[61] = 32'hFFFFFFFF; Vref[61] = 1'bx; Coutref[61] = 1'bx;        Stm[61] = 3'b001; stma[61] = 32'h11111111; stmb[61]=32'h11111111; Cinstm[61] = 0; //testing 1 XNOR 1 is 1
ref[62] = 32'hFFFFFFFF; Vref[62] = 1'bx; Coutref[62] = 1'bx;        Stm[62] = 3'b001; stma[62] = 32'h00000000; stmb[62]=32'h00000000; Cinstm[62] = 0; //testing 0 XNOR 0 is 1
ref[63] = 32'hEEEEEEEE; Vref[63] = 1'bx; Coutref[63] = 1'bx;        Stm[63] = 3'b001; stma[63] = 32'h10101010; stmb[63]=32'h01010101; Cinstm[63] = 0; //testing 0 XNOR 1 is 0 & 1 XNOR 0 is 0
ref[64] = 32'h6AAEEAA6; Vref[64] = 1'bx; Coutref[64] = 1'bx;        Stm[64] = 3'b001; stma[64] = 32'h12345678; stmb[64]=32'h87654321; Cinstm[64] = 0; //testing XNOR in more depth
ref[65] = 32'hEFFFFFFE; Vref[65] = 1'bx; Coutref[65] = 1'bx;        Stm[65] = 3'b001; stma[65] = 32'h00000001; stmb[65]=32'h10000000; Cinstm[65] = 0; //testing XNOR in more depth
ref[66] = 32'hEEFEFEEF; Vref[66] = 1'bx; Coutref[66] = 1'bx;        Stm[66] = 3'b001; stma[66] = 32'h11111100; stmb[66]=32'h00101010; Cinstm[66] = 0; //testing XNOR in more depth

//Testing AND in more depth
ref[67] = 32'h11111111; Vref[67] = 1'bx; Coutref[67] = 1'bx;        Stm[67] = 3'b110; stma[67] = 32'h11111111; stmb[67]=32'h11111111; Cinstm[67] = 0; //testing 1 AND 1 is 1
ref[68] = 32'h00000000; Vref[68] = 1'bx; Coutref[68] = 1'bx;        Stm[68] = 3'b110; stma[68] = 32'h11111111; stmb[68]=32'h00000000; Cinstm[68] = 0; //testing 1 AND 0 is 0
ref[69] = 32'h00000000; Vref[69] = 1'bx; Coutref[69] = 1'bx;        Stm[69] = 3'b110; stma[69] = 32'h00000000; stmb[69]=32'h11111111; Cinstm[69] = 0; //testing 0 AND 1 is 0
ref[70] = 32'h00000000; Vref[70] = 1'bx; Coutref[70] = 1'bx;        Stm[70] = 3'b110; stma[70] = 32'h00000000; stmb[70]=32'h00000000; Cinstm[70] = 0; //testing 0 AND 0 is 0
ref[71] = 32'h00101000; Vref[71] = 1'bx; Coutref[71] = 1'bx;        Stm[71] = 3'b110; stma[71] = 32'h11111100; stmb[71]=32'h00101010; Cinstm[71] = 0; //testing AND in more depth
ref[72] = 32'h11000000; Vref[72] = 1'bx; Coutref[72] = 1'bx;        Stm[72] = 3'b110; stma[72] = 32'h11111110; stmb[72]=32'h11000000; Cinstm[72] = 0; //testing AND in more depth
ref[73] = 32'h12141218; Vref[73] = 1'bx; Coutref[73] = 1'bx;        Stm[73] = 3'b110; stma[73] = 32'hFEDCBA98; stmb[73]=32'h12345678; Cinstm[73] = 0; //testing AND in more depth

//Testing OR in more depth
ref[74] = 32'h11110111; Vref[74] = 1'bx; Coutref[74] = 1'bx;        Stm[74] = 3'b100; stma[74] = 32'h11110101; stmb[74]=32'h00000111; Cinstm[74] = 0; //testing OR in more depth
ref[75] = 32'h97755779; Vref[75] = 1'bx; Coutref[75] = 1'bx;        Stm[75] = 3'b100; stma[75] = 32'h12345678; stmb[75]=32'h87654321; Cinstm[75] = 0; //testing OR in more depth
ref[76] = 32'hFEFCFEF8; Vref[76] = 1'bx; Coutref[76] = 1'bx;        Stm[76] = 3'b100; stma[76] = 32'hFEDCBA98; stmb[76]=32'h12345678; Cinstm[76] = 0; //testing OR in more depth

//Testing NOR in more depth
ref[77] = 32'h00000000; Vref[77] = 1'bx; Coutref[77] = 1'bx;        Stm[77] = 3'b101; stma[77] = 32'h00000000; stmb[77]=32'hFFFFFFFF; Cinstm[77] = 0; //testing 0 NOR 1 is 0
ref[78] = 32'h00000000; Vref[78] = 1'bx; Coutref[78] = 1'bx;        Stm[78] = 3'b101; stma[78] = 32'hFFFFFFFF; stmb[78]=32'h00000000; Cinstm[78] = 0; //testing 1 NOR 0 is 0
ref[79] = 32'h00000000; Vref[79] = 1'bx; Coutref[79] = 1'bx;        Stm[79] = 3'b101; stma[79] = 32'hFFFFFFFF; stmb[79]=32'hFFFFFFFF; Cinstm[79] = 0; //testing 1 NOR 1 is 0
ref[80] = 32'h00000000; Vref[80] = 1'bx; Coutref[80] = 1'bx;        Stm[80] = 3'b101; stma[80] = 32'hFEFEFEFE; stmb[80]=32'hEFEFEFEF; Cinstm[80] = 0; //testing NOR in more depth
ref[81] = 32'hEEEEFEEE; Vref[81] = 1'bx; Coutref[81] = 1'bx;        Stm[81] = 3'b101; stma[81] = 32'h11110101; stmb[81]=32'h00000111; Cinstm[81] = 0; //testing NOR in more depth


dontcare = 32'hx;
ntests = 81;
 
$timeformat(-9,1,"ns",12);
 
end

initial begin
 error = 0;
    
 for (k=0; k<= ntests; k=k+1)   		     // LOOPING THROUGH ALL THE TEST VECTORS AND ASSIGNING IT TO THE ALU INPUTS EVERY 8ns //
    begin
    S = Stm[k]; a = stma[k] ; b = stmb[k]; Cin = Cinstm[k];
    
    #20 str[k] = d; Vstr[k] = V; Coutstr[k] = Cout;   // #20 IS 8 ns DELAY FOR ASSIGNING THE OUTPUT TO THE REFERENCE REGISTERS // 

      
    if ( S == 3'b000 )
    $display ("-----  TEST FOR A XOR B  -----");
    
    if ( S == 3'b001 )
    $display ("-----  TEST FOR A XNOR B  -----");
  
    if ( S == 3'b010 )
    $display ("-----  TEST FOR A + B/ CARRY CHAIN  -----");
    
    if ( S == 3'b011 )
    $display ("-----  TEST FOR A - B  -----");
  
    if ( S == 3'b100 )
    $display ("-----  TEST FOR A OR B  -----");
  
    if ( S == 3'b101 )
    $display ("-----  TEST FOR A NOR B  -----");

    if ( S == 3'b110 )
    $display ("-----  TEST FOR A AND B  -----");


    $display ("Time=%t \n S=%b \n Cin=%b \n a=%b \n b=%b \n d=%b \n ref=%b \n Cout=%b \n CoutRef=%b \n V=%b \n Vref=%b \n",$realtime, S, Cin, a, b, d, ref[k], Cout, Coutref[k], V, Vref[k]);
    
    
    // THIS CONTROL BLOCK CHECKS FOR ERRORS  BY COMPARING YOUR OUTPUT WITH THE EXPECTED OUTPUTS AND INCREMENTS "error" IN CASE OF ERROR //
    
    if (( (ref[k] !== str[k]) && (ref[k] !== dontcare)  ) || ( (Vref[k] !== Vstr[k]) && (Vref[k] !== 1'bx)  ) || ( (Coutref[k] !==  Coutstr[k]) && (Coutref[k] !== 1'bx) ) )
      begin
      $display ("-------------ERROR. A Mismatch Has Occured-----------");
      error = error + 1;
    end

 end

    if ( error == 0)
        $display("---------YOU DID IT!! SIMULATION SUCCESFULLY FINISHED----------");
    
    if ( error != 0)
        $display("---------------ERRORS. Mismatches Have Occured, sorry------------------");

    $display(" Number Of Errors = %d", error);
    $display(" Total Test numbers = %d", ntests);
    $display(" Total number of correct operations = %d", (ntests-error));

end
         
        
endmodule
         
