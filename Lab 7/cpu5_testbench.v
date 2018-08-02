`timescale 1ns/10ps
module cpu5_testbench();

reg  [31:0] instrbus;
reg  [31:0] instrbusin[0:102];
wire [31:0] iaddrbus, daddrbus;
reg  [31:0] iaddrbusout[0:102], daddrbusout[0:102];
wire [31:0] databus;
reg  [31:0] databusk, databusin[0:102], databusout[0:102];
reg         clk, reset;
reg         clkd;

reg [31:0] dontcare;
reg [24*8:1] iname[0:100];
integer error, k, ntests;

	parameter Rformat	= 6'b000000;
	parameter ADDI		= 6'b000011;
	parameter SUBI		= 6'b000010;
	parameter XORI		= 6'b000001;
	parameter ANDI		= 6'b001111;
	parameter ORI		= 6'b001100;
	parameter LW		= 6'b011110;
	parameter SW		= 6'b011111;
	parameter BEQ		= 6'b110000;
	parameter BNE		= 6'b110001;
	parameter ADD		= 6'b000011;
	parameter SUB		= 6'b000010;
	parameter XOR		= 6'b000001;
	parameter AND		= 6'b000111;
	parameter OR		= 6'b000100;
	parameter SLT		= 6'b110110;
	parameter SLE		= 6'b110111;

cpu5 dut(.reset(reset),.clk(clk),.iaddrbus(iaddrbus),.ibus(instrbus),.daddrbus(daddrbus),.databus(databus));

initial begin
// This test file runs the following program.

iname[0] = "ADDI  R20, R0, #-1";
iname[1] = "ADDI  R21, R0, #1";
iname[2] = "ADDI  R22, R0, #2";
iname[3] = "LW    R24, 0(R20)";
iname[4] = "LW    R25, 0(R21)";
iname[5] = "SW    1000(R22), R20";
iname[6] = "SW    2(R0), R21";
iname[7] = "ADD   R26, R24, R25";
iname[8] = "SUBI  R17, R24, 6420";
iname[9] = "SUB   R27, R24, R25";
iname[10] = "ANDI R18, R24, #0";     
iname[11] = "AND  R28, R24, R0";     
iname[12] = "XORI R19, R24, 6420";
iname[13] = "XOR  R29, R24, R25";
iname[14] = "ORI  R20, R24, 6420";
iname[15] = "OR   R30, R24, R25";
iname[16] = "SW   0(R26),  R26";
iname[17] = "SW   0(R17),  R27";
iname[18] = "SW   1000(R18),  R28"; 
iname[19] = "SW   0(R19),  R29";
iname[20] = "SW   0(R20),  R30";
iname[21] = "SLT  R1,  R0,  R21";  // Setting R1 to 32'h00000001 (since, R0 < R21).
iname[22] = "ADDI R5,  R0, #1";
iname[23] = "ADDI R6,  R0, #1";
iname[24] = "BNE  R0,  R1, #10";   // Branching to (32'h00000060 + 32'h00000004 + 32'h00000028 = 32'h0000008C) since, R0 != R1.
iname[25] = "ADDI R8,  R0, #1";    // Delay Slot
//Branched Location - 32'h0000008C //
iname[26] = "SLE  R2,  R0, R0";    // Setting R2 to 32'h00000001 (since, R0 = R0).
iname[27] = "NOP";
iname[28] = "NOP";
iname[29] = "BEQ  R0,  R2, #25";   // NOT Branching since, R2 != R0. 
iname[30] = "NOP";                 // Delay Slot
iname[31] = "BEQ  R2,  R2, #10";   // Branching to (32h'0000000A0 + 32'h00000004 + 32'h00000028 = 32'h000000CC)
iname[32] = "ADDI R20, R0, #1";    // Delay Slot
//Branched Location - 32'h000000CC //
iname[33] = "NOP";
iname[34] = "NOP";
iname[35] = "NOP";
iname[36] = "ADDI   R1, R0, #1234";
iname[37] = "ADDI   R2, R0, #1234";
iname[38] = "ADDI   R3, R0, #1234";
iname[39] = "ADD    R4, R1, R2";
iname[40] = "LW     R5, 0(R1)";
iname[41] = "LW     R6, 1000(R2)";
iname[42] = "LW     R7, 0(R3)";
iname[43] = "ADDI   R8, R4, 1000";
iname[44] = "XORI   R9, R4 #9999";
iname[45] = "ADDI   R10, R4, #9999";
iname[46] = "SW     0(R4),  R27";
iname[47] = "ADDI   R28, R0, #1";
iname[48] = "OR     R11, R1, R4";
iname[49] = "XOR    R12, R1, R4"; 
iname[50] = "LW     R13, 0(R10)";
iname[51] = "ADD    R14, R0, R4";
iname[52] = "OR     R15, R7, R6";
iname[53] = "OR     R16 R13, R0";
iname[54] = "LW     R24 1000(R13)";
iname[55] = "ANDI   R1, R12, #FFFF";
iname[56] = "ADDI   R20, R0, #FFFF";
iname[57] = "LW     R15 0(R16)";
iname[58] = "ADDI   R21, R0, #FFFF";
iname[59] = "ADD    R22, R0, #FFFF";                  
iname[60] = "SW     0(R12),  R12";
iname[61] = "SW     1000(R0),  R14";
iname[62] = "SW     1000(R0),  R15";
iname[63] = "SW     2000(R2),  R18";                                 
iname[64] = "OR     R16 R13, R0";
iname[65] = "AND    R28 R0, R0";
iname[66] = "XOR    R29 R1, R0";
iname[67] = "SUB    R30 R1, R2";
iname[68] = "ADD    R2 R1, R0";
iname[69] = "LW     R1 1000(R16)";
iname[70] = "LW     R3 2000(R28)";
iname[71] = "LW     R4 4000(R29)";
iname[72] = "LW     R5 8000(R30)";
iname[73] = "LW     R6 0(R2)";
iname[74] = "ANDI   R1, R1, #FFFF";
iname[75] = "ADDI   R2, R1, #FFFF";
iname[76] = "SUBI   R3, R1, #FFFF";
iname[77] = "XORI   R4, R0, #FFFF";
iname[78] = "ORI    R5, R0, #FFFF";
iname[79] = "SW     0(R1),  R1";
iname[80] = "SW     1000(R2),  R2";
iname[81] = "SW     2000(R3),  R3";
iname[82] = "SW     4000(R4),  R4";
iname[83] = "SW     8000(R5),  R5";
iname[84] = "NOP";
iname[85] = "NOP";
iname[86] = "NOP";
iname[87] = "SLT    R5,  R5,  R0";
iname[88] = "SLE    R0,  R0,  R6";
iname[89] = "SLT    R0, R1, R7";
iname[90] = "SW     0(R5), R5";
iname[91] = "SW     0(R6), R6";
iname[92] = "SW     0(R7), R7";
iname[93] = "NOP";
iname[94] = "NOP";
iname[95] = "NOP";
iname[96] = "BNE     R0, R6, #00A0";
iname[97] = "BNE     R0, R0, #000A";
iname[98] = "BEQ     R0, R0, #000A";
iname[99] = "NOP";
iname[100] = "BEQ     R0, R1, #FFFF";
iname[101] = "NOP";
iname[102] = "NOP";


dontcare = 32'hx;

//* ADDI  R20, R0, #-1
iaddrbusout[0] = 32'h00000000;
//            opcode source1   dest      Immediate...
instrbusin[0]={ADDI, 5'b00000, 5'b10100, 16'hFFFF};

daddrbusout[0] = dontcare;
databusin[0] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[0] = dontcare;

//* ADDI  R21, R0, #1
iaddrbusout[1] = 32'h00000004;
//            opcode source1   dest      Immediate...
instrbusin[1]={ADDI, 5'b00000, 5'b10101, 16'h0001};

daddrbusout[1] = dontcare;
databusin[1] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[1] = dontcare;

//* ADDI  R22, R0, #2
iaddrbusout[2] = 32'h00000008;
//            opcode source1   dest      Immediate...
instrbusin[2]={ADDI, 5'b00000, 5'b10110, 16'h0002};

daddrbusout[2] = dontcare;
databusin[2] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[2] = dontcare;

//* LW     R24, 0(R20)
iaddrbusout[3] = 32'h0000000C;
//            opcode source1   dest      Immediate...
instrbusin[3]={LW, 5'b10100, 5'b11000, 16'h0000};

daddrbusout[3] = 32'hFFFFFFFF;
databusin[3] = 32'hCCCCCCCC;
databusout[3] = dontcare;

//* LW     R25, 0(R21)
iaddrbusout[4] = 32'h00000010;
//            opcode source1   dest      Immediate...
instrbusin[4]={LW, 5'b10101, 5'b11001, 16'h0000};

daddrbusout[4] = 32'h00000001;
databusin[4] = 32'hAAAAAAAA;
databusout[4] = dontcare;

//* SW     1000(R22), R20
iaddrbusout[5] = 32'h00000014;
//            opcode source1   dest      Immediate...
instrbusin[5]={SW, 5'b10110, 5'b10100, 16'h1000};

daddrbusout[5] = 32'h00001002;
databusin[5] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[5] = 32'hFFFFFFFF;

//* SW     2(R0), R21
iaddrbusout[6] = 32'h00000018;
//            opcode source1   dest      Immediate...
instrbusin[6]={SW, 5'b00000, 5'b10101, 16'h0002};

daddrbusout[6] = 32'h00000002;
databusin[6] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[6] = 32'h00000001;

//* ADD   R26, R24, R25
iaddrbusout[7] = 32'h0000001C;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[7]={Rformat, 5'b11000, 5'b11001, 5'b11010, 5'b00000, ADD};

daddrbusout[7] = dontcare;
databusin[7] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[7] = dontcare;

//* SUBI  R17, R24, 6420
iaddrbusout[8] = 32'h00000020;
//            opcode source1   dest      Immediate...
instrbusin[8]={SUBI, 5'b11000, 5'b10001, 16'h6420};

daddrbusout[8] = dontcare;
databusin[8] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[8] = dontcare;

//* SUB   R27, R24, R25
iaddrbusout[9] = 32'h00000024;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[9]={Rformat, 5'b11000, 5'b11001, 5'b11011, 5'b00000, SUB};

daddrbusout[9] = dontcare;
databusin[9] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[9] = dontcare;

//* ANDI   R18, R24, #0             
iaddrbusout[10] = 32'h00000028;
//            opcode source1   dest      Immediate...
instrbusin[10]={ANDI, 5'b11000, 5'b10010, 16'h0000};

daddrbusout[10] = dontcare;
databusin[10] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[10] = dontcare;

//* AND    R28, R24, R0           
iaddrbusout[11] = 32'h0000002C;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[11]={Rformat, 5'b11000, 5'b00000, 5'b11100, 5'b00000, AND};

daddrbusout[11] = dontcare;
databusin[11] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[11] = dontcare;

//* XORI   R19, R24, 6420
iaddrbusout[12] = 32'h00000030;
//            opcode source1   dest      Immediate...
instrbusin[12]={XORI, 5'b11000, 5'b10011, 16'h6420};

daddrbusout[12] = dontcare;
databusin[12] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[12] = dontcare;

//* XOR    R29, R24, R25
iaddrbusout[13] = 32'h00000034;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[13]={Rformat, 5'b11000, 5'b11001, 5'b11101, 5'b00000, XOR};

daddrbusout[13] = dontcare;
databusin[13] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[13] = dontcare;

//* ORI    R20, R24, 6420
iaddrbusout[14] = 32'h00000038;
//            opcode source1   dest      Immediate...
instrbusin[14]={ORI, 5'b11000, 5'b10100, 16'h6420};

daddrbusout[14] = dontcare;
databusin[14] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[14] = dontcare;

//* OR     R30, R24, R25
iaddrbusout[15] = 32'h0000003C;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[15]={Rformat, 5'b11000, 5'b11001, 5'b11110, 5'b00000, OR};

daddrbusout[15] = dontcare;
databusin[15] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[15] =  dontcare;

//* SW     0(R26),  R26
iaddrbusout[16] = 32'h00000040;
//            opcode source1   dest      Immediate...
instrbusin[16]={SW, 5'b11010, 5'b11010, 16'h0000};

daddrbusout[16] = 32'h77777776;
databusin[16] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[16] = 32'h77777776;

//18* SW     0(R17),  R27
iaddrbusout[17] = 32'h00000044;
//            opcode source1   dest      Immediate...
instrbusin[17]={SW, 5'b10001, 5'b11011, 16'h0000};

daddrbusout[17] = 32'hCCCC68AC;
databusin[17] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[17] = 32'h22222222;

//19* SW     1000(R18),  R28           
iaddrbusout[18] = 32'h00000048;
//            opcode source1   dest      Immediate...
instrbusin[18]={SW, 5'b10010, 5'b11100, 16'h1000};

daddrbusout[18] = 32'h00001000;
databusin[18] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[18] = 32'h00000000;

//20* SW     0(R19),  R29
iaddrbusout[19] = 32'h0000004C;
//            opcode source1   dest      Immediate...
instrbusin[19]={SW, 5'b10011, 5'b11101, 16'h0000};

daddrbusout[19] = 32'hCCCCA8EC;
databusin[19] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[19] = 32'h66666666;

//21* SW     0(R20),  R30
iaddrbusout[20] = 32'h00000050;
//            opcode source1   dest      Immediate...
instrbusin[20]={SW, 5'b10100, 5'b11110, 16'h0000};

daddrbusout[20] = 32'hCCCCECEC;
databusin[20] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[20] = 32'hEEEEEEEE;


//22* SLT  R1,  R0,  R21
iaddrbusout[21] = 32'h00000054;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[21]={Rformat, 5'b00000, 5'b10101, 5'b00001, 5'b00000, SLT};
daddrbusout[21] = dontcare;
databusin[21]   = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[21]  = dontcare;

//* ADDI R5,  R0, #1
iaddrbusout[22] = 32'h00000058;
//            opcode source1   dest      Immediate...
instrbusin[22]={ADDI, 5'b00000, 5'b00101, 16'h0001};
daddrbusout[22] = dontcare;
databusin[22] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[22] = dontcare;

//* ADDI R6,  R0, #1
iaddrbusout[23] = 32'h0000005C;
//            opcode source1   dest      Immediate...
instrbusin[23]={ADDI, 5'b00000, 5'b00110, 16'h0001};
daddrbusout[23] = dontcare;
databusin[23] =   32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[23] =  dontcare;

//* BNE  R0,  R1, #10
iaddrbusout[24] = 32'h00000060;
//            opcode source1   dest      Immediate...
instrbusin[24]={BNE, 5'b00001, 5'b00000, 16'h000A};
daddrbusout[24] = dontcare;
databusin[24] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[24] = dontcare;

//* ADDI R8,  R0, #1
iaddrbusout[25] = 32'h00000064;
//            opcode source1   dest      Immediate...
instrbusin[25]={ADDI, 5'b00000, 5'b01000, 16'h0001};
daddrbusout[25] = dontcare;
databusin[25] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[25] = dontcare;

//* SLE  R2,  R0, R0
iaddrbusout[26] = 32'h0000008C;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[26]={Rformat, 5'b00000, 5'b00000, 5'b00010, 5'b00000, SLE};
daddrbusout[26] = dontcare;
databusin[26] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[26] = dontcare;

//* NOP
iaddrbusout[27] = 32'h00000090;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[27] = 32'b00000000000000000000000000000000;
daddrbusout[27] = dontcare;
databusin[27] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[27] = dontcare;

//* NOP
iaddrbusout[28] = 32'h00000094;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[28] = 32'b00000000000000000000000000000000;
daddrbusout[28] = dontcare;
databusin[28]  = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[28] = dontcare;

//* BEQ  R0,  R2, #25
iaddrbusout[29] = 32'h00000098;
//            opcode source1   dest      Immediate...
instrbusin[29]={BEQ, 5'b00010, 5'b00000, 16'h0019};
daddrbusout[29] = dontcare;
databusin[29] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[29] = dontcare;

//* NOP
iaddrbusout[30] = 32'h0000009C;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[30] = 32'b00000000000000000000000000000000;
daddrbusout[30] = dontcare;
databusin[30] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[30] = dontcare;

//* BEQ  R2,  R2, #10
iaddrbusout[31] = 32'h000000A0;
//            opcode source1   dest      Immediate...
instrbusin[31]={BEQ, 5'b00010, 5'b00010, 16'h000A};
daddrbusout[31] = dontcare;
databusin[31] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[31] = dontcare;

//* ADDI R20, R0, #1
iaddrbusout[32] = 32'h000000A4;
//            opcode source1   dest      Immediate...
instrbusin[32]={ADDI, 5'b00000, 5'b10100, 16'h0001};
daddrbusout[32] = dontcare;
databusin[32] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[32] = dontcare;

//* NOP
iaddrbusout[33] = 32'h000000CC;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[33] = 32'b00000000000000000000000000000000;
daddrbusout[33] = dontcare;
databusin[33] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[33] = dontcare;

//* NOP
iaddrbusout[34] = 32'h000000D0;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[34] = 32'b00000000000000000000000000000000;
daddrbusout[34] = dontcare;
databusin[34] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[34] = dontcare;

//* NOP
iaddrbusout[35] = 32'h000000D4;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[35] = 32'b00000000000000000000000000000000;
daddrbusout[35] = dontcare;
databusin[35] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[35] = dontcare;


// ADDI    R1, R0, #1234  
iaddrbusout[36] = 32'h000000D8;
//            opcode source1   dest      Immediate...
instrbusin[36]={ADDI, 5'b00000, 5'b00001, 16'h1234};

daddrbusout[36] = dontcare;
databusin[36] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[36] = dontcare;

//  ADDI    R2, R0, #1234  
iaddrbusout[37] = 32'h000000DC;

//            opcode source1   dest      Immediate...
instrbusin[37]={ADDI, 5'b00000, 5'b00010, 16'h1234};

daddrbusout[37] = dontcare;
databusin[37] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[37] = dontcare;

//  ADDI    R3, R0, #1234  
iaddrbusout[38] = 32'h000000E0;

//            opcode source1   dest      Immediate...
instrbusin[38]={ADDI, 5'b00000, 5'b00011, 16'h1234};

daddrbusout[38] = dontcare;
databusin[38] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[38] = dontcare;

//  ADD    R4, R1, R2  
iaddrbusout[39] = 32'h000000E4;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[39]={Rformat, 5'b00001, 5'b00010, 5'b00100, 5'b00000, ADD};

daddrbusout[39] = dontcare;
databusin[39] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[39] = dontcare;

//  LW    R5, 0(R1)
iaddrbusout[40] = 32'h000000E8;
//            opcode source1   dest      Immediate...
instrbusin[40]={LW, 5'b00001, 5'b00101, 16'h0000};

daddrbusout[40] = 32'h00001234;
databusin[40] = 32'h00001234;
databusout[40] = dontcare;


// * LW   R6, 1000(R2) 
iaddrbusout[41] = 32'h000000EC;
//            opcode source1   dest      Immediate...
instrbusin[41]={LW, 5'b00010, 5'b00110, 16'h1000};

daddrbusout[41] = 32'h00002234;
databusin[41] = 32'h00001234;
databusout[41] = dontcare;

// * LW    R7, 0(R3)
iaddrbusout[42] = 32'h000000F0;
//            opcode source1   dest      Immediate...
instrbusin[42]={LW, 5'b00011, 5'b00111, 16'h0000};

daddrbusout[42] = 32'h00001234;
databusin[42] = 32'h00001234;
databusout[42] = dontcare;


// * ADDI   R8, R4, 1000
iaddrbusout[43] = 32'h000000F4;
//            opcode source1   dest      Immediate...
instrbusin[43]={ADDI, 5'b00100, 5'b01000, 16'h1000};

daddrbusout[43] = dontcare;
databusin[43] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[43] = dontcare;

// * XORI   R9, R4, #9999
iaddrbusout[44] = 32'h000000F8;
//            opcode source1   dest      Immediate...
instrbusin[44]={XORI, 5'b00100, 5'b01001, 16'h9999};

daddrbusout[44] = dontcare;
databusin[44] = 44'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[44] = dontcare;

// * ADDI   R10, R4, #9999
iaddrbusout[45] = 32'h000000FC;
//            opcode source1   dest      Immediate...
instrbusin[45]={ADDI, 5'b00100, 5'b01010, 16'h9999};

daddrbusout[45] = dontcare;
databusin[45] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[45] = dontcare;

// * SW     0000(R4),  R2
iaddrbusout[46] = 32'h00000100;
//            opcode source1   dest      Immediate...
instrbusin[46]={SW, 5'b00011, 5'b00010, 16'h1000};

daddrbusout[46] = 32'h00002234;
databusin[46] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[46] = 32'h00001234;

// * ADDI     R28, R0, #1
iaddrbusout[47] = 32'h00000104;
//            opcode source1   dest      Immediate...
instrbusin[47] = {ADDI, 5'b00000, 5'b11100, 16'h0001};

daddrbusout[47] = dontcare;
databusin[47] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[47] = dontcare;

// * OR     R11, R1, R4
iaddrbusout[48] = 32'h00000108;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[48]={Rformat, 5'b00001, 5'b00100, 5'b01011, 5'b00000, OR};

daddrbusout[48] = dontcare;
databusin[48] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[48] =  dontcare;

// * XOR     R12, R1, R4
iaddrbusout[49] = 32'h0000010C;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[49]={Rformat, 5'b00001, 5'b00100, 5'b01100, 5'b00000, XOR};

daddrbusout[49] = dontcare;
databusin[49] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[49] =  dontcare;

// * LW   R13, 0(R1) 
iaddrbusout[50] = 32'h00000110;
//            opcode source1   dest      Immediate...
instrbusin[50]={LW, 5'b00001, 5'b01101, 16'h0000};

daddrbusout[50] = 32'h00001234;
databusin[50] = 32'h00002468;
databusout[50] = dontcare;

// * ADD     R14, R0, R4
iaddrbusout[51] = 32'h00000114;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[51]={Rformat, 5'b00000, 5'b00100, 5'b01110, 5'b00000, ADD};

daddrbusout[51] = dontcare;
databusin[51] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[51] =  dontcare;

// * OR     R15, R7, R6
iaddrbusout[52] = 32'h00000118;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[52]={Rformat, 5'b00111, 5'b00110, 5'b01111, 5'b00000, OR};

daddrbusout[52] = dontcare;
databusin[52] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[52] =  dontcare;

// * OR     R16 R13, R0
iaddrbusout[53] = 32'h0000011C;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[53]={Rformat, 5'b01101, 5'b00000, 5'b10000, 5'b00000, OR};

daddrbusout[53] = dontcare;
databusin[53] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[53] =  dontcare;

// * LW      R24 1000(R13)
iaddrbusout[54] = 32'h00000120;
//            opcode source1   dest      Immediate...
instrbusin[54]={LW, 5'b01101, 5'b11000, 16'h1000};

daddrbusout[54] = 32'h00003468;
databusin[54] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[54] = dontcare;

// * ANDI      R1, R12, #FFFF
iaddrbusout[55] = 32'h00000124;
//            opcode source1   dest      Immediate...
instrbusin[55]={ANDI, 5'b00001, 5'b01100, 16'hFFFF};

daddrbusout[55] = dontcare;
databusin[55] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[55] =  dontcare;


// * ADDI      R20, R0, #FFFF
iaddrbusout[56] = 32'h00000128;
//            opcode source1   dest      Immediate...
instrbusin[56]={ADDI, 5'b00000, 5'b10100, 16'hFFFF};

daddrbusout[56] = dontcare;
databusin[56] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[56] = dontcare;

// * LW      R15 0(R1)
iaddrbusout[57] = 32'h0000012C;
//            opcode source1   dest      Immediate...
instrbusin[57]={LW, 5'b01111, 5'b00001, 16'h0000};

daddrbusout[57] = 32'h00001234;
databusin[57] = 32'h00001234;
databusout[57] =  dontcare;

// * ADDI      R21, R0, #FFFF
iaddrbusout[58] = 32'h00000130;
//            opcode source1   dest      Immediate...
instrbusin[58]={ADDI, 5'b00000, 5'b10101, 16'hFFFF};

daddrbusout[58] = dontcare;
databusin[58] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[58] = dontcare;

// * ADDI      R22, R0, #FFFF
iaddrbusout[59] = 32'h00000134;
//            opcode source1   dest      Immediate...
instrbusin[59]={ADDI, 5'b00000, 5'b10110, 16'hFFFF};

daddrbusout[59] = dontcare;
databusin[59] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[59] = dontcare;

// * SW     0(R12),  R12
iaddrbusout[60] = 32'h00000138;
//            opcode source1   dest      Immediate...
instrbusin[60]={SW, 5'b01100, 5'b01100, 16'h0000};

daddrbusout[60] = 32'h00001234;
databusin[60] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[60] = 32'h00001234;

// * SW     1000(R0),  R2
iaddrbusout[61] = 32'h0000013C;
//            opcode source1   dest      Immediate...
instrbusin[61]={SW, 5'b00000, 5'b00010, 16'h1000};

daddrbusout[61] = 32'h00001000;
databusin[61] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[61] = 32'h00001234;

// * SW     1000(R0),  R15
iaddrbusout[62] = 32'h00000140;
//            opcode source1   dest      Immediate...
instrbusin[62]={SW, 5'b00000, 5'b01111, 16'h1000};

daddrbusout[62] = 32'h00001000;
databusin[62] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[62] = 32'h00001234;

// * SW     2000(R2),  R18
iaddrbusout[63] = 32'h00000144;
//            opcode source1   dest      Immediate...
instrbusin[63]={SW, 5'b00010, 5'b10010, 16'h2000};

daddrbusout[63] = 32'h0003234;
databusin[63] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[63] = 32'h0000000;

// * OR     R16 R13, R0
iaddrbusout[64] = 32'h00000148;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[64]={Rformat, 5'b01101, 5'b00000, 5'b10000, 5'b00000, OR};

daddrbusout[64] = dontcare;
databusin[64] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[64] =  dontcare;

// * AND     R28 R0, R0
iaddrbusout[65] = 32'h0000014C;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[65]={Rformat, 5'b11100, 5'b00000, 5'b00000, 5'b00000, AND};

daddrbusout[65] = dontcare;
databusin[65] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[65] =  dontcare;

// * XOR     R29 R1, R0
iaddrbusout[66] = 32'h00000150;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[66]={Rformat, 5'b00001, 5'b00000, 5'b11101, 5'b00000, XOR};

daddrbusout[66] = dontcare;
databusin[66] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[66] =  dontcare;

//  SUB     R30 R1, R2
iaddrbusout[67] = 32'h00000154;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[67]={Rformat, 5'b00010, 5'b00001, 5'b11110, 5'b00000, SUB};

daddrbusout[67] = dontcare;
databusin[67] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[67] =  dontcare;

// * ADD     R2 R1, R0
iaddrbusout[68] = 32'h00000158;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[68]={Rformat, 5'b00001, 5'b00001, 5'b00010, 5'b00000, ADD};

daddrbusout[68] = dontcare;
databusin[68] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[68] =  dontcare;

// * LW      R1 1000(R16)
iaddrbusout[69] = 32'h0000015C;
//            opcode source1   dest      Immediate...
instrbusin[69]={LW, 5'b01101, 5'b11000, 16'h1000};

daddrbusout[69] = 32'h00003468;
databusin[69] = 32'h00000000;
databusout[69] = dontcare;

// * LW      R3 2000(R28)
iaddrbusout[70] = 32'h00000160;
//            opcode source1   dest      Immediate...
instrbusin[70]={LW, 5'b11100, 5'b11000, 16'h2000};

daddrbusout[70] = 32'h00002001;
databusin[70] = 32'h0000000;
databusout[70] = dontcare;

// * LW      R4 4000(R29)
iaddrbusout[71] = 32'h00000164;
//            opcode source1   dest      Immediate...
instrbusin[71]={LW, 5'b11101, 5'b00100, 16'h4000};

daddrbusout[71] = 32'h00005234;
databusin[71] = 32'h00000000;
databusout[71] = dontcare;

// * LW      R5 8000(R30)
iaddrbusout[72] = 32'h00000168;
//            opcode source1   dest      Immediate...
instrbusin[72]={LW, 5'b11110, 5'b00101, 16'h8000};

daddrbusout[72] = 32'hFFFF8000;
databusin[72] = 32'h0000000;
databusout[72] = dontcare;

// * LW      R6 0(R2)
iaddrbusout[73] = 32'h0000016C;
//            opcode source1   dest      Immediate...
instrbusin[73]={LW, 5'b00010, 5'b00110, 16'h0000};

daddrbusout[73] = 32'h00002468;
databusin[73] = 32'h0000000;
databusout[73] = dontcare;

// * ANDI      R1, R1, #FFFF
iaddrbusout[74] = 32'h00000170;
//            opcode source1   dest      Immediate...
instrbusin[74]={ANDI, 5'b00001, 5'b00001, 16'hFFFF};

daddrbusout[74] = dontcare;
databusin[74] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[74] =  dontcare;

// * ADDI      R2, R1, #FFFF
iaddrbusout[75] = 32'h00000174;
//            opcode source1   dest      Immediate...
instrbusin[75]={ADDI, 5'b00001, 5'b00010, 16'hFFFF};

daddrbusout[75] = dontcare;
databusin[75] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[75] =  dontcare;

// * SUBI      R3, R1, #FFFF
iaddrbusout[76] = 32'h00000178;
//            opcode source1   dest      Immediate...
instrbusin[76]={SUBI, 5'b00001, 5'b00011, 16'hFFFF};

daddrbusout[76] = dontcare;
databusin[76] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[76] =  dontcare;

// * XORI      R4, R0, #FFFF
iaddrbusout[77] = 32'h0000017C;
//            opcode source1   dest      Immediate...
instrbusin[77]={XORI, 5'b00000, 5'b00100, 16'hFFFF};

daddrbusout[77] = dontcare;
databusin[77] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[77] =  dontcare;

// * ORI      R5, R0, #FFFF
iaddrbusout[78] = 32'h00000180;
//            opcode source1   dest      Immediate...
instrbusin[78]={ORI, 5'b00000, 5'b00101, 16'hFFFF};

daddrbusout[78] = dontcare;
databusin[78] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[78] =  dontcare;

// * SW     0(R1),  R1
iaddrbusout[79] = 32'h00000184;
//            opcode source1   dest      Immediate...
instrbusin[79]={SW, 5'b00001, 5'b00001, 16'h0000};

daddrbusout[79] = 32'h00001234;
databusin[79] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[79] = 32'h00001234;

// * SW     1000(R2),  R2
iaddrbusout[80] = 32'h00000188;
//            opcode source1   dest      Immediate...
instrbusin[80]={SW, 5'b00010, 5'b00010, 16'h1000};

daddrbusout[80] = 32'h00002233;
databusin[80] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[80] = 32'h00001233;

// * SW     2000(R3),  R3
iaddrbusout[81] = 32'h0000018C;
//            opcode source1   dest      Immediate...
instrbusin[81]={SW, 5'b00011, 5'b00011, 16'h2000};

daddrbusout[81] = 32'h00003235;
databusin[81] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[81] = 32'h00001235;

// * SW     4000(R4),  R4
iaddrbusout[82] = 32'h00000190;
//            opcode source1   dest      Immediate...
instrbusin[82]={SW, 5'b00100, 5'b00100, 16'h4000};

daddrbusout[82] = 32'h00003FFF;
databusin[82] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[82] = 32'hFFFFFFFF;

// * SW     8000(R5),  R5
iaddrbusout[83] = 32'h00000194;
//            opcode source1   dest      Immediate...
instrbusin[83]={SW, 5'b00101, 5'b00101, 16'h8000};

daddrbusout[83] = 32'hFFFF7FFF;
databusin[83] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[83] = 32'hFFFFFFFF;


// * NOP
iaddrbusout[84] = 32'h00000198;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[84] = 32'b00000000000000000000000000000000;

daddrbusout[84] = dontcare;
databusin[84] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[84] = dontcare;

// * NOP
iaddrbusout[85] = 32'h0000019C;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[85] = 32'b00000000000000000000000000000000;

daddrbusout[85] = dontcare;
databusin[85] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[85] = dontcare;

// * NOP
iaddrbusout[86] = 32'h000001A0;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[86] = 32'b00000000000000000000000000000000;

daddrbusout[86] = dontcare;
databusin[86] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[86] = dontcare;

//* SLT  R5,  R5,  R0
iaddrbusout[87] = 32'h0000001A4;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[87]={Rformat, 5'b00101, 5'b00000, 5'b00101, 5'b00000, SLT};
daddrbusout[87] = dontcare;
databusin[87]   = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[87]  = dontcare;

//* SLE  R0,  R0,  R6
iaddrbusout[88] = 32'h0000001A8;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[88]={Rformat, 5'b00000, 5'b00000, 5'b00110, 5'b00000, SLE};
daddrbusout[88] = dontcare;
databusin[88]   = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[88]  = dontcare;

//* SLT     R0, R1, R7
iaddrbusout[89] = 32'h0000001AC;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[89]={Rformat, 5'b00000, 5'b00001, 5'b00111, 5'b00000, SLT};
daddrbusout[89] = dontcare;
databusin[89]   = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[89]  = dontcare;

//* SW      0(R5), R5
iaddrbusout[90] = 32'h000001B0;
//            opcode source1   dest      Immediate...
instrbusin[90]={SW, 5'b00101, 5'b00101, 16'h0000};

daddrbusout[90] = 32'h00000000;
databusin[90] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[90] = 32'h00000000;

//* SW      0(R6), R6
iaddrbusout[91] = 32'h000001B4;
//            opcode source1   dest      Immediate...
instrbusin[91]={SW, 5'b00110, 5'b00110, 16'h0000};

daddrbusout[91] = 32'h00000001;
databusin[91] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[91] = 32'h00000001;

//* SW      0(R7), R7
iaddrbusout[92] = 32'h000001B8;
//            opcode source1   dest      Immediate...
instrbusin[92]={SW, 5'b00111, 5'b00111, 16'h0000};

daddrbusout[92] = 32'h00000001;
databusin[92] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[92] = 32'h00000001;

// * NOP
iaddrbusout[93] = 32'h000001BC;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[93] = 32'b00000000000000000000000000000000;

daddrbusout[93] = dontcare;
databusin[93] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[93] = dontcare;

// * NOP
iaddrbusout[94] = 32'h000001C0;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[94] = 32'b00000000000000000000000000000000;

daddrbusout[94] = dontcare;
databusin[94] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[94] = dontcare;

// * NOP
iaddrbusout[95] = 32'h000001C4;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[95] = 32'b00000000000000000000000000000000;

daddrbusout[95] = dontcare;
databusin[95] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[95] = dontcare;

//* BNE     R0, R6, #00A0
iaddrbusout[96] = 32'h000001C8;
//            opcode source1   dest      Immediate...
instrbusin[96] = {BNE, 5'b00000, 5'b00110, 16'h00A0};
daddrbusout[96] = dontcare;
databusin[96] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[96] = dontcare;

//* BNE     R0, R0, #000A
iaddrbusout[97] = 32'h000001CC;
//            opcode source1   dest      Immediate...
instrbusin[97] = {BNE, 5'b00000, 5'b00000, 16'h000A};
daddrbusout[97] = dontcare;
databusin[97] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[97] = dontcare;

//* BEQ     R0, R0, #000A
iaddrbusout[98] = 32'h0000044C;
//            opcode source1   dest      Immediate...
instrbusin[98] = {BEQ, 5'b00000, 5'b00000, 16'h000A};
daddrbusout[98] = dontcare;
databusin[98] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[98] = dontcare;

// * NOP
iaddrbusout[99] = 32'h00000450;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[99] = 32'b00000000000000000000000000000000;

daddrbusout[99] = dontcare;
databusin[99] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[99] = dontcare;

//* BEQ     R0, R1, #FFFF
iaddrbusout[100] = 32'h00000478;
//            opcode source1   dest      Immediate...
instrbusin[100] = {BEQ, 5'b00000, 5'b00001, 16'hFFFF};
daddrbusout[100] = dontcare;
databusin[100] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[100] = dontcare;

// * NOP
iaddrbusout[101] = 32'h0000047C;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[101] = 32'b00000000000000000000000000000000;

daddrbusout[101] = dontcare;
databusin[101] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[101] = dontcare;

// * NOP
iaddrbusout[102] = 32'h00000480;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[102] = 32'b00000000000000000000000000000000;

daddrbusout[102] = dontcare;
databusin[102] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[102] = dontcare;

// (no. instructions) + (no. loads) + 2*(no. stores) = 35 + 2 + 2*7 = 51
ntests = 102;

$timeformat(-9,1,"ns",12);

end


//assumes positive edge FF.
//testbench reads databus when clk high, writes databus when clk low.
assign databus = clkd ? 32'bz : databusk;

//Change inputs in middle of period (falling edge).
initial begin
  error = 0;
  clkd =1;
  clk=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  databusk = 32'bz;

  //extended reset to set up PC MUX
  reset = 1;
  $display ("reset=%b", reset);
  #5
  clk=0;
  clkd=0;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5

  clk=1;
  clkd=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5
  clk=0;
  clkd=0;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5
  $display ("Time=%t\n  clk=%b", $realtime, clk);

for (k=0; k<= ntests; k=k+1) begin
    clk=1;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    #2
    clkd=1;
    #3
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    reset = 0;
    $display ("reset=%b", reset);


    //set load data for 3rd previous instruction
    if (k >=3)
      databusk = databusin[k-3];

    //check PC for this instruction
    if (k >= 0) begin
      $display ("  Testing PC for instruction %d", k);
      $display ("    Your iaddrbus =    %b", iaddrbus);
      $display ("    Correct iaddrbus = %b", iaddrbusout[k]);
      if (iaddrbusout[k] !== iaddrbus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end

    //put next instruction on ibus
    instrbus=instrbusin[k];
    $display ("  instrbus=%b %b %b %b %b for instruction %d: %s", instrbus[31:26], instrbus[25:21], instrbus[20:16], instrbus[15:11], instrbus[10:0], k, iname[k]);

    //check data address from 3rd previous instruction
    if ( (k >= 3) && (daddrbusout[k-3] !== dontcare) ) begin
      $display ("  Testing data address for instruction %d:", k-3);
      $display ("  %s", iname[k-3]);
      $display ("    Your daddrbus =    %b", daddrbus);
      $display ("    Correct daddrbus = %b", daddrbusout[k-3]);
      if (daddrbusout[k-3] !== daddrbus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end

    //check store data from 3rd previous instruction
    if ( (k >= 3) && (databusout[k-3] !== dontcare) ) begin
      $display ("  Testing store data for instruction %d:", k-3);
      $display ("  %s", iname[k-3]);
      $display ("    Your databus =    %b", databus);
      $display ("    Correct databus = %b", databusout[k-3]);
      if (databusout[k-3] !== databus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end

    clk = 0;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    #2
    clkd = 0;
    #3
    $display ("Time=%t\n  clk=%b", $realtime, clk);
  end

  if ( error !== 0) begin
    $display("--------- SIMULATION UNSUCCESFUL - MISMATCHES HAVE OCCURED ----------");
    $display(" No. Of Errors = %d", error);
  end
  if ( error == 0)
    $display("---------YOU DID IT!! SIMULATION SUCCESFULLY FINISHED----------");
end

endmodule