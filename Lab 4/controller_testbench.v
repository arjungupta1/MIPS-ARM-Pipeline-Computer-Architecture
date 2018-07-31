`timescale 1ns/10ps
module controller_testbench();


reg [31:0] ibustm[0:81], ibus, Ref_Aselect[0:81], Ref_Bselect[0:81],Ref_Dselect[0:81];
reg clk, Ref_Imm[0:81], Ref_Cin[0:81];
reg [2:0] Ref_S[0:81];
wire [2:0] S;
wire Cin,Imm;
wire [31:0] Aselect,Bselect, Dselect;
 

reg [31:0] dontcare;
reg neglect;
reg [2:0] neg;
integer error, k, ntests;

parameter ADDI = 6'b000011;
parameter SUBI = 6'b000010;
parameter XORI = 6'b000001;
parameter ANDI = 6'b001111;
parameter ORI = 6'b001100;
parameter Rformat = 6'b000000;
parameter ADD = 6'b000011;
parameter SUB = 6'b000010;
parameter XOR = 6'b000001;
parameter AND = 6'b000111;
parameter OR = 6'b000100;
parameter SADD = 3'b010;
parameter SSUB = 3'b011;
parameter SXOR = 3'b000;
parameter SAND = 3'b110;
parameter SOR = 3'b100;



controller dut(.ibus(ibus), .clk(clk), .Cin(Cin), .Imm(Imm), .S(S) , .Aselect(Aselect) , .Bselect(Bselect), .Dselect(Dselect));


initial begin
dontcare = 32'hxxxxxxxx;
neglect = 1'bx;
neg = 3'bxxx;



// ----------
// 1. Begin test clear SUB R13, R0, R0
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[0]={Rformat, 5'b00000, 5'b00000, 5'b01101, 5'b00000, SUB};
ibustm[1]={Rformat, 5'b00000, 5'b00000, 5'b01101, 5'b00000, SUB};

Ref_Aselect[1] = 32'b00000000000000000000000000000001; //input 1
Ref_Bselect[1] = 32'b00000000000000000000000000000001; //input 1
Ref_Dselect[1] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
Ref_Imm[1] =1'bx;
Ref_Cin[1] =1'bx;
Ref_S[1] = 3'bxxx;

// ----------
//  2. ADDI R1, R0, #FFFF
// ----------

//        opcode source1   dest      Immediate...
ibustm[2]={ADDI, 5'b00000, 5'b00001, 16'hFFFF};

Ref_Aselect[2] = 32'b00000000000000000000000000000001; //input2 
Ref_Bselect[2] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input2 
Ref_Dselect[2] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input2 
Ref_Imm[2] =1'b0;  //input1
Ref_Cin[2] =1'b1;  //input1
Ref_S[2] = SSUB; //input1



// ---------- 
// 3. ADDI R0, R0, #FFFF
// ----------
//        opcode source1   dest      Immediate...
ibustm[3]={ADDI, 5'b00000, 5'b00000, 16'hFFFF};

Ref_Aselect[3] = 32'b0000000000000000000000000000001; //input3
Ref_Bselect[3] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input3
Ref_Dselect[3] = 32'b0000000000000000010000000000000; //input1
Ref_Imm[3] =1'b1;  //input2
Ref_Cin[3] =1'b0;  //input2 
Ref_S[3] = SADD; //input2

// ---------- 
// 4. ADDI R30, R1,#AFC0
// ----------

//        opcode source1   dest      Immediate...
ibustm[4]={ADDI, 5'b00001, 5'b11110, 16'hAFC0};

Ref_Aselect[4] = 32'b00000000000000000000000000000010; //input4
Ref_Bselect[4] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input4
Ref_Dselect[4] = 32'b00000000000000000000000000000010; //input2
Ref_Imm[4] =1'b1;  //input3
Ref_Cin[4] =1'b0;  //input3
Ref_S[4] = SADD; //input3


// ---------- 
// 5. SUB R0, R0, R0
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[5]={Rformat, 5'b00000, 5'b00000, 5'b00000, 5'b00000, SUB};

Ref_Aselect[5] = 32'b0000000000000000000000000000001; //input5
Ref_Bselect[5] = 32'b0000000000000000000000000000001; //input5
Ref_Dselect[5] = 32'b0000000000000000000000000000001; //input3
Ref_Imm[5] =1'b1;  //input4
Ref_Cin[5] =1'b0;  //input4
Ref_S[5] = SADD; //input4

// ---------- // 6. XORI R3, R0, #8CCB
// ----------

//        opcode source1   dest      Immediate...
ibustm[6]={XORI, 5'b00000, 5'b00011, 16'h8CCB};

Ref_Aselect[6] = 32'b00000000000000000000000000000001; //input6
Ref_Bselect[6] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input6
Ref_Dselect[6] = 32'b01000000000000000000000000000000; //input4
Ref_Imm[6] =1'b0;  //input5
Ref_Cin[6] =1'b1;  //input5
Ref_S[6] = SSUB; //input5


// ---------- 
// 7. ORI R21, R0, #F98B 
// ----------

//        opcode source1   dest      Immediate...
ibustm[7]={ORI, 5'b00000, 5'b10101, 16'hF98B};

Ref_Aselect[7] = 32'b00000000000000000000000000000001;//input7
Ref_Bselect[7] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input7
Ref_Dselect[7] = 32'b00000000000000000000000000000001; //input5
Ref_Imm[7] =1'b1; //input6
Ref_Cin[7] =1'b0; //input6
Ref_S[7] = SXOR; //input6


// ---------- 
// 8. XOR R16, R1, R3
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[8]={Rformat, 5'b00001, 5'b00011, 5'b10000, 5'b00000, XOR};

Ref_Aselect[8] = 32'b00000000000000000000000000000010; //input8
Ref_Bselect[8] = 32'b00000000000000000000000000001000; //input8
Ref_Dselect[8] = 32'b00000000000000000000000000001000; //input6
Ref_Imm[8] =1'b1;  //input7
Ref_Cin[8] =1'b0;  //input7
Ref_S[8] = SOR; //input7


// ---------- 
// 9. SUBI R31, R21, #0030
// ----------

//        opcode source1   dest      Immediate...
ibustm[9]={SUBI, 5'b10101, 5'b11111, 16'h0030};

Ref_Aselect[9] = 32'b00000000001000000000000000000000;//input9
Ref_Bselect[9] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input9
Ref_Dselect[9] = 32'b00000000001000000000000000000000;//input7
Ref_Imm[9] =1'b0;  //input8
Ref_Cin[9] =1'b0;  //input8
Ref_S[9] = SXOR; //input8


// ---------- 
// 10. XOR R5, R16, R21
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[10]={Rformat, 5'b10000, 5'b10101, 5'b00101, 5'b00000, XOR};

Ref_Aselect[10] = 32'b00000000000000010000000000000000; //input10
Ref_Bselect[10] = 32'b00000000001000000000000000000000; //input10
Ref_Dselect[10] = 32'b00000000000000010000000000000000; //input8
Ref_Imm[10] =1'b1; //input9
Ref_Cin[10] =1'b1; //input9
Ref_S[10] = SSUB; //input9


// ------------ 
// 11. ORI R10, R0, #34FB  
// ------------

//        opcode source1   dest      Immediate...
ibustm[11]={ORI, 5'b00000, 5'b01010, 16'h34FB};
Ref_Aselect[11] = 32'b00000000000000000000000000000001;//input11
Ref_Bselect[11] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input11
Ref_Dselect[11] = 32'b10000000000000000000000000000000;//input9
Ref_Imm[11] =1'b0;  //input10
Ref_Cin[11] =1'b0;  //input10
Ref_S[11] = SXOR; //input10

// ------------ 
// 12. XORI R18, R1, #0B31
// ------------

//         opcode source1   dest      Immediate...
ibustm[12]={XORI, 5'b00001, 5'b10010, 16'h0B31};

Ref_Aselect[12] = 32'b00000000000000000000000000000010; //input12
Ref_Bselect[12] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input12
Ref_Dselect[12] = 32'b00000000000000000000000000100000; //input10
Ref_Imm[12] =1'b1;  //input11
Ref_Cin[12] =1'b0;  //input11
Ref_S[12] = SOR; //input11


// --------- 
// 13. ADD R24, R16, R3
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[13]={Rformat, 5'b10000, 5'b00011, 5'b11000, 5'b00000, ADD};

Ref_Aselect[13] = 32'b00000000000000010000000000000000;//input13
Ref_Bselect[13] = 32'b00000000000000000000000000001000;//input13
Ref_Dselect[13] = 32'b00000000000000000000010000000000;//input11
Ref_Imm[13] =1'b1;  //input12
Ref_Cin[13] =1'b0;  //input12
Ref_S[13] = SXOR; //input12


// --------- 
// 14. OR R7, R10, R10
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[14]={Rformat, 5'b01010, 5'b01010, 5'b00111, 5'b00000, OR};

Ref_Aselect[14] = 32'b00000000000000000000010000000000; //input14
Ref_Bselect[14] = 32'b00000000000000000000010000000000; //input14
Ref_Dselect[14] = 32'b00000000000001000000000000000000; //input12
Ref_Imm[14] =1'b0;  //input13
Ref_Cin[14] =1'b0;  //input13
Ref_S[14] = SADD; //input13


// --------- 
// 15. XORI R12, R21, #00F0
// ---------

//         opcode source1   dest      Immediate...
ibustm[15]={XORI, 5'b10101, 5'b01100, 16'h00F0};

Ref_Aselect[15] = 32'b00000000001000000000000000000000;//input15
Ref_Bselect[15] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input15
Ref_Dselect[15] = 32'b00000001000000000000000000000000;//input13
Ref_Imm[15] =1'b0;  //input14
Ref_Cin[15] =1'b0;  //input14
Ref_S[15] = SOR; //input14

// --------- 
// 16. SUBI R26, R31, #0111  
// ---------

//         opcode source1   dest      Immediate...
ibustm[16]={SUBI, 5'b11111, 5'b11010, 16'h0111};

Ref_Aselect[16] = 32'b10000000000000000000000000000000; //input16
Ref_Bselect[16] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input16
Ref_Dselect[16] = 32'b00000000000000000000000010000000; //input14
Ref_Imm[16] =1'b1;  //input15
Ref_Cin[16] =1'b0;  //input15
Ref_S[16] = SXOR; //input15
// --------- 
// 17. ADD R17, R3, R21
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[17]={Rformat, 5'b00011, 5'b10101, 5'b10001, 5'b00000, ADD};

Ref_Aselect[17] = 32'b00000000000000000000000000001000;//input17
Ref_Bselect[17] = 32'b00000000001000000000000000000000;//input17
Ref_Dselect[17] = 32'b00000000000000000001000000000000;//input15
Ref_Imm[17] =1'b1;  //input16
Ref_Cin[17] =1'b1;  //input16
Ref_S[17] = SSUB; //input16

// --------- 
// 18. XOR R15, R7, R21
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[18]={Rformat, 5'b00111, 5'b10101, 5'b01111, 5'b00000, XOR};

Ref_Aselect[18] = 32'b00000000000000000000000010000000; //input18
Ref_Bselect[18] = 32'b00000000001000000000000000000000; //input18
Ref_Dselect[18] = 32'b00000100000000000000000000000000; //input16
Ref_Imm[18] =1'b0;  //input17
Ref_Cin[18] =1'b0;  //input17
Ref_S[18] = SADD; //input17


// --------- 
// 19. ADDI R13, R13, #FFFF
// ---------

//         opcode source1   dest      Immediate...
ibustm[19]={ADDI, 5'b01101, 5'b01101, 16'hFFFF};

Ref_Aselect[19] = 32'b00000000000000000010000000000000; //input19
Ref_Bselect[19] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input19
Ref_Dselect[19] = 32'b00000000000000100000000000000000; //input17
Ref_Imm[19] =1'b0;  //input18
Ref_Cin[19] =1'b0;  //input18
Ref_S[19] = SXOR; //input18

// --------- 
// 20. ADDI R23, R1, #AFC0
// ---------

//         opcode source1   dest      Immediate...
ibustm[20]={ADDI, 5'b00001, 5'b10111, 16'hAFC0};

Ref_Aselect[20] = 32'b00000000000000000000000000000010;//input20
Ref_Bselect[20] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input20
Ref_Dselect[20] = 32'b00000000000000001000000000000000; //input18
Ref_Imm[20] =1'b1;  //input19
Ref_Cin[20] =1'b0;  //input19
Ref_S[20] = SADD; //input19

// --------- 
// 21. SUB R20, R1, R1
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[21]={Rformat, 5'b00001, 5'b00001, 5'b10100, 5'b00000, SUB};

Ref_Aselect[21] = 32'b00000000000000000000000000000010; //input21
Ref_Bselect[21] = 32'b00000000000000000000000000000010; //input21
Ref_Dselect[21] = 32'b00000000000000000010000000000000; //input19
Ref_Imm[21] =1'b1;  //input20
Ref_Cin[21] =1'b0;  //input20
Ref_S[21] = SADD; //input20

// --------- 
// 22. XORI R19, R0, #8CCB
// ---------

//         opcode source1   dest      Immediate...
ibustm[22]={XORI, 5'b00000, 5'b10011, 16'h8CCB};

Ref_Aselect[22] = 32'b00000000000000000000000000000001;//input22
Ref_Bselect[22] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input22
Ref_Dselect[22] = 32'b00000000100000000000000000000000;//input20
Ref_Imm[22] =1'b0;  //input21
Ref_Cin[22] =1'b1;  //input21
Ref_S[22] = SSUB; //input21

// -------- 
// 23. ORI R9, R20, #F98B
// --------

//         opcode source1   dest      Immediate...
ibustm[23]={ORI, 5'b10100, 5'b01001, 16'hF98B};

Ref_Aselect[23] = 32'b00000000000100000000000000000000; //input23
Ref_Bselect[23] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input23
Ref_Dselect[23] = 32'b00000000000100000000000000000000; //input21
Ref_Imm[23] =1'b1;  //input22
Ref_Cin[23] =1'b0;  //input22
Ref_S[23] = SXOR; //input22

// -------- 
// 24. XOR R2, R13, R19
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[24]={Rformat, 5'b01101, 5'b10011, 5'b00010, 5'b00000, XOR};

Ref_Aselect[24] = 32'b00000000000000000010000000000000;//input24
Ref_Bselect[24] = 32'b00000000000010000000000000000000;//input24
Ref_Dselect[24] = 32'b00000000000010000000000000000000;//input22
Ref_Imm[24] =1'b1;  //input23
Ref_Cin[24] =1'b0;  //input23
Ref_S[24] = SOR; //input23


// -------- 
// 25. SUBI R26, R9, #0030
// --------
//         opcode source1   dest      Immediate...
ibustm[25]={SUBI, 5'b01001, 5'b11010, 16'h0030};

Ref_Aselect[25] = 32'b00000000000000000000001000000000; //input25
Ref_Bselect[25] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input25
Ref_Dselect[25] = 32'b00000000000000000000001000000000; //input23
Ref_Imm[25] =1'b0;  //input24
Ref_Cin[25] =1'b0;  //input24
Ref_S[25] = SXOR; //input24

// -------- 
// 26. XOR R25, R2, R9
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[26]={Rformat, 5'b00010, 5'b01001, 5'b11001, 5'b00000, XOR};

Ref_Aselect[26] = 32'b00000000000000000000000000000100;//input26
Ref_Bselect[26] = 32'b00000000000000000000001000000000;//input26
Ref_Dselect[26] = 32'b00000000000000000000000000000100;//input24
Ref_Imm[26] =1'b1;  //input25
Ref_Cin[26] =1'b1;  //input25
Ref_S[26] = SSUB; //input25


// -------- 
// 27. ORI R8, R20, #34FB
// --------

//         opcode source1   dest      Immediate...
ibustm[27]={ORI, 5'b10100, 5'b01000, 16'h34FB};

Ref_Aselect[27] = 32'b00000000000100000000000000000000;//input27
Ref_Bselect[27] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; //input27
Ref_Dselect[27] = 32'b00000100000000000000000000000000; //input25
Ref_Imm[27] =1'b0;  //input26
Ref_Cin[27] =1'b0;  //input26
Ref_S[27] = SXOR; //input26
// -------- 
// 28. XORI R27, R13, #0B31
// --------

//         opcode source1   dest      Immediate...
ibustm[28]={XORI, 5'b01101, 5'b11011, 16'h0B31};

Ref_Aselect[28] = 32'b00000000000000000010000000000000;//input28
Ref_Bselect[28] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input28
Ref_Dselect[28] = 32'b00000010000000000000000000000000;//input26
Ref_Imm[28] =1'b1;  //input27
Ref_Cin[28] =1'b0;  //input27
Ref_S[28] = SOR; //input27

// -------- 
// 29. ADD R14, R2, R19
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[29]={Rformat, 5'b00010, 5'b10011, 5'b01110, 5'b00000, ADD};

Ref_Aselect[29] = 32'b00000000000000000000000000000100;//input29
Ref_Bselect[29] = 32'b00000000000010000000000000000000;//input29
Ref_Dselect[29] = 32'b00000000000000000000000100000000;//input27
Ref_Imm[29] =1'b1;  //input28
Ref_Cin[29] =1'b0;  //input28
Ref_S[29] = SXOR; //input28

// -------- 
// 30. OR R4, R8, R8 
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[30]={Rformat, 5'b01000, 5'b01000, 5'b00100, 5'b00000, OR};

Ref_Aselect[30] = 32'b00000000000000000000000100000000;//input30
Ref_Bselect[30] = 32'b00000000000000000000000100000000;//input30
Ref_Dselect[30] = 32'b00001000000000000000000000000000;//input28
Ref_Imm[30] =1'b0;  //input29
Ref_Cin[30] =1'b0;  //input29
Ref_S[30] = SADD; //input29


// -------- 
// 31. XORI R12, R21, #5555 
// --------

//         opcode source1   dest      Immediate...
ibustm[31]={XORI, 5'b10101, 5'b01100, 16'h5555};

Ref_Aselect[31] = 32'b00000000001000000000000000000000;//input31
Ref_Bselect[31] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input31
Ref_Dselect[31] = 32'b00000000000000000100000000000000;//input29
Ref_Imm[31] =1'b0;  //input30
Ref_Cin[31] =1'b0;  //input30
Ref_S[31] = SOR; //input30

// -------- 
// 32. ADDI R20, R20, h1234

//         opcode source1   dest      Immediate...
ibustm[32]={ADDI, 5'b10100, 5'b10100, 16'h1234};

Ref_Aselect[32] = 32'b00000000000100000000000000000000;//input32
Ref_Bselect[32] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input32
Ref_Dselect[32] = 32'b00000000000000000000000000010000;//input30
Ref_Imm[32] =1'b1;  //input31
Ref_Cin[32] =1'b0;  //input31
Ref_S[32] = SXOR; //input31

 // -------- 
// 33. OR R20, R20, R19

//          opcode   source1   source2   dest      shift     Function...
ibustm[33]={Rformat, 5'b10100, 5'b10100, 5'b10011, 5'b00000, OR};

Ref_Aselect[33] = 32'b00000000000100000000000000000000;//input33
Ref_Bselect[33] = 32'b00000000000100000000000000000000;//input33
Ref_Dselect[33] = 32'b00000000000000000001000000000000;//input31
Ref_Imm[33] =1'b1;  //input32
Ref_Cin[33] =1'b0;  //input32
Ref_S[33] = SADD; //input32


 // -------- 
// 34. AND R1, R0, R20

//          opcode   source1   source2   dest      shift     Function...
ibustm[34]={Rformat, 5'b00001, 5'b00000, 5'b10100, 5'b00000, AND};

Ref_Aselect[34] = 32'b00000000000000000000000000000010;//input34
Ref_Bselect[34] = 32'b00000000000000000000000000000001;//input34
Ref_Dselect[34] = 32'b00000000000100000000000000000000;//input32
Ref_Imm[34] =1'b0;  //input33
Ref_Cin[34] =1'b0;  //input33
Ref_S[34] = SOR; //input33

 // -------- 
// 35. XOR R2, R1, R29

//          opcode   source1   source2   dest      shift     Function...
ibustm[35]={Rformat, 5'b00010, 5'b00001, 5'b11101, 5'b00000, XOR};

Ref_Aselect[35] = 32'b00000000000000000000000000000100;//input35
Ref_Bselect[35] = 32'b00000000000000000000000000000010;//input35
Ref_Dselect[35] = 32'b00000000000010000000000000000000;//input33
Ref_Imm[35] =1'b0;  //input34
Ref_Cin[35] =1'b0;  //input34
Ref_S[35] = SAND; //input34

 // -------- 
// 36. SUB R2, R1, R29

//          opcode   source1   source2   dest      shift     Function...
ibustm[36]={Rformat, 5'b00010, 5'b00001, 5'b11101, 5'b00000, SUB};

Ref_Aselect[36] = 32'b00000000000000000000000000000100;//input36
Ref_Bselect[36] = 32'b00000000000000000000000000000010;//input36
Ref_Dselect[36] = 32'b00000000000100000000000000000000;//input34
Ref_Imm[36] =1'b0;  //input35
Ref_Cin[36] =1'b0;  //input35
Ref_S[36] = SXOR; //input35

 // -------- 
// 37. ADDI R1, R2, h9999

//         opcode source1   dest      Immediate...
ibustm[37]={ADDI, 5'b00010, 5'b00001, 16'h9999};

Ref_Aselect[37] = 32'b00000000000000000000000000000100;//input37
Ref_Bselect[37] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input37
Ref_Dselect[37] = 32'b00100000000000000000000000000000;//input35
Ref_Imm[37] =1'b0;  //input36
Ref_Cin[37] =1'b1;  //input36
Ref_S[37] = SSUB; //input36

 // -------- 
// 38. ADDI R1, R10, h9999

//         opcode source1   dest      Immediate...
ibustm[38]={ADDI, 5'b01010, 5'b00001, 16'h9999};

Ref_Aselect[38] = 32'b00000000000000000000010000000000;//input38
Ref_Bselect[38] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input38
Ref_Dselect[38] = 32'b00100000000000000000000000000000;//input36
Ref_Imm[38] =1'b1;  //input37
Ref_Cin[38] =1'b0;  //input37
Ref_S[38] = SADD; //input37

 // -------- 
// 39. XORI R1, R10, h9999

//         opcode source1   dest      Immediate...
ibustm[39]={XORI, 5'b01010, 5'b00001, 16'h9999};

Ref_Aselect[39] = 32'b00000000000000000000010000000000;//input39
Ref_Bselect[39] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input39
Ref_Dselect[39] = 32'b00000000000000000000000000000010;//input37
Ref_Imm[39] =1'b1;  //input38
Ref_Cin[39] =1'b0;  //input38
Ref_S[39] = SADD; //input38

 // -------- 
// 40. ORI R1, R10, h9999

//         opcode source1   dest      Immediate...
ibustm[40]={ORI, 5'b01010, 5'b00001, 16'h9999};

Ref_Aselect[40] = 32'b00000000000000000000010000000000;//input40
Ref_Bselect[40] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input40
Ref_Dselect[40] = 32'b00000000000000000000000000000010;//input38
Ref_Imm[40] =1'b1;  //input39
Ref_Cin[40] =1'b0;  //input39
Ref_S[40] = SXOR; //input39

 // -------- 
// 41. SUBI R1, R10, h9999

//         opcode source1   dest      Immediate...
ibustm[41]={SUBI, 5'b01010, 5'b00001, 16'h9999};

Ref_Aselect[41] = 32'b00000000000000000000010000000000;//input41
Ref_Bselect[41] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input41
Ref_Dselect[41] = 32'b00000000000000000000000000000010;//input39
Ref_Imm[41] =1'b1;  //input40
Ref_Cin[41] =1'b0;  //input40
Ref_S[41] = SOR; //input40

 // -------- 
// 42. ADD R1, R10, R1

//          opcode   source1   source2   dest      shift     Function...
ibustm[42]={Rformat, 5'b01010, 5'b00001, 5'b00001, 5'b00000, ADD};

Ref_Aselect[42] = 32'b00000000000000000000010000000000;//input42
Ref_Bselect[42] = 32'b00000000000000000000000000000010;//input42
Ref_Dselect[42] = 32'b00000000000000000000000000000010;//input40
Ref_Imm[42] =1'b1;  //input41
Ref_Cin[42] =1'b1;  //input41
Ref_S[42] = SSUB; //input41


 // -------- 
// 43. SUB R1, R10, R1

//          opcode   source1   source2   dest      shift     Function...
ibustm[43]={Rformat, 5'b01010, 5'b00001, 5'b00001, 5'b00000, SUB};

Ref_Aselect[43] = 32'b00000000000000000000010000000000;//input43
Ref_Bselect[43] = 32'b00000000000000000000000000000010;//input43
Ref_Dselect[43] = 32'b00000000000000000000000000000010;//input41
Ref_Imm[43] =1'b0;  //input42
Ref_Cin[43] =1'b0;  //input42
Ref_S[43] = SADD; //input42


 // -------- 
// 44. OR R1, R10, R1

//          opcode   source1   source2   dest      shift     Function...
ibustm[44]={Rformat, 5'b01010, 5'b00001, 5'b00001, 5'b00000, OR};

Ref_Aselect[44] = 32'b00000000000000000000010000000000;//input44
Ref_Bselect[44] = 32'b00000000000000000000000000000010;//input44
Ref_Dselect[44] = 32'b00000000000000000000000000000010;//input42
Ref_Imm[44] =1'b0;  //input43
Ref_Cin[44] =1'b1;  //input43
Ref_S[44] = SSUB; //input43


 // -------- 
// 45. AND R1, R10, R1

//          opcode   source1   source2   dest      shift     Function...
ibustm[45]={Rformat, 5'b01010, 5'b00001, 5'b00001, 5'b00000, AND};

Ref_Aselect[45] = 32'b00000000000000000000010000000000;//input45
Ref_Bselect[45] = 32'b00000000000000000000000000000010;//input45
Ref_Dselect[45] = 32'b00000000000000000000000000000010;//input43
Ref_Imm[45] =1'b0;  //input44
Ref_Cin[45] =1'b0;  //input44
Ref_S[45] = SOR; //input44

// -------- 
// 46. XOR R1, R10, R1

//          opcode   source1   source2   dest      shift     Function...
ibustm[46]={Rformat, 5'b01010, 5'b00001, 5'b00001, 5'b00000, XOR};

Ref_Aselect[46] = 32'b00000000000000000000010000000000;//input46
Ref_Bselect[46] = 32'b00000000000000000000000000000010;//input46
Ref_Dselect[46] = 32'b00000000000000000000000000000010;//input44
Ref_Imm[46] =1'b0;  //input45
Ref_Cin[46] =1'b0;  //input45
Ref_S[46] = SAND; //input45

// -------- 
// 47. AND R10, R30, R20

//          opcode   source1   source2   dest      shift     Function...
ibustm[47]={Rformat, 5'b11110, 5'b10100, 5'b01010, 5'b00000, AND};

Ref_Aselect[47] = 32'b01000000000000000000000000000000;//input47
Ref_Bselect[47] = 32'b00000000000100000000000000000000;//input47
Ref_Dselect[47] = 32'b00000000000000000000000000000010;//input45
Ref_Imm[47] =1'b0;  //input46
Ref_Cin[47] =1'b0;  //input46
Ref_S[47] = SXOR; //input46

// -------- 
// 48. OR R1, R17, 29

//          opcode   source1   source2   dest      shift     Function...
ibustm[48]={Rformat, 5'b10001, 5'b11101, 5'b00001, 5'b00000, OR};

Ref_Aselect[48] = 32'b00000000000000100000000000000000;//input48
Ref_Bselect[48] = 32'b00100000000000000000000000000000;//input48
Ref_Dselect[48] = 32'b00000000000000000000000000000010;//input46
Ref_Imm[48] =1'b0;  //input47
Ref_Cin[48] =1'b0;  //input47
Ref_S[48] = SAND; //input47

// -------- 
// 49. ORI R14, R14, h4567

//         opcode source1   dest      Immediate...
ibustm[49]={ORI, 5'b01110, 5'b01110, 16'h4567};

Ref_Aselect[49] = 32'b00000000000000000100000000000000;//input49
Ref_Bselect[49] = 32'b00000000000000000100000000000000;//input49
Ref_Dselect[49] = 32'b00000000000000000000010000000000;//input47
Ref_Imm[49] =1'b0;  //input48
Ref_Cin[49] =1'b0;  //input48
Ref_S[49] = SOR; //input48


// -------- 
// 50. AND R14, R14, R14

//          opcode   source1   source2   dest      shift     Function...
ibustm[50]={Rformat, 5'b01110, 5'b01110, 5'b01110, 5'b00000, AND};

Ref_Aselect[50] = 32'b00000000000000000100000000000000;//input50
Ref_Bselect[50] = 32'b00000000000000000100000000000000;//input50
Ref_Dselect[50] = 32'b00000000000000000000000000000010;//input48
Ref_Imm[50] =1'b1;  //input49
Ref_Cin[50] =1'b0;  //input49
Ref_S[50] = SOR; //input49

// -------- 
// 51. SUBI R14, R14, h4567

//         opcode source1   dest      Immediate...
ibustm[51]={SUBI, 5'b01110, 5'b01110, 16'h4567};

Ref_Aselect[51] = 32'b00000000000000000100000000000000;//input51
Ref_Bselect[51] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input51
Ref_Dselect[51] = 32'b00000000000000000100000000000000;//input49
Ref_Imm[51] =1'b0;  //input50
Ref_Cin[51] =1'b0;  //input50
Ref_S[51] = SAND; //input50

// -------- 
// 52. ORI R17, R18, h4567

//         opcode source1   dest      Immediate...
ibustm[52]={ORI, 5'b10010, 5'b10001, 16'h4567};

Ref_Aselect[52] = 32'b00000000000001000000000000000000;//input52
Ref_Bselect[52] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input52
Ref_Dselect[52] = 32'b00000000000000000100000000000000;//input50
Ref_Imm[52] =1'b1;  //input51
Ref_Cin[52] =1'b1;  //input51
Ref_S[52] = SSUB; //input51

// -------- 
// 53. XORI R17, R18, h4567

//         opcode source1   dest      Immediate...
ibustm[53]={XORI, 5'b10010, 5'b10001, 16'h4567};

Ref_Aselect[53] = 32'b00000000000001000000000000000000;//input53
Ref_Bselect[53] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input53
Ref_Dselect[53] = 32'b00000000000000000100000000000000;//input51
Ref_Imm[53] =1'b1;  //input52
Ref_Cin[53] =1'b0;  //input52
Ref_S[53] = SOR; //input52

// -------- 
// 54. ANDI R17, R18, hFFFF

//         opcode source1   dest      Immediate...
ibustm[54]={ANDI, 5'b10010, 5'b10001, 16'h4567};

Ref_Aselect[54] = 32'b00000000000001000000000000000000;//input54
Ref_Bselect[54] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input54
Ref_Dselect[54] = 32'b00000000000000100000000000000000;//input52
Ref_Imm[54] =1'b1;  //input53
Ref_Cin[54] =1'b0;  //input53
Ref_S[54] = SXOR; //input53

// -------- 
// 55. ANDI R17, R18, hFFFF

//         opcode source1   dest      Immediate...
ibustm[55]={ADDI, 5'b10010, 5'b10001, 16'hFFFF};

Ref_Aselect[55] = 32'b00000000000001000000000000000000;//input55
Ref_Bselect[55] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input55
Ref_Dselect[55] = 32'b00000000000000100000000000000000;//input53
Ref_Imm[55] =1'b1;  //input54
Ref_Cin[55] =1'b0;  //input54
Ref_S[55] = SAND; //input54

// -------- 
// 56. SUBI  R17, R18, hFFFF

//         opcode source1   dest      Immediate...
ibustm[56]={SUBI, 5'b10010, 5'b10001, 16'hFFFF};

Ref_Aselect[56] = 32'b00000000000001000000000000000000;//input56
Ref_Bselect[56] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input56
Ref_Dselect[56] = 32'b00000000000000100000000000000000;//input54
Ref_Imm[56] =1'b1;  //input55
Ref_Cin[56] =1'b0;  //input55
Ref_S[56] = SADD; //input55

// -------- 
// 57. XORI R17, R18, hFFFF

//         opcode source1   dest      Immediate...
ibustm[57]={XORI, 5'b10010, 5'b10001, 16'hFFFF};

Ref_Aselect[57] = 32'b00000000000001000000000000000000;//input57
Ref_Bselect[57] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input57
Ref_Dselect[57] = 32'b00000000000000100000000000000000;//input55
Ref_Imm[57] =1'b1;  //input56
Ref_Cin[57] =1'b1;  //input56
Ref_S[57] = SSUB; //input56

// -------- 
// 58. ADD R31, R21, R12

//          opcode   source1   source2   dest      shift     Function...
ibustm[58]={Rformat, 5'b10101, 5'b01010, 5'b11111, 5'b00000, ADD};

Ref_Aselect[58] = 32'b00000000001000000000000000000000;//input58
Ref_Bselect[58] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input58
Ref_Dselect[58] = 32'b00000000000000100000000000000000;//input56
Ref_Imm[58] =1'b1;  //input57
Ref_Cin[58] =1'b0;  //input57
Ref_S[58] = SXOR; //input57

// -------- 
// 59. SUB R31, R21, R12

//          opcode   source1   source2   dest      shift     Function...
ibustm[59]={Rformat, 5'b10101, 5'b01010, 5'b11111, 5'b00000, SUB};

Ref_Aselect[59] = 32'b00000000001000000000000000000000;//input59
Ref_Bselect[59] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input59
Ref_Dselect[59] = 32'b00000000000000100000000000000000;//input57
Ref_Imm[59] =1'b0;  //input58
Ref_Cin[59] =1'b0;  //input58
Ref_S[59] = SADD; //input58

// -------- 
// 60. XOR R31, R21, R12

//          opcode   source1   source2   dest      shift     Function...
ibustm[60]={Rformat, 5'b10101, 5'b01010, 5'b11111, 5'b00000, XOR};

Ref_Aselect[60] = 32'b00000000001000000000000000000000;//input60
Ref_Bselect[60] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input60
Ref_Dselect[60] = 32'b10000000000000000000000000000000;//input58
Ref_Imm[60] =1'b0;  //input59
Ref_Cin[60] =1'b1;  //input59
Ref_S[60] = SSUB; //input59

// -------- 
// 61. OR R31, R21, R12

//          opcode   source1   source2   dest      shift     Function...
ibustm[61]={Rformat, 5'b10101, 5'b01010, 5'b11111, 5'b00000, OR};

Ref_Aselect[61] = 32'b00000000001000000000000000000000;//input61
Ref_Bselect[61] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input61
Ref_Dselect[61] = 32'b10000000000000000000000000000000;//input59
Ref_Imm[61] =1'b0;  //input60
Ref_Cin[61] =1'b0;  //input60
Ref_S[61] = SXOR; //input60

// -------- 
// 62. AND R31, R21, R12

//          opcode   source1   source2   dest      shift     Function...
ibustm[62]={Rformat, 5'b10101, 5'b01010, 5'b11111, 5'b00000, AND};

Ref_Aselect[62] = 32'b00000000001000000000000000000000;//input62
Ref_Bselect[62] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input62
Ref_Dselect[62] = 32'b10000000000000000000000000000000;//input60
Ref_Imm[62] =1'b0;  //input61
Ref_Cin[62] =1'b0;  //input61
Ref_S[62] = SOR; //input61

// -------- 
// 63. XORI R2, R1, hFFFF

//         opcode source1   dest      Immediate...
ibustm[63]={XORI, 5'b00001, 5'b00010, 16'hFFFF};

Ref_Aselect[63] = 32'b00000000000000000000000000000010;//input63
Ref_Bselect[63] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input63
Ref_Dselect[63] = 32'b10000000000000000000000000000000;//input61
Ref_Imm[63] =1'b0;  //input62
Ref_Cin[63] =1'b0;  //input62
Ref_S[63] = SAND; //input62

// -------- 
// 64. ANDI R2, R1, hFFFF

//         opcode source1   dest      Immediate...
ibustm[64]={ANDI, 5'b00001, 5'b00010, 16'hFFFF};

Ref_Aselect[64] = 32'b00000000000000000000000000000010;//input64
Ref_Bselect[64] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input64
Ref_Dselect[64] = 32'b10000000000000000000000000000000;//input62
Ref_Imm[64] =1'b1;  //input63
Ref_Cin[64] =1'b0;  //input63
Ref_S[64] = SXOR; //input63

// -------- 
// 65. ADDI R2, R1, hFFFF

//         opcode source1   dest      Immediate...
ibustm[65]={ADDI, 5'b00001, 5'b00010, 16'hFFFF};

Ref_Aselect[65] = 32'b00000000000000000000000000000010;//input65
Ref_Bselect[65] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input65
Ref_Dselect[65] = 32'b00000000000000000000000000000100;//input63
Ref_Imm[65] =1'b1;  //input64
Ref_Cin[65] =1'b0;  //input64
Ref_S[65] = SAND; //input64

// -------- 
// 66. ORI R2, R1, hFFFF

//         opcode source1   dest      Immediate...
ibustm[66]={ORI, 5'b00001, 5'b00010, 16'hFFFF};

Ref_Aselect[66] = 32'b00000000000000000000000000000010;//input66
Ref_Bselect[66] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input66
Ref_Dselect[66] = 32'b00000000000000000000000000000100;//input64
Ref_Imm[66] =1'b1;  //input65
Ref_Cin[66] =1'b0;  //input65
Ref_S[66] = SADD; //input65

// -------- 
// 67. SUBI R2, R1, hFFFF

//         opcode source1   dest      Immediate...
ibustm[67]={SUBI, 5'b00001, 5'b00010, 16'hFFFF};

Ref_Aselect[67] = 32'b00000000000000000000000000000010;//input67
Ref_Bselect[67] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input67
Ref_Dselect[67] = 32'b00000000000000000000000000000100;//input65
Ref_Imm[67] =1'b1;  //input66
Ref_Cin[67] =1'b0;  //input66
Ref_S[67] = SOR; //input66

// -------- 
// 68. XOR R0, R0, R0

//          opcode   source1   source2   dest      shift     Function...
ibustm[68]={Rformat, 5'b00000, 5'b00000, 5'b00000, 5'b00000, XOR};

Ref_Aselect[68] = 32'b00000000000000000000000000000001;//input68
Ref_Bselect[68] = 32'b00000000000000000000000000000001;//input68
Ref_Dselect[68] = 32'b00000000000000000000000000000100;//input66
Ref_Imm[68] =1'b1;  //input67
Ref_Cin[68] =1'b1;  //input67
Ref_S[68] = SSUB; //input67

// -------- 
// 69. AND R0, R0, R0

//          opcode   source1   source2   dest      shift     Function...
ibustm[69]={Rformat, 5'b00000, 5'b00000, 5'b00000, 5'b00000, AND};

Ref_Aselect[69] = 32'b00000000000000000000000000000001;//input69
Ref_Bselect[69] = 32'b00000000000000000000000000000001;//input69
Ref_Dselect[69] = 32'b00000000000000000000000000000100;//input67
Ref_Imm[69] =1'b0;  //input68
Ref_Cin[69] =1'b0;  //input68
Ref_S[69] = SXOR; //input68

// -------- 
// 70. OR R0, R0, R0

//          opcode   source1   source2   dest      shift     Function...
ibustm[70]={Rformat, 5'b00000, 5'b00000, 5'b00000, 5'b00000, OR};

Ref_Aselect[70] = 32'b00000000000000000000000000000001;//input70
Ref_Bselect[70] = 32'b00000000000000000000000000000001;//input70
Ref_Dselect[70] = 32'b00000000000000000000000000000001;//input68
Ref_Imm[70] =1'b0;  //input69
Ref_Cin[70] =1'b0;  //input69
Ref_S[70] = SAND; //input69

// -------- 
// 71. ADD R0, R0, R0

//          opcode   source1   source2   dest      shift     Function...
ibustm[71]={Rformat, 5'b00000, 5'b00000, 5'b00000, 5'b00000, ADD};

Ref_Aselect[71] = 32'b00000000000000000000000000000001;//input71
Ref_Bselect[71] = 32'b00000000000000000000000000000001;//input71
Ref_Dselect[71] = 32'b00000000000000000000000000000001;//input69
Ref_Imm[71] =1'b0;  //input70
Ref_Cin[71] =1'b0;  //input70
Ref_S[71] = SOR; //input70

// -------- 
// 72. SUB R0, R0, R0

//          opcode   source1   source2   dest      shift     Function...
ibustm[72]={Rformat, 5'b00000, 5'b00000, 5'b00000, 5'b00000, SUB};

Ref_Aselect[72] = 32'b00000000000000000000000000000001;//input72
Ref_Bselect[72] = 32'b00000000000000000000000000000001;//input72
Ref_Dselect[72] = 32'b00000000000000000000000000000001;//input70
Ref_Imm[72] =1'b0;  //input71
Ref_Cin[72] =1'b0;  //input71
Ref_S[72] = SADD; //input71

// -------- 
// 73. SUBI R31, R31, hFFFF 

//         opcode source1   dest      Immediate...
ibustm[73]={SUBI, 5'b11111, 5'b11111, 16'hFFFF};

Ref_Aselect[73] = 32'b10000000000000000000000000000000;//input73
Ref_Bselect[73] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input73
Ref_Dselect[73] = 32'b00000000000000000000000000000001;//input71
Ref_Imm[73] = 1'b0;  //input72
Ref_Cin[73] = 1'b1;  //input72
Ref_S[73] = SSUB; //input72 

// -------- 
// 74. ADDI R31, R31, hFFFF 

//         opcode source1   dest      Immediate...
ibustm[74]={ADDI, 5'b11111, 5'b11111, 16'hFFFF};

Ref_Aselect[74] = 32'b10000000000000000000000000000000;//input74
Ref_Bselect[74] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input74
Ref_Dselect[74] = 32'b00000000000000000000000000000001;//input72
Ref_Imm[74] = 1'b1;  //input73
Ref_Cin[74] = 1'b1;  //input73
Ref_S[74] = SSUB; //input73

// -------- 
// 75. XORI R31, R31, hFFFF 

//         opcode source1   dest      Immediate...
ibustm[75]={XORI, 5'b11111, 5'b11111, 16'hFFFF};

Ref_Aselect[75] = 32'b10000000000000000000000000000000;//input75
Ref_Bselect[75] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input75
Ref_Dselect[75] = 32'b10000000000000000000000000000000;//input73
Ref_Imm[75] = 1'b1;  //input74
Ref_Cin[75] = 1'b0;  //input74
Ref_S[75] = SADD; //input74

// -------- 
// 76. ANDI R31, R31, hFFFF 

//         opcode source1   dest      Immediate...
ibustm[76]={ANDI, 5'b11111, 5'b11111, 16'hFFFF};

Ref_Aselect[76] = 32'b10000000000000000000000000000000;//input76
Ref_Bselect[76] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input76
Ref_Dselect[76] = 32'b10000000000000000000000000000000;//input74
Ref_Imm[76] = 1'b1;  //input75
Ref_Cin[76] = 1'b0;  //input75
Ref_S[76] = SXOR; //input75

// -------- 
// 77. ORI R31, R31, hFFFF 

//         opcode source1   dest      Immediate...
ibustm[77]={ORI, 5'b11111, 5'b11111, 16'hFFFF};

Ref_Aselect[77] = 32'b10000000000000000000000000000000;//input77
Ref_Bselect[77] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input77
Ref_Dselect[77] = 32'b10000000000000000000000000000000;//input75
Ref_Imm[77] = 1'b1;  //input76
Ref_Cin[77] = 1'b0;  //input76
Ref_S[77] = SAND; //input76

// -------- 
// 78. ADDI R31, R31, hFFFF 

//         opcode source1   dest      Immediate...
ibustm[78]={ADDI, 5'b11111, 5'b11111, 16'hFFFF};

Ref_Aselect[78] = 32'b10000000000000000000000000000000;//input78
Ref_Bselect[78] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input78
Ref_Dselect[78] = 32'b10000000000000000000000000000000;//input76
Ref_Imm[78] = 1'b1;  //input77
Ref_Cin[78] = 1'b0;  //input77
Ref_S[78] = SOR; //input77

// -------- 
// 79. ORI R29, R31, hFFFF 

//         opcode source1   dest      Immediate...
ibustm[79]={ORI, 5'b11111, 5'b11101, 16'hFFFF};

Ref_Aselect[79] = 32'b10000000000000000000000000000000;//input79
Ref_Bselect[79] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//input79
Ref_Dselect[79] = 32'b10000000000000000000000000000000;//input77
Ref_Imm[79] = 1'b1;  //input78
Ref_Cin[79] = 1'b0;  //input78
Ref_S[79] = SADD; //input78 

// -------- 
// 80. ORI R29, R31, hFFFF 

//         opcode source1   dest      Immediate...
ibustm[80]={ORI, 5'b11111, 5'b11101, 16'hFFFF};

Ref_Aselect[80] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//no input, getting value for 78
Ref_Bselect[80] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//no input, getting value for 78
Ref_Dselect[80] = 32'b10000000000000000000000000000000;//input78
Ref_Imm[80] = 1'b1;  //input79
Ref_Cin[80] = 1'b0;  //input79
Ref_S[80] = SOR; //input79


// -------- 
// 81. ORI R29, R31, hFFFF 

//         opcode source1   dest      Immediate...
ibustm[81]={ORI, 5'b11111, 5'b11101, 16'hFFFF};

Ref_Aselect[81] = 32'b00100000000000000000000000000000;//no input, getting value for 79
Ref_Bselect[81] = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;//no input, getting value for 79
Ref_Dselect[81] = 32'b10000000000000000000000000000000;//input79
Ref_Imm[81] = 1'bx;  ///no input, getting value for 79
Ref_Cin[81] = 1'bx;  //no input, getting value for 79
Ref_S[81] = 3'bx; //no input, getting value for 79

ntests = 81;

$timeformat(-9,1,"ns",12); 

end


initial begin
  error = 0;
  clk=0;
  $display("-------------------------------");
  $display("Time=%t   Instruction Number: 0 ",$realtime);
  $display("-------------------------------");
  ibus = ibustm[0];
  #25;
 
  for (k=1; k<= ntests; k=k+1) begin
  $display("-------------------------------");
  $display("Time=%t   Instruction Number: %d ",$realtime,k);
 $display("-------------------------------");
    clk=1;
    #5
    
    if (k>=1) begin
    
      $display ("  Testing Immediate, Cin and S for instruction %d", k-1);
      $display ("    Your Imm     = %b", Imm);
      $display ("    Correct Imm  = %b", Ref_Imm[k]);
      
      if ( (Imm !== Ref_Imm[k]) && (Ref_Imm[k] !== 1'bx) ) begin
         error = error+1;
         $display("-------ERROR. Mismatch Has Occured--------");
      end
    
      $display ("    Your Cin     = %b", Cin);
      $display ("    Correct Cin  = %b", Ref_Cin[k]);
      
      if ( (Cin !== Ref_Cin[k]) && (Ref_Cin[k] !== 1'bx) ) begin
          error = error+1;
          $display("-------ERROR. Mismatch Has Occured--------");
      end
      
      $display ("    Your S     = %b", S);
      $display ("    Correct S  = %b", Ref_S[k]);
    
      if ( (S !== Ref_S[k]) && (Ref_S[k] !== 3'bxxx) ) begin
         error = error+1;
         $display("-------ERROR. Mismatch Has Occured--------");
      end
    
    end
     
    if (k>=2) begin
      $display ("  Testing Destination Registers for instruction %d", k-2);
      $display ("    Your Dselect     = %b with ibus %b", Dselect, ibustm[k-2]);
      $display ("    Correct Dselect  = %b", Ref_Dselect[k]);
      
      if ( (Dselect !== Ref_Dselect[k]) && (Ref_Dselect[k] !== dontcare) ) begin
         error = error+1;
 $display("-------ERROR. Mismatch Has Occured--------");
      end
    end
               
    #20	
    clk = 0;
    $display ("-------------------------------");
    $display ("          Time=%t              ",$realtime);
    $display ("-------------------------------");
    ibus = ibustm[k+1];
    
    #5
    
    $display ("  Testing Source Registers for instruction %d", k);
    $display ("    Your Aselect     = %b", Aselect);
    $display ("    Correct Aselect  = %b", Ref_Aselect[k]);

    if ( (Aselect !== Ref_Aselect[k]) && (Ref_Aselect[k]) ) begin
        error = error+1;
        $display("-------------ERROR. Mismatch Has Occured---------------");
    end 
      
    $display ("    Your Bselect     = %b", Bselect);
    $display ("    Correct Bselect  = %b", Ref_Bselect[k]);
        
    if ( (Bselect !== Ref_Bselect[k]) && (Ref_Bselect[k] !== dontcare) ) begin
       error = error+1;
       $display("-------------ERROR. Mismatch Has Occured---------------");
    end
    
    #20
    clk = 0;
  end
 
  if ( error !== 0) begin 
    $display("--------- SIMULATION UNSUCCESFUL - MISMATCHES HAVE OCCURED ----------");
    $display(" No. Of Errors = %d", error);
  end

  if ( error == 0) 
 $display("-----------YOU DID IT :-) !!! SIMULATION SUCCESFULLY FINISHED----------");

end
      
endmodule