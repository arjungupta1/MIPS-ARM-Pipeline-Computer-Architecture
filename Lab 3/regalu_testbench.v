`timescale 1ns/10ps
module regalu_testbench();

//------ Ports Declaration-----//
reg [31:0] Aselect, Bselect, Dselect;
reg [2:0] S, stm_S[0:79];
reg Cin, clk, stm_CL[0:79], stm_Cin[0:79];
wire [31:0] abus;
wire [31:0] bbus;
wire [31:0] dbus;
reg [31:0] dontcare, ref_abus[0:79], ref_bbus[0:79], ref_dbus[0:79], asel[0:79], bsel[0:79], dsel[0:79]; 
integer error, i, k, ntests;



regalu dut(.Aselect(Aselect), .Bselect(Bselect), .Dselect(Dselect), .clk(clk), .abus(abus), .bbus(bbus), .dbus(dbus), .S(S), .Cin(Cin));


initial begin


// ---------- NO TEST 1a ---------- //
stm_CL[0]=0;
stm_Cin[0]=0;
stm_S[0] =3'b001;
asel[0]= 32'h00000001;
bsel[0]=32'h00000001;
dsel[0]=32'h00000001;
ref_abus[0]=32'h00000000;
ref_bbus[0]=32'h00000000; // Reading R0 for 00000000 in abus and bbus for input to alu.(XNOR R0,R0 )
ref_dbus[0]=32'hxxxxxxxx;

stm_CL[1]=1;
stm_Cin[1]=0;
stm_S[1]=3'b001;
asel[1]= 32'h00000001;
bsel[1]=32'h00000001;
dsel[1]=32'h00000001;
ref_abus[1]=32'hxxxxxxxx;
ref_bbus[1]=32'hxxxxxxxx;
ref_dbus[1]=32'hxxxxxxxx; //Doing nothing with the register

// ----------  XNOR TEST 1b ----------//
stm_CL[2]=0;
stm_Cin[2]=0;
stm_S[2]=3'b001;
asel[2]= 32'h00000001;
bsel[2]=32'h00000001;
dsel[2]=32'h00000001;
ref_abus[2]=32'h00000000;
ref_bbus[2]=32'h00000000; // Reading R0 in abus and bbus for input to alu.(XNOR R0,R0)
ref_dbus[2]=32'hxxxxxxxx;

stm_CL[3]=1;
stm_Cin[3]=0;
stm_S[3]=3'b110;
asel[3]= 32'h00000001;
bsel[3]= 32'h00000001;
dsel[3]=32'h00000002;
ref_abus[3]=32'hxxxxxxxx;
ref_bbus[3]=32'hxxxxxxxx;
ref_dbus[3]=32'hFFFFFFFF; // Writing R1 with FFFFFFFF (Result of XNOR R0,R0) From alu.


// ----------  XNOR TEST 2 ---------- //

stm_CL[4]=0;
stm_Cin[4]=0;
stm_S[4]=3'b001;
asel[4]=32'h00000001;
bsel[4]=32'h00000002;
dsel[4]=32'h00000001;
ref_abus[4]=32'h00000000;
ref_bbus[4]=32'hFFFFFFFF; //Reading R0 and R1 for input to alu (OR R0,R1)
ref_dbus[4]=32'hxxxxxxxx;

stm_CL[5]=1;
stm_Cin[5]=0;
stm_S[5]=3'b100;
asel[5]=32'h00000001;
bsel[5]=32'h00000001;
dsel[5]=32'h00000004;
ref_abus[5]=32'hxxxxxxxx;
ref_bbus[5]=32'hxxxxxxxx;
ref_dbus[5]=32'hFFFFFFFF; // Writing R2 with FFFFFFFF (Result of XNOR R0,R1) From alu. 


// ---------- OR TEST 3 ---------- //
stm_CL[6]=0;
stm_Cin[6]=0;
stm_S[6]=3'b100;
asel[6]=32'h00000004;
bsel[6]=32'h00000002;
dsel[6]=32'h00000001;
ref_abus[6]=32'hFFFFFFFF; 
ref_bbus[6]=32'hFFFFFFFF; //Reading R1 and R2 for input to alu (XOR R1,R2) 
ref_dbus[6]=32'hxxxxxxxx;

stm_CL[7]=1;
stm_Cin[7]=0;
stm_S[7]=3'b000;
asel[7]=32'h00000001;
bsel[7]=32'h00000001;
dsel[7]=32'h00000008; 
ref_abus[7]=32'hxxxxxxxx;
ref_bbus[7]=32'hxxxxxxxx;
ref_dbus[7]=32'hFFFFFFFF; // Writing R3 with FFFFFFFF ( Result of OR R0,R1) from alu.


// ---------- XOR TEST 4 ---------- //
stm_CL[8]=0;
stm_Cin[8]=0;
stm_S[8]=3'b000;
asel[8]=32'h00000008;
bsel[8]=32'h00000004;
dsel[8]=32'h00000000;
ref_abus[8]=32'hFFFFFFFF; 
ref_bbus[8]=32'hFFFFFFFF; //Reading R3 and R2 for input to alu (XNOR R3,R2)
ref_dbus[8]=32'hxxxxxxxx;

stm_CL[9]=1;
stm_Cin[9]=0;
stm_S[9]=3'b001;
asel[9]=32'h00000001;
bsel[9]=32'h00000001;
dsel[9]=32'h00000010;
ref_abus[9]=32'hxxxxxxxx;
ref_bbus[9]=32'hxxxxxxxx;
ref_dbus[9]=32'h00000000; // Writing R4 With 00000000 (Result of XOR R1,R2) from alu



// ------------ XNOR NOT TEST ------------ //
stm_CL[10]=0;
stm_Cin[10]=0;
stm_S[10]=3'b001;
asel[10]=32'h00000008; 
bsel[10]=32'h00000010; 
dsel[10]=32'h00000000; 
ref_abus[10]=32'hFFFFFFFF; 
ref_bbus[10]=32'h00000000; // Reading R3 and R4 for input to alu (NOR R3,R4)
ref_dbus[10]=32'hxxxxxxxx;

stm_CL[11]=1;
stm_Cin[11]=0;
stm_S[11]=3'b101;
asel[11]=32'h00000001;
bsel[11]=32'h00000001;
dsel[11]=32'h00000020;
ref_abus[11]=32'hxxxxxxxx;
ref_bbus[11]=32'hxxxxxxxx;
ref_dbus[11]=32'hFFFFFFFF; // Writing R5 with FFFFFFFF (Result of XNOR R3,R2) from alu

// ------------ NOR TEST  ---------------- //

stm_CL[12]=0;
stm_Cin[12]=0;
stm_S[12]=3'b101;
asel[12]=32'h00000010;
bsel[12]=32'h00000020;
dsel[12]=32'h00000000;
ref_abus[12]=32'h00000000; 
ref_bbus[12]=32'hFFFFFFFF; //Reading R4,R5 for input to alu (ADD R4,R5)
ref_dbus[12]=32'hxxxxxxxx;

stm_CL[13]=1;
stm_Cin[13]=0;
stm_S[13]=3'b010;
asel[13]=32'h00000001;
bsel[13]=32'h00000001;
dsel[13]=32'h00000040;
ref_abus[13]=32'hxxxxxxxx;
ref_bbus[13]=32'hxxxxxxxx;
ref_dbus[13]=32'h00000000; // Writing R6 with 00000000 (Result of NOR R3,R4) From alu.

// ------------- ADD TEST --------------//
stm_CL[14]=0;
stm_Cin[14]=0;
stm_S[14]=3'b010;
asel[14]=32'h00000020;
bsel[14]=32'h00000040;
dsel[14]=32'h00000000;
ref_abus[14]=32'hFFFFFFFF;
ref_bbus[14]=32'h00000000; // Reading R5, R6 for input to alu (XOR R5,R6)
ref_dbus[14]=32'hxxxxxxxx;

stm_CL[15]=1;
stm_Cin[15]=0;
stm_S[15]=3'b000;
asel[15]=32'h00000001;
bsel[15]=32'h00000001;
dsel[15]=32'h00000080;
ref_abus[15]=32'hxxxxxxxx;
ref_bbus[15]=32'hxxxxxxxx;
ref_dbus[15]=32'hFFFFFFFF; // Writing R7 with FFFFFFFF (Result of ADD R4,R5)

// ------------ XOR TEST ---------------//

stm_CL[16]=0;
stm_Cin[16]=0;
stm_S[16]=3'b000;
asel[16]=32'h00000040;
bsel[16]=32'h00000080;
dsel[16]=32'h00000000;
ref_abus[16]=32'h00000000;  
ref_bbus[16]=32'hFFFFFFFF; // Reading R6,R7 for input to alu (XNOR R6,R7)
ref_dbus[16]=32'hxxxxxxxx;

stm_CL[17]=1;
stm_Cin[17]=0;
stm_S[17]=3'b001;
asel[17]=32'h00000001;
bsel[17]=32'h00000001;
dsel[17]=32'h00000100;
ref_abus[17]=32'hxxxxxxxx;
ref_bbus[17]=32'hxxxxxxxx;
ref_dbus[17]=32'hFFFFFFFF; // Writing R8 with FFFFFFFF (Result of XOR R5,R6)


// ------------ XNOR TEST -------------//

stm_CL[18]=0;
stm_Cin[18]=0;
stm_S[18]=3'b001;
asel[18]=32'h00000080;
bsel[18]=32'h00000100;
dsel[18]=32'h00000100;
ref_abus[18]=32'hFFFFFFFF; 
ref_bbus[18]=32'hFFFFFFFF; // Reading R7,R8 for input to alu (OR R7,R8)
ref_dbus[18]=32'hxxxxxxxx;

stm_CL[19]=1;
stm_Cin[19]=0;
stm_S[19]=3'b100;
asel[19]=32'h00000001;
bsel[19]=32'h00000001;
dsel[19]=32'h00000200;
ref_abus[19]=32'hxxxxxxxx;
ref_bbus[19]=32'hxxxxxxxx;
ref_dbus[19]=32'h00000000; // Writing R9 with 00000000 (Result of XNOR R6,R7)

// ------------- OR TEST ------------//

stm_CL[20]=0;
stm_Cin[20]=0;
stm_S[20]=3'b100;
asel[20]=32'h00000100;
bsel[20]=32'h00000200;
dsel[20]=32'h00000000;
ref_abus[20]=32'hFFFFFFFF; 
ref_bbus[20]=32'h00000000; // Reading R8,R9 for input to alu (NOR R8,R9)
ref_dbus[20]=32'hxxxxxxxx;

stm_CL[21]=1;
stm_Cin[21]=0;
stm_S[21]=3'b101;
asel[21]=32'h00000001;
bsel[21]=32'h00000001;
dsel[21]=32'h00000400;
ref_abus[21]=32'hxxxxxxxx;
ref_bbus[21]=32'hxxxxxxxx;
ref_dbus[21]=32'hFFFFFFFF; //Writing R10 with FFFFFFFF (Result of OR R7,R8)

// ------------ NOR TEST -------------//

stm_CL[22]=0;
stm_Cin[22]=0;
stm_S[22]=3'b101;
asel[22]=32'h00000200;
bsel[22]=32'h00000400;
dsel[22]=32'h00000000;
ref_abus[22]=32'h00000000;
ref_bbus[22]=32'hFFFFFFFF; //Reading R9,R10 for input to alu (AND R9,R10)
ref_dbus[22]=32'hxxxxxxxx;

stm_CL[23]=1;
stm_Cin[23]=0;
stm_S[23]=3'b110;
asel[23]=32'h0000001;
bsel[23]=32'h0000001;
dsel[23]=32'h0000800;
ref_abus[23]=32'hxxxxxxxx;
ref_bbus[23]=32'hxxxxxxxx;
ref_dbus[23]=32'h00000000; // Writing R11 with 00000000 (Result of NOR R8,R9)

// ------------ AND TEST ---------------//

stm_CL[24]=0;
stm_Cin[24]=0;
stm_S[24]=3'b110;
asel[24]=32'h00000400;
bsel[24]=32'h00000800;
dsel[24]=32'h00000000;
ref_abus[24]=32'hFFFFFFFF;
ref_bbus[24]=32'h00000000; // Reading R10,R11 for input to alu (XOR R10,R11)
ref_dbus[24]=32'hxxxxxxxx;

stm_CL[25]=1;
stm_Cin[25]=0;
stm_S[25]=3'b000;
asel[25]=32'h00000001;
bsel[25]=32'h00000001;
dsel[25]=32'h00001000;
ref_abus[25]=32'hxxxxxxxx;
ref_bbus[25]=32'hxxxxxxxx;
ref_dbus[25]=32'h00000000; //Writing R12 with 00000000 (Result of AND R9,R10)


// ------------ XOR TEST --------------//

stm_CL[26]=0;
stm_Cin[26]=0;
stm_S[26]=3'b000;
asel[26]=32'h00000800;
bsel[26]=32'h00001000;
dsel[26]=32'h00000000;
ref_abus[26]=32'h00000000;
ref_bbus[26]=32'h00000000; //Reading R11,R12  for input to alu (XNOR R11,R12)
ref_dbus[26]=32'hxxxxxxxx;

stm_CL[27]=1;
stm_Cin[27]=0;
stm_S[27]=3'b001;
asel[27]=32'h00000001;
bsel[27]=32'h00000001;
dsel[27]=32'h00002000;
ref_abus[27]=32'hxxxxxxxx;
ref_bbus[27]=32'hxxxxxxxx;
ref_dbus[27]=32'hFFFFFFFF; // Writing R13 with FFFFFFFF (Result of XOR R10,R11)


// ------------ XNOR TEST ---------------//
stm_CL[28]=0;
stm_Cin[28]=0;
stm_S[28]=3'b001;
asel[28]=32'h00001000;
bsel[28]=32'h00002000;
dsel[28]=32'h00000000;
ref_abus[28]=32'h00000000;
ref_bbus[28]=32'hFFFFFFFF; // Reading R12,R13 for input to alu (OR R12,R13)
ref_dbus[28]=32'hxxxxxxxx;

stm_CL[29]=1;
stm_Cin[29]=1;
stm_S[29]=3'b110;
asel[29]=32'h00000001;
bsel[29]=32'h00000001;
dsel[29]=32'h00004000;
ref_abus[29]=32'hxxxxxxxx;
ref_bbus[29]=32'hxxxxxxxx;
ref_dbus[29]=32'hFFFFFFFF; //Writing R14 with FFFFFFFF (Result of XNOR R11,R12)

// MORE TESTS ADDED HERE
// ------------ AND TEST ---------------//
stm_CL[30]=0;
stm_Cin[30]=0;
stm_S[30]=3'b110; //0 XNOR 0 
asel[30]=32'h00004000;
bsel[30]=32'h00004000;
dsel[30]=32'h00000001;
ref_abus[30]=32'hFFFFFFFF;
ref_bbus[30]=32'hFFFFFFFF; // Reading R14, R14 as inputs to ALU
ref_dbus[30]=32'hxxxxxxxx;


stm_CL[31]=1;
stm_Cin[31]=0;
stm_S[31]=3'b100;
asel[31]=32'h00000001;
bsel[31]=32'h00000001;
dsel[31]=32'h00008000;
ref_abus[31]=32'hxxxxxxxx;
ref_bbus[31]=32'hxxxxxxxx;
ref_dbus[31]=32'h00000000; //Writing R15 with 00000000 (Result of AND R12 , R13)

// ------------ NOR TEST ---------------//
stm_CL[32]=0;
stm_Cin[32]=0;
stm_S[32]=3'b100;
asel[32]=32'h00000001;
bsel[32]=32'h00000008;
dsel[32]=32'h00008000;
ref_abus[32]=32'h00000000;
ref_bbus[32]=32'hFFFFFFFF;
ref_dbus[32]=32'hxxxxxxxx; //Reading R0 and R3 as inputs to ALu


stm_CL[33]=1;
stm_Cin[33]=0;
stm_S[33]=3'b101;
asel[33]=32'h00000001;
bsel[33]=32'h00000001;
dsel[33]=32'h00010000;  
ref_abus[33]=32'hxxxxxxxx;
ref_bbus[33]=32'hxxxxxxxx;
ref_dbus[33]=32'hFFFFFFFF; //Writing R16 with FFFFFFFF (Result of OR R14, R14)


// ------------ SUBTRACT TEST ---------------//

stm_CL[34]=0;
stm_Cin[34]=0;
stm_S[34]=3'b101;
asel[34]=32'h00001000;
bsel[34]=32'h00010000;
dsel[34]=32'h00000001;  
ref_abus[34]=32'h00000000;
ref_bbus[34]=32'hFFFFFFFF;
ref_dbus[34]=32'hxxxxxxxx; //Reading R12 and R16 as inputs to ALU


stm_CL[35]=1;
stm_Cin[35]=1;
stm_S[35]=3'b011;
asel[35]=32'h00000001;
bsel[35]=32'h00000001;
dsel[35]=32'h00020000;  
ref_abus[35]=32'hxxxxxxxx;
ref_bbus[35]=32'hxxxxxxxx;
ref_dbus[35]=32'h00000000; //Writing R17 with 00000000 (Result of NOR R0, R3)

// ------------ XNOR TEST ---------------//

stm_CL[36]=0;
stm_Cin[36]=0;
stm_S[36]=3'b011;
asel[36]=32'h00002000;
bsel[36]=32'h00020000;
dsel[36]=32'h00000001;  
ref_abus[36]=32'hFFFFFFFF;
ref_bbus[36]=32'h00000000;
ref_dbus[36]=32'hxxxxxxxx; //Reading R13 and R17 as inputs to ALU


stm_CL[37]=1;
stm_Cin[37]=0;
stm_S[37]=3'b001;
asel[37]=32'h00000001;
bsel[37]=32'h00000001;
dsel[37]=32'h00040000;  
ref_abus[37]=32'hxxxxxxxx;
ref_bbus[37]=32'hxxxxxxxx;
ref_dbus[37]=32'h00000000; //Writing R18 with 00000000 (Result of SUB R12, R16)

// ------------ XNOR TEST ---------------//

stm_CL[38]=0;
stm_Cin[38]=0;
stm_S[38]=3'b001;
asel[38]=32'h00000001;
bsel[38]=32'h00010000;
dsel[38]=32'h00000001;  
ref_abus[38]=32'h00000000;
ref_bbus[38]=32'hFFFFFFFF;
ref_dbus[38]=32'hxxxxxxxx; //Reading R0 and R16 as inputs to ALU

stm_CL[39]=1;
stm_Cin[39]=0;
stm_S[39]=3'b000;
asel[39]=32'h00000001;
bsel[39]=32'h00000001;
dsel[39]=32'h00080000;  
ref_abus[39]=32'hxxxxxxxx;
ref_bbus[39]=32'hxxxxxxxx;
ref_dbus[39]=32'h00000000; //Writing R19 with 00000000 (Result of XNOR R13, R17)


// ------------ XNOR TEST ---------------//

stm_CL[40]=0;
stm_Cin[40]=0;
stm_S[40]=3'b000;
asel[40]=32'h00002000;
bsel[40]=32'h00040000;
dsel[40]=32'h00000001;  
ref_abus[40]=32'hFFFFFFFF;
ref_bbus[40]=32'h00000000;
ref_dbus[40]=32'hxxxxxxxx; //Reading R12 and R17 as inputs to ALU

stm_CL[41]=1;
stm_Cin[41]=0;
stm_S[41]=3'b010;
asel[41]=32'h00000001;
bsel[41]=32'h00000001;
dsel[41]=32'h00080000;  
ref_abus[41]=32'hxxxxxxxx;
ref_bbus[41]=32'hxxxxxxxx;
ref_dbus[41]=32'hFFFFFFFF; //Writing R19 with FFFFFFFF (Result of XOR R0, R16)

// ------------ ADD TEST ---------------//

stm_CL[42]=0;
stm_Cin[42]=0;
stm_S[42]=3'b010;
asel[42]=32'h00002000;
bsel[42]=32'h00000001;
dsel[42]=32'h00000001;  
ref_abus[42]=32'hFFFFFFFF;
ref_bbus[42]=32'h00000000;
ref_dbus[42]=32'hxxxxxxxx; //Reading R12 and R0 as inputs to ALU

stm_CL[43]=1;
stm_Cin[43]=1;
stm_S[43]=3'b011;
asel[43]=32'h00000001;
bsel[43]=32'h00000001;
dsel[43]=32'h00100000;  
ref_abus[43]=32'hxxxxxxxx;
ref_bbus[43]=32'hxxxxxxxx;
ref_dbus[43]=32'hFFFFFFFF; //Writing R20 with FFFFFFFF (Result of ADD R12, R17)

// ------------ SUB TEST ---------------//

stm_CL[44]=0;
stm_Cin[44]=1;
stm_S[44]=3'b011;
asel[44]=32'h00000001;
bsel[44]=32'h00000001;
dsel[44]=32'h00000001;  
ref_abus[44]=32'h00000000;
ref_bbus[44]=32'h00000000;
ref_dbus[44]=32'hxxxxxxxx; //Reading R0 and R0 as inputs to ALU


stm_CL[45]=1;
stm_Cin[45]=0;
stm_S[45]=3'b101;
asel[45]=32'h00000001;
bsel[45]=32'h00000001;
dsel[45]=32'h00200000;  
ref_abus[45]=32'hxxxxxxxx;
ref_bbus[45]=32'hxxxxxxxx;
ref_dbus[45]=32'hFFFFFFFF; //Writing R21 with FFFFFFFF (Result of SUB R12, R0)


// ------------ NOR TEST ---------------//

stm_CL[46]=0;
stm_Cin[46]=1;
stm_S[46]=3'b101;
asel[46]=32'h00001000;
bsel[46]=32'h00002000;
dsel[46]=32'h00000001;  
ref_abus[46]=32'h00000000;
ref_bbus[46]=32'hFFFFFFFF;
ref_dbus[46]=32'hxxxxxxxx; //Reading R12 and R13 as inputs to ALU


stm_CL[47]=1;
stm_Cin[47]=0;
stm_S[47]=3'b100;
asel[47]=32'h00000001;
bsel[47]=32'h00000001;
dsel[47]=32'h00400000;  
ref_abus[47]=32'hxxxxxxxx;
ref_bbus[47]=32'hxxxxxxxx;
ref_dbus[47]=32'hFFFFFFFF; //Writing R22 with FFFFFFFF (Result of NOR R0, R0)


// ------------ OR TEST ---------------//

stm_CL[48]=0;
stm_Cin[48]=0;
stm_S[48]=3'b100;
asel[48]=32'h00002000;
bsel[48]=32'h00004000;
dsel[48]=32'h00000001;  
ref_abus[48]=32'hFFFFFFFF;
ref_bbus[48]=32'hFFFFFFFF;
ref_dbus[48]=32'hxxxxxxxx; //Reading R13 and R14 as inputs to ALU


stm_CL[49]=1;
stm_Cin[49]=0;
stm_S[49]=3'b001;
asel[49]=32'h00000001;
bsel[49]=32'h00000001;
dsel[49]=32'h00800000;  
ref_abus[49]=32'hxxxxxxxx;
ref_bbus[49]=32'hxxxxxxxx;
ref_dbus[49]=32'hFFFFFFFF; //Writing R23 with FFFFFFFF (Result of OR R12, R13)


// ------------ XNOR TEST ---------------//

stm_CL[50]=0;
stm_Cin[50]=0;
stm_S[50]=3'b100;
asel[50]=32'h00008000;
bsel[50]=32'h00010000;
dsel[50]=32'h00000001;  
ref_abus[50]=32'h00000000;
ref_bbus[50]=32'hFFFFFFFF;
ref_dbus[50]=32'hxxxxxxxx; //Reading R15 and R16 as inputs to ALU


stm_CL[51]=1;
stm_Cin[51]=0;
stm_S[51]=3'b000;
asel[51]=32'h00000001;
bsel[51]=32'h00000001;
dsel[51]=32'h01000000;  
ref_abus[51]=32'hxxxxxxxx;
ref_bbus[51]=32'hxxxxxxxx;
ref_dbus[51]=32'hFFFFFFFF; //Writing R24 with FFFFFFFF (Result of XNOR R13, R14)


// ------------ XOR TEST ---------------//

stm_CL[52]=0;
stm_Cin[52]=0;
stm_S[52]=3'b000;
asel[52]=32'h00000001;
bsel[52]=32'h00020000;
dsel[52]=32'h00000001;  
ref_abus[52]=32'h00000000;
ref_bbus[52]=32'h00000000;
ref_dbus[52]=32'hxxxxxxxx; //Reading R0 and R17 as inputs to ALU


stm_CL[53]=1;
stm_Cin[53]=0;
stm_S[53]=3'b110;
asel[53]=32'h00000001;
bsel[53]=32'h00000001;
dsel[53]=32'h02000000;  
ref_abus[53]=32'hxxxxxxxx;
ref_bbus[53]=32'hxxxxxxxx;
ref_dbus[53]=32'hFFFFFFFF; //Writing R25 with FFFFFFFF (Result of XOR R15, R16)

// ------------ AND TEST ---------------//

stm_CL[54]=0;
stm_Cin[54]=0;
stm_S[54]=3'b110;
asel[54]=32'h00000001;
bsel[54]=32'h00000001;
dsel[54]=32'h00000001;  
ref_abus[54]=32'h00000000;
ref_bbus[54]=32'h00000000;
ref_dbus[54]=32'hxxxxxxxx; //Reading R0 and R0 as inputs to ALU


stm_CL[55]=1;
stm_Cin[55]=1;
stm_S[55]=3'b011;
asel[55]=32'h00000001;
bsel[55]=32'h00000001;
dsel[55]=32'h04000000;  
ref_abus[55]=32'hxxxxxxxx;
ref_bbus[55]=32'hxxxxxxxx;
ref_dbus[55]=32'h00000000; //Writing R26 with 00000000 (Result of AND R0, R17)

// ------------ SUB TEST ---------------//

stm_CL[56]=0;
stm_Cin[56]=1;
stm_S[56]=3'b011;
asel[56]=32'h00000002;
bsel[56]=32'h00000004;
dsel[56]=32'h00000001;  
ref_abus[56]=32'hFFFFFFFF;
ref_bbus[56]=32'hFFFFFFFF;
ref_dbus[56]=32'hxxxxxxxx; //Reading R1 and R2 as inputs to ALU


stm_CL[57]=1;
stm_Cin[57]=0;
stm_S[57]=3'b110;
asel[57]=32'h00000001;
bsel[57]=32'h00000001;
dsel[57]=32'h08000000;  
ref_abus[57]=32'hxxxxxxxx;
ref_bbus[57]=32'hxxxxxxxx;
ref_dbus[57]=32'h00000000; //Writing R26 with 00000000 (Result of SUB R0, R0)    

// ------------ AND TEST ---------------//

stm_CL[58]=0;
stm_Cin[58]=0;
stm_S[58]=3'b110;
asel[58]=32'h00000004;
bsel[58]=32'h00000008;
dsel[58]=32'h00000001;  
ref_abus[58]=32'hFFFFFFFF;
ref_bbus[58]=32'hFFFFFFFF;
ref_dbus[58]=32'hxxxxxxxx; //Reading R2 and R3 as inputs to ALU

stm_CL[59]=1;
stm_Cin[59]=0;
stm_S[59]=3'b000;
asel[59]=32'h00000001;
bsel[59]=32'h00000001;
dsel[59]=32'h10000000;  
ref_abus[59]=32'hxxxxxxxx;
ref_bbus[59]=32'hxxxxxxxx;
ref_dbus[59]=32'hFFFFFFFF; //Writing R27 with FFFFFFFFF (Result of AND R1, R2)   

// ------------ XOR TEST ---------------//

stm_CL[60]=0;
stm_Cin[60]=0;
stm_S[60]=3'b000;
asel[60]=32'h00000008;
bsel[60]=32'h00000010;
dsel[60]=32'h00000001;  
ref_abus[60]=32'hFFFFFFFF;
ref_bbus[60]=32'h00000000;
ref_dbus[60]=32'hxxxxxxxx; //Reading R3 and R4 as inputs to ALU

stm_CL[61]=1;
stm_Cin[61]=0;
stm_S[61]=3'b110;
asel[61]=32'h00000001;
bsel[61]=32'h00000001;
dsel[61]=32'h20000000;  
ref_abus[61]=32'hxxxxxxxx;
ref_bbus[61]=32'hxxxxxxxx;
ref_dbus[61]=32'h00000000; //Writing R28 with FFFFFFFFF (Result of XOR R2, R3)   

// ------------ AND TEST ---------------//

stm_CL[62]=0;
stm_Cin[62]=0;
stm_S[62]=3'b110;
asel[62]=32'h00000010;
bsel[62]=32'h00000020;
dsel[62]=32'h00000001;  
ref_abus[62]=32'h00000000;
ref_bbus[62]=32'hFFFFFFFF;
ref_dbus[62]=32'hxxxxxxxx; //Reading R4 and R5 as inputs to ALU

stm_CL[63]=1;
stm_Cin[63]=1;
stm_S[63]=3'b011;
asel[63]=32'h00000001;
bsel[63]=32'h00000001;
dsel[63]=32'h40000000;  
ref_abus[63]=32'hxxxxxxxx;
ref_bbus[63]=32'hxxxxxxxx;
ref_dbus[63]=32'h00000000; //Writing R29 with FFFFFFFFF (Result of AND R3, R4)   

// ------------ SUB TEST ---------------//

stm_CL[64]=0;
stm_Cin[64]=1;
stm_S[64]=3'b011;
asel[64]=32'h00000020;
bsel[64]=32'h00000040;
dsel[64]=32'h00000001;  
ref_abus[64]=32'hFFFFFFFF;
ref_bbus[64]=32'h00000000;
ref_dbus[64]=32'hxxxxxxxx; //Reading R5 and R6 as inputs to ALU

stm_CL[65]=1;
stm_Cin[65]=0;
stm_S[65]=3'b100;
asel[65]=32'h00000001;
bsel[65]=32'h00000001;
dsel[65]=32'h00000002;  
ref_abus[65]=32'hxxxxxxxx;
ref_bbus[65]=32'hxxxxxxxx;
ref_dbus[65]=32'h00000001; //Writing R1 with 00000001 (Result of SUB R4, R5)   

// ------------ OR TEST ---------------//

stm_CL[66]=0;
stm_Cin[66]=1;
stm_S[66]=3'b100;
asel[66]=32'h00000001;
bsel[66]=32'h00000001;
dsel[66]=32'h00000001;  
ref_abus[66]=32'h00000000;
ref_bbus[66]=32'h00000000;
ref_dbus[66]=32'hxxxxxxxx; //Reading R6 and R7 as inputs to ALU

stm_CL[67]=1;
stm_Cin[67]=0;
stm_S[67]=3'b110;
asel[67]=32'h00000001;
bsel[67]=32'h00000001;
dsel[67]=32'h00000001;  
ref_abus[67]=32'hxxxxxxxx;
ref_bbus[67]=32'hxxxxxxxx;
ref_dbus[67]=32'hFFFFFFFF; //Writing R0 with FFFFFFFF, but always gets assigned to 00000000 (Result of SUB R4, R5)   

// ------------ AND TEST proving writes to R0 result in 0---------------//

stm_CL[68]=0;
stm_Cin[68]=1;
stm_S[68]=3'b110;
asel[68]=32'h00001000;
bsel[68]=32'h00002000;
dsel[68]=32'h00000001;  
ref_abus[68]=32'h00000000;
ref_bbus[68]=32'hFFFFFFFF;
ref_dbus[68]=32'hxxxxxxxx; //Reading R12 and R13 as inputs to ALU

stm_CL[69]=1;
stm_Cin[69]=0;
stm_S[69]=3'b100;
asel[69]=32'h00000001;
bsel[69]=32'h00000001;
dsel[69]=32'h80000000;  
ref_abus[69]=32'hxxxxxxxx;
ref_bbus[69]=32'hxxxxxxxx;
ref_dbus[69]=32'h00000000; //Writing R30 with 00000000 (Result of AND R0, R0), proves that any writes to R0 will result in 32'b0

// ------------ OR TEST ---------------//

stm_CL[70]=0;
stm_Cin[70]=1;
stm_S[70]=3'b100;
asel[70]=32'h00000002;
bsel[70]=32'h00000001;
dsel[70]=32'h00000001;  
ref_abus[70]=32'h00000001;
ref_bbus[70]=32'h00000000;
ref_dbus[70]=32'hxxxxxxxx; //Reading R1 and R0 as inputs to ALU

stm_CL[71]=1;
stm_Cin[71]=0;
stm_S[71]=3'b001;
asel[71]=32'h00000001;
bsel[71]=32'h00000001;
dsel[71]=32'h80000000;  
ref_abus[71]=32'hxxxxxxxx;
ref_bbus[71]=32'hxxxxxxxx;
ref_dbus[71]=32'hFFFFFFFF; //Writing R30 with FFFFFFFF (Result of OR R12, R13)   

// ------------ XNOR TEST ---------------//

stm_CL[72]=0;
stm_Cin[72]=1;
stm_S[72]=3'b001;
asel[72]=32'h00000002;
bsel[72]=32'h40000000;
dsel[72]=32'h00000001;  
ref_abus[72]=32'h00000001;
ref_bbus[72]=32'h00000000;
ref_dbus[72]=32'hxxxxxxxx; //Reading R1 and R29 as inputs to ALU

stm_CL[73]=1;
stm_Cin[73]=0;
stm_S[73]=3'b101;
asel[73]=32'h00000001;
bsel[73]=32'h00000001;
dsel[73]=32'h00000004;  
ref_abus[73]=32'hxxxxxxxx;
ref_bbus[73]=32'hxxxxxxxx;
ref_dbus[73]=32'hFFFFFFFE; //Writing R2 with FFFFFFFE (Result of XNOR R1, R0)  

// ------------ NOR TEST ---------------//

stm_CL[74]=0;
stm_Cin[74]=1;
stm_S[74]=3'b101;
asel[74]=32'h00000004;
bsel[74]=32'h00000002;
dsel[74]=32'h00000001;  
ref_abus[74]=32'hFFFFFFFE;
ref_bbus[74]=32'h00000001;
ref_dbus[74]=32'hxxxxxxxx; //Reading R1 and R2 as inputs to ALU

stm_CL[75]=1;
stm_Cin[75]=0;
stm_S[75]=3'b100;
asel[75]=32'h00000001;
bsel[75]=32'h00000001;
dsel[75]=32'h00000008;  
ref_abus[75]=32'hxxxxxxxx;
ref_bbus[75]=32'hxxxxxxxx;
ref_dbus[75]=32'hFFFFFFFE; //Writing R3 with FFFFFFFE (Result of NOR R1, R29)   

// ------------ XOR TEST ---------------//

stm_CL[76]=0;
stm_Cin[76]=0;
stm_S[76]=3'b100;
asel[76]=32'h00000002;
bsel[76]=32'h00000004;
dsel[76]=32'h00000001;  
ref_abus[76]=32'h00000001;
ref_bbus[76]=32'hFFFFFFFE;
ref_dbus[76]=32'hxxxxxxxx; //Reading R1 and R2 as inputs to ALU

stm_CL[77]=1;
stm_Cin[77]=0;
stm_S[77]=3'b010;
asel[77]=32'h00000001;
bsel[77]=32'h00000001;
dsel[77]=32'h00000010;  
ref_abus[77]=32'hxxxxxxxx;
ref_bbus[77]=32'hxxxxxxxx;
ref_dbus[77]=32'hFFFFFFFF; //Writing R4 with FFFFFFFE (Result of NOR R1, R29)   


// ------------ XOR TEST ---------------//

stm_CL[78]=0;
stm_Cin[78]=0;
stm_S[78]=3'b010;
asel[78]=32'hx;
bsel[78]=32'hx;
dsel[78]=32'hx;  
ref_abus[78]=32'hx;
ref_bbus[78]=32'hx;
ref_dbus[78]=32'hx; //No need to read on the last test

stm_CL[79]=1;
stm_Cin[79]=0;
stm_S[79]=3'bx; //doesn't matter what we select on the last test
asel[79]=32'h00000001;
bsel[79]=32'h00000001;
dsel[79]=32'h00000002;  
ref_abus[79]=32'hxxxxxxxx;
ref_bbus[79]=32'hxxxxxxxx;
ref_dbus[79]=32'hFFFFFFFF; //Writing R1 with FFFFFFFE (Result of ADD R1, R2)   

dontcare = 32'hxxxxxxxx;
ntests = 79;

$timeformat(-9,1,"ns",12); 

end


initial begin
    error = 0;
    
    for (k=0; k<= ntests; k=k+1)
    begin
    
    Aselect=asel[k]; Bselect=bsel[k]; Dselect=dsel[k]; clk=stm_CL[k]; S=stm_S[k]; Cin=stm_Cin[k];
    #25

  if ( k >= 3) begin
     if ( stm_S[k-2] == 3'b000 && (k== 3 || k== 5 || k== 7 || k== 9 || k== 11 || k== 13 || k== 15 || k== 17 || k== 19 || k== 21 || k== 23 || k== 25 || k== 27 || k== 29 || k == 31 || k == 33 || k == 35 || k == 37 || k == 39 || k == 41 || k == 43 || k == 45 || k == 47 || k == 49 || k == 51 || k == 53 || k == 55 || k == 57 || k == 59 || k == 61 || k == 63 || k == 65 || k == 67 || k == 69 || k == 71 || k == 73 || k == 75 || k == 77 || k == 79))
       $display ("-----  TEST FOR A XOR B  -----");
     if ( stm_S[k-2] == 3'b001  && (k== 3 || k== 5 || k== 7 || k== 9 || k== 11 || k== 13 || k== 15 || k== 17 || k== 19 || k== 21 || k== 23 || k== 25 || k== 27 || k== 29 || k == 31 || k == 33 || k == 35 || k == 37 || k == 39 || k == 41 || k == 43 || k == 45 || k == 47 || k == 49 || k == 51 || k == 53 || k == 55 || k == 57 || k == 59 || k == 61 || k == 63 || k == 65 || k == 67 || k == 69 || k == 71 || k == 73 || k == 75 || k == 77 || k == 79))
       $display ("-----  TEST FOR A XNOR B  -----");
     if ( stm_S[k-2] == 3'b010  && (k== 3 || k== 5 || k== 7 || k== 9 || k== 11 || k== 13 || k== 15 || k== 17 || k== 19 || k== 21 || k== 23 || k== 25 || k== 27 || k== 29 || k == 31 || k == 33 || k == 35 || k == 37 || k == 39 || k == 41 || k == 43 || k == 45 || k == 47 || k == 49 || k == 51 || k == 53 || k == 55 || k == 57 || k == 59 || k == 61 || k == 63 || k == 65 || k == 67 || k == 69 || k == 71 || k == 73 || k == 75 || k == 77 || k == 79))
       $display ("-----  TEST FOR A + B // CARRY CHAIN  -----");
     if ( stm_S[k-2] == 3'b100  && (k== 3 || k== 5 || k== 7 || k== 9 || k== 11 || k== 13 || k== 15 || k== 17 || k== 19 || k== 21 || k== 23 || k== 25 || k== 27 || k== 29 || k == 31 || k == 33 || k == 35 || k == 37 || k == 39 || k == 41 || k == 43 || k == 45 || k == 47 || k == 49 || k == 51 || k == 53 || k == 55 || k == 57 || k == 59 || k == 61 || k == 63 || k == 65 || k == 67 || k == 69 || k == 71 || k == 73 || k == 75 || k == 77 || k == 79))
       $display ("-----  TEST FOR A OR B  -----");
     if ( stm_S[k-2] == 3'b011  && (k== 3 || k== 5 || k== 7 || k== 9 || k== 11 || k== 13 || k== 15 || k== 17 || k== 19 || k== 21 || k== 23 || k== 25 || k== 27 || k== 29 || k == 31 || k == 33 || k == 35 || k == 37 || k == 39 || k == 41 || k == 43 || k == 45 || k == 47 || k == 49 || k == 51 || k == 53 || k == 55 || k == 57 || k == 59 || k == 61 || k == 63 || k == 65 || k == 67 || k == 69 || k == 71 || k == 73 || k == 75 || k == 77 || k == 79))
       $display ("-----  TEST FOR A - B  -----");
     if ( stm_S[k-2] == 3'b101  && ((k== 3 || k== 5 || k== 7 || k== 9 || k== 11 || k== 13 || k== 15 || k== 17 || k== 19 || k== 21 || k== 23 || k== 25 || k== 27 || k== 29 || k == 31 || k == 33 || k == 35 || k == 37 || k == 39 || k == 41 || k == 43 || k == 45 || k == 47 || k == 49 || k == 51 || k == 53 || k == 55 || k == 57 || k == 59 || k == 61 || k == 63 || k == 65 || k == 67 || k == 69 || k == 71 || k == 73 || k == 75 || k == 77 || k == 79)))
       $display ("-----  TEST FOR A NOR  B  -----");
     if ( stm_S[k-2] == 3'b110  && ((k== 3 || k== 5 || k== 7 || k== 9 || k== 11 || k== 13 || k== 15 || k== 17 || k== 19 || k== 21 || k== 23 || k== 25 || k== 27 || k== 29 || k == 31 || k == 33 || k == 35 || k == 37 || k == 39 || k == 41 || k == 43 || k == 45 || k == 47 || k == 49 || k == 51 || k == 53 || k == 55 || k == 57 || k == 59 || k == 61 || k == 63 || k == 65 || k == 67 || k == 69 || k == 71 || k == 73 || k == 75 || k == 77 || k == 79)))
       $display ("-----  TEST FOR A AND  B  -----");
   
   end
  
  $display ("Test=%d \n Time=%t \n Clk=%b \n S=%b \n Cin=%b \n Aselect=%b \n Bselect=%b \n Dselect=%b \n abus=%b \n ref_abus=%b \n bbus=%b \n ref_bbus=%b \n dbus=%b \n ref_dbus=%b \n ", k, $realtime, clk, S, Cin, Aselect, Bselect, Dselect, abus, ref_abus[k], bbus, ref_bbus[k], dbus, ref_dbus[k]);
 
 
  if  ( ( (ref_bbus[k] !== bbus) && (ref_bbus[k] !== dontcare) ) || ( (ref_abus[k] !== abus) && (ref_abus[k] !== dontcare)) || ( (ref_dbus[k] !== dbus) && (ref_dbus[k] !== dontcare)) )
  begin
   $display ("-------------ERROR. A Mismatch Has Occured-----------");
   error = error + 1;
  end
  
 end
  
   if ( error !== 0)
   begin 
   $display("--------- SIMULATION UNSUCCESFUL - MISMATCHES HAVE OCCURED ----------");
   $display(" No. Of Errors = %d", error);
   end
if ( error == 0) 
   $display("---------YOU DID IT!! SIMULATION SUCCESFULLY FINISHED----------");

end
        
endmodule
         