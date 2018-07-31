`timescale 1ns/10ps
module cpu3_testbench();


reg [31:0] ibustm[0:81], ibus;
wire [31:0] abus;
wire [31:0] bbus;
wire [31:0] dbus;
reg clk;

reg [31:0] dontcare, abusin[0:81], bbusin[0:81], dbusout[0:81];
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



cpu3 dut(.ibus(ibus), .clk(clk), .abus(abus), .bbus(bbus), .dbus(dbus));


initial begin


// ---------- 
// 1. Begin test clear SUB R13, R0, R0
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[0]={Rformat, 5'b00000, 5'b00000, 5'b01101, 5'b00000, SUB};
abusin[0]=32'h00000000;
bbusin[0]=32'h00000000;
dbusout[0]=32'h00000000;


// ----------
//  2. ADDI R1, R0, #0000
// ----------

//        opcode source1   dest      Immediate... 
ibustm[1]={ADDI, 5'b00000, 5'b00001, 16'h0000};
abusin[1]=32'h00000000;
bbusin[1]=32'h00000000;
dbusout[1]=32'h00000000;



// ---------- 
// 3. Begin TEST # 0 ADDI R0, R0, #FFFF
// ----------

//        opcode source1   dest      Immediate... 
ibustm[2]={ADDI, 5'b00000, 5'b00000, 16'hFFFF};
abusin[2]=32'h00000000;
bbusin[2]=32'hFFFFFFFF;
dbusout[2]=32'hFFFFFFFF;

// ---------- 
// 4. Begin TEST # 1  ADDI R30, R1,#AFC0
// ----------

//        opcode source1   dest      Immediate... 
ibustm[3]={ADDI, 5'b00001, 5'b11110, 16'hAFC0};
abusin[3]=32'h00000000;
bbusin[3]=32'hFFFFAFC0;
dbusout[3]=32'hFFFFAFC0;


// ---------- 
// 5. Begin TEST # 2 SUB R0, R0, R0
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[4]={Rformat, 5'b00000, 5'b00000, 5'b00000, 5'b00000, SUB};
abusin[4]=32'h00000000;
bbusin[4]=32'h00000000;
dbusout[4]=32'h00000000;

// ---------- 
// 6. Begin TEST # 3  ORI R3, R1, #7334 
// ----------

//        opcode source1   dest      Immediate... 
ibustm[5]={ORI, 5'b00001, 5'b00011, 16'h7334};
abusin[5]=32'h00000000;
bbusin[5]=32'h00007334;
dbusout[5]=32'h00007334;


// ---------- 
// 7. Begin TEST # 4 ORI R21, R1, #F98B 
// ----------

//        opcode source1   dest      Immediate... 
ibustm[6]={ORI, 5'b00001, 5'b10101, 16'hF98B};
abusin[6]=32'h00000000;
bbusin[6]=32'hFFFFF98B;
dbusout[6]=32'hFFFFF98B;


// ---------- 
// 8. Begin TEST # 5 XOR R16, R1, R3
// ----------

//         opcode   source1   source2   dest      shift     Function...
ibustm[7]={Rformat, 5'b00001, 5'b00011, 5'b10000, 5'b00000, XOR};
abusin[7]=32'h00000000;
bbusin[7]=32'h00007334;
dbusout[7]=32'h00007334;



// ---------- 
// 9. Begin TEST # 6 SUBI R31, R21, #0030
// ----------

//        opcode source1   dest      Immediate... 
ibustm[8]={SUBI, 5'b10101, 5'b11111, 16'h0030};
abusin[8]=32'hFFFFF98B;
bbusin[8]=32'h00000030;
dbusout[8]=32'hFFFFF95B;

// ---------- 
// 10. Begin TEST # 7 ORI R5, R1, #8ABF
// ----------

//        opcode source1   dest      Immediate... 
ibustm[9]={ORI, 5'b00001, 5'b00101, 16'h8ABF};
abusin[9]=32'h00000000;
bbusin[9]=32'hFFFF8ABF;
dbusout[9]=32'hFFFF8ABF;

// ------------ 
// 11. Begin TEST # 8 ORI R10, R1, #34FB  
// ------------

//        opcode source1   dest      Immediate... 
ibustm[10]={ORI, 5'b00001, 5'b01010, 16'h34FB};
abusin[10]=32'h00000000;
bbusin[10]=32'h000034FB;
dbusout[10]=32'h000034FB;


// ------------ 
// 12. Begin TEST # 9  XORI R18, R1, #0B31
// ------------

//         opcode source1   dest      Immediate... 
ibustm[11]={XORI, 5'b00001, 5'b10010, 16'h0B31};
abusin[11]=32'h00000000;
bbusin[11]=32'h00000B31;
dbusout[11]=32'h00000B31;


// --------- 
// 13. Begin TEST # 10  ADD R24, R16, R3
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[12]={Rformat, 5'b10000, 5'b00011, 5'b11000, 5'b00000, ADD};
abusin[12]=32'h00007334;
bbusin[12]=32'h00007334;
dbusout[12]=32'h0000E668;

// --------- 
// 14. Begin TEST # 11 OR R7, R10, R10
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[13]={Rformat, 5'b01010, 5'b01010, 5'b00111, 5'b00000, OR};
abusin[13]=32'h000034FB;
bbusin[13]=32'h000034FB;
dbusout[13]=32'h000034FB;

// --------- 
// 15. Begin TEST # 12 XORI R12, R21, #00F0
// ---------

//         opcode source1   dest      Immediate... 
ibustm[14]={XORI, 5'b10101, 5'b01100, 16'h00F0};
abusin[14]=32'hFFFFF98B;
bbusin[14]=32'h000000F0;
dbusout[14]=32'hFFFFF97B;

// --------- 
// 16. Begin TEST # 13 SUBI R28, R31, #0111 
// ---------

//         opcode source1   dest      Immediate... 
ibustm[15]={SUBI, 5'b11111, 5'b11100, 16'h0111};
abusin[15]=32'hFFFFF95B;
bbusin[15]=32'h00000111;
dbusout[15]=32'hFFFFF84A;



// --------- 
// 17. Begin TEST # 14 ADD R17, R3, R21
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[16]={Rformat, 5'b00011, 5'b10101, 5'b10001, 5'b00000, ADD};
abusin[16]=32'h00007334;
bbusin[16]=32'hFFFFF98B;
dbusout[16]=32'h00006CBF;

// ---------- 
// 18. Begin TEST # 15 ORI R15, R1, #328F
// ----------

//         opcode source1   dest      Immediate... 
ibustm[17]={ORI, 5'b00001, 5'b01111, 16'h328F};
abusin[17]=32'h00000000;
bbusin[17]=32'h0000328F;
dbusout[17]=32'h0000328F;


// --------- 
// 19. Begin TEST # 16 ADDI R13, R13, #FFFF
// ---------

//         opcode source1   dest      Immediate... 
ibustm[18]={ADDI, 5'b01101, 5'b01101, 16'hFFFF};
abusin[18]=32'h00000000;
bbusin[18]=32'hFFFFFFFF;
dbusout[18]=32'hFFFFFFFF;

// --------- 
// 20. Begin TEST # 17 ADDI R23, R1, #AFC0
// ---------

//         opcode source1   dest      Immediate... 
ibustm[19]={ADDI, 5'b00001, 5'b10111, 16'hAFC0};
abusin[19]=32'h00000000;
bbusin[19]=32'hFFFFAFC0;
dbusout[19]=32'hFFFFAFC0;

// --------- 
// 21. Begin TEST # 18 SUB R20, R1, R1
// ---------

//          opcode   source1   source2   dest      shift     Function...
ibustm[20]={Rformat, 5'b00001, 5'b00001, 5'b10100, 5'b00000, SUB};
abusin[20]=32'h00000000;
bbusin[20]=32'h00000000;
dbusout[20]=32'h00000000;


// ---------- 
// 22. Begin TEST # 19 ORI R19, R1, #7334
// ----------

//         opcode source1   dest      Immediate... 
ibustm[21]={ORI, 5'b00001, 5'b10011, 16'h7334};
abusin[21]=32'h00000000;
bbusin[21]=32'h00007334;
dbusout[21]=32'h00007334;


// -------- 
// 23. Begin TEST # 20 ORI R9, R13, #F98B
// --------

//         opcode source1   dest      Immediate... 
ibustm[22]={ORI, 5'b01101, 5'b01001, 16'hF98B};
abusin[22]=32'hFFFFFFFF;
bbusin[22]=32'hFFFFF98B;
dbusout[22]=32'hFFFFFFFF;

// -------- 
// 24. Begin TEST # 21 XOR R2, R13, R19
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[23]={Rformat, 5'b01101, 5'b10011, 5'b00010, 5'b00000, XOR};
abusin[23]=32'hFFFFFFFF;
bbusin[23]=32'h00007334;
dbusout[23]=32'hFFFF8CCB;


// -------- 
// 25. Begin TEST # 22 SUBI R26, R9, #0030
// --------

//         opcode source1   dest      Immediate... 
ibustm[24]={SUBI, 5'b01001, 5'b11010, 16'h0030};
abusin[24]=32'hFFFFFFFF;
bbusin[24]=32'h00000030;
dbusout[24]=32'hFFFFFFCF;


// -------- 
// 26. Begin TEST # 23 ORI R25, R1, #8ABF
// --------

//         opcode source1   dest      Immediate... 
ibustm[25]={ORI, 5'b00001, 5'b11001, 16'h8ABF};
abusin[25]=32'h00000000;
bbusin[25]=32'hFFFF8ABF;
dbusout[25]=32'hFFFF8ABF;


// -------- 
// 27. Begin TEST # 24 ORI R8, R13, #34FB
// --------

//         opcode source1   dest      Immediate... 
ibustm[26]={ORI, 5'b01101, 5'b01000, 16'h34FB};
abusin[26]=32'hFFFFFFFF;
bbusin[26]=32'h000034FB;
dbusout[26]=32'hFFFFFFFF;

// -------- 
// 28. Begin TEST # 25 XORI R27, R13, #0B31
// --------

//         opcode source1   dest      Immediate... 
ibustm[27]={XORI, 5'b01101, 5'b11011, 16'h0B31};
abusin[27]=32'hFFFFFFFF;
bbusin[27]=32'h00000B31;
dbusout[27]=32'hFFFFF4CE;


// -------- 
// 29. Begin TEST # 26 ADD R14, R2, R19
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[28]={Rformat, 5'b00010, 5'b10011, 5'b01110, 5'b00000, ADD};
abusin[28]=32'hFFFF8CCB;
bbusin[28]=32'h00007334;
dbusout[28]=32'hFFFFFFFF;

// -------- 
// 30. Begin TEST # 27 OR R4, R8, R8 
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[29]={Rformat, 5'b01000, 5'b01000, 5'b00100, 5'b00000, OR};
abusin[29]=32'hFFFFFFFF;
bbusin[29]=32'hFFFFFFFF;
dbusout[29]=32'hFFFFFFFF;


// -------- 
// 31. Begin TEST # 28 XORI R12, R21, #5555 
// --------

//         opcode source1   dest      Immediate... 
ibustm[30]={XORI, 5'b10101, 5'b01100, 16'h5555};
abusin[30]=32'hFFFFF98B;
bbusin[30]=32'h00005555;
dbusout[30]=32'hFFFFACDE;


// -------- 
// 32. Begin TEST # 29 ADDI R13, R0, #5555 
// --------

//         opcode source1   dest      Immediate... 
ibustm[31]={ADDI, 5'b00000, 5'b01101, 16'h5555};
abusin[31]=32'h00000000;
bbusin[31]=32'h00005555;
dbusout[31]=32'h00005555;

// -------- 
// 33. Begin TEST # 30 ORI R14, R0, #1234 
// --------

//         opcode source1   dest      Immediate... 
ibustm[32]={ORI, 5'b00000, 5'b01110, 16'h1234};
abusin[32]=32'h00000000;
bbusin[32]=32'h00001234;
dbusout[32]=32'h00001234;

// -------- 
// 34. Begin TEST # 31 ORI R0, R0, 1234  
// --------

//         opcode source1   dest      Immediate... 
ibustm[33]={ORI, 5'b00000, 5'b00000, 16'h1234};
abusin[33]=32'h00000000;
bbusin[33]=32'h00001234;
dbusout[33]=32'h00001234; //never flushes back to memory as a number

// -------- 
// 35. Begin TEST # 32 ADD R15, R13, R14  
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[34]={Rformat, 5'b01101, 5'b01110, 5'b01111, 5'b00000, ADD};
abusin[34]=32'h00005555;
bbusin[34]=32'h00001234;
dbusout[34]=32'h00006789;

// -------- 
// 36. Begin TEST # 33 OR R15, R13, R14  
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[35]={Rformat, 5'b01101, 5'b01110, 5'b01111, 5'b00000, OR};
abusin[35]=32'h00005555;
bbusin[35]=32'h00001234;
dbusout[35]=32'h00005775;

// -------- 
// 37. Begin TEST # 34 AND R15, R13, R14  
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[36]={Rformat, 5'b01101, 5'b01110, 5'b01111, 5'b00000, AND};
abusin[36]=32'h00005555;
bbusin[36]=32'h00001234;
dbusout[36]=32'h00001014;

// -------- 
// 38. Begin TEST # 35 XOR R15, R13, R14  
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[37]={Rformat, 5'b01101, 5'b01110, 5'b01111, 5'b00000, XOR};
abusin[37]=32'h00005555;
bbusin[37]=32'h00001234;
dbusout[37]=32'h00004761;

// -------- 
// 39. Begin TEST # 36 SUB R15, R13, R14  
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[38]={Rformat, 5'b01101, 5'b01110, 5'b01111, 5'b00000, SUB};
abusin[38]=32'h00005555;
bbusin[38]=32'h00001234;
dbusout[38]=32'h00004321;

// -------- 
// 40. Begin TEST # 37 ADDI R15, R13 #AAAA  
// --------

//         opcode source1   dest      Immediate... 
ibustm[39]={ADDI, 5'b01101, 5'b01111, 16'hAAAA};
abusin[39]=32'h00005555;
bbusin[39]=32'hFFFFAAAA;
dbusout[39]=32'hFFFFFFFF;

// -------- 
// 41. Begin TEST # 38 XORI R15, R13 #1234  
// --------

//         opcode source1   dest      Immediate... 
ibustm[40]={XORI, 5'b01101, 5'b01111, 16'h1234};
abusin[40]=32'h00005555;
bbusin[40]=32'h00001234;
dbusout[40]=32'h00004761;

// -------- 
// 42. Begin TEST # 39 SUBI R15, R13 #1234  
// --------

//         opcode source1   dest      Immediate... 
ibustm[41]={SUBI, 5'b01101, 5'b01111, 16'h1234};
abusin[41]=32'h00005555;
bbusin[41]=32'h00001234;
dbusout[41]=32'h00004321;

// -------- 
// 43. Begin TEST # 40 ANDI R15, R13 #1234  
// --------

//         opcode source1   dest      Immediate... 
ibustm[42]={ANDI, 5'b01101, 5'b01111, 16'h1234};
abusin[42]=32'h00005555;
bbusin[42]=32'h00001234;
dbusout[42]=32'h00001014;

// -------- 
// 44. Begin TEST # 41 ANDI R15, R13 #1234  
// --------

//         opcode source1   dest      Immediate... 
ibustm[43]={ORI, 5'b01101, 5'b01111, 16'h1234};
abusin[43]=32'h00005555;
bbusin[43]=32'h00001234;
dbusout[43]=32'h00005775;


// -------- 
// 45. Begin TEST # 42 ADD R16, R13, R10
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[44]={Rformat, 5'b01101, 5'b00000, 5'b10000, 5'b00000, ADD};
abusin[44]=32'h00005555;
bbusin[44]=32'h00000000;
dbusout[44]=32'h00005555;

// -------- 
// 46. Begin TEST # 43 ADD R16, R13, R13
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[45]={Rformat, 5'b01101, 5'b01101, 5'b10000, 5'b00000, ADD};
abusin[45]=32'h00005555;
bbusin[45]=32'h00005555;
dbusout[45]=32'h0000AAAA;

// -------- 
// 47. Begin TEST # 44 OR R17, R0, R0
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[46]={Rformat, 5'b00000, 5'b00000, 5'b10001, 5'b00000, OR};
abusin[46]=32'h00000000;
bbusin[46]=32'h00000000;
dbusout[46]=32'h00000000;

// -------- 
// 48. Begin TEST # 45 ADD R16, R16, R13
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[47]={Rformat, 5'b10000, 5'b01101, 5'b10000, 5'b00000, ADD};
abusin[47]=32'h0000AAAA;
bbusin[47]=32'h00005555;
dbusout[47]=32'h0000FFFF;

// -------- 
// 49. Begin TEST # 46 OR R16, R15, R14
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[48]={Rformat, 5'b01111, 5'b01110, 5'b10000, 5'b00000, OR};
abusin[48]=32'h00005775;
bbusin[48]=32'h00001234;
dbusout[48]=32'h00005775;

// -------- 
// 50. Begin TEST # 47 AND R16, R15, R14
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[49]={Rformat, 5'b01111, 5'b01110, 5'b10000, 5'b00000, AND};
abusin[49]=32'h00005775;
bbusin[49]=32'h00001234;
dbusout[49]=32'h00001234;

// -------- 
// 51. Begin TEST # 48 XOR R16, R15, R14
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[50]={Rformat, 5'b01111, 5'b01110, 5'b10000, 5'b00000, XOR};
abusin[50]=32'h00005775;
bbusin[50]=32'h00001234;
dbusout[50]=32'h00004541;

// -------- 
// 52. Begin TEST # 49 SUB R16, R15, R14
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[51]={Rformat, 5'b01111, 5'b01110, 5'b10000, 5'b00000, SUB};
abusin[51]=32'h00005775;
bbusin[51]=32'h00001234;
dbusout[51]=32'h00004541;


// -------- 
// 53. Begin TEST # 50 ADDI R16, R15, F000
// --------

//         opcode source1   dest      Immediate... 
ibustm[52]={ADDI, 5'b01111, 5'b10000, 16'hF000};
abusin[52]=32'h00005775;
bbusin[52]=32'hFFFFF000;
dbusout[52]=32'h00004775;


// -------- 
// 54. Begin TEST # 51 SUBI R16, R15, F000
// --------

//         opcode source1   dest      Immediate... 
ibustm[53]={SUBI, 5'b01111, 5'b10000, 16'hF000};
abusin[53]=32'h00005775;
bbusin[53]=32'hFFFFF000;
dbusout[53]=32'h00006775;

// -------- 
// 55. Begin TEST # 52 ORI R16, R15, F000
// --------

//         opcode source1   dest      Immediate... 
ibustm[54]={ORI, 5'b01111, 5'b10000, 16'hF000};
abusin[54]=32'h00005775;
bbusin[54]=32'hFFFFF000;
dbusout[54]=32'hFFFFF775;

// -------- 
// 56. Begin TEST # 53 ANDI R16, R15, F000
// --------

//         opcode source1   dest      Immediate... 
ibustm[55]={ANDI, 5'b01111, 5'b10000, 16'hF000};
abusin[55]=32'h00005775;
bbusin[55]=32'hFFFFF000;
dbusout[55]=32'h00005000;

// -------- 
// 57. Begin TEST # 54 XORI R16, R15, F000
// --------

//         opcode source1   dest      Immediate... 
ibustm[56]={ANDI, 5'b01111, 5'b10000, 16'hF000};
abusin[56]=32'h00005775;
bbusin[56]=32'hFFFFF000;
dbusout[56]=32'h00005000;

// -------- 
// 58. Begin TEST # 55 ADD R17, R15, R15
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[57]={Rformat, 5'b01111, 5'b01111, 5'b10001, 5'b00000, ADD};
abusin[57]=32'h00005775;
bbusin[57]=32'h00005775;
dbusout[57]=32'h0000AEEA;


// -------- 
// 59. Begin TEST # 56 SUB R17, R15, R15
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[58]={Rformat, 5'b01111, 5'b01111, 5'b10001, 5'b00000, SUB};
abusin[58]=32'h00005775;
bbusin[58]=32'h00005775;
dbusout[58]=32'h0000000;

// -------- 
// 60. Begin TEST # 57 AND R17, R15, R16
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[59]={Rformat, 5'b01111, 5'b10000, 5'b10001, 5'b00000, AND};
abusin[59]=32'h00005775;
bbusin[59]=32'h00005000;
dbusout[59]=32'h00005000;

// -------- 
// 61. Begin TEST # 58 OR R17, R15, R16
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[60]={Rformat, 5'b01111, 5'b10000, 5'b10001, 5'b00000, OR};
abusin[60]=32'h00005775;
bbusin[60]=32'h00005000;
dbusout[60]=32'h00005775;

// -------- 
// 62. Begin TEST # 59 OR R17, R15, R16
// --------

//          opcode   source1   source2   dest      shift     Function...
ibustm[61]={Rformat, 5'b01111, 5'b10000, 5'b10001, 5'b00000, XOR};
abusin[61]=32'h00005775;
bbusin[61]=32'h00005000;
dbusout[61]=32'h00000775;


// -------- 
// 63. Begin TEST # 60 ADDI R17 R16 #FFFF
// --------

//         opcode source1   dest      Immediate... 
ibustm[62]={ADDI, 5'b10000, 5'b10001, 16'hFFFF};
abusin[62]=32'h00005000;
bbusin[62]=32'hFFFFFFFF;
dbusout[62]=32'h00004FFF;

// -------- 
// 64. Begin TEST # 61 SUBI R17 R16 #FFFF
// --------

//         opcode source1   dest      Immediate... 
ibustm[63]={SUBI, 5'b10000, 5'b10001, 16'hFFFF};
abusin[63]=32'h00005000;
bbusin[63]=32'hFFFFFFFF;
dbusout[63]=32'h00005001;

// -------- 
// 65. Begin TEST # 62 ANDI R17 R16 #FFFF
// --------

//         opcode source1   dest      Immediate... 
ibustm[64]={ANDI, 5'b10000, 5'b10001, 16'hFFFF};
abusin[64]=32'h00005000;
bbusin[64]=32'hFFFFFFFF;
dbusout[64]=32'h00005000;

// -------- 
// 66. Begin TEST # 63 ORI R17 R16 #FFFF
// --------

//         opcode source1   dest      Immediate... 
ibustm[65]={ORI, 5'b10000, 5'b10001, 16'hFFFF};
abusin[65]=32'h00005000;
bbusin[65]=32'hFFFFFFFF;
dbusout[65]=32'hFFFFFFFF;


// -------- 
// 67. Begin TEST # 64 XORI R17 R16 #FFFF
// --------

//         opcode source1   dest      Immediate... 
ibustm[66]={XORI, 5'b10000, 5'b10001, 16'hFFFF};
abusin[66]=32'h00005000;
bbusin[66]=32'hFFFFFFFF;
dbusout[66]=32'hFFFFAFFF;

// -------- 
// 68. Begin TEST # 65 ADDI R18 R10 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[67]={ADDI, 5'b01010, 5'b10010, 16'hF123};
abusin[67]=32'h000034FB;
bbusin[67]=32'hFFFFF123;
dbusout[67]=32'h0000261E;

// -------- 
// 69. Begin TEST # 66 ORI R18 R10 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[68]={ORI, 5'b01010, 5'b10010, 16'hF123};
abusin[68]=32'h000034FB;
bbusin[68]=32'hFFFFF123;
dbusout[68]=32'hFFFFF5FB;

// -------- 
// 70. Begin TEST # 67 ANDI R18 R10 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[69]={ANDI, 5'b01010, 5'b10010, 16'hF123};
abusin[69]=32'h000034FB;
bbusin[69]=32'hFFFFF123;
dbusout[69]=32'h00003023;

// -------- 
// 71. Begin TEST # 68 XORI R18 R10 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[70]={XORI, 5'b01010, 5'b10010, 16'hF123};
abusin[70]=32'h000034FB;
bbusin[70]=32'hFFFFF123;
dbusout[70]=32'hFFFFC5D8;

// -------- 
// 72. Begin TEST # 69 XORI R19 R10 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[71]={XORI, 5'b01010, 5'b10011, 16'hF123};
abusin[71]=32'h000034FB;
bbusin[71]=32'hFFFFF123;
dbusout[71]=32'hFFFFC5D8;

// -------- 
// 73. Begin TEST # 70 XORI R20 R18 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[72]={XORI, 5'b10010, 5'b10100, 16'hF123};
abusin[72]=32'hFFFFC5D8;
bbusin[72]=32'hFFFFF123;
dbusout[72]=32'h000034FB;

// -------- 
// 74. Begin TEST # 71 XORI R21 R19 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[73]={XORI, 5'b10011, 5'b10101, 16'hF123};
abusin[73]=32'hFFFFC5D8;
bbusin[73]=32'hFFFFF123;
dbusout[73]=32'h000034FB;

// -------- 
// 75. Begin TEST # 72 XORI R22 R20 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[74]={XORI, 5'b10100, 5'b10110, 16'hF123};
abusin[74]=32'h000034FB;
bbusin[74]=32'hFFFFF123;
dbusout[74]=32'hFFFFC5D8;

// -------- 
// 76. Begin TEST # 73 XORI R23 R21 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[75]={XORI, 5'b10101, 5'b10111, 16'hF123};
abusin[75]=32'h000034FB;
bbusin[75]=32'hFFFFF123;
dbusout[75]=32'hFFFFC5D8;

// -------- 
// 77. Begin TEST # 74 XORI R24 R22 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[76]={XORI, 5'b10110, 5'b11000, 16'hF123};
abusin[76]=32'hFFFFC5D8;
bbusin[76]=32'hFFFFF123;
dbusout[76]=32'h000034FB;

// -------- 
// 78. Begin TEST # 75 XORI R25 R23 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[77]={XORI, 5'b10111, 5'b11001, 16'hF123};
abusin[77]=32'hFFFFC5D8;
bbusin[77]=32'hFFFFF123;
dbusout[77]=32'h000034FB;

// -------- 
// 79. Begin TEST # 76 XORI R26 R24 #F123
// --------

//         opcode source1   dest      Immediate... 
ibustm[78]={XORI, 5'b11000, 5'b11010, 16'hF123};
abusin[78]=32'h000034FB;
bbusin[78]=32'hFFFFF123;
dbusout[78]=32'hFFFFC5D8;


// -------- 
// 80. Testing TEST #77
// --------

ibustm[79]= 32'hx;
abusin[79]= 32'hx;
bbusin[79]= 32'hx;
dbusout[79]=32'hx;

// -------- 
// 81. Testing TEST #78
// --------

ibustm[80]= 32'hx;
abusin[80]= 32'hx;
bbusin[80]= 32'hx;
dbusout[80]=32'hx;

// -------- 
// 81. Testing OUTPUT OF TEST #78
// --------

ibustm[81]= 32'hx;
abusin[81]= 32'hx;
bbusin[81]= 32'hx;
dbusout[81]=32'hx;

// 31*2
ntests = 81 ;

$timeformat(-9,1,"ns",12); 

end


initial begin
  error = 0;
  clk=0;
  for (k=0; k<= ntests; k=k+1) begin
    
    //check input operands from 2nd previous instruction
    
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    if (k >= 3) begin
      $display ("  Testing input operands for instruction %d", k-3);
      $display ("    Your abus =    %b", abus);
      $display ("    Correct abus = %b", abusin[k-3]);
      $display ("    Your bbus =    %b", bbus);
      $display ("    Correct bbus = %b", bbusin[k-3]);
     
      if ((abusin[k-3] !== abus) ||(bbusin[k-3] !== bbus)) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    
    end

    clk=1;
    #25	
    
    //check output operand from 3rd previous instruction on bbus
    
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    if (k >= 3) begin
      $display ("  Testing output operand for instruction %d", k-3);
      $display ("    Your dbus =    %b", dbus);
      $display ("    Correct dbus = %b", dbusout[k-3]);
      
      if (dbusout[k-3] !== dbus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
      
    end

    //put next instruction on ibus
    ibus=ibustm[k];
    $display ("  ibus=%b %b %b %b %b for instruction %d", ibus[31:26], ibus[25:21], ibus[20:16], ibus[15:11], ibus[10:0], k);
    clk = 0;
    #25
    error = error;
  
  end
 
  if ( error !== 0) begin 
    $display("--------- SIMULATION UNSUCCESFUL - MISMATCHES HAVE OCCURED----------");
    $display(" No. Of Errors = %d", error);
  end
  if ( error == 0) 
    $display("---------YOU DID IT!! SIMULATION SUCCESFULLY FINISHED----------");

end

endmodule