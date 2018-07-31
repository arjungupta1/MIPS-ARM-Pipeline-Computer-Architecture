`timescale 1ns/10ps
module cpu4_testbench();

reg [0:31] ibus;
reg [0:31] ibusin[0:74];
wire [0:31] daddrbus;
reg [0:31] daddrbusout[0:74];
wire [0:31] databus;
reg [0:31] databusk, databusin[0:74], databusout[0:74];
reg clk;
reg clkd;

reg [0:31] dontcare;
reg [24*8:1] iname[0:74];
integer error, k, ntests;

parameter ADDI = 6'b000011;
parameter SUBI = 6'b000010;
parameter XORI = 6'b000001;
parameter ANDI = 6'b001111;
parameter ORI = 6'b001100;
parameter LW = 6'b011110;
parameter SW = 6'b011111;
parameter Rformat = 6'b000000;
parameter ADD = 6'b000011;
parameter SUB = 6'b000010;
parameter XOR = 6'b000001;
parameter AND = 6'b000111;
parameter OR = 6'b000100;

cpu4 dut(.clk(clk),.ibus(ibus),.daddrbus(daddrbus),.databus(databus));

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
iname[12] = "XORI  R19, R24, 6420";
iname[13] = "XOR   R29, R24, R25";
iname[14] = "ORI   R20, R24, 6420";
iname[15] = "OR    R30, R24, R25";
iname[16] = "SW    0(R26),  R26";
iname[17] = "SW    0(R17),  R27";
iname[18] = "SW    1000(R18),  R28"; 
iname[19] = "SW    0(R19),  R29";
iname[20] = "SW    0(R20),  R30";
iname[21] = "NOP";
iname[22] = "NOP";
iname[23] = "NOP";
iname[24] = "ADDI   R1, R0, #1234";
iname[25] = "ADDI   R2, R0, #1234";
iname[26] = "ADDI   R3, R0, #1234";
iname[27] = "ADD    R4, R1, R2";
iname[28] = "LW     R5, 0(R1)";
iname[29] = "LW     R6, 1000(R2)";
iname[30] = "LW     R7, 0(R3)";
iname[31] = "ADDI   R8, R4, 1000";
iname[32] = "XORI   R9, R4 #9999";
iname[33] = "ADDI   R10, R4, #9999";
iname[34] = "SW     0(R4),  R27";
iname[35] = "ADDI   R28, R0, #1";
iname[36] = "OR     R11, R1, R4";
iname[37] = "XOR    R12, R1, R4"; 
iname[38] = "LW     R13, 0(R10)";
iname[39] = "ADD    R14, R0, R4";
iname[40] = "OR     R15, R7, R6";
iname[41] = "OR     R16 R13, R0";
iname[42] = "LW     R24 1000(R13)";
iname[43] = "ANDI   R1, R12, #FFFF";
iname[44] = "ADDI   R20, R0, #FFFF";
iname[45] = "LW     R15 0(R16)";
iname[46] = "ADDI   R21, R0, #FFFF";
iname[47] = "ADD    R22, R0, #FFFF";                  
iname[48] = "SW     0(R12),  R12";
iname[49] = "SW     1000(R0),  R14";
iname[50] = "SW     1000(R0),  R15";
iname[51] = "SW     2000(R2),  R18";                                 
iname[52] = "OR     R16 R13, R0";
iname[53] = "AND    R28 R0, R0";
iname[54] = "XOR    R29 R1, R0";
iname[55] = "SUB    R30 R1, R2";
iname[56] = "ADD    R2 R1, R0";
iname[57] = "LW     R1 1000(R16)";
iname[58] = "LW     R3 2000(R28)";
iname[59] = "LW     R4 4000(R29)";
iname[60] = "LW     R5 8000(R30)";
iname[61] = "LW     R6 0(R2)";
iname[62] = "ANDI   R1, R1, #FFFF";
iname[63] = "ADDI   R2, R1, #FFFF";
iname[64] = "SUBI   R3, R1, #FFFF";
iname[65] = "XORI   R4, R0, #FFFF";
iname[66] = "ORI    R5, R0, #FFFF";
iname[67] = "SW     0(R1),  R1";
iname[68] = "SW     1000(R2),  R2";
iname[69] = "SW     2000(R3),  R3";
iname[70] = "SW     4000(R4),  R4";
iname[71] = "SW     8000(R5),  R5";
iname[72] = "NOP";
iname[73] = "NOP";
iname[74] = "NOP";


dontcare = 32'hx;

// 1* ADDI  R20, R0, #-1
//            opcode source1   dest      Immediate...
ibusin[0]={ADDI, 5'b00000, 5'b10100, 16'hFFFF};

daddrbusout[0] = dontcare;
databusin[0] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[0] = dontcare;

// 2* ADDI  R21, R0, #1
//            opcode source1   dest      Immediate...
ibusin[1]={ADDI, 5'b00000, 5'b10101, 16'h0001};

daddrbusout[1] = dontcare;
databusin[1] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[1] = dontcare;

// 3* ADDI  R22, R0, #2
//            opcode source1   dest      Immediate...
ibusin[2]={ADDI, 5'b00000, 5'b10110, 16'h0002};

daddrbusout[2] = dontcare;
databusin[2] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[2] = dontcare;

// 4* LW     R24, 0(R20)
//            opcode source1   dest      Immediate...
ibusin[3]={LW, 5'b10100, 5'b11000, 16'h0000};

daddrbusout[3] = 32'hFFFFFFFF;
databusin[3] = 32'hCCCCCCCC;
databusout[3] = dontcare;

// 5* LW     R25, 0(R21)
//            opcode source1   dest      Immediate...
ibusin[4]={LW, 5'b10101, 5'b11001, 16'h0000};

daddrbusout[4] = 32'h00000001;
databusin[4] = 32'hAAAAAAAA;
databusout[4] = dontcare;

// 6* SW     1000(R22), R20
//            opcode source1   dest      Immediate...
ibusin[5]={SW, 5'b10110, 5'b10100, 16'h1000};

daddrbusout[5] = 32'h00001002;
databusin[5] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[5] = 32'hFFFFFFFF;

// 7* SW     2(R0), R21
//            opcode source1   dest      Immediate...
ibusin[6]={SW, 5'b00000, 5'b10101, 16'h0002};

daddrbusout[6] = 32'h00000002;
databusin[6] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[6] = 32'h00000001;

// 8* ADD   R26, R24, R25
//             opcode   source1   source2   dest      shift     Function...
ibusin[7]={Rformat, 5'b11000, 5'b11001, 5'b11010, 5'b00000, ADD};

daddrbusout[7] = dontcare;
databusin[7] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[7] = dontcare;

// 9* SUBI  R17, R24, 6420
//            opcode source1   dest      Immediate...
ibusin[8]={SUBI, 5'b11000, 5'b10001, 16'h6420};

daddrbusout[8] = dontcare;
databusin[8] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[8] = dontcare;

// 10* SUB   R27, R24, R25
//             opcode   source1   source2   dest      shift     Function...
ibusin[9]={Rformat, 5'b11000, 5'b11001, 5'b11011, 5'b00000, SUB};
daddrbusout[9] = dontcare;
databusin[9] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[9] = dontcare;

// 11* ANDI   R18, R24, #0             
//            opcode source1   dest      Immediate...
ibusin[10]={ANDI, 5'b11000, 5'b10010, 16'h0000};

daddrbusout[10] = dontcare;
databusin[10] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[10] = dontcare;

// 12* AND    R28, R24, R0           
//             opcode   source1   source2   dest      shift     Function...
ibusin[11]={Rformat, 5'b11000, 5'b00000, 5'b11100, 5'b00000, AND};

daddrbusout[11] = dontcare;
databusin[11] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[11] = dontcare;

// 13* XORI   R19, R24, 6420
//            opcode source1   dest      Immediate...
ibusin[12]={XORI, 5'b11000, 5'b10011, 16'h6420};

daddrbusout[12] = dontcare;
databusin[12] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[12] = dontcare;

// 14* XOR    R29, R24, R25
//             opcode   source1   source2   dest      shift     Function...
ibusin[13]={Rformat, 5'b11000, 5'b11001, 5'b11101, 5'b00000, XOR};

daddrbusout[13] = dontcare;
databusin[13] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[13] = dontcare;

// 15* ORI    R20, R24, 6420
//            opcode source1   dest      Immediate...
ibusin[14]={ORI, 5'b11000, 5'b10100, 16'h6420};

daddrbusout[14] = dontcare;
databusin[14] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[14] = dontcare;

// 16* OR     R30, R24, R25
//             opcode   source1   source2   dest      shift     Function...
ibusin[15]={Rformat, 5'b11000, 5'b11001, 5'b11110, 5'b00000, OR};

daddrbusout[15] = dontcare;
databusin[15] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[15] =  dontcare;

// 17* SW     0(R26),  R26
//            opcode source1   dest      Immediate...
ibusin[16]={SW, 5'b11010, 5'b11010, 16'h0000};

daddrbusout[16] = 32'h77777776;
databusin[16] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[16] = 32'h77777776;

// 18* SW     0(R17),  R27
//            opcode source1   dest      Immediate...
ibusin[17]={SW, 5'b10001, 5'b11011, 16'h0000};

daddrbusout[17] = 32'hCCCC68AC;
databusin[17] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[17] = 32'h22222222;

// 19* SW     1000(R18),  R28           
//            opcode source1   dest      Immediate...
ibusin[18]={SW, 5'b10010, 5'b11100, 16'h1000};

daddrbusout[18] = 32'h00001000;
databusin[18] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[18] = 32'h00000000;

// 20* SW     0(R19),  R29
//            opcode source1   dest      Immediate...
ibusin[19]={SW, 5'b10011, 5'b11101, 16'h0000};

daddrbusout[19] = 32'hCCCCA8EC;
databusin[19] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[19] = 32'h66666666;

// 21* SW     0(R20),  R30
//            opcode source1   dest      Immediate...
ibusin[20]={SW, 5'b10100, 5'b11110, 16'h0000};

daddrbusout[20] = 32'hCCCCECEC;
databusin[20] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[20] = 32'hEEEEEEEE;

// 22* NOP
//                   oooooosssssdddddiiiiiiiiiiiiiiii
ibusin[21] = 32'b00000000000000000000000000000000;

daddrbusout[21] = dontcare;
databusin[21] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[21] = dontcare;

// 23* NOP
//                   oooooosssssdddddiiiiiiiiiiiiiiii
ibusin[22] = 32'b00000000000000000000000000000000;

daddrbusout[22] = dontcare;
databusin[22] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[22] = dontcare;

// 24* NOP
//                   oooooosssssdddddiiiiiiiiiiiiiiii
ibusin[23] = 32'b00000000000000000000000000000000;

daddrbusout[23] = dontcare;
databusin[23] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[23] = dontcare;

// 25* ADDI    R1, R0, #1234  
//            opcode source1   dest      Immediate...
ibusin[24]={ADDI, 5'b00000, 5'b00001, 16'h1234};

daddrbusout[24] = dontcare;
databusin[24] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[24] = dontcare;

// 26* ADDI    R2, R0, #1234  
//            opcode source1   dest      Immediate...
ibusin[25]={ADDI, 5'b00000, 5'b00010, 16'h1234};

daddrbusout[25] = dontcare;
databusin[25] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[25] = dontcare;

// 27* ADDI    R3, R0, #1234  
//            opcode source1   dest      Immediate...
ibusin[26]={ADDI, 5'b00000, 5'b00011, 16'h1234};

daddrbusout[26] = dontcare;
databusin[26] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[26] = dontcare;

// 28* ADD    R4, R1, R2  
//             opcode   source1   source2   dest      shift     Function...
ibusin[27]={Rformat, 5'b00001, 5'b00010, 5'b00100, 5'b00000, ADD};

daddrbusout[27] = dontcare;
databusin[27] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[27] = dontcare;

// 29* LW    R5, 0(R1)
//            opcode source1   dest      Immediate...
ibusin[28]={LW, 5'b00001, 5'b00101, 16'h0000};

daddrbusout[28] = 32'h00001234;
databusin[28] = 32'h00001234;
databusout[28] = dontcare;


// 30* LW   R6, 1000(R2) 
//            opcode source1   dest      Immediate...
ibusin[29]={LW, 5'b00010, 5'b00110, 16'h1000};

daddrbusout[29] = 32'h00002234;
databusin[29] = 32'h00001234;
databusout[29] = dontcare;

// 31* LW    R7, 0(R3)
//            opcode source1   dest      Immediate...
ibusin[30]={LW, 5'b00011, 5'b00111, 16'h0000};

daddrbusout[30] = 32'h00001234;
databusin[30] = 32'h00001234;
databusout[30] = dontcare;


// 32* ADDI   R8, R4, 1000
//            opcode source1   dest      Immediate...
ibusin[31]={ADDI, 5'b00100, 5'b01000, 16'h1000};

daddrbusout[31] = dontcare;
databusin[31] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[31] = dontcare;

// 33* XORI   R9, R4, #9999
//            opcode source1   dest      Immediate...
ibusin[32]={XORI, 5'b00100, 5'b01001, 16'h9999};

daddrbusout[32] = dontcare;
databusin[32] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[32] = dontcare;

// 34* ADDI   R10, R4, #9999
//            opcode source1   dest      Immediate...
ibusin[33]={ADDI, 5'b00100, 5'b01010, 16'h9999};

daddrbusout[33] = dontcare;
databusin[33] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[33] = dontcare;

// 35* SW     0000(R4),  R2
//            opcode source1   dest      Immediate...
ibusin[34]={SW, 5'b00011, 5'b00010, 16'h1000};

daddrbusout[34] = 32'h00002234;
databusin[34] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[34] = 32'h00001234;

// 36* ADDI     R28, R0, #1
//            opcode source1   dest      Immediate...
ibusin[35] = {ADDI, 5'b00000, 5'b11100, 16'h0001};

daddrbusout[35] = dontcare;
databusin[35] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[35] = dontcare;

// 37* OR     R11, R1, R4
//             opcode   source1   source2   dest      shift     Function...
ibusin[36]={Rformat, 5'b00001, 5'b00100, 5'b01011, 5'b00000, OR};

daddrbusout[36] = dontcare;
databusin[36] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[36] =  dontcare;

// 38* XOR     R12, R1, R4
//             opcode   source1   source2   dest      shift     Function...
ibusin[37]={Rformat, 5'b00001, 5'b00100, 5'b01100, 5'b00000, XOR};

daddrbusout[37] = dontcare;
databusin[37] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[37] =  dontcare;

// 39* LW   R13, 0(R1) 
//            opcode source1   dest      Immediate...
ibusin[38]={LW, 5'b00001, 5'b01101, 16'h0000};

daddrbusout[38] = 32'h00001234;
databusin[38] = 32'h00002468;
databusout[38] = dontcare;

// 40* ADD     R14, R0, R4
//             opcode   source1   source2   dest      shift     Function...
ibusin[39]={Rformat, 5'b00000, 5'b00100, 5'b01110, 5'b00000, ADD};

daddrbusout[39] = dontcare;
databusin[39] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[39] =  dontcare;

// 41* OR     R15, R7, R6
//             opcode   source1   source2   dest      shift     Function...
ibusin[40]={Rformat, 5'b00111, 5'b00110, 5'b01111, 5'b00000, OR};

daddrbusout[40] = dontcare;
databusin[40] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[40] =  dontcare;

// 42* OR     R16 R13, R0
//             opcode   source1   source2   dest      shift     Function...
ibusin[41]={Rformat, 5'b01101, 5'b00000, 5'b10000, 5'b00000, OR};

daddrbusout[41] = dontcare;
databusin[41] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[41] =  dontcare;

// 43* LW      R24 1000(R13)
//            opcode source1   dest      Immediate...
ibusin[42]={LW, 5'b01101, 5'b11000, 16'h1000};

daddrbusout[42] = 32'h00003468;
databusin[42] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[42] = dontcare;

// 44* ANDI      R1, R12, #FFFF
//            opcode source1   dest      Immediate...
ibusin[43]={ANDI, 5'b00001, 5'b01100, 16'hFFFF};

daddrbusout[43] = dontcare;
databusin[43] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[43] =  dontcare;


// 45* ADDI      R20, R0, #FFFF
//            opcode source1   dest      Immediate...
ibusin[44]={ADDI, 5'b00000, 5'b10100, 16'hFFFF};

daddrbusout[44] = dontcare;
databusin[44] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[44] = dontcare;

// 46* LW      R15 0(R1)
//            opcode source1   dest      Immediate...
ibusin[45]={LW, 5'b01111, 5'b00001, 16'h0000};

daddrbusout[45] = 32'h00001234;
databusin[45] = 32'h00001234;
databusout[45] =  dontcare;

// 47* ADDI      R21, R0, #FFFF
//            opcode source1   dest      Immediate...
ibusin[46]={ADDI, 5'b00000, 5'b10101, 16'hFFFF};

daddrbusout[46] = dontcare;
databusin[46] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[46] = dontcare;

// 48* ADDI      R22, R0, #FFFF
//            opcode source1   dest      Immediate...
ibusin[47]={ADDI, 5'b00000, 5'b10110, 16'hFFFF};

daddrbusout[47] = dontcare;
databusin[47] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[47] = dontcare;

// 49* SW     0(R12),  R12
//            opcode source1   dest      Immediate...
ibusin[48]={SW, 5'b01100, 5'b01100, 16'h0000};

daddrbusout[48] = 32'h00001234;
databusin[48] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[48] = 32'h00001234;

// 50* SW     1000(R0),  R2
//            opcode source1   dest      Immediate...
ibusin[49]={SW, 5'b00000, 5'b00010, 16'h1000};

daddrbusout[49] = 32'h00001000;
databusin[49] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[49] = 32'h00001234;

// 51* SW     1000(R0),  R15
//            opcode source1   dest      Immediate...
ibusin[50]={SW, 5'b00000, 5'b01111, 16'h1000};

daddrbusout[50] = 32'h00001000;
databusin[50] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[50] = 32'h00001234;

// 52* SW     2000(R2),  R18
//            opcode source1   dest      Immediate...
ibusin[51]={SW, 5'b00010, 5'b10010, 16'h2000};

daddrbusout[51] = 32'h0003234;
databusin[51] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[51] = 32'h0000000;

// 53* OR     R16 R13, R0
//             opcode   source1   source2   dest      shift     Function...
ibusin[52]={Rformat, 5'b01101, 5'b00000, 5'b10000, 5'b00000, OR};

daddrbusout[52] = dontcare;
databusin[52] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[52] =  dontcare;

// 54* AND     R28 R0, R0
//             opcode   source1   source2   dest      shift     Function...
ibusin[53]={Rformat, 5'b11100, 5'b00000, 5'b00000, 5'b00000, AND};

daddrbusout[53] = dontcare;
databusin[53] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[53] =  dontcare;

// 55* XOR     R29 R1, R0
//             opcode   source1   source2   dest      shift     Function...
ibusin[54]={Rformat, 5'b00001, 5'b00000, 5'b11101, 5'b00000, XOR};

daddrbusout[54] = dontcare;
databusin[54] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[54] =  dontcare;

// 56 SUB     R30 R1, R2
//             opcode   source1   source2   dest      shift     Function...
ibusin[55]={Rformat, 5'b00010, 5'b00001, 5'b11110, 5'b00000, SUB};

daddrbusout[55] = dontcare;
databusin[55] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[55] =  dontcare;

// 57* ADD     R2 R1, R0
//             opcode   source1   source2   dest      shift     Function...
ibusin[56]={Rformat, 5'b00001, 5'b00001, 5'b00010, 5'b00000, ADD};

daddrbusout[56] = dontcare;
databusin[56] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[56] =  dontcare;

// 58* LW      R1 1000(R16)
//            opcode source1   dest      Immediate...
ibusin[57]={LW, 5'b01101, 5'b11000, 16'h1000};

daddrbusout[57] = 32'h00003468;
databusin[57] = 32'h00000000;
databusout[57] = dontcare;

// 59* LW      R3 2000(R28)
//            opcode source1   dest      Immediate...
ibusin[58]={LW, 5'b11100, 5'b11000, 16'h2000};

daddrbusout[58] = 32'h00002001;
databusin[58] = 32'h0000000;
databusout[58] = dontcare;

// 60* LW      R4 4000(R29)
//            opcode source1   dest      Immediate...
ibusin[59]={LW, 5'b11101, 5'b00100, 16'h4000};

daddrbusout[59] = 32'h00005234;
databusin[59] = 32'h00000000;
databusout[59] = dontcare;

// 61* LW      R5 8000(R30)
//            opcode source1   dest      Immediate...
ibusin[60]={LW, 5'b11110, 5'b00101, 16'h8000};

daddrbusout[60] = 32'hFFFF8000;
databusin[60] = 32'h0000000;
databusout[60] = dontcare;

// 62* LW      R6 0(R2)
//            opcode source1   dest      Immediate...
ibusin[61]={LW, 5'b00010, 5'b00110, 16'h0000};

daddrbusout[61] = 32'h00002468;
databusin[61] = 32'h0000000;
databusout[61] = dontcare;

// 63* ANDI      R1, R1, #FFFF
//            opcode source1   dest      Immediate...
ibusin[62]={ANDI, 5'b00001, 5'b00001, 16'hFFFF};

daddrbusout[62] = dontcare;
databusin[62] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[62] =  dontcare;

// 64* ADDI      R2, R1, #FFFF
//            opcode source1   dest      Immediate...
ibusin[63]={ADDI, 5'b00001, 5'b00010, 16'hFFFF};

daddrbusout[63] = dontcare;
databusin[63] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[63] =  dontcare;

// 65* SUBI      R3, R1, #FFFF
//            opcode source1   dest      Immediate...
ibusin[64]={SUBI, 5'b00001, 5'b00011, 16'hFFFF};

daddrbusout[64] = dontcare;
databusin[64] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[64] =  dontcare;

// 66* XORI      R4, R0, #FFFF
//            opcode source1   dest      Immediate...
ibusin[65]={XORI, 5'b00000, 5'b00100, 16'hFFFF};

daddrbusout[65] = dontcare;
databusin[65] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[65] =  dontcare;

// 67* ORI      R5, R0, #FFFF
//            opcode source1   dest      Immediate...
ibusin[66]={ORI, 5'b00000, 5'b00101, 16'hFFFF};

daddrbusout[66] = dontcare;
databusin[66] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[66] =  dontcare;

// 68* SW     0(R1),  R1
//            opcode source1   dest      Immediate...
ibusin[67]={SW, 5'b00001, 5'b00001, 16'h0000};

daddrbusout[67] = 32'h00001234;
databusin[67] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[67] = 32'h00001234;

// 69* SW     1000(R2),  R2
//            opcode source1   dest      Immediate...
ibusin[68]={SW, 5'b00010, 5'b00010, 16'h1000};

daddrbusout[68] = 32'h00002233;
databusin[68] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[68] = 32'h00001233;

// 70* SW     2000(R3),  R3
//            opcode source1   dest      Immediate...
ibusin[69]={SW, 5'b00011, 5'b00011, 16'h2000};

daddrbusout[69] = 32'h00003235;
databusin[69] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[69] = 32'h00001235;

// 71* SW     4000(R4),  R4
//            opcode source1   dest      Immediate...
ibusin[70]={SW, 5'b00100, 5'b00100, 16'h4000};

daddrbusout[70] = 32'h00003FFF;
databusin[70] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[70] = 32'hFFFFFFFF;

// 72* SW     8000(R5),  R5
//            opcode source1   dest      Immediate...
ibusin[71]={SW, 5'b00101, 5'b00101, 16'h8000};

daddrbusout[71] = 32'hFFFF7FFF;
databusin[71] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[71] = 32'hFFFFFFFF;


// 73* NOP
//                   oooooosssssdddddiiiiiiiiiiiiiiii
ibusin[72] = 32'b00000000000000000000000000000000;

daddrbusout[72] = dontcare;
databusin[72] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[72] = dontcare;

// 74* NOP
//                   oooooosssssdddddiiiiiiiiiiiiiiii
ibusin[73] = 32'b00000000000000000000000000000000;

daddrbusout[73] = dontcare;
databusin[73] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[73] = dontcare;

// 75* NOP
//                   oooooosssssdddddiiiiiiiiiiiiiiii
ibusin[74] = 32'b00000000000000000000000000000000;

daddrbusout[74] = dontcare;
databusin[74] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[74] = dontcare;



// (no. loads) + 2*(no. stores) = 2 + 2*7 = 16
ntests = 74;

$timeformat(-9,1,"ns",12);

end


//assumes positive edge FF.
//testbench reads databus when clk high, writes databus when clk low.
assign databus = clkd ? 32'bz : databusk;

//Change inputs in middle of period (falling edge).
initial begin
  error = 0;
  clkd =0;
  clk=0;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  databusk = 32'bz;

  #25
  $display ("Time=%t\n  clk=%b", $realtime, clk);

  for (k=0; k<= ntests; k=k+1) begin
    clk=1;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    #5
    clkd=1;
    #20
    $display ("Time=%t\n  clk=%b", $realtime, clk);

    //set load data for 3rd previous instruction
    if (k >=3)
      databusk = databusin[k-3];

    //put next instruction on ibus
    ibus=ibusin[k];
    $display ("  ibus=%b %b %b %b %b for instruction %d: %s", ibus[0:5], ibus[6:10], ibus[11:15], ibus[16:20], ibus[21:31], k, iname[k]);

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
    #5
    clkd = 0;
    #20
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