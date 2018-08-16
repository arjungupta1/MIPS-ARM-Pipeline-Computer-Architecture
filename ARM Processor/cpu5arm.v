`timescale 1ns / 1ps



module cpu5arm(ibus, daddrbus, databus, reset, iaddrbus, clk);
    input [31:0] ibus;
    input reset;
    input clk;
    output [63:0] daddrbus, iaddrbus;
    inout [63:0] databus;
    
    //PC Intermediate wires
    wire [63:0] pc_in;     
    wire [63:0] pc_out;

    //IF/ID intermediate wires
    wire [63:0] pc_plus_4;
    wire [31:0] ibus_intermediate; 
        
    wire [63:0] ALUImm_decode, BranchAddr, CondBranchAddr, DTAddr_decode, MOVImm_decode;    
        
    wire cbz, cbnz;
    
    wire ldur_decode, stur_decode;
    
    wire lsl_decode, lsr_decode;
    
    wire movz_decode;
    
    wire b;
        
    wire beq, bne, blt, bge;
    
    wire set_flags_decode;
    wire branch_handler, branch_conditional_handler;
    
    //ID/EX intermediate wires
    wire [63:0] pc_decode;
    wire [63:0] sign_extend_immediate;
    wire [63:0] sign_extend_branch_address;
    wire [31:0] Aselect_intermediate;
    wire [31:0] Aselect, Bselect, Dselect_decode;
    wire [63:0] abus_intermediate, bbus_intermediate;
    wire [2:0] s_intermediate;
    wire imm_intermediate, cin_intermediate; 
    wire [5:0] shamt_decode;
    wire [1:0] movz_22_21_decode;
    
    //EX/MEM intermediate wires
    wire [63:0] abus, bbus_mux_in;
    wire [63:0] bbus;
    wire [63:0] dbus_intermediate;
    wire [63:0] sign_extend;
    wire [31:0] Dselect_execute;
    wire [63:0] databus_intermediate;
    wire [2:0] S;
    wire Imm, Cin;
    wire ldur_execute, stur_execute;
    wire set_flags_execute;
    wire [5:0] shamt_execute;
    
    wire [63:0] ALUImm_execute, DTAddr_execute, MOVImm_execute;
    wire movz_execute, lsl_execute, lsr_execute;
    wire [1:0] movz_22_21_execute;
    
    wire [63:0] dbus_post_shift;
    
    //represents the NCVZ bits that get flushed with values once the set_flags control signal is high.
    wire N, C, V, Z; 
          
    //MEM/WB intermediate wires
    wire [31:0] Dselect_mem;
    wire ldur_mem, stur_mem;
    
    wire [63:0] databus_mux_in, daddrbus_mux_in; 
    wire ldur_wb, stur_wb;   
    
    wire [63:0] dbus;
    wire [31:0] Dselect;
           
    pc my_pc(
        .pc_in(pc_in),
        .reset(reset),
        .clk(clk),
        .pc_out(pc_out)
    );
    
    assign iaddrbus = pc_out;
    assign pc_plus_4 = pc_out + 4;
    
    //Instantiating the first pipeline for the ibus
    fetch my_fetch(
         .ibus_in(ibus),
         .pc_in(pc_plus_4),
         .clk(clk),
         .ibus_out(ibus_intermediate),
         .pc_out(pc_decode)
     );
     
     //gets the immediate value for I Type instructions
     aluimm_zero_extend get_alu_immediate(
        .ALU_immediate(ibus_intermediate[21:10]),
        .ALUImm_zero_extend(ALUImm_decode)
     );
     
     //gets the sign extended immediate value for the B type instructions
     branchaddr_sign_extend get_branch_address(
        .BR_address(ibus_intermediate[25:0]),
        .BranchAddr_sign_extend(BranchAddr)
     );
     
     //gets the sign extended immediate value for the CB type instructions
     condbranchaddr_sign_extend get_cond_branch_address(
        .COND_BR_address(ibus_intermediate[23:5]),
        .CondBranchAddr_sign_extend(CondBranchAddr)
     );
     
     //gets the sign extended immediate value for the D type instructions
     dtaddr_sign_extend get_dt_address(
        .DT_address(ibus_intermediate[20:12]),
        .DTAddr_sign_extend(DTAddr_decode)
     );  
     
     //gets the zero extended value for the IM type instructions
     movimm_zero_extend get_mov_imm(
        .MOV_immediate(ibus_intermediate[20:5]),
        .MOVImm_zero_extend(MOVImm_decode)
     );
           
     //Finding the values for Aselect, Bselect, Dselect (needs to be passed through pipeline), Imm (needs to be passed through pipeline), S and Cin (both need t o be passed through pipeline)    
     controller my_controller(
         .ibus(ibus_intermediate), 
         .Aselect(Aselect), //assigned to either 32-bit register index specified in ibus[4:0] or ibus[9:5]
         .Bselect(Bselect),
         .Dselect(Dselect_decode), //intermediate value
         .Imm(imm_intermediate), //intermediate value
         .S(s_intermediate), //intermediate value
         .Cin(cin_intermediate), //intermediate value
         .cbz(cbz),
         .cbnz(cbnz),
         .ldur(ldur_decode),
         .lsl(lsl_decode),
         .lsr(lsr_decode),
         .movz(movz_decode),
         .stur(stur_decode),
         .b(b),
         .beq(beq),
         .bne(bne),
         .blt(blt),
         .bge(bge),
         .set_flags(set_flags_decode),
         .shamt(shamt_decode),
         .movz_22_21(movz_22_21_decode)
     );
          
     //Fetching the values for abus and bbus on the negedge of a clock.
     //Puts the value of dbus into the correct Dselect on the ngedge of each clock cycle
     regfile my_regfile(
         .Aselect(Aselect),
         .Bselect(Bselect),
         .Dselect(Dselect),
         .clk(clk),
         .abus(abus_intermediate),
         .bbus(bbus_intermediate),
         .dbus(dbus)
     );   
          
     //implement logic for branching if the previous instruction was a set_flags instruction
     //Can use the set_flags_execute control signal
     branch_handling branching_logic(
        .b(b),
        .beq(beq),
        .bne(bne),
        .blt(blt),
        .bge(bge),
        .cbz(cbz),
        .cbnz(cbnz),
        .abus(abus_intermediate), //abus is the overridden output from the regfile[Aselect] where aselect = ibus[4:0].
        .N(N), //checks for NCVZ bits after the execute stage
        .C(C),
        .V(V),
        .Z(Z),
        .BranchAddr(BranchAddr),
        .CondBranchAddr(CondBranchAddr),
        .set_flags(set_flags_execute), //if set_flags was set high in the execute stage, then the previous instruction was a "___S" operation.
        .branch(branch_handler),
        .branch_cond(branch_conditional_handler)
     );
     
     //selects between the new PC being either PC + 4, PC + BranchAddress or PC + CondBranchAddress depending on if the branch or conditional branch is taken
     pc_in_mux pc_in_muxer(
        .pc(pc_decode),
        .pc_plus_4(pc_plus_4),
        .branch(branch_handler),
        .branch_cond(branch_conditional_handler),
        .BranchAddr(BranchAddr),
        .CondBranchAddr(CondBranchAddr),
        .pc_out(pc_in)       
     );
     
     //Passes each value that needs to be passed through the pipeline on the positive edge of a clock
     decode my_decode(
         .Dselect_in(Dselect_decode),
         .Dselect_out(Dselect_execute),
         .Imm_in(imm_intermediate),
         .Imm_out(Imm),
         .S_in(s_intermediate),
         .S_out(S),
         .Cin_in(cin_intermediate),
         .Cin_out(Cin),
         .abus_in(abus_intermediate),
         .abus_out(abus),
         .bbus_in(bbus_intermediate),
         .bbus_out(bbus_mux_in),
         .ldur_ctrl_in(ldur_decode),
         .ldur_ctrl_out(ldur_execute),
         .stur_ctrl_in(stur_decode),
         .stur_ctrl_out(stur_execute),    
         .set_flags_in(set_flags_decode),
         .set_flags_out(set_flags_execute),
         .shamt_in(shamt_decode),
         .shamt_out(shamt_execute),
         .ALUImm_in(ALUImm_decode),
         .ALUImm_out(ALUImm_execute),
         .DTAddr_in(DTAddr_decode),
         .DTAddr_out(DTAddr_execute),
         .MOVImm_in(MOVImm_decode),
         .MOVImm_out(MOVImm_execute),
         .movz_in(movz_decode),
         .movz_out(movz_execute),
         .movz_22_21_in(movz_22_21_decode),
         .movz_22_21_out(movz_22_21_execute),
         .lsl_in(lsl_decode),
         .lsl_out(lsl_execute),
         .lsr_in(lsr_decode),
         .lsr_out(lsr_execute),
         .clk(clk)
     );
     
    //Creates the multiplexer that switches between the value from the register file for bbus and the sign extended immediate value
     //Based on the immediate value that is passed through the pipeline
     
     immediate_selector select_immediate(
        .bbus_in(bbus_mux_in),
        .ALUImm_in(ALUImm_execute),
        .DTAddr_in(DTAddr_execute),
        .MOVImm_in(MOVImm_execute),
        .movz_ctrl(movz_execute),
        .ldur_stur_ctrl(ldur_execute | stur_execute),
        .Imm_ctrl(Imm),
        .out(bbus)
     );
     
          
    //Computes the value of dbus given the correct operation and inputs from the previous modules
     alu my_alu(
         .a(abus),
         .b(bbus),
         .d(dbus_intermediate),
         .Cin(Cin),
         .S(S),
         .N(N),
         .C(C),
         .V(V),
         .Z(Z)
     );  
     
     //override the value in dbus_intermediate with the result of LSL and LSR.
     shift_handler lsl_lsr_movz(
        .abus_in(abus),
        .bbus_in(bbus),
        .dbus_alu(dbus_intermediate),
        .shamt_in(shamt_execute),
        .movz_bits(movz_22_21_execute),
        .lsl(lsl_execute),
        .lsr(lsr_execute),
        .movz(movz_execute),
        .out(dbus_post_shift)
     );
     
     
        
    //flushes the value of dbus and Dselect back into the register value after being piped through the pipeline on the positive edge of the next clock cycle
     execute my_execute(
         .dbus_in(dbus_post_shift), //mux between ALU and shift control
         .dbus_out(daddrbus),
         .Dselect_in(Dselect_execute),
         .Dselect_out(Dselect_mem),
         .databus_in(bbus_mux_in),
         .databus_out(databus_intermediate),
         .ldur_ctrl_in(ldur_execute),
         .ldur_ctrl_out(ldur_mem),
         .stur_ctrl_in(stur_execute),
         .stur_ctrl_out(stur_mem),
         .clk(clk)
     );    
     
     //Sets the value in the databus to high impedance if not used by a load or store
     databus_value get_databus(
        .databus_in(databus_intermediate),
        .stur_ctrl(stur_mem),
        .databus_out(databus)
     );
     
     //models the writeback DFF
     writeback my_writeback(
        .databus_in(databus),
        .daddrbus_in(daddrbus),
        .ldur_ctrl_in(ldur_mem),
        .stur_ctrl_in(stur_mem),
        .Dselect_in(Dselect_mem),
        .clk(clk),
        .databus_out(databus_mux_in),
        .daddrbus_out(daddrbus_mux_in),
        .ldur_ctrl_out(ldur_wb),
        .stur_ctrl_out(stur_wb),
        .Dselect_out(Dselect)        
     );
     
     //Selects between the address bus and the databus for writeback based on the load word. 
     mux_2_to_1 dbus_mux(
        .in1(daddrbus_mux_in),
        .in2(databus_mux_in),
        .sel(ldur_wb),
        .out(dbus)
     );
     

endmodule

module pc_in_mux(pc, pc_plus_4, pc_out, branch, branch_cond, BranchAddr, CondBranchAddr);
    input [63:0] pc, pc_plus_4;
    input [63:0] BranchAddr, CondBranchAddr;
    input branch, branch_cond;
    
    output reg [63:0] pc_out;
    
    always @ (pc, pc_plus_4, pc_out, branch, branch_cond, BranchAddr, CondBranchAddr) begin
        if (branch == 1'b1)
            pc_out = pc + BranchAddr + 64'hFFFFFFFFFFFFFFFC; //subtracts 4 to account for the pc_plus_4 propogated signal
        else if (branch_cond == 1'b1)
            pc_out = pc + CondBranchAddr + 64'hFFFFFFFFFFFFFFFC; 
        else
            pc_out = pc_plus_4;
    end
endmodule

module shift_handler(abus_in, bbus_in, shamt_in, movz_bits, lsl, lsr, movz, dbus_alu, out);
    input [63:0] abus_in, bbus_in, dbus_alu;
    input [5:0] shamt_in;
    input [1:0] movz_bits;
    input lsl, lsr, movz;
    output reg [63:0] out;
    
    wire [5:0] movz_shamt;
    assign movz_shamt = movz_bits << 4;
    
    
    always @(abus_in, bbus_in, dbus_alu, shamt_in, movz_bits, lsl, lsr, movz, out) begin
        if (movz == 1'b1) begin
            out = bbus_in << movz_shamt;
        end
        else if (lsl == 1'b1)
            out = abus_in << shamt_in;
        else if (lsr == 1'b1)
            out = abus_in >>> shamt_in;
        else
            out = dbus_alu;
    end
endmodule


module immediate_selector(bbus_in, ALUImm_in, DTAddr_in, MOVImm_in, movz_ctrl, ldur_stur_ctrl, Imm_ctrl, out);
    input [63:0] bbus_in, ALUImm_in, DTAddr_in, MOVImm_in;
    input movz_ctrl, ldur_stur_ctrl, Imm_ctrl;
    
    output reg [63:0] out;
    
    always @ (bbus_in, ALUImm_in, DTAddr_in, MOVImm_in, movz_ctrl, ldur_stur_ctrl, Imm_ctrl, out) begin
        if (movz_ctrl == 1'b1)
            out = MOVImm_in;
        else if (ldur_stur_ctrl == 1'b1)
            out = DTAddr_in;
        else if (Imm_ctrl == 1'b1)
            out = ALUImm_in;
        else
            out = bbus_in;
    end
endmodule


module branch_handling(b, beq, bne, blt, bge, cbz, cbnz, abus, N, C, V, Z, BranchAddr, CondBranchAddr, set_flags, branch, branch_cond);
    input b, beq, bne, blt, bge, cbz, cbnz;
    input N, C, V, Z;
    input set_flags;
    input [63:0] abus; //make sure to override the value in aselect with the Dselect register from the controller. 
                       //This is to make sure that the Aselect value in the ALU represents ibus [4:0]. 
    input [63:0] BranchAddr, CondBranchAddr;
    output reg branch, branch_cond;
    
    always @ (b, beq, bne, blt, bge, cbz, cbnz, abus, N, C, V, Z, BranchAddr, CondBranchAddr, set_flags, branch, branch_cond) begin
        branch = 0;
        branch_cond = 0;
        //Unconditional branch, branch directly to the pc + branch_address
        if (b == 1'b1) begin
            branch = 1'b1;
        end
        //Represents the response to the B.Cond that is dependent on whether or not the flags were just set in the execute stage on the previous instruction.
        else if (beq == 1'b1 | bne == 1'b1 | blt == 1'b1 | bge == 1'b1) begin
            //Only try and compute the new branch address if the flags were set on the previous instruction 
            if (set_flags == 1'b1) begin
                //Checking flags for BEQ
                if (beq == 1'b1) begin
                    //Compute new branch address if the correct flags are set for BEQ, otherwise treat as NOP.
                    if (Z == 1'b1)
                        branch_cond = 1'b1;
                end
                //Checking flags for BNE
                else if (bne == 1'b1) begin
                    //Compute new branch address if the correct flags are set for BNE, otherwise treat as NOP.
                    if (Z == 1'b0)
                        branch_cond = 1'b1;
                end
                //Checking flags for BLT
                else if (blt == 1'b1) begin
                    //Compute new branch address if the correct flags are set for BLT, otherwise treat as NOP.
                    if (N != V)
                        branch_cond = 1'b1;
                end
                //Checking flags for BGE
                else if (bge == 1'b1) begin 
                    //Compute new branch address if the correct flags are set for BGE, otherwise treat as NOP.
                    if (N == V)
                        branch_cond = 1'b1;
                end
            end
        end
        //Checking requirements for Compare & branch if zero instruction
        else if (cbz == 1'b1) begin
            //only branch if the value of the abus in the register is 0
            if (abus == 64'b0)
                branch_cond = 1'b1;
        end
        //Checking requirements for Compare & Branch if not zero instruction
        else if (cbnz == 1'b1) begin
            //only branch if the value of abus in the register is not 0
            if (abus != 64'b0)
                branch_cond = 1'b1;
        end
    end   
endmodule


//Zero Extends the ALU Immediate field from the instruction bus 
module aluimm_zero_extend(ALU_immediate, ALUImm_zero_extend);
    input [11:0] ALU_immediate;
    output [63:0] ALUImm_zero_extend;
    
    assign ALUImm_zero_extend = {52'b0, ALU_immediate};
endmodule

//Sign extends the Branch Address field from the instruction  bus
module branchaddr_sign_extend(BR_address, BranchAddr_sign_extend);
    input [25:0] BR_address;
    output [63:0] BranchAddr_sign_extend;
    
    assign BranchAddr_sign_extend = {{36{BR_address[25]}}, BR_address, 2'b0};
endmodule

//Sign extends the Conditional Branch Address from the instruction bus
module condbranchaddr_sign_extend(COND_BR_address, CondBranchAddr_sign_extend);
    input [18:0] COND_BR_address;
    output [63:0] CondBranchAddr_sign_extend;
    
    assign CondBranchAddr_sign_extend = {{43{COND_BR_address[18]}}, COND_BR_address, 2'b0};
endmodule

//Sign extends the Data Immediate address for load and store functions from the instruction bus
module dtaddr_sign_extend(DT_address, DTAddr_sign_extend);
    input [8:0] DT_address;
    output [63:0] DTAddr_sign_extend;
    
    assign DTAddr_sign_extend = {{55{DT_address[8]}}, DT_address};
endmodule

//Zero extends the Immediate value for the mov immediate to register
module movimm_zero_extend(MOV_immediate, MOVImm_zero_extend);
    input [15:0] MOV_immediate;
    output [63:0] MOVImm_zero_extend;
    
    assign MOVImm_zero_extend = {48'b0, MOV_immediate};
endmodule

//models the PC D flip flop
module pc(pc_in, reset, clk, pc_out);
    input [63:0] pc_in;
    input reset;
    input clk;
    output reg [63:0] pc_out;
    
    //initally sets the iaddrbus to 0 on the first Clock Cycle. this is to prevent infinite propogation of dontcare value
    initial begin
        pc_out = 64'b0;
    end
    
    always @ (posedge clk) begin
        if (reset == 1'b1)
            pc_out = 64'b0;
        else
            pc_out = pc_in;
    end
endmodule   


//Represents the first d flip-flop in the pipeline (IF/ID)
module fetch(ibus_in, pc_in, clk, ibus_out, pc_out);
    input [31:0] ibus_in;
    input [63:0] pc_in;
    input clk;
    output reg [31:0] ibus_out;
    output reg [63:0] pc_out;
    
    initial begin
        pc_out = 64'b0;
    end
    
    always @(posedge clk) begin
        ibus_out = ibus_in;
        pc_out = pc_in;
    end
endmodule


module writeback(databus_in, daddrbus_in, ldur_ctrl_in, stur_ctrl_in, Dselect_in, clk, databus_out, daddrbus_out, ldur_ctrl_out, stur_ctrl_out, Dselect_out);
    input [63:0] databus_in, daddrbus_in;
    input [31:0] Dselect_in;
    input ldur_ctrl_in, stur_ctrl_in;
    input clk;
    output reg [63:0] databus_out, daddrbus_out;
    output reg [31:0] Dselect_out;
    output reg ldur_ctrl_out, stur_ctrl_out;
    
    always @(posedge clk) begin
        databus_out = databus_in;
        daddrbus_out = daddrbus_in;
        Dselect_out = Dselect_in;
        ldur_ctrl_out = ldur_ctrl_in;
        stur_ctrl_out = stur_ctrl_in;
    end
endmodule


//Creating the controller which grabs the values for Aselect, Bselect, and Dselect as well as Imm, S, and Cin.
//These are all intermediate values
module controller(ibus, Aselect, Bselect, Dselect, Imm, S, Cin, cbz, cbnz, ldur, lsl, lsr, movz, stur, b, beq, bne, blt, bge, set_flags, shamt, movz_22_21);
    input [31:0] ibus;
    output [31:0] Aselect, Bselect;
    output [31:0] Dselect;
    output [5:0] shamt;
    output [2:0] S;
    output Imm, Cin;
    output cbz, cbnz;
    output lsl, lsr;
    output ldur, stur;
    output b;
    output movz;
    output beq, bne, blt, bge;
    output set_flags;
    output [1:0] movz_22_21;
    
    wire [31:0] Aselect_intermediate;
    wire [31:0] dsel_intermediate;
    wire [31:0] dsel_intermediate2;
    wire [31:0] Bselect_intermediate; 
    wire [31:0] zero_register;
    
    assign zero_register = 1'b1 << 5'b11111;
    
    //Is there any modification that needs to be made to Aselect, Bselect, or Dselect based on the control signal?    
    
    //Creating the three decoders from 5-bit segments of the instruction bus to 32-bit numbers for use in the ALU Register File
    decoder_5_to_32 rn_decoder(
        .in(ibus[9:5]), 
        .out(Aselect_intermediate)
    );
    
    decoder_5_to_32 rm_decoder(
        .in(ibus[20:16]), 
        .out(Bselect_intermediate)
    );
    
    //Intermediate value used to keep exposed Dselect signal consistent with the value in the correct stage of the pipeline
    decoder_5_to_32 rd_decoder(
        .in(ibus[4:0]),
        .out(dsel_intermediate)
    );    
            
    decode_opcode find_control_signals(
        .ibus(ibus),
        .S(S),
        .Cin(Cin),
        .Imm(Imm),
        .cbz(cbz),
        .cbnz(cbnz),
        .ldur(ldur),
        .lsl(lsl),
        .lsr(lsr),
        .movz(movz),
        .stur(stur),
        .b(b),
        .beq(beq),
        .bne(bne),
        .blt(blt),
        .bge(bge),
        .set_flags(set_flags)
    );

    
    assign shamt = ibus[15:10];
    
    assign movz_22_21 = (movz == 1'b1) ? ibus[22:21] : 2'b0;
    
    //overrides the value in Aselect to check if the cbz or cbnz bits were set high. 
    //This is because the CB instructions need immediate access to the value at the specific register specified in the ibus[4:0] bits.
    assign Aselect = (cbz == 1'b1 | cbnz == 1'b1) ? dsel_intermediate : Aselect_intermediate;
    
    assign Bselect = (stur == 1'b1) ? dsel_intermediate : Bselect_intermediate;
    
    //Any B, CB, or Store instruction should make Dselect be the 0 register at index 31.
    assign Dselect = (stur | b | beq | bne | blt | bge | cbz | cbnz) ? zero_register : dsel_intermediate;
        
endmodule

module decode_opcode(ibus, S, Cin, Imm, cbz, cbnz, ldur, lsl, lsr, movz, stur, b, beq, bne, blt, bge, set_flags);

    input [31:0] ibus;
    
    //Control signals for S, Cin, and Imm to be passed to ALU (R-Type and I-type instructions)
    output reg [2:0] S;
    output reg Cin, Imm; //Imm represents ALU_immediate at ibus[21:10].
    
    //Control signals for D type instructions 
    output reg ldur, stur;
    
    //Control signals for R type instructions
    output reg lsl, lsr;
    
    //Control signals for IM type instructions
    output reg movz;
    
    //Control signals for B type instrutions
    output reg b;
    
    //Control signals for CB type instructions
    output reg beq, bne, blt, bge, cbz, cbnz;
       
    //Control signal that determines if flags should be set
    output reg set_flags;
   
    reg r_type, i_type, d_type, b_type, cb_type, im_type;
    
    always @ (ibus, S, Cin, Imm, cbz, cbnz, ldur, lsl, lsr, movz, stur, b, beq, bne, blt, bge, set_flags, r_type, i_type, d_type, b_type, cb_type, im_type) begin
        r_type = 1'b0;
        i_type = 1'b0;
        d_type = 1'b0;
        b_type = 1'b0;
        cb_type = 1'b0;
        im_type = 1'b0;
        //Handling B Type instructions
        case (ibus[31:26])
            6'b000101: begin
                b = 1'b1;
                b_type = 1'b1;
            end
        endcase
        
        //Handling CB type instructions
        case (ibus[31:24])
        //beq, bne, blt, bge, cbz, cbnz;
            //Assigning control signals for CBNZ
            8'b10110101: begin
                cbnz = 1'b1;
                cb_type = 1'b1;
                beq = 1'b0;
                bne = 1'b0;
                blt = 1'b0;
                bge = 1'b0;
                cbz = 1'b0;                
            end
            //Assigning control signals for CBZ
            8'b10110100: begin
                cbz = 1'b1;
                cb_type = 1'b1;
                beq = 1'b0;
                bne = 1'b0;
                blt = 1'b0;
                bge = 1'b0;
                cbnz = 1'b0;
            end
            //Assigning control signals for BEQ
            8'b01010101: begin
                beq = 1'b1;
                cb_type = 1'b1;
                bne = 1'b0;
                blt = 1'b0;
                bge = 1'b0;
                cbnz = 1'b0;
                cbz = 1'b0;
            end
            //Assigning control signals for BNE
            8'b01010110: begin
                bne = 1'b1;
                cb_type = 1'b1;
                beq = 1'b0;
                blt = 1'b0;
                bge = 1'b0;
                cbnz = 1'b0;
                cbz = 1'b0;
            end
            //Assigning control signals for BLT 
            8'b01010111: begin
                blt = 1'b1;
                cb_type = 1'b1;
                beq = 1'b0;
                bne = 1'b0;
                bge = 1'b0;
                cbnz = 1'b0;
                cbz = 1'b0;
            end
            //Assigning control signals for BGE
            8'b01011000: begin
                bge = 1'b1;
                cb_type = 1'b1;
                beq = 1'b0;
                bne = 1'b0;
                blt = 1'b0;
                cbnz = 1'b0;
                cbz = 1'b0;
            end 
            
        endcase
        
        //Handling IM Type instructions
        case (ibus[31:23])
            //Assigning control bits for MOVZ
            9'b110100101: begin
                movz = 1'b1;
                im_type = 1'b1;
            end 
        endcase 
        
        //Handling I Type instructions
        case (ibus[31:22])
            //Assigning control signals for ADDI
            10'b1001000100: begin
                S = 3'b010;
                Cin = 1'b0;
                set_flags = 1'b0;
                i_type = 1'b1;
            end
            //Assigning control signals for ADDIS
            10'b1011000100: begin
                S = 3'b010;
                Cin = 1'b0;
                set_flags = 1'b1;
                i_type = 1'b1;
            end
            //Assigning control signals for ANDI
            10'b1001001000: begin
                S = 3'b110;
                Cin = 1'b0;
                set_flags = 1'b0;
                i_type = 1'b1;
            end
            //Assigning control signals for ANDIS
            10'b1111001000: begin
                S = 3'b110;
                Cin = 1'b0;
                set_flags = 1'b1;
                i_type = 1'b1;
            end
            //Assigning control signals for EORI
            10'b1101001000: begin
                S = 3'b000;
                Cin = 1'b0;
                set_flags = 1'b0;
                i_type = 1'b1;
            end
            //Assigning control signals for ORRI 
            10'b1011001000: begin
                S = 3'b100;
                Cin = 1'b0;
                set_flags = 1'b0;
                i_type = 1'b1;
            end
            //Assigning control signals for SUBI
            10'b1101000100: begin
                S = 3'b011;
                Cin = 1'b1;
                set_flags = 1'b0;
                i_type = 1'b1;
            end
            //Assigning control signals for SUBIS
            10'b1111000100: begin
                S = 3'b011;
                Cin = 1'b1;
                set_flags = 1'b1;
                i_type = 1'b1;
            end
        endcase
               
        //Handling R Type instructions
        case (ibus[31:21]) 
            //Assigning control signals for ADD
            11'b10001011000: begin
                S = 3'b010;
                Cin = 1'b0;
                set_flags = 1'b0;
                r_type = 1'b1;
                lsl = 1'b0;
                lsr = 1'b0;
            end
            //Assigning control signals for ADDS
            11'b10101011000: begin
                S = 3'b010;
                Cin = 1'b0;
                set_flags = 1'b1;
                r_type = 1'b1;
                lsl = 1'b0;
                lsr = 1'b0;
            end
            //Assigning control signals for AND
            11'b10001010000: begin
                S = 3'b110;
                Cin = 1'b0;
                set_flags = 1'b0;
                r_type = 1'b1;
                lsl = 1'b0;
                lsr = 1'b0;
            end
            //Assigning control signals for ANDS
            11'b11101010000: begin
                S = 3'b110;
                Cin = 1'b0;
                set_flags = 1'b1;
                r_type = 1'b1;
                lsl = 1'b0;
                lsr = 1'b0;
            end   
            //Assigning control signals for ORR
            11'b10101010000: begin
                S = 3'b100;
                Cin = 1'b0;
                set_flags = 1'b0;
                r_type = 1'b1;
                lsl = 1'b0;
                lsr = 1'b0;
            end
            //Assigning control signals for EOR (XOR)
            11'b11001010000: begin
                S = 3'b000;
                Cin = 1'b0;
                set_flags = 1'b0;
                r_type = 1'b1;
                lsl = 1'b0;
                lsr = 1'b0;
            end         
            //Assigning control bits for SUB
            11'b11001011000: begin
                S = 3'b011;
                Cin = 1'b1;
                set_flags = 1'b0;
                r_type = 1'b1;
                lsl = 1'b0;
                lsr = 1'b0;
            end
            //Assigning control bits for SUBS
            11'b11101011000: begin
                S = 3'b011;
                Cin = 1'b1;
                set_flags = 1'b1;
                r_type = 1'b1;
                lsl = 1'b0;
                lsr = 1'b0;
            end
            //Assigning control bits for LSL
            11'b11010011011: begin
                S = 3'b111;
                Cin = 1'b0;
                set_flags = 1'b0;
                r_type = 1'b1;
                lsl = 1'b1;
                lsr = 1'b0;
            end
            //Assigning control bits for LSR
            11'b11010011010: begin
                S = 3'b111;
                Cin = 1'b0;
                set_flags = 1'b0;
                r_type = 1'b1;
                lsl = 1'b0;
                lsr = 1'b1;
            end
        endcase
        
        //Handling D Type instructions
        case (ibus[31:21])
            //Assigning control signals for LDUR
            11'b11111000010: begin
                S = 3'b010;
                Cin = 1'b0;
                ldur = 1'b1;
                stur = 1'b0;
                d_type = 1'b1;
            end
            11'b11111000000: begin
                S = 3'b010;
                Cin = 1'b0;
                ldur = 1'b0;
                stur = 1'b1;
                d_type = 1'b1;
            end
        endcase
        
        if (r_type == 1'b1) begin
            Imm = 1'b0;
            cbz = 1'b0;
            cbnz = 1'b0;
            ldur = 1'b0;
            movz = 1'b0;
            stur = 1'b0;
            b = 1'b0;
            beq = 1'b0;
            bne = 1'b0;
            blt = 1'b0;
            bge = 1'b0;
        end
        if (i_type == 1'b1) begin
            Imm = 1'b1;
            cbz = 1'b0;
            cbnz = 1'b0;
            ldur = 1'b0;
            lsl = 1'b0;
            lsr = 1'b0;
            movz = 1'b0;
            stur = 1'b0;
            b = 1'b0;
            beq = 1'b0;
            bne = 1'b0;
            blt = 1'b0;
            bge = 1'b0;
        end
        if (d_type == 1'b1) begin
            Imm = 1'b0;            
            cbz = 1'b0;
            cbnz = 1'b0;
            lsl = 1'b0;
            lsr = 1'b0;
            movz = 1'b0;
            b = 1'b0;
            beq = 1'b0;
            bne = 1'b0;
            blt = 1'b0;
            bge = 1'b0;
            set_flags = 1'b0;
        end
        if (b_type == 1'b1) begin
            Imm = 1'b0;
            S = 3'b111; //Bypassing ID/EX stage so S can be assigned to 3'b111
            Imm = 1'b0;
            cbz = 1'b0;
            cbnz = 1'b0;
            lsl = 1'b0;
            lsr = 1'b0;
            ldur = 1'b0;
            stur = 1'b0;
            movz = 1'b0;
            beq = 1'b0;
            bne = 1'b0;
            blt = 1'b0;
            bge = 1'b0;
            set_flags = 1'b0;
        end
        if (cb_type == 1'b1) begin
            S = 3'b111; //Bypassing ID/EX Stage anyways, so we can assign don't cares to S? 
            Cin = 1'b0; //Bypassing ID/EX Stage anways, so we can assign don't care to Cin?       
            Imm = 1'b0; //ALU Input can be don't care as well?????s
            lsl = 1'b0;
            lsr = 1'b0;
            ldur = 1'b0;
            stur = 1'b0;
            movz = 1'b0;
            b = 1'b0;
            set_flags = 1'b0;
        end
        if (im_type == 1'b1) begin
            S = 3'b111; //Bypassing ALU to store in dbus based on the immediate value
            Cin = 1'b0; 
            Imm = 1'b0;
            lsl = 1'b0;
            lsr = 1'b0;
            ldur = 1'b0;
            stur = 1'b0;
            b = 1'b0;
            beq = 1'b0;
            bne = 1'b0;
            blt = 1'b0;
            bge = 1'b0;
            cbz = 1'b0;
            cbnz = 1'b0;
            set_flags = 1'b0;
        end
    end

endmodule


//Represents the second d flip-flop in the pipeline (ID/EX)
module decode(Dselect_in, S_in, Cin_in, Imm_in, abus_in, bbus_in, ldur_ctrl_in, stur_ctrl_in, set_flags_in, shamt_in, ALUImm_in, DTAddr_in, MOVImm_in, movz_in, lsl_in, lsr_in, movz_22_21_in,clk, Dselect_out, S_out, Cin_out, Imm_out, abus_out, bbus_out, ldur_ctrl_out, stur_ctrl_out, set_flags_out, shamt_out, ALUImm_out, DTAddr_out, MOVImm_out, movz_out, lsl_out, lsr_out, movz_22_21_out);
    input [31:0] Dselect_in;
    input [63:0] abus_in, bbus_in;
    input [63:0] ALUImm_in, DTAddr_in, MOVImm_in;
    input [5:0] shamt_in;
    input [2:0] S_in;
    input Cin_in, Imm_in, clk;
    input ldur_ctrl_in, stur_ctrl_in;
    input set_flags_in;
    input movz_in;
    input lsl_in;
    input lsr_in;
    input [1:0] movz_22_21_in;
    
    
    output reg [31:0] Dselect_out;
    output reg [63:0] ALUImm_out, DTAddr_out, MOVImm_out;
    output reg [2:0] S_out;
    output reg Cin_out, Imm_out;
    output reg [63:0] abus_out, bbus_out;
    output reg [5:0] shamt_out;
    output reg ldur_ctrl_out, stur_ctrl_out;
    output reg set_flags_out;
    output reg movz_out, lsl_out, lsr_out;
    output reg [1:0] movz_22_21_out;
   
    always @ (posedge clk) begin
        Dselect_out = Dselect_in;
        S_out = S_in;
        Cin_out = Cin_in;
        Imm_out = Imm_in;
        abus_out = abus_in;
        bbus_out = bbus_in;
        ldur_ctrl_out = ldur_ctrl_in;
        stur_ctrl_out = stur_ctrl_in;
        ALUImm_out = ALUImm_in;
        DTAddr_out = DTAddr_in;
        MOVImm_out = MOVImm_in;
        movz_out = movz_in;
        set_flags_out = set_flags_in;
        shamt_out = shamt_in;
        lsl_out = lsl_in;
        lsr_out = lsr_in;
        movz_22_21_out = movz_22_21_in;
    end
endmodule

//represents the third d flip-flop in the pipeline (EX/MEM)
module execute(dbus_in, Dselect_in, databus_in, ldur_ctrl_in, stur_ctrl_in, clk, dbus_out, Dselect_out, databus_out, ldur_ctrl_out, stur_ctrl_out);
    input [31:0] Dselect_in; 
    input [63:0] dbus_in, databus_in;
    input ldur_ctrl_in, stur_ctrl_in;
    input clk;
    output reg [31:0] Dselect_out;
    output reg [63:0] dbus_out, databus_out;
    output reg ldur_ctrl_out, stur_ctrl_out;
    
    always @ (posedge clk) begin
        Dselect_out = Dselect_in;
        dbus_out = dbus_in;
        ldur_ctrl_out = ldur_ctrl_in;
        stur_ctrl_out = stur_ctrl_in;
        databus_out = databus_in;
    end
endmodule

module databus_value(databus_in, stur_ctrl, databus_out);
    input [63:0] databus_in;
    input stur_ctrl;
    output reg [63:0] databus_out;
    
    always @ (stur_ctrl, databus_in, databus_out) begin
        if (stur_ctrl == 1'b1) begin
            databus_out = databus_in;
        end
        else begin
            databus_out = 64'bz;
        end
    end
endmodule

//Represents a 5-to-32 decoder
module decoder_5_to_32(in, out);
    input [4:0] in;
    output [31:0] out;
    assign out = 1 << in;
endmodule


//Creates the register file with 32, 32-bit registers
module regfile(Aselect, Bselect, Dselect, clk, abus, bbus, dbus);
    input [31:0] Aselect, Bselect, Dselect;
    input [63:0] dbus;
    input clk;
    output [63:0] abus, bbus;
    
    regfile_intermediate regfile_intermediate [30:0] (
        .Aselect(Aselect[30:0]), 
        .Bselect(Bselect[30:0]), 
        .Dselect(Dselect[30:0]), 
        .clk(clk), 
        .abus(abus), 
        .bbus(bbus), 
        .dbus(dbus)
     );
     assign abus = Aselect[31] ? 64'b0 : 64'bz;
     assign bbus = Bselect[31] ? 64'b0 : 64'bz;
endmodule

//probably need to change
module mux_2_to_1(in1, in2, sel, out);
    input [63:0] in1, in2;
    input sel;
    output reg [63:0] out;
        
    
    always @ (sel, in1, in2, out) begin
        if (sel == 1'b1)
            out = in2;
        else
            out = in1;
    end
endmodule


//This module is responsible for storing values in the registers, as well as readback.
module regfile_intermediate(Aselect, Bselect, Dselect, clk, abus, bbus, dbus);
    input Aselect, Bselect, Dselect, clk;
    input [63:0] dbus;
    output [63:0] abus, bbus;
    reg [63:0] q; //Creating intermediate value for the output from whatever is stored in the register
    always @ (negedge clk) begin
        if (Dselect == 1'b1)
            q = dbus; //grabs the value stored in the register
    end
    assign abus = Aselect ? q : 64'bz; //selects if this specific register value is being used, otherwise set as open circuit
    assign bbus = Bselect ? q : 64'bz;
    //since only one bit is being selected at once, need to assign every bus value not at that specific register index to an open circuit
endmodule

//Creates the alu module that calculates the value of D with combinational logic.
//The ALU also always gets the result of the NCVZ bits, but sets the flags in the top level module based on the set_flags control signal.
module alu (a, b, d, Cin, S, N, C, V, Z);
    input [63:0] a, b;
    input [2:0] S;
    input Cin;
    output [63:0] d;
    
    output N, C, V, Z;
    
    wire [63:0] c, g, p;
    wire gout, pout;
        
    
    //Instantiating the ALU cell
    alu_cell mycell[63:0] (
       .d(d),
       .g(g),
       .p(p),
       .a(a),
       .b(b),
       .c(c),
       .S(S)
    );
    
   //Instantiating the LAC
    lac6 lac(
       .c(c),
       .gout(gout),
       .pout(pout),
       .Cin(Cin),
       .g(g),
       .p(p)
    );
 
    //Instantiating the overflow detector
    //populates the value in C and V
    overflow ov(
       .Cout(C),
       .V(V),
       .g(gout),
       .p(pout),
       .c63(c[63]),
       .Cin(Cin)
    );
    
    //Checks if the output is zero
    zero_detector zero(
        .d(d),
        .zero(Z)
    );
    
    //Checks if the output is negative
    neg_detector neg(
        .d63(d[63]),
        .neg(N)
    ); 
       
endmodule

module neg_detector (d63, neg);
    input d63;
    output reg neg;
    
    always @ (d63, neg) begin
        neg = d63;
    end
endmodule


module zero_detector (d, zero);
    input [63:0] d;
    output reg zero;
    
    always @ (d, zero) begin
        if (d == 64'b0) 
            zero = 1'b1;
        else
            zero = 1'b0;
    end
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


module overflow (Cout, V, g, p, c63, Cin);
   output Cout, V;
   input g, p, c63, Cin;
   
   assign Cout = g|(p&Cin); //gets the Carry out bit based on the generator and propogator bit
   assign V = Cout^c63; //finds out whether or not the overflow bit is set high
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

module lac6 (c, gout, pout, Cin, g, p);
   output [63:0] c;
   output gout, pout;
   input Cin;
   input [63:0] g, p;
   
   wire [1:0] cint, gint, pint;
   
   lac5 leaf0(
       .c(c[31:0]),
       .gout(gint[0]),
       .pout(pint[0]),
       .Cin(cint[0]),
       .g(g[31:0]),
       .p(p[31:0])
   );
   
   lac5 leaf1(
       .c(c[63:32]),
       .gout(gint[1]),
       .pout(pint[1]),
       .Cin(cint[1]),
       .g(g[63:32]),
       .p(p[63:32])
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