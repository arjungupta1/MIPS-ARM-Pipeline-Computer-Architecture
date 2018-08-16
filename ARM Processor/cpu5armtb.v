`timescale 1ns/10ps


module cpu5armtb();

parameter num = 201;
reg  [31:0] instrbus;
reg  [31:0] instrbusin[0:num];
wire [63:0] iaddrbus, daddrbus;
reg  [63:0] iaddrbusout[0:num], daddrbusout[0:num];
wire [63:0] databus;
reg  [63:0] databusk, databusin[0:num], databusout[0:num];
reg         clk, reset;
reg         clkd;

reg [63:0] dontcare;
reg [24*8:1] iname[0:num];
integer error, k, ntests;

	parameter BRANCH	= 6'b000101;
	parameter BEQ		= 8'b01010101;
	parameter BNE		= 8'b01010110;
	parameter BLT		= 8'b01010111;
	parameter BGE		= 8'b01011000;
	parameter CBZ		= 8'b10110100;
	parameter CBNZ		= 8'b10110101;
	parameter ADD		= 11'b10001011000;
	parameter ADDS		= 11'b10101011000;
	parameter SUB		= 11'b11001011000;
	parameter SUBS		= 11'b11101011000;
	parameter AND		= 11'b10001010000;
	parameter ANDS		= 11'b11101010000;
	parameter EOR		= 11'b11001010000;
	parameter ORR		= 11'b10101010000;
	parameter LSL		= 11'b11010011011;
	parameter LSR		= 11'b11010011010;
	parameter ADDI  	= 10'b1001000100;
	parameter ADDIS		= 10'b1011000100;
	parameter SUBI		= 10'b1101000100;
	parameter SUBIS		= 10'b1111000100;
	parameter ANDI		= 10'b1001001000;
	parameter ANDIS		= 10'b1111001000;
	parameter EORI		= 10'b1101001000;
	parameter ORRI		= 10'b1011001000;
	parameter MOVZ		= 9'b110100101;
	parameter STUR		= 11'b11111000000;
	parameter LDUR		= 11'b11111000010;
	
	
cpu5arm dut(.reset(reset),.clk(clk),.iaddrbus(iaddrbus),.ibus(instrbus),.daddrbus(daddrbus),.databus(databus));

initial begin
// This test file runs the following program.

/**
    Bit formats:
R   {11'b opcode, 5'b Rm,         6'b shamt,    5'b Rn, 5'b Rd}
I   {10'b opcode, 12'b ALU Immediate,           5'b Rn, 5'b Rd}
D   {9'b  opcode, 9'b DT Address, 2'b op,       5'b Rn, 5'b Rt}
B   {6'b  opcode, 26'b Branch Address                         }
CB  {8'b  opcode, 19'b COND Branch address,             5'b Rt}
IM  {9'b  opcode, 2'b shamt,      16'b mov_immediate,   5'b Rd}

**/

iname[0] = "ADDI R1, R31, #123";
iname[1] = "ADDI R2, R31, #FFF";
iname[2] = "ADDI R3, R31, #246";
iname[3] = "AND R4, R1, R2";
iname[4] = "LDUR R5, 0[R2]";
iname[5] = "LSL R6, R1, 6'd30";
iname[6] = "ORR R2, R1, R2";
iname[7] = "ADDI R7, R3, #123";
iname[8] = "LSR R6, R1, 6'd30";
iname[9] = "AND R9, R6, R1";
iname[10] = "LDUR R8, 100[R7]";
iname[11] = "B h14";
iname[12] = "SUBIS R31, R4, R1";
iname[13] = "BEQ h10";
iname[14] = "LDUR R10, 0[R1]";
iname[15] = "STUR 0[R2], R8";
iname[16] = "BEQ hFFFF";
iname[17] = "BNE hFFFF";
iname[18] = "BLT hFFFF";
iname[19] = "BGE hFFFF";
iname[20] = "ADD R11, R2, R3";
iname[21] = "LSL R12, R7, 6'd16";
iname[22] = "B h20";
iname[23] = "ADDIS R13, R1, #333";
iname[24] = "ADD R14, R10, R1";
iname[25] = "ANDI R15, R7, #123";
iname[26] = "ADDS R16, R12, R7";
iname[27] = "SUB R17, R12, R12";
iname[28] = "SUBI R18, R12, #123";
iname[29] = "ORR R19, R12, R7";
iname[30] = "MOVZ R20, 0<<16 #1";
iname[31] = "MOVZ R21, 1<<16 #1";
iname[32] = "MOVZ R22, 2<<16 #1";

iname[33] = "MOVZ R23, 3<<16 #1";
iname[34] = "LDUR R24, 1FF[R18]";
iname[35] = "LDUR R25, 10F[R19]";
iname[36] = "EORI R26, R20, #0";
iname[37] = "EOR R27, R20, R21";
iname[38] = "EOR R28, R1, R2";
iname[39] = "EOR R29, R1, R3";
iname[40] = "CBZ #123, R1";
iname[41] = "CBZ #123, R2";
iname[42] = "CBNZ #123, R3";
iname[43] = "ANDI R30, R1, #ABC";
iname[44] = "ANDI R1, R2, #DEF";
iname[45] = "AND R2, R10, R11";
iname[46] = "AND R3, R11, R12";
iname[47] = "AND R4, R23, R22";
iname[48] = "ADDS R5, R20, R21";
iname[49] = "ADDS R6, R21, R22";
iname[50] = "ADDS R1, R2, R30";
iname[51] = "B h30";
iname[52] = "BEQ hFFFF";
iname[53] = "CBNZ #10, R6";
iname[54] = "EORI, R0, R31, #FFF";
iname[55] = "EORI, R31, R31, #FFF";
iname[56] = "EOR R31, R1, R2";
iname[57] = "CBNZ #10, R31";
iname[58] = "LSL R5, R2, 6'd19";
iname[59] = "LSR R6, R3, 6'd20";
iname[60] = "ORRI R7, R3, #F0F";
iname[61] = "ORRI R8, R1, #F0F";
iname[62] = "STUR 0[R23], R9";
iname[63] = "SUBI R10, R31, #FFF";
iname[64] = "SUB R1, R5, R0";

iname[65] = "SUBI R2, R31, #FFF";
iname[66] = "ORRI R3, R31, #111";
iname[67] = "ORR, R4, R31, R31";
iname[68] = "ADDI R5, R31, #100";
iname[69] = "ADD R6, R1, R1";
iname[70] = "ADDIS R7, R2, R1";
iname[71] = "ADDS R8, R3, R3";
iname[72] = "ANDS R9, R31, R31";
iname[73] = "ANDIS R10, R2, #FFF";
iname[74] = "B h40";
iname[75] = "SUBS R31,  R31 R31";
iname[76] = "BEQ h8";
iname[77] = "SUBS R31, R31, R31";
iname[78] = "BNE hFFFF";
iname[79] = "SUBS R31, R31, R31";
iname[80] = "BLT hFFFF";
iname[81] = "SUBS R31, R31, R31";
iname[82] = "BGE hFFFF";
iname[83] = "ANDIS R11, R10, #1";
iname[84] = "EORI R12, R9, #BBB";
iname[85] = "MOVZ R13, 2<<16, #FFFF";
iname[86] = "MOVZ R14, 1<<16 #FF11";
iname[87] = "LSL R15, R9, 6'd10";
iname[88] = "LSL R16, R10, 6'd9";
iname[89] = "ANDS R17, R8, R3";
iname[90] = "ANDS R18, R11, R31";
iname[91] = "ORR R1, R2, R3";
iname[92] = "ORR R1, R3, R4";
iname[93] = "ORR R1, R4, R5";
iname[94] = "ORR R1, R5, R6";
iname[95] = "ORRI R2, R14, #FED";
iname[96] = "ORRI R2, R15, #DFA";

iname[97] = "ORRI R2, R12, #AAA";
iname[98] = "ORRI R2, R31, #ABC";
iname[99] = "ADDIS R19, R1, #AAA";
iname[100] = "ADDIS R19, R13, #BBB";
iname[101] = "ADDIS R19, R3, #CCC";
iname[102] = "ADDIS R19, R2, #DDD";
iname[103] = "ADD R20, R17, R17";
iname[104] = "ADD R20, R18, R17";
iname[105] = "ADD R20, R2, R11";
iname[106] = "ADD R20, R31, R31";
iname[107] = "ADDI R10, R31, #123";
iname[108] = "ADDI R10, R19, #FFF";
iname[109] = "ADDS R11, R19, R18";
iname[110] = "ADDS R12, R20, R19";
iname[111] = "AND R13, R20, R19";
iname[112] = "AND R14, R10, R20";
iname[113] = "ANDS R9, R10, R20";
iname[114] = "ANDS R0, R31, R31";
iname[115] = "ANDI R22, R11, #123";
iname[116] = "ANDI R23, R10, #123";
iname[117] = "ANDIS R1, R19, #DED";
iname[118] = "ANDIS R1, R20, #AAA";
iname[119] = "ANDIS R1, R19, #ACD";
iname[120] = "ANDI R2, R22, #141";
iname[121] = "ANDI R3, R23, #141";
iname[122] = "ADDI R4, R10, #FFF";
iname[123] = "STUR 0[R10], R5";
iname[124] = "STUR 1FF[R20], R6";
iname[125] = "STUR F0[R19], R7";
iname[126] = "STUR 0[R14], R8";
iname[127] = "SUBI R15, R31, #400";

iname[128] = "ORRI R10, R3, #FFA";
iname[129] = "SUB R20, R3, R5";
iname[130] = "SUB R21, R4, R6";
iname[131] = "SUB R22, R31, R31";
iname[132] = "SUBI, R16, R15, #9F4";
iname[133] = "B h'10";
iname[134] = "LSR R4, R10, 6d'10";
iname[135] = "LSR R4, R9, 6d'3F";
iname[136] = "LSR R4, R15, 6d'5";
iname[137] = "LSR R4, R16, 6d'A";
iname[138] = "MOVZ R16, 1<<16 #FA";
iname[139] = "SUBI R11, R31, #FFF";
iname[140] = "ADDIS R12, R31, #0F0";
iname[141] = "LDUR R30 FF[R21]";
iname[142] = "LDUR R29 0[R22]";
iname[143] = "SUBS R31, R10, R11";
iname[144] = "BGE h1000";
iname[145] = "SUBS R31, R31, R11";
iname[146] = "BLT h1000";
iname[147] = "SUBS R31, R10, R11";
iname[148] = "BEQ h1000";
iname[149] = "SUBS R31, R31, R31";
iname[150] = "BNE h1000";
iname[151] = "SUBS R31, R15 R16";
iname[152] = "BNE hFFFF";
iname[153] = "BEQ h1000";
iname[154] = "BLT h1000";
iname[155] = "BGE h1000";
iname[156] = "B h'1000";
iname[157] = "BEQ h1000";
iname[158] = "BNE h1000";
iname[159] = "BEQ h1000";

iname[160] = "BLT h1000";
iname[161] = "BGE h1000";
iname[162] = "BNE h1000";
iname[163] = "SUBS R31, R31, R31";
iname[164] = "BLT h1000";
iname[165] = "SUBS R31, R10, R11";
iname[166] = "BGE h1000";
iname[167] = "CBNZ R31 #10";
iname[168] = "CBZ R29 #FFFF";
iname[169] = "CBNZ R10 #100";
iname[170] = "CBNZ R14 #100";
iname[171] = "CBZ R31 #100";
iname[172] = "CBZ R10 #100";
iname[173] = "CBZ R14 #100";
iname[174] = "CBZ R30 #1000";
iname[175] = "CBNZ R31 #FFFFF";
iname[176] = "EOR R0, R31, R30";
iname[177] = "EOR R1, R30, R29";
iname[178] = "EOR R2, R31, R4";
iname[179] = "EOR R3, R31, R11";
iname[180] = "EOR R4, R11, R0";
iname[181] = "EORI R31, R31, #FFF";
iname[182] = "EORI R30, R1, #FAB";
iname[183] = "EORI R20, R2 #F00";
iname[184] = "EORI E21, R3, #ABC";
iname[185] = "LSL R6, R1, 6'd9";
iname[186] = "LSL R7, R4, 6'd12";
iname[187] = "LSL R8, R3, 6'd3";
iname[188] = "SUB R9, R31, R31";
iname[189] = "SUBI, R10, R1, #123";
iname[190] = "SUBI, R11, R31, #123";
iname[191] = "SUBI, R12, R2, #123";
iname[192] = "SUB R13, R31, R10";
iname[193] = "SUB R14, R4, R3";
iname[194] = "ANDI R31, R31, R31";
iname[195] = "ANDIS R0, R31, #100";
iname[196] = "ANDS R10, R1, R2";
iname[197] = "B h'FFF";
iname[198] = "B h'F123";
iname[199] = "B h'FAD";
iname[200] = "NOP NOP NOP NOP NOP NOP";
iname[201] = "NOP NOP NOP NOP NOP NOP";



dontcare = 64'hx;

// ADDI R1, R31, #123
iaddrbusout[0] = 64'h0000000000000000;
//            opcode
instrbusin[0] = {ADDI, 12'h123, 5'b11111, 5'b00001};

daddrbusout[0] = 64'b0000000000000000000000000000000000000000000000000000000100100011;
databusin[0] = 64'bz;
databusout[0] = dontcare;

// ADDI R2, R31, #FFF
iaddrbusout[1] = 64'h0000000000000004;
//            opcode
instrbusin[1] = {ADDI, 12'hFFF, 5'b11111, 5'b00010};

daddrbusout[1] = 64'b0000000000000000000000000000000000000000000000000000111111111111;
databusin[1] = 64'bz;
databusout[1] = dontcare;

// ADDI R3, R31, #246
iaddrbusout[2] = 64'h0000000000000008;
//            opcode
instrbusin[2] = {ADDI, 12'h246, 5'b11111, 5'b00011};

daddrbusout[2] = 64'b0000000000000000000000000000000000000000000000000000001001000110;
databusin[2] = 64'bz;
databusout[2] = dontcare;

// AND R4, R1, R1
iaddrbusout[3] = 64'h000000000000000C;
//            opcode
instrbusin[3] = {AND, 5'b00001, 6'b000000, 5'b00001, 5'b00100};

daddrbusout[3] = 64'b0000000000000000000000000000000000000000000000000000000100100011;
databusin[3] = 64'bz;
databusout[3] = dontcare;

// LDUR R5, 0[R2]
iaddrbusout[4] = 64'h0000000000000010;
//            opcode
instrbusin[4] = {LDUR, 9'b000000000, 2'b00, 5'b00010, 5'b00101};

daddrbusout[4] = 64'h0000000000000FFF;
databusin[4] = 64'h0000000000000000;
databusout[4] = dontcare;

// LSL R6, R1, 6'd30
iaddrbusout[5] = 64'h0000000000000014;
//            opcode
instrbusin[5] = {LSL, 5'b00000, 6'd30, 5'b00001, 5'b00110};

daddrbusout[5] = 64'b0000000000000000000000000100100011000000000000000000000000000000; 
databusin[5] = 64'bz;
databusout[5] = dontcare;

// ORR R2, R1, R2
iaddrbusout[6] = 64'h0000000000000018;
//            opcode
instrbusin[6] = {ORR, 5'b00001, 6'b000000, 5'b00010, 5'b00010};

daddrbusout[6] = 64'b0000000000000000000000000000000000000000000000000000111111111111;
databusin[6] = 64'bz;
databusout[6] = dontcare;

// ADDI R7, R3, #123
iaddrbusout[7] = 64'h000000000000001C;
    //            opcode
instrbusin[7] = {ADDI, 12'h123, 5'b00011, 5'b00111};

daddrbusout[7] = 64'b0000000000000000000000000000000000000000000000000000001101101001;
databusin[7] = 64'bz;
databusout[7] = dontcare;

// LSR R3, R1, 6'd30
iaddrbusout[8] = 64'h0000000000000020;
//            opcode
instrbusin[8] = {LSR, 5'b00000, 6'd30, 5'b00001, 5'b00011};

daddrbusout[8] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[8] = 64'bz;
databusout[8] = dontcare;

// AND R9, R6, R1
iaddrbusout[9] = 64'h0000000000000024;
//            opcode
instrbusin[9] = {AND, 5'b00110, 6'b000000, 5'b00001, 5'b01001};

daddrbusout[9] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[9] = 64'bz;
databusout[9] = dontcare;

// LDUR R8, 100[R7]
iaddrbusout[10] = 64'h0000000000000028;
//            opcode
instrbusin[10] = {LDUR, 9'h100, 2'b00, 5'b00111, 5'b01000};

daddrbusout[10] = 64'h0000000000000269;
databusin[10] = 64'h0000000000000100;
databusout[10] = dontcare;

// BRANCH h14
iaddrbusout[11] = 64'h000000000000002C;
//            opcode
instrbusin[11] = {BRANCH, 26'h14};

daddrbusout[11] = dontcare;
databusin[11] = 64'bz;
databusout[11] = dontcare;

// SUBS R31, R4, R1
iaddrbusout[12] = 64'h0000000000000030;
//            opcode
instrbusin[12] = {SUBS, 5'b00100, 6'b000000, 5'b00001, 5'b11111};

daddrbusout[12] = 64'h0000000000000000;
databusin[12] = 64'bz;
databusout[12] = dontcare;

// BEQ h10
iaddrbusout[13] = 64'h000000000000007C; //branch unconditionally to h2C + (h14 << 2)= h7C
//            opcode
instrbusin[13] = {BEQ, 19'h10, 5'b00000};

daddrbusout[13] = dontcare;
databusin[13] = 64'bz;
databusout[13] = dontcare;

// LDUR R10, 0[R1]
iaddrbusout[14] = 64'h0000000000000080; //new pc for BEQ instruction to propogate
//            opcode
instrbusin[14] = {LDUR, 9'b0, 2'b00, 5'b00001, 5'b01010};

daddrbusout[14] = 64'b0000000000000000000000000000000000000000000000000000000100100011;
databusin[14] = 64'h0000000000000000;
databusout[14] = dontcare;

// STUR 0[R2], R8
iaddrbusout[15] = 64'h00000000000000BC; //branch conditionally to h7C + (h10 << 2) = BC
//            opcode
instrbusin[15] = {STUR, 9'b0, 2'b00, 5'b00010, 5'b01000};

daddrbusout[15] = 64'b0000000000000000000000000000000000000000000000000000111111111111;
databusin[15] = 64'bz;
databusout[15] = 64'b0000000000000000000000000000000000000000000000000000000100000000;

// BEQ hFFFF
iaddrbusout[16] = 64'h00000000000000C0; //beq not taken here due to no set flags, we will see that iaddrbusout[18] = hC4 + h4 = hC8
//            opcode
instrbusin[16] = {BEQ, 19'hFFFF, 5'b00000};

daddrbusout[16] = dontcare;
databusin[16] = 64'bz;
databusout[16] = dontcare;

// BNE hFFFF
iaddrbusout[17] = 64'h00000000000000C4; //bne not taken here due to no set flags, we will see that iaddrbusout[19] = hC8 + h4 = hCC
//            opcode
instrbusin[17] = {BNE, 19'hFFFF, 5'b00000};

daddrbusout[17] = dontcare;
databusin[17] = 64'bz;
databusout[17] = dontcare;

// BLT hFFFF
iaddrbusout[18] = 64'h00000000000000C8; //blt not taken here due to no set flags, we will see that iaddrbus[20] = hCC + h4 = hD0
//            opcode
instrbusin[18] = {BLT, 19'hFFFF, 5'b00000};

daddrbusout[18] = dontcare;
databusin[18] = 64'bz;
databusout[18] = dontcare;

// BGE hFFFF
iaddrbusout[19] = 64'h00000000000000CC; //bge not taken here due to no set flags, we will see that iaddrbus[21] = hD0 + h4 = hD4
//            opcode
instrbusin[19] = {BGE, 19'hFFFF, 5'b00000};

daddrbusout[19] = dontcare;
databusin[19] = 64'bz;
databusout[19] = dontcare;

// ADD R11  , R2, R3
iaddrbusout[20] = 64'h00000000000000D0;
//            opcode
instrbusin[20] = {ADD, 5'b00010, 6'b000000, 5'b00011, 5'b01011};

daddrbusout[20] = 64'b0000000000000000000000000000000000000000000000000000111111111111;
databusin[20] = 64'bz;
databusout[20] = dontcare;

// LSL R12, R7, 6'd16
iaddrbusout[21] = 64'h00000000000000D4;
//            opcode
instrbusin[21] = {LSL, 5'b00000, 6'd16, 5'b00111, 5'b01100};

daddrbusout[21] = 64'b0000000000000000000000000000000000000011011010010000000000000000;
databusin[21] = 64'bz;
databusout[21] = dontcare;

// BRANCH h20
iaddrbusout[22] = 64'h00000000000000D8;
//            opcode
instrbusin[22] = {BRANCH, 26'h20};

daddrbusout[22] = dontcare;
databusin[22] = 64'bz;
databusout[22] = dontcare;


// ADDIS R13, R1, #333
iaddrbusout[23] = 64'h00000000000000DC;
//            opcode
instrbusin[23] = {ADDIS, 12'h333, 5'b00001, 5'b01101};

daddrbusout[23] = 64'b0000000000000000000000000000000000000000000000000000010001010110;
databusin[23] = 64'bz;
databusout[23] = dontcare;


// ADD R14, R10, R1
iaddrbusout[24] = 64'h0000000000000158;
//            opcode
instrbusin[24] = {ADD, 5'b01010, 6'b00000, 5'b00001, 5'b01110};

daddrbusout[24] = 64'b0000000000000000000000000000000000000000000000000000000100100011;
databusin[24] = 64'bz;
databusout[24] = dontcare;

// ANDI R15, R7, #123
iaddrbusout[25] = 64'h000000000000015C;
//            opcode
instrbusin[25] = {ANDI, 12'h123, 5'b00111, 5'b01111};

daddrbusout[25] = 64'b0000000000000000000000000000000000000000000000000000000100100001;
databusin[25] = 64'bz;
databusout[25] = dontcare;

// ADDS R16, R12, R7
iaddrbusout[26] = 64'h0000000000000160;
//            opcode
instrbusin[26] = {ADDS, 5'b01100, 6'b000000, 5'b00111, 5'b10000};

daddrbusout[26] = 64'b0000000000000000000000000000000000000011011010010000001101101001;
databusin[26] = 64'bz;
databusout[26] = dontcare;

// SUB R17, R12, R12
iaddrbusout[27] = 64'h0000000000000164;
//            opcode
instrbusin[27] = {SUB, 5'b01100, 6'b000000, 5'b01100, 5'b10001};

daddrbusout[27] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[27] = 64'bz;
databusout[27] = dontcare;

// SUBI R18, R12, #123
iaddrbusout[28] = 64'h0000000000000168;
//            opcode
instrbusin[28] = {SUBI, 12'h123, 5'b01100, 5'b10010};

daddrbusout[28] = 64'b0000000000000000000000000000000000000011011010001111111011011101;
databusin[28] = 64'bz;
databusout[28] = dontcare;

// ORR R19, R12, R7
iaddrbusout[29] = 64'h000000000000016C;
//            opcode
instrbusin[29] = {ORR, 5'b01100, 6'b000000, 5'b00111, 5'b10011};

daddrbusout[29] = 64'b0000000000000000000000000000000000000011011010010000001101101001;
databusin[29] = 64'bz;
databusout[29] = dontcare;

// MOVZ R20, 0<<16 #1
iaddrbusout[30] = 64'h0000000000000170;
//            opcode
instrbusin[30] = {MOVZ, 2'b00, 16'd1, 5'b10100};

daddrbusout[30] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
databusin[30] = 64'bz;
databusout[30] = dontcare;

// MOVZ R21, 1<<16 #1
iaddrbusout[31] = 64'h0000000000000174;
//            opcode
instrbusin[31] = {MOVZ, 2'b01, 16'd1, 5'b10101};

daddrbusout[31] = 64'b0000000000000000000000000000000000000000000000010000000000000000;
databusin[31] = 64'bz;
databusout[31] = dontcare;

// MOVZ R22, 2<<16 #1
iaddrbusout[32] = 64'h0000000000000178;
//            opcode
instrbusin[32] = {MOVZ, 2'b10, 16'd1, 5'b10110};

daddrbusout[32] = 64'b0000000000000000000000000000000100000000000000000000000000000000;
databusin[32] = 64'bz;
databusout[32] = dontcare;

// MOVZ R23, 3<<16 #1
iaddrbusout[33] = 64'h000000000000017C;
//            opcode
instrbusin[33] = {MOVZ, 2'b11, 16'd1, 5'b10111};

daddrbusout[33] = 64'b0000000000000001000000000000000000000000000000000000000000000000;
databusin[33] = 64'bz;
databusout[33] = dontcare;

// LDUR R24, 1FF[R18]
iaddrbusout[34] = 64'h0000000000000180;
//            opcode
instrbusin[34] = {LDUR, 9'h1FF, 2'b00, 5'b10010, 5'b11000};

daddrbusout[34] = 64'b0000000000000000000000000000000000000011011010001111111011011100;
databusin[34] = 64'h00000000000001FF;
databusout[34] = dontcare;

// LDUR R25, 10F[R19]
iaddrbusout[35] = 64'h0000000000000184;
//            opcode
instrbusin[35] = {LDUR, 9'h10F, 2'b00, 5'b10011, 5'b11001};

daddrbusout[35] = 64'b0000000000000000000000000000000000000011011010010000001001111000;
databusin[35] = 64'h000000000000010F;
databusout[35] = dontcare;

// EORI R26, R20, #0
iaddrbusout[36] = 64'h0000000000000188;
//            opcode
instrbusin[36] = {EORI, 12'h0, 5'b10100, 5'b11010};

daddrbusout[36] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
databusin[36] = 64'bz;
databusout[36] = dontcare;

// EOR R27, R20, R21
iaddrbusout[37] = 64'h000000000000018C;
//            opcode
instrbusin[37] = {EOR, 5'b10010, 6'b000000, 5'b10011, 6'b11011};

daddrbusout[37] = 64'b0000000000000000000000000100100011000000000000000000100100000001;
databusin[37] = 64'bz;
databusout[37] = dontcare;

// EOR R28, R1, R2
iaddrbusout[38] = 64'h0000000000000190;
//            opcode
instrbusin[38] = {EOR, 5'b00001, 6'b000000, 5'b00010, 5'b11100};

daddrbusout[38] = 64'b0000000000000000000000000000000000000000000000000000111011011100;
databusin[38] = 64'bz;
databusout[38] = dontcare;

// EOR R29, R1, R3
iaddrbusout[39] = 64'h0000000000000194;
//            opcode
instrbusin[39] = {EOR, 5'b00001, 6'b000000, 5'b00011, 5'b11101};

daddrbusout[39] = 64'b0000000000000000000000000000000000000000000000000000000100100011;
databusin[39] = 64'bz;
databusout[39] = dontcare;

// CBZ #123, R1
iaddrbusout[40] = 64'h0000000000000198; //do not branch since R1 is not 0
//            opcode
instrbusin[40] = {CBZ, 19'h123, 5'b00001};

daddrbusout[40] = dontcare;
databusin[40] = 64'bz;
databusout[40] = dontcare;

// CBZ #123, R2
iaddrbusout[41] = 64'h000000000000019C; //do not branch since R2 is not 0
//            opcode
instrbusin[41] = {CBZ, 19'h123, 5'b00010};

daddrbusout[41] = dontcare;
databusin[41] = 64'bz;
databusout[41] = dontcare;

// CBNZ #123, R3
iaddrbusout[42] = 64'h00000000000001A0; //do not branch since R3 is not 0
//            opcode
instrbusin[42] = {CBNZ, 19'h123, 5'b00011};

daddrbusout[42] = dontcare;
databusin[42] = 64'bz;
databusout[42] = dontcare;

// ANDI R30, R1, #ABC
iaddrbusout[43] = 64'h00000000000001A4;
//            opcode
instrbusin[43] = {ANDI, 12'hABC, 5'b00001, 5'b11110};

daddrbusout[43] = 64'b0000000000000000000000000000000000000000000000000000000000100000;
databusin[43] = 64'bz;
databusout[43] = dontcare;

// ANDI R1, R2, #DEF
iaddrbusout[44] = 64'h00000000000001A8;
//            opcode
instrbusin[44] = {ANDI, 12'hDEF, 5'b00010, 5'b00001};

daddrbusout[44] = 64'b0000000000000000000000000000000000000000000000000000110111101111;
databusin[44] = 64'bz;
databusout[44] = dontcare;

// AND R2, R10, R11
iaddrbusout[45] = 64'h00000000000001AC;
//            opcode
instrbusin[45] = {AND, 5'b01010, 6'b000000, 5'b01011, 5'b00010};

daddrbusout[45] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[45] = 64'bz;
databusout[45] = dontcare;

// AND R3, R11, R12
iaddrbusout[46] = 64'h00000000000001B0;
//            opcode
instrbusin[46] = {AND, 5'b01011, 6'b000000, 5'b01100, 5'b00011};

daddrbusout[46] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[46] = 64'bz;
databusout[46] = dontcare;

// AND R4, R23, R22
iaddrbusout[47] = 64'h00000000000001B4;
//            opcode
instrbusin[47] = {AND, 5'b10111, 6'b000000, 5'b10110, 5'b00100};

daddrbusout[47] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[47] = 64'bz;
databusout[47] = dontcare;

// ADDS R5, R20, R21
iaddrbusout[48] = 64'h00000000000001B8;
//            opcode
instrbusin[48] = {ADDS, 5'b10100, 6'b000000, 5'b10101, 5'b00101};

daddrbusout[48] = 64'b0000000000000000000000000000000000000000000000010000000000000001;
databusin[48] = 64'bz;
databusout[48] = dontcare;

// ADDS R6, R21, R22
iaddrbusout[49] = 64'h00000000000001BC;
//            opcode
instrbusin[49] = {ADDS, 5'b10101, 6'b000000, 5'b10110, 5'b00110};

daddrbusout[49] = 64'b0000000000000000000000000000000100000000000000010000000000000000;
databusin[49] = 64'bz;
databusout[49] = dontcare;

// ADDS R1, R2, R30
iaddrbusout[50] = 64'h00000000000001C0;
//            opcode
instrbusin[50] = {ADDS, 5'b00010, 6'b000000, 5'b11110, 5'b00001};

daddrbusout[50] = 64'b0000000000000000000000000000000000000000000000000000000000100000;
databusin[50] = 64'bz;
databusout[50] = dontcare;

// B h30
iaddrbusout[51] = 64'h00000000000001C4; //branches unconditionally to 1C4 + (30 << 2) = 284 on instruction 53.
//            opcode
instrbusin[51] = {BRANCH, 26'h30};

daddrbusout[51] = dontcare;
databusin[51] = 64'bz;
databusout[51] = dontcare;

// BEQ hFFFF
iaddrbusout[52] = 64'h00000000000001C8; //does not branch because flags are not set
//            opcode
instrbusin[52] = {BEQ, 19'hFFFF, 5'b00000};

daddrbusout[52] = dontcare;
databusin[52] = 64'bz;
databusout[52] = dontcare;

// CBNZ #10, R6
iaddrbusout[53] = 64'h0000000000000284; //branches to 284 + (10 << 2) = 2C4 on instruction 55.
//            opcode
instrbusin[53] = {CBNZ, 19'h10, 5'b00110};

daddrbusout[53] = dontcare;
databusin[53] = 64'bz;
databusout[53] = dontcare;

// EORI, R0, R31, #FFF
iaddrbusout[54] = 64'h0000000000000288;
//            opcode
instrbusin[54] = {EORI, 12'hFFF, 5'b11111, 5'b00000};

daddrbusout[54] = 64'b0000000000000000000000000000000000000000000000000000111111111111;
databusin[54] = 64'bz;
databusout[54] = dontcare;

// EORI, R31, R31, #FFF
iaddrbusout[55] = 64'h00000000000002C4;
//            opcode
instrbusin[55] = {EORI, 12'hFFF, 5'b11111, 5'b11111};

daddrbusout[55] = 64'b0000000000000000000000000000000000000000000000000000111111111111;
databusin[55] = 64'bz;
databusout[55] = dontcare;

// EOR R31, R1, R2
iaddrbusout[56] = 64'h00000000000002C8;
//            opcode
instrbusin[56] = {EOR, 5'b00001, 6'b000000, 5'b00010, 5'b11111};

daddrbusout[56] = 64'b0000000000000000000000000000000000000000000000000000000000100000;
databusin[56] = 64'bz;
databusout[56] = dontcare;

// CBNZ #10, R31
iaddrbusout[57] = 64'h00000000000002CC; //does not branch on instruction 59. address should be 2D0 + h4 = 2D4 at instruction 59.
//            opcode
instrbusin[57] = {CBNZ, 19'h10, 5'b11111};

daddrbusout[57] = dontcare;
databusin[57] = 64'bz;
databusout[57] = dontcare;

// LSL R5, R2, 6'd19
iaddrbusout[58] = 64'h00000000000002D0;
//            opcode
instrbusin[58] = {LSL, 5'b00000, 6'd19, 5'b00010, 5'b00101};

daddrbusout[58] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[58] = 64'bz;
databusout[58] = dontcare;

// LSR R6, R3, 6'd20
iaddrbusout[59] = 64'h00000000000002D4;
//            opcode
instrbusin[59] = {LSR, 5'b00000, 6'd20, 5'b00011, 5'b00110};

daddrbusout[59] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[59] = 64'bz;
databusout[59] = dontcare;

// ORRI R7, R3, #F0F
iaddrbusout[60] = 64'h00000000000002D8;
//            opcode
instrbusin[60] = {ORRI, 12'hF0F, 5'b00101, 5'b00111};

daddrbusout[60] = 64'b0000000000000000000000000000000000000000000000010000111100001111;
databusin[60] = 64'bz;
databusout[60] = dontcare;

// ORRI R8, R1, #F0F
iaddrbusout[61] = 64'h00000000000002DC;
//            opcode
instrbusin[61] = {ORRI, 12'hF0F, 5'b00001, 5'b01000};

daddrbusout[61] = 64'b0000000000000000000000000000000000000000000000000000111100101111;
databusin[61] = 64'bz;
databusout[61] = dontcare;

// STUR 0[R23], R9
iaddrbusout[62] = 64'h00000000000002E0;
//            opcode 
instrbusin[62] = {STUR, 9'b000000000, 2'b00, 5'b10111, 5'b01001};

daddrbusout[62] = 64'b0000000000000001000000000000000000000000000000000000000000000000;
databusin[62] = 64'bz;
databusout[62] = 64'b0000000000000000000000000000000000000000000000000000000000000000;

// SUBI R10, R31, #FFF
iaddrbusout[63] = 64'h00000000000002E4;
//            opcode
instrbusin[63] = {SUBI, 12'hFFF, 5'b11111, 5'b01010};

daddrbusout[63] = 64'b1111111111111111111111111111111111111111111111111111000000000001;
databusin[63] = 64'bz;
databusout[63] = dontcare;

// SUB R1, R5, R0
iaddrbusout[64] = 64'h00000000000002E8;
//            opcode
instrbusin[64] = {SUB, 5'b00101, 6'b000000, 5'b00000, 5'b00001};

daddrbusout[64] = 64'b0000000000000000000000000000000000000000000000000000111111111111;
databusin[64] = 64'bz;
databusout[64] = dontcare;

// SUBI R2, R31, #FFF
iaddrbusout[65] = 64'h00000000000002EC;
//            opcode
instrbusin[65] = {SUBI, 12'hFFF, 5'b11111, 5'b00010};


daddrbusout[65] = 64'b1111111111111111111111111111111111111111111111111111000000000001;
databusin[65] = 64'bz;
databusout[65] = dontcare;

// ORRI R3, R31, #111
iaddrbusout[66] = 64'h00000000000002F0;
//            opcode
instrbusin[66] = {ORRI, 12'h111, 5'b11111, 5'b00011};

daddrbusout[66] = 64'b0000000000000000000000000000000000000000000000000000000100010001;
databusin[66] = 64'bz;
databusout[66] = dontcare;

// ORR, R4, R31, R31
iaddrbusout[67] = 64'h00000000000002F4;
//            opcode
instrbusin[67] = {ORR, 5'b11111, 6'b000000, 5'b11111, 5'b00100};

daddrbusout[67] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[67] = 64'bz;
databusout[67] = dontcare; 

// ADDI R5, R31, #100
iaddrbusout[68] = 64'h00000000000002F8;
//            opcode
instrbusin[68] = {ADDI, 12'h100, 5'b11111, 5'b00101};

daddrbusout[68] = 64'b0000000000000000000000000000000000000000000000000000000100000000;
databusin[68] = 64'bz;
databusout[68] = dontcare;

// ADD R6, R1, R1
iaddrbusout[69] = 64'h00000000000002FC;
//            opcode
instrbusin[69] = {ADD, 5'b00001, 6'b000000, 5'b00001, 5'b00110};

daddrbusout[69] = 64'b0000000000000000000000000000000000000000000000000001111111111110;
databusin[69] = 64'bz;
databusout[69] = dontcare;

// ADDIS R7, R2, R1
iaddrbusout[70] = 64'h0000000000000300;
//            opcode
instrbusin[70] = {ADDIS, 5'b00010, 6'b000000, 5'b00001, 5'b00111};

daddrbusout[70] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[70] = 64'bz;
databusout[70] = dontcare;

// ADDS R8, R3, R3
iaddrbusout[71] = 64'h0000000000000304;
//            opcode
instrbusin[71] = {ADDS, 5'b00011, 6'b000000, 5'b00011, 5'b01000};

daddrbusout[71] = 64'b0000000000000000000000000000000000000000000000000000001000100010;
databusin[71] = 64'bz;
databusout[71] = dontcare;

// ANDS R9, R31, R31
iaddrbusout[72] = 64'h0000000000000308;
//            opcode
instrbusin[72] = {ANDS, 5'b11111, 6'b000000, 5'b11111, 5'b01001};

daddrbusout[72] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[72] = 64'bz;
databusout[72] = dontcare;

// ANDIS R10, R2, #FFF
iaddrbusout[73] = 64'h000000000000030C;
//            opcode
instrbusin[73] = {ANDIS, 12'hFFF, 5'b00010, 5'b01010};

daddrbusout[73] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
databusin[73] = 64'bz;
databusout[73] = dontcare;

// B h40
iaddrbusout[74] = 64'h0000000000000310; //branches to h310 + (h40 << 2) = 410 on instruction 76
//            opcode
instrbusin[74] = {BRANCH, 26'h40};

daddrbusout[74] = dontcare;
databusin[74] = 64'bz;
databusout[74] = dontcare;

// SUBS R31,  R31 R31
iaddrbusout[75] = 64'h0000000000000314;
//            opcode
instrbusin[75] = {SUBS, 5'b11111, 6'b000000, 5'b11111, 5'b11111};

daddrbusout[75] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[75] = 64'bz;
databusout[75] = dontcare;

// BEQ h8
iaddrbusout[76] = 64'h0000000000000410; //branches to h410 + (h8 << 2) = 430 on instruction 78.
//            opcode
instrbusin[76] = {BEQ, 19'h8, 5'b00000};

daddrbusout[76] = dontcare;
databusin[76] = 64'bz;
databusout[76] = dontcare;

// SUBS R31, R31, R31
iaddrbusout[77] = 64'h0000000000000414;
//            opcode
instrbusin[77] = {SUBS, 5'b11111, 6'b000000, 5'b11111, 5'b11111};

daddrbusout[77] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[77] = 64'bz;
databusout[77] = dontcare;

// BNE hFFFF
iaddrbusout[78] = 64'h0000000000000430; //does not take the branch because R31 and R31 are equal
//            opcode
instrbusin[78] = {BNE, 19'hFFFF, 5'b00000};

daddrbusout[78] = dontcare;
databusin[78] = 64'bz;
databusout[78] = dontcare;

// SUBS R31, R31, R31
iaddrbusout[79] = 64'h0000000000000434;  
//            opcode
instrbusin[79] = {SUBS, 5'b11111, 6'b000000, 5'b11111, 5'b11111};

daddrbusout[79] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[79] = 64'bz;
databusout[79] = dontcare;

// BLT hFFFF
iaddrbusout[80] = 64'h0000000000000438; //does not take the branch because R31 is not less than R31
//            opcode
instrbusin[80] = {BLT, 19'hFFFF, 5'b00000};

daddrbusout[80] = dontcare;
databusin[80] = 64'bz;
databusout[80] = dontcare;

// SUBS R31, R31, R31
iaddrbusout[81] = 64'h000000000000043C;
//            opcode
instrbusin[81] = {SUBS, 5'b11111, 6'b000000, 5'b11111, 5'b11111};

daddrbusout[81] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[81] = 64'bz;
databusout[81] = dontcare;

// BGE hFFFF
iaddrbusout[82] = 64'h0000000000000440; //does take the branch because R31 is greater than or equal to R31
                                        //will branch to 440 + (FFFF << 2) = 4043C on instruction 84
//            opcode
instrbusin[82] = {BGE, 19'hFFFF, 5'b00000};

daddrbusout[82] = dontcare;
databusin[82] = 64'bz;
databusout[82] = dontcare;

// ANDIS R11, R10, #1
iaddrbusout[83] = 64'h0000000000000444;
//            opcode
instrbusin[83] = {ANDIS, 12'h1, 5'b01010, 5'b01011};

daddrbusout[83] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
databusin[83] = 64'bz;
databusout[83] = dontcare;

// EORI R12, R9, #BBB
iaddrbusout[84] = 64'h000000000004043C;
//            opcode
instrbusin[84] = {EORI, 12'hBBB, 5'b01001, 5'b01100};

daddrbusout[84] = 64'b0000000000000000000000000000000000000000000000000000101110111011;
databusin[84] = 64'bz;
databusout[84] = dontcare;

// MOVZ R13, 2<<16, #FFFF
iaddrbusout[85] = 64'h0000000000040440;
//            opcode
instrbusin[85] = {MOVZ, 2'b10, 16'hFFFF, 5'b01101};

daddrbusout[85] = 64'b0000000000000000111111111111111100000000000000000000000000000000;
databusin[85] = 64'bz;
databusout[85] = dontcare;

// MOVZ R14, 1<<16 #FF11
iaddrbusout[86] = 64'h0000000000040444;
//            opcode
instrbusin[86] = {MOVZ, 2'b01, 16'hFF11, 5'b01110};

daddrbusout[86] = 64'b0000000000000000000000000000000011111111000100010000000000000000;
databusin[86] = 64'bz;
databusout[86] = dontcare;

// LSL R15, R9, 6'd10
iaddrbusout[87] = 64'h0000000000040448;
//            opcode
instrbusin[87] = {LSL, 5'b00000, 6'd10, 5'b01001, 5'b01111};

daddrbusout[87] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[87] = 64'bz;
databusout[87] = dontcare;

// LSL R16, R10, 6'd9
iaddrbusout[88] = 64'h000000000004044C;
//            opcode
instrbusin[88] = {LSL, 5'b00000, 6'd9, 5'b01010, 5'b10000};

daddrbusout[88] = 64'b0000000000000000000000000000000000000000000000000000001000000000;
databusin[88] = 64'bz;
databusout[88] = dontcare;

// ANDS R17, R8, R3
iaddrbusout[89] = 64'h0000000000040450;
//            opcode
instrbusin[89] = {ANDS, 5'b01000, 6'b000000, 5'b00011, 5'b10001};

daddrbusout[89] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[89] = 64'bz;
databusout[89] = dontcare;

// ANDS R18, R11, R31
iaddrbusout[90] = 64'h0000000000040454;
//            opcode
instrbusin[90] = {ANDS, 5'b01011, 6'b000000, 5'b11111, 5'b10010};

daddrbusout[90] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[90] = 64'bz;
databusout[90] = dontcare;

// ORR R1, R2, R3
iaddrbusout[91] = 64'h0000000000040458;
//            opcode
instrbusin[91] = {ORR, 5'b00010, 6'b000000, 5'b00011, 5'b00001};

daddrbusout[91] = 64'b1111111111111111111111111111111111111111111111111111000100010001;
databusin[91] = 64'bz;
databusout[91] = dontcare;

// ORR R1, R3, R4
iaddrbusout[92] = 64'h000000000004045C;
//            opcode
instrbusin[92] = {ORR, 5'b00011, 6'b000000, 5'b00100, 5'b00001};

daddrbusout[92] = 64'b0000000000000000000000000000000000000000000000000000000100010001;
databusin[92] = 64'bz;
databusout[92] = dontcare;

// ORR R1, R4, R5
iaddrbusout[93] = 64'h0000000000040460;
//            opcode
instrbusin[93] = {ORR, 5'b00100, 6'b000000, 5'b00101, 5'b00001};

daddrbusout[93] = 64'b0000000000000000000000000000000000000000000000000000000100000000;
databusin[93] = 64'bz;
databusout[93] = dontcare;

// ORR R1, R5, R6
iaddrbusout[94] = 64'h0000000000040464;
//            opcode
instrbusin[94] = {ORR, 5'b00101, 6'b000000, 5'b00110, 5'b00001};

daddrbusout[94] = 64'b0000000000000000000000000000000000000000000000000001111111111110;
databusin[94] = 64'bz;
databusout[94] = dontcare;

// ORRI R2, R14, #FED
iaddrbusout[95] = 64'h0000000000040468;
//            opcode
instrbusin[95] = {ORRI, 12'hFED, 5'b01110, 5'b00010};

daddrbusout[95] = 64'b0000000000000000000000000000000011111111000100010000111111101101;
databusin[95] = 64'bz;
databusout[95] = dontcare;

// ORRI R2, R15, #DFA
iaddrbusout[96] = 64'h000000000004046C;
//            opcode
instrbusin[96] = {ORRI, 12'hDFA, 5'b01111, 5'b00010};

daddrbusout[96] = 64'b0000000000000000000000000000000000000000000000000000110111111010;
databusin[96] = 64'bz;
databusout[96] = dontcare;

// ORRI R2, R12, #AAA
iaddrbusout[97] = 64'h0000000000040470;
//            opcode
instrbusin[97] = {ORRI, 12'hAAA, 5'b01100, 5'b00010};

daddrbusout[97] = 64'b0000000000000000000000000000000000000000000000000000101110111011;
databusin[97] = 64'bz;
databusout[97] = dontcare;

// ORRI R2, R31, #ABC
iaddrbusout[98] = 64'h0000000000040474;
//            opcode
instrbusin[98] = {ORRI, 12'hABC, 5'b11111, 5'b00010};

daddrbusout[98] = 64'b0000000000000000000000000000000000000000000000000000101010111100;
databusin[98] = 64'bz;
databusout[98] = dontcare;

// ADDIS R19, R1, AAA
iaddrbusout[99] = 64'h0000000000040478;
//            opcode
instrbusin[99] = {ADDIS, 12'hAAA, 5'b00001, 5'b10011};

daddrbusout[99] = 64'b0000000000000000000000000000000000000000000000000010101010101000;
databusin[99] = 64'bz;
databusout[99] = dontcare;

// ADDIS R19, R13, BBB
iaddrbusout[100] = 64'h000000000004047C;
//            opcode
instrbusin[100] = {ADDIS, 12'hBBB, 5'b01101, 5'b10011};

daddrbusout[100] = 64'b0000000000000000111111111111111100000000000000000000101110111011;
databusin[100] = 64'bz;
databusout[100] = dontcare;

// ADDIS R19, R3, CCC
iaddrbusout[101] = 64'h0000000000040480;
//            opcode
instrbusin[101] = {ADDIS, 12'hCCC, 5'b00011, 5'b10011};

daddrbusout[101] = 64'b0000000000000000000000000000000000000000000000000000110111011101;
databusin[101] = 64'bz;
databusout[101] = dontcare;

// ADDIS R19, R2 DDD
iaddrbusout[102] = 64'h0000000000040484;
//            opcode
instrbusin[102] = {ADDIS, 12'hDDD, 5'b00010, 5'b10011};

daddrbusout[102] = 64'b0000000000000000000000000000000000000000000000000001100010011001;
databusin[102] = 64'bz;
databusout[102] = dontcare;

// ADD R20, R17, R17
iaddrbusout[103] = 64'h0000000000040488;
//            opcode
instrbusin[103] = {ADD, 5'b10001, 6'b000000, 5'b10001, 5'b10100};

daddrbusout[103] = 64'b0;
databusin[103] = 64'bz;
databusout[103] = dontcare;

// ADD R20, R18, R17
iaddrbusout[104] = 64'h000000000004048C;
//            opcode
instrbusin[104] = {ADD, 5'b10010, 6'b000000, 5'b10001, 5'b10100};

daddrbusout[104] = 64'b0;
databusin[104] = 64'bz;
databusout[104] = dontcare;

// ADD R20, R2, R11
iaddrbusout[105] = 64'h0000000000040490;
//            opcode
instrbusin[105] = {ADD, 5'b00010, 6'b000000, 5'b010011, 5'b10100};

daddrbusout[105] = 64'b0000000000000000000000000000000000000000000000000010001101010101;
databusin[105] = 64'bz;
databusout[105] = dontcare;

// ADD R20, R31, R31
iaddrbusout[106] = 64'h0000000000040494;
//            opcode
instrbusin[106] = {ADD, 5'b11111, 6'b000000, 5'b11111, 5'b10100};

daddrbusout[106] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[106] = 64'bz;
databusout[106] = dontcare;

// ADDI R10, R31, #123
iaddrbusout[107] = 64'h0000000000040498;
//            opcode
instrbusin[107] = {ADDI, 12'h123, 5'b11111, 5'b01010};
daddrbusout[107] = 64'b0000000000000000000000000000000000000000000000000000000100100011;
databusin[107] = 64'bz;
databusout[107] = dontcare;

// ADDI R10, R19, #FFF
iaddrbusout[108] = 64'h000000000004049C;
//            opcode
instrbusin[108] = {ADDI, 12'hFFF, 5'b10011, 5'b01010};

daddrbusout[108] = 64'b0000000000000000000000000000000000000000000000000010100010011000;
databusin[108] = 64'bz;
databusout[108] = dontcare;

// ADDS R11, R19, R18
iaddrbusout[109] = 64'h00000000000404A0;
//            opcode
instrbusin[109] = {ADDS, 5'b10011, 6'b000000, 5'b10010, 5'b01011};

daddrbusout[109] = 64'b0000000000000000000000000000000000000000000000000001100010011001;
databusin[109] = 64'bz;
databusout[109] = dontcare;

// ADDS R12, R20, R19
iaddrbusout[110] = 64'h00000000000404A4;
//            opcode
instrbusin[110] = {ADDS, 5'b10100, 6'b000000, 5'b10011, 5'b01100};

daddrbusout[110] = 64'b0000000000000000000000000000000000000000000000000001100010011001;
databusin[110] = 64'bz;
databusout[110] = dontcare;

// AND R13, R20, R19
iaddrbusout[111] = 64'h00000000000404A8;
//            opcode
instrbusin[111] = {AND, 5'b10100, 6'b000000, 5'b10011, 5'b010101};

daddrbusout[111] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[111] = 64'bz;
databusout[111] = dontcare;

// AND R14, R10, R20
iaddrbusout[112] = 64'h00000000000404AC;
//            opcode
instrbusin[112] = {AND, 5'b01010, 6'b000000, 5'b10100, 5'b01110};

daddrbusout[112] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[112] = 64'bz;
databusout[112] = dontcare;

// ANDS R9, R10, R20
iaddrbusout[113] = 64'h00000000000404B0;
//            opcode
instrbusin[113] = {ANDS, 5'b01010, 6'b000000, 5'b10100, 5'b01001};

daddrbusout[113] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[113] = 64'bz;
databusout[113] = dontcare;

// ANDS R0, R31, R31
iaddrbusout[114] = 64'h00000000000404B4;
//            opcode
instrbusin[114] = {ANDS, 5'b11111, 6'b000000, 5'b11111, 5'b00000};

daddrbusout[114] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[114] = 64'bz;
databusout[114] = dontcare;

// ANDI R22, R11, #123
iaddrbusout[115] = 64'h00000000000404B8;
//            opcode
instrbusin[115] = {ANDI, 12'h123, 5'b01011, 5'b10110};

daddrbusout[115] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
databusin[115] = 64'bz;
databusout[115] = dontcare;

// ANDI R23, R10, #123
iaddrbusout[116] = 64'h00000000000404BC;
//            opcode
instrbusin[116] = {ANDI, 12'h123, 5'b01010, 5'b10111};

daddrbusout[116] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[116] = 64'bz;
databusout[116] = dontcare;

// ANDIS R1, R19, #DED
iaddrbusout[117] = 64'h00000000000404C0;
//            opcode
instrbusin[117] = {ANDIS, 12'hDED, 5'b10011, 5'b00001};

daddrbusout[117] = 64'b0000000000000000000000000000000000000000000000000000100010001001;
databusin[117] = 64'bz;
databusout[117] = dontcare;

// ANDIS R1, R20, #AAA
iaddrbusout[118] = 64'h00000000000404C4;
//            opcode
instrbusin[118] = {ANDIS, 12'hAAA, 5'b10100, 5'b00001};

daddrbusout[118] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[118] = 64'bz;
databusout[118] = dontcare;

// ANDIS R1, R19, #ACD
iaddrbusout[119] = 64'h00000000000404C8;
//            opcode
instrbusin[119] = {ANDIS, 12'hACD, 5'b10011, 5'b00001};

daddrbusout[119] = 64'b0000000000000000000000000000000000000000000000000000100010001001;
databusin[119] = 64'bz;
databusout[119] = dontcare;

// ANDI R2, R22, #141
iaddrbusout[120] = 64'h00000000000404CC;
//            opcode
instrbusin[120] = {ANDI, 12'h141, 5'b10110, 5'b00010};

daddrbusout[120] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
databusin[120] = 64'bz;
databusout[120] = dontcare;

// ANDI R3, R23, #141
iaddrbusout[121] = 64'h00000000000404D0;
//            opcode
instrbusin[121] = {ANDI, 12'h141, 5'b10111, 5'b00011};

daddrbusout[121] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[121] = 64'bz;
databusout[121] = dontcare;

// ADDI R4, R10, #FFF
iaddrbusout[122] = 64'h00000000000404D4;
//            opcode
instrbusin[122] = {ADDI, 12'hFFF, 5'b00100, 5'b01010};

daddrbusout[122] = 64'b0000000000000000000000000000000000000000000000000000111111111111;
databusin[122] = 64'bz;
databusout[122] = dontcare;

// STUR 0[R10], R5
iaddrbusout[123] = 64'h00000000000404D8;
//            opcode
instrbusin[123] = {STUR, 9'b0, 2'b00, 5'b01010, 5'b00101};

daddrbusout[123] = 64'b0000000000000000000000000000000000000000000000000010100010011000;
databusin[123] = 64'bz;
databusout[123] = 64'b0000000000000000000000000000000000000000000000000000000100000000;

// STUR 1FF[R20], R6
iaddrbusout[124] = 64'h00000000000404DC;
//            opcode
instrbusin[124] = {STUR, 9'h1FF, 2'b00, 5'b10100, 5'b00110};

daddrbusout[124] = 64'b1111111111111111111111111111111111111111111111111111111111111111;
databusin[124] = 64'bz;
databusout[124] = 64'b0000000000000000000000000000000000000000000000000001111111111110;

// STUR F0[R19], R7
iaddrbusout[125] = 64'h00000000000404E0;
//            opcode
instrbusin[125] = {STUR, 9'hF0, 2'b00, 5'b10011, 5'b00111};

daddrbusout[125] = 64'b0000000000000000000000000000000000000000000000000001100110001001;
databusin[125] = 64'bz;
databusout[125] = 64'b0000000000000000000000000000000000000000000000010000111100001111;

// STUR 0[R14], R8
iaddrbusout[126] = 64'h00000000000404E4;
//            opcode
instrbusin[126] = {STUR, 9'h0, 2'b00, 5'b01110, 5'b01000};

daddrbusout[126] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[126] = 64'bz;
databusout[126] = 64'b0000000000000000000000000000000000000000000000000000001000100010;

// SUBI R15, R31, #400
iaddrbusout[127] = 64'h00000000000404E8;
//            opcode
instrbusin[127] = {SUBI, 12'h400, 5'b11111, 5'b01111};

daddrbusout[127] = 64'b1111111111111111111111111111111111111111111111111111110000000000;
databusin[127] = 64'bz;
databusout[127] = dontcare;

// ORRI R10, R3, #FFA
iaddrbusout[128] = 64'h00000000000404EC;
//            opcode
instrbusin[128] = {ORRI, 12'hFFA, 5'b00011, 5'b01010};

daddrbusout[128] = 64'b0000000000000000000000000000000000000000000000000000111111111010;
databusin[128] = 64'bz;
databusout[128] = dontcare;

// SUB R20, R3, R5
iaddrbusout[129] = 64'h00000000000404F0;
//            opcode
instrbusin[129] = {SUB, 5'b00011, 6'b000000, 5'b00101, 5'b10100};

daddrbusout[129] = 64'b0000000000000000000000000000000000000000000000000000000100000000;
databusin[129] = 64'bz;
databusout[129] = dontcare;

// SUB R21, R4, R6
iaddrbusout[130] = 64'h00000000000404F4;
//            opcode
instrbusin[130] = {SUB, 5'b00100, 6'b000000, 5'b00110, 5'b10101};

daddrbusout[130] = 64'b0000000000000000000000000000000000000000000000000001111111111110;
databusin[130] = 64'bz;
databusout[130] = dontcare;

// SUB R22, R31, R31
iaddrbusout[131] = 64'h00000000000404F8;
//            opcode
instrbusin[131] = {SUB, 5'b11111, 6'b000000, 5'b11111, 5'b10110};

daddrbusout[131] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[131] = 64'bz;
databusout[131] = dontcare;

// SUBI, R16, R15, #9F4
iaddrbusout[132] = 64'h00000000000404FC;
//            opcode
instrbusin[132] = {SUBI, 12'h9F4, 5'b01111, 5'b10000};

daddrbusout[132] = 64'b1111111111111111111111111111111111111111111111111111001000001100;
databusin[132] = 64'bz;
databusout[132] = dontcare;

// B h'10
iaddrbusout[133] = 64'h0000000000040500; //branches unconditionally to (40500 + (10 << 2)) = 40540 on instruciton 135
//            opcode
instrbusin[133] = {BRANCH, 26'h10};

daddrbusout[133] = dontcare;
databusin[133] = 64'bz;
databusout[133] = dontcare;

// LSR R4, R10, 6d'10
iaddrbusout[134] = 64'h0000000000040504;
//            opcode
instrbusin[134] = {LSR, 5'b00000, 6'd10, 5'b01010, 5'b00100};

daddrbusout[134] = 64'b0000000000000000000000000000000000000000000000000000000000000011;
databusin[134] = 64'bz;
databusout[134] = dontcare;

// LSR R4, R9, 6h'3F
iaddrbusout[135] = 64'h0000000000040540;
//            opcode
instrbusin[135] = {LSR, 5'b00000, 6'h3F, 5'b01001, 5'b00100};

daddrbusout[135] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[135] = 64'bz;
databusout[135] = dontcare;

// LSR R4, R15, 6d'5
iaddrbusout[136] = 64'h0000000000040544;
//            opcode
instrbusin[136] = {LSR, 5'b00000, 6'd5, 5'b01111, 5'b00100};

daddrbusout[136] = 64'b0000011111111111111111111111111111111111111111111111111111100000;
databusin[136] = 64'bz;
databusout[136] = dontcare;

// LSR R4, R16, 6h'A
iaddrbusout[137] = 64'h0000000000040548;
//            opcode
instrbusin[137] = {LSR, 5'b00000, 6'hA, 5'b10000, 5'b00100};

daddrbusout[137] = 64'b0000000000111111111111111111111111111111111111111111111111111100;
databusin[137] = 64'bz;
databusout[137] = dontcare;

// MOVZ R16, 1<<16 #FA
iaddrbusout[138] = 64'h000000000004054C;
//            opcode
instrbusin[138] = {MOVZ, 2'b01, 16'hFA, 5'b10000};

daddrbusout[138] = 64'b0000000000000000000000000000000000000000111110100000000000000000;
databusin[138] = 64'bz;
databusout[138] = dontcare;

// SUBI R11, R31, #FFF
iaddrbusout[139] = 64'h0000000000040550;
//            opcode
instrbusin[139] = {SUBI, 12'hFFF, 5'b11111, 5'b01011};

daddrbusout[139] = 64'b1111111111111111111111111111111111111111111111111111000000000001;
databusin[139] = 64'bz;
databusout[139] = dontcare;

// ADDIS R12, R31, #0F0
iaddrbusout[140] = 64'h0000000000040554;
//            opcode
instrbusin[140] = {ADDIS, 12'h0F0, 5'b11111, 5'b01100};

daddrbusout[140] = 64'b0000000000000000000000000000000000000000000000000000000011110000;
databusin[140] = 64'bz;
databusout[140] = dontcare;


// LDUR R30 FF[R21]
iaddrbusout[141] = 64'h0000000000040558;
//            opcode
instrbusin[141] = {LDUR, 9'hFF, 2'b00, 5'b10101, 5'b11110};

daddrbusout[141] = 64'b0000000000000000000000000000000000000000000000000010000011111101;
databusin[141] = 64'h00000000000000FF;
databusout[141] = dontcare;

// LDUR R29 0[R22]
iaddrbusout[142] = 64'h000000000004055C;
//            opcode
instrbusin[142] = {LDUR, 9'b000000000, 2'b00, 5'b10110, 5'b11101};

daddrbusout[142] = 64'h0000000000000000000000000000000000000000000000000000000000000000;
databusin[142] = 64'h0000000000000000;
databusout[142] = dontcare;

// SUBS R31, R10, R11
iaddrbusout[143] = 64'h0000000000040560;
//            opcode
instrbusin[143] = {SUBS, 5'b01010, 6'b000000, 5'b01010, 5'b01011};

daddrbusout[143] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[143] = 64'bz;
databusout[143] = dontcare;

// BGE h1000
iaddrbusout[144] = 64'h0000000000040564; //branches to 40564 + (1000 << 2) = 44564 at instr 146 since R10 is >= R11
//            opcode
instrbusin[144] = {BGE, 19'h1000, 5'b00000};

daddrbusout[144] = dontcare;
databusin[144] = 64'bz;
databusout[144] = dontcare;

// SUBS R31, R31, R11
iaddrbusout[145] = 64'h0000000000040568;
//            opcode
instrbusin[145] = {SUBS, 5'b11111, 6'b000000, 5'b01011, 5'b11111};

daddrbusout[145] = 64'b1111111111111111111111111111111111111111111111111111000000000001;
databusin[145] = 64'bz;
databusout[145] = dontcare;

// BLT h1000
iaddrbusout[146] = 64'h0000000000044564; //branches to h44564 + (1000 << 2) = 48564 at instr 148 since R11 < R10
//            opcode
instrbusin[146] = {BLT, 19'h1000, 5'b0000};

daddrbusout[146] = dontcare;
databusin[146] = 64'bz;
databusout[146] = dontcare;

// SUBS R31, R10, R11
iaddrbusout[147] = 64'h0000000000044568;
//            opcode
instrbusin[147] = {SUBS, 5'b01010, 6'b000000, 5'b01010, 5'b01011};

daddrbusout[147] = 64'b0;
databusin[147] = 64'bz;
databusout[147] = dontcare;

// BEQ h1000
iaddrbusout[148] = 64'h0000000000048564; //branches to h48564 + (1000 << 2) = 4C564 at instr 150 since R10 != R11
//            opcode
instrbusin[148] = {BEQ, 19'h1000, 5'b00000};

daddrbusout[148] = dontcare;
databusin[148] = 64'bz;
databusout[148] = dontcare;

// SUBS R31, R31, R31
iaddrbusout[149] = 64'h0000000000048568;
//            opcode
instrbusin[149] = {SUBS, 5'b11111, 6'b000000, 5'b11111, 5'b11111};

daddrbusout[149] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[149] = 64'bz;
databusout[149] = dontcare;

// BNE h1000
iaddrbusout[150] = 64'h000000000004C564; //does not branch since R31 and R31 are equal, PC = PC +4.
//            opcode
instrbusin[150] = {BNE, 19'h1000, 5'b00000};

daddrbusout[150] = dontcare;
databusin[150] = 64'bz;
databusout[150] = dontcare;

// SUBS R31, R15 R16
iaddrbusout[151] = 64'h000000000004C568;
//            opcode
instrbusin[151] = {SUBS, 5'b01111, 6'b000000, 5'b10000, 5'b11111};

daddrbusout[151] = 64'b0000000000000000000000000000000000000000111110100000010000000000;
databusin[151] = 64'bz;
databusout[151] = dontcare;

// BNE hFFFF
iaddrbusout[152] = 64'h000000000004C56C; //branches to 4C56C + (FFFF << 2) = 8C568 at instr 154 since R15 and R16 are not equal
//            opcode
instrbusin[152] = {BNE, 19'hFFFF, 5'b0000};

daddrbusout[152] = dontcare;
databusin[152] = 64'bz;
databusout[152] = dontcare;

// BEQ h1000
iaddrbusout[153] = 64'h000000000004C570; //does not branch since flags were not set
//            opcode
instrbusin[153] = {BEQ, 19'h1000, 5'b00000};

daddrbusout[153] = dontcare;
databusin[153] = 64'bz;
databusout[153] = dontcare;

// BLT h1000
iaddrbusout[154] = 64'h000000000008C568; //does not branch
//            opcode
instrbusin[154] = {BLT, 19'h1000, 5'b00000};

daddrbusout[154] = dontcare;
databusin[154] = 64'bz;
databusout[154] = dontcare;

// BGE h1000
iaddrbusout[155] = 64'h000000000008C56C; //does not branch
//            opcode
instrbusin[155] = {BGE, 19'h1000, 5'b00000};

daddrbusout[155] = dontcare;
databusin[155] = 64'bz;
databusout[155] = dontcare;

// B h'1000
iaddrbusout[156] = 64'h000000000008C570; //branches to 8C570 + (1000 << 2) = 90570 on instr 158
//            opcode
instrbusin[156] = {BRANCH, 26'h1000};

daddrbusout[156] = dontcare;
databusin[156] = 64'bz;
databusout[156] = dontcare;

// BEQ h1000
iaddrbusout[157] = 64'h000000000008C574; //does not branch
//            opcode
instrbusin[157] = {BEQ, 19'h1000, 5'b00000};

daddrbusout[157] = dontcare;
databusin[157] = 64'bz;
databusout[157] = dontcare;

// BNE h1000
iaddrbusout[158] = 64'h0000000000090570; //does not branch
//            opcode
instrbusin[158] = {BNE, 19'h1000, 5'b00000};

daddrbusout[158] = dontcare;
databusin[158] = 64'bz;
databusout[158] = dontcare;

// BEQ h1000
iaddrbusout[159] = 64'h0000000000090574; //does not branch
//            opcode
instrbusin[159] = {BEQ, 19'h1000, 5'b00000};

daddrbusout[159] = dontcare;
databusin[159] = 64'bz;
databusout[159] = dontcare;

// BLT h1000
iaddrbusout[160] = 64'h0000000000090578; //does not branch
//            opcode
instrbusin[160] = {BLT, 19'h1000, 5'b00000};

daddrbusout[160] = dontcare;
databusin[160] = 64'bz;
databusout[160] = dontcare;

// BGE h1000
iaddrbusout[161] = 64'h000000000009057C; //does not branch
//            opcode
instrbusin[161] = {BGE, 19'h1000, 5'b00000};

daddrbusout[161] = dontcare;
databusin[161] = 64'bz;
databusout[161] = dontcare;

// BNE h1000
iaddrbusout[162] = 64'h0000000000090580; //does not branch
//            opcode
instrbusin[162] = {BNE, 19'h1000, 5'b00000};

daddrbusout[162] = dontcare;
databusin[162] = 64'bz;
databusout[162] = dontcare;

// SUBS R31, R31, R31
iaddrbusout[163] = 64'h0000000000090584;
//            opcode
instrbusin[163] = {SUBS, 5'b11111, 6'b000000, 5'b11111, 5'b11111};

daddrbusout[163] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[163] = 64'bz;
databusout[163] = dontcare;

// BLT h1000
iaddrbusout[164] = 64'h0000000000090588; //does not branch since R31 and R31 are not less than eachother
//            opcode
instrbusin[164] = {BLT, 19'h1000, 5'b00000};

daddrbusout[164] = dontcare;
databusin[164] = 64'bz;
databusout[164] = dontcare;

// SUBS R31, R10, R11
iaddrbusout[165] = 64'h000000000009058C;
//            opcode
instrbusin[165] = {SUBS, 5'b01010, 6'b000000, 5'b01011, 5'b11111};

daddrbusout[165] = 64'b1111111111111111111111111111111111111111111111111111000000000110;
databusin[165] = 64'bz;
databusout[165] = dontcare;

// BGE h1000
iaddrbusout[166] = 64'h0000000000090590; //does branch since R10 > R11 on instruction 168.
//            opcode
instrbusin[166] = {BGE, 19'h1000, 5'b0000};

daddrbusout[166] = dontcare;
databusin[166] = 64'bz;
databusout[166] = dontcare;;

// CBNZ R31 #10
iaddrbusout[167] = 64'h0000000000090594; //does not branch
//            opcode
instrbusin[167] = {CBNZ, 19'h10, 5'b11111};

daddrbusout[167] = dontcare;
databusin[167] = 64'bz;
databusout[167] = dontcare;

// CBZ R29 #FFFF
iaddrbusout[168] = 64'h0000000000090598; //branches to 90598 + (FFFF << 2) = D0594 on instruction 170
//            opcode
instrbusin[168] = {CBZ, 19'hFFFF, 5'b11101};

daddrbusout[168] = dontcare;
databusin[168] = 64'bz;
databusout[168] = dontcare;

// CBNZ R10 #100
iaddrbusout[169] = 64'h000000000009059C; //branches to 9059C + (100 << 2) = 9099C on instruction 171?
//            opcode
instrbusin[169] = {CBNZ, 19'h100, 5'b01010};

daddrbusout[169] = dontcare;
databusin[169] = 64'bz;
databusout[169] = dontcare;

// CBNZ R14 #100
iaddrbusout[170] = 64'h00000000000D0594; //does not branch
//            opcode
instrbusin[170] = {CBNZ, 19'h100, 5'b01110};

daddrbusout[170] = dontcare;
databusin[170] = 64'bz;
databusout[170] = dontcare;

// CBZ R31 #100
iaddrbusout[171] = 64'h000000000009099C; //branches to 9099C + (100 << 2) = 90D9C on instr 173
//            opcode
instrbusin[171] = {CBZ, 19'h100, 5'b11111};

daddrbusout[171] = dontcare;
databusin[171] = 64'bz;
databusout[171] = dontcare;

// CBZ R10 #100
iaddrbusout[172] = 64'h00000000000909A0;
//            opcode
instrbusin[172] = {CBZ, 19'h100, 5'b01010}; //does not branch

daddrbusout[172] = dontcare;
databusin[172] = 64'bz;
databusout[172] = dontcare;

// CBZ R14 #100
iaddrbusout[173] = 64'h0000000000090D9C; //branches to 90D9C + (100 << 2) = 9119C on instr 175
//            opcode
instrbusin[173] = {CBZ, 19'h100, 5'b01110};

daddrbusout[173] = dontcare;
databusin[173] = 64'bz;
databusout[173] = dontcare;

// CBZ R30 #1000
iaddrbusout[174] = 64'h0000000000090DA0;
//            opcode
instrbusin[174] = {CBZ, 19'h1000, 5'b11110}; //does not branch since R30 != 0

daddrbusout[174] = dontcare;
databusin[174] = 64'bz;
databusout[174] = dontcare;

// CBNZ R31 #FFFFF
iaddrbusout[175] = 64'h000000000009119C; //does not branch since R31 == 0
//            opcode
instrbusin[175] = {CBNZ, 19'hFFFFF, 5'b11111};

daddrbusout[175] = dontcare;
databusin[175] = 64'bz;
databusout[175] = dontcare;

// EOR R0, R31, R30
iaddrbusout[176] = 64'h00000000000911A0;
//            opcode
instrbusin[176] = {EOR, 5'b11111, 6'b000000, 5'b11110, 5'b00000};

daddrbusout[176] = 64'b0000000000000000000000000000000000000000000000000000000011111111;
databusin[176] = 64'bz;
databusout[176] = dontcare;

// EOR R1, R30, R29
iaddrbusout[177] = 64'h00000000000911A4;
//            opcode
instrbusin[177] = {EOR, 5'b11110, 6'b000000, 5'b11101, 5'b00001};

daddrbusout[177] = 64'b0000000000000000000000000000000000000000000000000000000011111111;
databusin[177] = 64'bz;
databusout[177] = dontcare;

// EOR R2, R31, R4
iaddrbusout[178] = 64'h00000000000911A8;
//            opcode
instrbusin[178] = {EOR, 5'b11111, 6'b000000, 5'b00100, 5'b00010};

daddrbusout[178] = 64'b0000000000111111111111111111111111111111111111111111111111111100;
databusin[178] = 64'bz;
databusout[178] = dontcare;

// EOR R3, R31, R11
iaddrbusout[179] = 64'h00000000000911AC;
//            opcode
instrbusin[179] = {EOR, 5'b11111, 6'b000000, 5'b01011, 5'b00011};

daddrbusout[179] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[179] = 64'bz;
databusout[179] = dontcare;

// EOR R4, R11, R0
iaddrbusout[180] = 64'h00000000000911B0;
//            opcode
instrbusin[180] = {EOR, 5'b01011, 6'b000000, 5'b00000, 5'b00100};

daddrbusout[180] = 64'b0000000000000000000000000000000000000000000000000000000011111111;
databusin[180] = 64'bz;
databusout[180] = dontcare;

// EORI R31, R31, #FFF
iaddrbusout[181] = 64'h00000000000911B4;
//            opcode
instrbusin[181] = {EORI, 12'hFFF, 5'b11111, 5'b11111};

daddrbusout[181] = 64'b0000000000000000000000000000000000000000000000000000111111111111;
databusin[181] = 64'bz;
databusout[181] = dontcare;

// EORI R30, R1, #FAB
iaddrbusout[182] = 64'h00000000000911B8;
//            opcode
instrbusin[182] = {EORI, 12'hFAB, 5'b00001, 5'b11110};

daddrbusout[182] = 64'b0000000000000000000000000000000000000000000000000000111101010100;
databusin[182] = 64'bz;
databusout[182] = dontcare;

// EORI R20, R2 #F00
iaddrbusout[183] = 64'h00000000000911BC;
//            opcode
instrbusin[183] = {EORI, 12'hF00, 5'b00010, 5'b10100};

daddrbusout[183] = 64'b0000000000111111111111111111111111111111111111111111000011111100;
databusin[183] = 64'bz;
databusout[183] = dontcare;

// EORI E21, R3, #ABC
iaddrbusout[184] = 64'h00000000000911C0;
//            opcode
instrbusin[184] = {EORI, 12'hABC, 5'b00011, 5'b10101};

daddrbusout[184] = 64'b0000000000000000000000000000000000000000000000000000101010111100;
databusin[184] = 64'bz;
databusout[184] = dontcare;

// LSL R6, R1, 6'd9
iaddrbusout[185] = 64'h00000000000911C4;
//            opcode
instrbusin[185] = {LSL, 5'b00000, 6'd9, 5'b00001, 5'b00110};

daddrbusout[185] = 64'b0000000000000000000000000000000000000000000000011111111000000000;
databusin[185] = 64'bz;
databusout[185] = dontcare;

// LSL R7, R4, 6'd12
iaddrbusout[186] = 64'h00000000000911C8;
//            opcode
instrbusin[186] = {LSL, 5'b00000, 6'd12, 5'b00100, 5'b00111};

daddrbusout[186] = 64'b0000000000000000000000000000000000000000000011111111000000000000;
databusin[186] = 64'bz;
databusout[186] = dontcare;

// LSL R8, R3, 6'd3
iaddrbusout[187] = 64'h00000000000911CC;
//            opcode
instrbusin[187] = {LSL, 5'b00000, 6'd3, 5'b00011, 5'b01000};

daddrbusout[187] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[187] = 64'bz;
databusout[187] = dontcare;

// SUB R9, R31, R31
iaddrbusout[188] = 64'h00000000000911D0;
//            opcode
instrbusin[188] = {SUB, 5'b11111, 6'b000000, 5'b11111, 5'b01001};

daddrbusout[188] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[188] = 64'bz;
databusout[188] = dontcare;

// SUBI, R10, R1, #123
iaddrbusout[189] = 64'h00000000000911D4;
//            opcode
instrbusin[189] = {SUBI, 12'h123, 5'b00001, 5'b01010};

daddrbusout[189] = 64'b1111111111111111111111111111111111111111111111111111111111011100;
databusin[189] = 64'bz;
databusout[189] = dontcare;

// SUBI, R11, R31, #123
iaddrbusout[190] = 64'h00000000000911D8;
//            opcode
instrbusin[190] = {SUBI, 12'h123, 5'b11111, 5'b01011};

daddrbusout[190] = 64'b1111111111111111111111111111111111111111111111111111111011011101;
databusin[190] = 64'bz;
databusout[190] = dontcare;

// SUBI, R12, R2, #123
iaddrbusout[191] = 64'h00000000000911DC;
//            opcode
instrbusin[191] = {SUBI, 12'h123, 5'b00010, 5'b01100};

daddrbusout[191] = 64'b0000000000111111111111111111111111111111111111111111111011011001;
databusin[191] = 64'bz;
databusout[191] = dontcare;

// SUB R13, R31, R10
iaddrbusout[192] = 64'h00000000000911E0;
//            opcode
instrbusin[192] = {SUB, 5'b11111, 6'b000000, 5'b01010, 5'b01101};

daddrbusout[192] = 64'b1111111111111111111111111111111111111111111111111111111111011100;
databusin[192] = 64'bz;
databusout[192] = dontcare;

// SUB R14, R4, R3
iaddrbusout[193] = 64'h00000000000911E4;
//            opcode
instrbusin[193] = {SUB, 5'b00011, 6'b000000, 5'b00100, 5'b01110};

daddrbusout[193] = 64'b0000000000000000000000000000000000000000000000000000000011111111;
databusin[193] = 64'bz;
databusout[193] = dontcare;

// ANDI R31 R31 R31
iaddrbusout[194] = 64'h00000000000911E8; 
//            opcode
instrbusin[194] = {ANDI, 5'b11111, 6'b000000, 5'b11111, 5'b11111};

daddrbusout[194] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[194] = 64'bz;
databusout[194] = dontcare;

// ANDIS R0, R31, #100
iaddrbusout[195] = 64'h00000000000911EC;
//            opcode
instrbusin[195] = {ANDIS, 12'h100, 5'b11111, 5'b00000};

daddrbusout[195] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[195] = 64'bz;
databusout[195] = dontcare;

// ANDS R10, R1, R2
iaddrbusout[196] = 64'h00000000000911F0;
//            opcode
instrbusin[196] = {ANDS, 5'b00001, 6'b000000, 5'b00010, 5'b01010};

daddrbusout[196] = 64'b0000000000000000000000000000000000000000000000000000000011111100;
databusin[196] = 64'bz;
databusout[196] = dontcare;

// B h'FFF
iaddrbusout[197] = 64'h00000000000911F4; //branches to 911F4 + (FFF << 2) on instr 199 = 951F0
//            opcode
instrbusin[197] = {BRANCH, 26'hFFF};

daddrbusout[197] = dontcare;
databusin[197] = 64'bz;
databusout[197] = dontcare;

// B h'F123
iaddrbusout[198] = 64'h00000000000911F8; //BRANCHES TO 911F8 + (F123 << 2) = CD684 ON INSTR 200
//            opcode
instrbusin[198] = {BRANCH, 26'hF123};

daddrbusout[198] = dontcare;
databusin[198] = 64'bz;
databusout[198] = dontcare;

// B h'FAD
iaddrbusout[199] = 64'h00000000000951F0; //Branches to 951F0 + (FAD << 2) = 990A4 on instr 201
//            opcode
instrbusin[199] = {BRANCH, 26'hFAD};

daddrbusout[199] = dontcare;
databusin[199] = 64'bz;
databusout[199] = dontcare;

//NOP TO FIND BRANCH ADDRESS FROM INSTR 198
iaddrbusout[200] = 64'h00000000000CD684; 
//            opcode
instrbusin[200] = 32'hx;

daddrbusout[200] = dontcare;
databusin[200] = 64'bz;
databusout[200] = dontcare;

//NOP TO FIND BRANCH ADDRESS FROM INSTR 199
iaddrbusout[201] = 64'h00000000000990A4; 
//            opcode
instrbusin[201] = 32'hx;

daddrbusout[201] = dontcare;
databusin[201] = 64'hx;
databusout[201] = dontcare;





// (no. instructions) + (no. loads) + 2*(no. stores) = 
ntests = 221;

$timeformat(-9,1,"ns",12);

end


//assumes positive edge FF.
//testbench reads databus when clk high, writes databus when clk low.
assign databus = clkd ? 64'bz : databusk;

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

for (k=0; k<= num; k=k+1) begin
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
    if ( (k >= 3) && 
	     ((k-3) != 11) && ((k-3) != 13) && ((k-3) != 16)  && ((k-3) != 17) && ((k-3) != 18) && ((k-3) != 19) && 
	     ((k-3) != 22) && ((k-3) != 40) && ((k-3) != 41)  && ((k-3) != 42) && ((k-3) != 51) && ((k-3) != 52) &&
	     ((k-3) != 53) && ((k-3) != 57) && ((k-3) != 74)  && ((k-3) != 76) && ((k-3) != 78) && ((k-3) != 80) &&  
	     ((k-3) != 82) && ((k-3) != 133) && ((k-3) != 144) && ((k-3) != 146) && ((k-3) != 148) && ((k-3) != 150) &&
	     ((k-3) != 152) && ((k-3) != 153) && ((k-3) != 154) && ((k-3) != 155) && ((k-3) != 156) && ((k-3) != 157) &&
	     ((k-3) != 158) && ((k-3) != 159) && ((k-3) != 160) && ((k-3) != 161) && ((k-3) != 162) && ((k-3) != 164) && ((k-3) != 166) &&
	     ((k-3) != 167) && ((k-3) != 168) && ((k-3) != 169) && ((k-3) != 170) && ((k-3) != 171) && ((k-3) != 172) && ((k-3) != 173) &&  
	     ((k-3) != 174) && ((k-3) != 175) && ((k-3) != 197) && ((k-3) != 198) && ((k-3) != 199)     ) begin
	
	//if ( (k >= 3) && (daddrbusout[k-3] !== dontcare) ) begin
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
    if ( (k >= 3) && (databusout[k-3] !== dontcare) && 
	      ((k-3) != 11) && ((k-3) != 13) && ((k-3) != 16)  && ((k-3) != 17) && ((k-3) != 18) && ((k-3) != 19) && 
          ((k-3) != 22) && ((k-3) != 40) && ((k-3) != 41)  && ((k-3) != 42) && ((k-3) != 51) && ((k-3) != 52) &&
          ((k-3) != 53) && ((k-3) != 57) && ((k-3) != 74)  && ((k-3) != 76) && ((k-3) != 78) && ((k-3) != 80) &&  
          ((k-3) != 82) && ((k-3) != 133) && ((k-3) != 144) && ((k-3) != 146) && ((k-3) != 148) && ((k-3) != 150) &&
          ((k-3) != 152) && ((k-3) != 153) && ((k-3) != 154) && ((k-3) != 155) && ((k-3) != 156) && ((k-3) != 157) &&
          ((k-3) != 158) && ((k-3) != 159) && ((k-3) != 160) && ((k-3) != 161) && ((k-3) != 162) && ((k-3) != 164) && ((k-3) != 166) &&
          ((k-3) != 167) && ((k-3) != 168) && ((k-3) != 169) && ((k-3) != 170) && ((k-3) != 171) && ((k-3) != 172) && ((k-3) != 173) &&  
          ((k-3) != 174) && ((k-3) != 175) && ((k-3) != 197) && ((k-3) != 198) && ((k-3) != 199)     ) begin
       
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
  end

  if ( error == 0)
    $display("---------YOU DID IT!! SIMULATION SUCCESFULLY FINISHED----------");

   $display(" Number Of Errors = %d", error);
   $display(" Total Test numbers = %d", ntests);
   $display(" Total number of correct operations = %d", (ntests-error));
   $display(" ");

end

endmodule