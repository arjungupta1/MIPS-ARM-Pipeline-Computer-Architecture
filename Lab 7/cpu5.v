`timescale 1ns / 1ps


module cpu5(ibus, daddrbus, databus, reset, iaddrbus, clk);
    input [31:0] ibus;
    input reset;
    input clk;
    output [31:0] daddrbus, iaddrbus;
    inout [31:0] databus;
    
    //PC Intermediate wires
    wire [31:0] pc_in;     
    wire [31:0] pc_out;

    //IF/ID intermediate wires
    wire [31:0] pc_plus_4;
    wire [31:0] ibus_intermediate; 
    
    //ID/EX intermediate wires
    wire [31:0] pc_decode;
    wire [31:0] sign_extend_immediate;
    wire [31:0] sign_extend_branch_address;
    wire [31:0] Aselect, Bselect, Dselect_decode;
    wire [31:0] abus_intermediate, bbus_intermediate;
    wire [2:0] s_intermediate;
    wire imm_intermediate, cin_intermediate; 
    wire lw_ctrl_decode, sw_ctrl_decode;
    wire beq_ctrl, bne_ctrl;
    wire slt_ctrl_decode, sle_ctrl_decode;
    wire branch;
    
    //EX/MEM intermediate wires
    wire [31:0] abus, bbus_mux_in;
    wire [31:0] bbus;
    wire [31:0] dbus_intermediate;
    wire [31:0] dbus_post_set_ctrl;
    wire [31:0] sign_extend;
    wire [31:0] Dselect_execute;
    wire [31:0] databus_intermediate;
    wire [2:0] S;
    wire Imm, Cin, Cout;
    wire is_zero;
    wire lw_ctrl_execute, sw_ctrl_execute;
    wire slt_ctrl_execute, sle_ctrl_execute;
    
    
    //MEM/WB intermediate wires
    wire [31:0] Dselect_mem;
    wire lw_ctrl_mem, sw_ctrl_mem;
    
    wire [31:0] databus_mux_in, daddrbus_mux_in; 
    wire lw_ctrl_wb, sw_ctrl_wb;   
    
    wire [31:0] dbus;
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
     
    //Creating the sign extend module with combinational logic
     sign_extended_value my_sign_extended_value(
         .in(ibus_intermediate[15:0]),
         .out(sign_extend_immediate)
     );
     
     assign sign_extend_branch_address = ( sign_extend_immediate << 2 ) + pc_decode;
          
     //Finding the values for Aselect, Bselect, Dselect (needs to be passed through pipeline), Imm (needs to be passed through pipeline), S and Cin (both need t o be passed through pipeline)    
     controller my_controller(
         .ibus(ibus_intermediate), 
         .Aselect(Aselect), 
         .Bselect(Bselect),
         .Dselect(Dselect_decode), //intermediate value
         .Imm(imm_intermediate), //intermediate value
         .S(s_intermediate), //intermediate value
         .Cin(cin_intermediate), //intermediate value
         .lw_ctrl(lw_ctrl_decode),
         .sw_ctrl(sw_ctrl_decode),
         .beq_ctrl(beq_ctrl),
         .bne_ctrl(bne_ctrl),
         .slt_ctrl(slt_ctrl_decode),
         .sle_ctrl(sle_ctrl_decode)
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
          
     branch_logic my_branch_logic(
        .in1(abus_intermediate),
        .in2(bbus_intermediate),
        .beq_ctrl(beq_ctrl),
        .bne_ctrl(bne_ctrl),
        .branch(branch)
     );
     
     mux_2_to_1 pc_mux(
        .in1(pc_plus_4),
        .in2(sign_extend_branch_address), //do i need to change with pc_decode?
        .sel(branch),
        .out(pc_in)        
     );
     
     //Passes each value that needs to be passed through the pipeline on the positive edge of a clock
     decode my_decode(
         .mux_in(Dselect_decode),
         .mux_out(Dselect_execute),
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
         .sign_extend_in(sign_extend_immediate),
         .sign_extend_out(sign_extend),  
         .lw_ctrl_in(lw_ctrl_decode),
         .lw_ctrl_out(lw_ctrl_execute),
         .sw_ctrl_in(sw_ctrl_decode),
         .sw_ctrl_out(sw_ctrl_execute),    
         .slt_ctrl_in(slt_ctrl_decode),
         .slt_ctrl_out(slt_ctrl_execute),
         .sle_ctrl_in(sle_ctrl_decode),
         .sle_ctrl_out(sle_ctrl_execute),  
         .clk(clk)
     );
     
    //Creates the multiplexer that switches between the value from the register file for bbus and the sign extended immediate value
     //Based on the immediate value that is passed through the pipeline
     mux_2_to_1 bbus_or_sign_extend(
         .in1(bbus_mux_in),
         .in2(sign_extend),
         .sel(Imm),
         .out(bbus)
     );
     
    //Computes the value of dbus given the correct operation and inputs from the previous modules
     alu my_alu(
         .a(abus),
         .b(bbus),
         .d(dbus_intermediate),
         .Cin(Cin),
         .S(S),
         .Cout(Cout)
     );  
     
     zero_detector zero(
         .a(abus),
         .b(bbus),
         .zero(is_zero)
     );

     slt_sle_ctrl my_slt_sle_ctrl(
        .slt_ctrl(slt_ctrl_execute),
        .sle_ctrl(sle_ctrl_execute),
        .zero(is_zero),
        .Cout(Cout),
        .d_in(dbus_intermediate),
        .d_out(dbus_post_set_ctrl)
     );
        
    //flushes the value of dbus and Dselect back into the register value after being piped through the pipeline on the positive edge of the next clock cycle
     execute my_execute(
         .dbus_in(dbus_post_set_ctrl),
         .dbus_out(daddrbus),
         .Dselect_in(Dselect_execute),
         .Dselect_out(Dselect_mem),
         .databus_in(bbus_mux_in),
         .databus_out(databus_intermediate),
         .lw_ctrl_in(lw_ctrl_execute),
         .lw_ctrl_out(lw_ctrl_mem),
         .sw_ctrl_in(sw_ctrl_execute),
         .sw_ctrl_out(sw_ctrl_mem),
         .clk(clk)
     );    
     
     //Sets the value in the databus to high impedance if not used by a load or store
     databus_value get_databus(
        .databus_in(databus_intermediate),
        .lw_ctrl(lw_ctrl_mem),
        .sw_ctrl(sw_ctrl_mem),
        .databus_out(databus)
     );
     
     //models the writeback DFF
     writeback my_writeback(
        .databus_in(databus),
        .daddrbus_in(daddrbus),
        .lw_ctrl_in(lw_ctrl_mem),
        .sw_ctrl_in(sw_ctrl_mem),
        .Dselect_in(Dselect_mem),
        .clk(clk),
        .databus_out(databus_mux_in),
        .daddrbus_out(daddrbus_mux_in),
        .lw_ctrl_out(lw_ctrl_wb),
        .sw_ctrl_out(sw_ctrl_wb),
        .Dselect_out(Dselect)        
     );
     
     
     //Selects between the address bus and the databus for writeback based on the load word. 
     mux_2_to_1 dbus_mux(
        .in1(daddrbus_mux_in),
        .in2(databus_mux_in),
        .sel(lw_ctrl_wb),
        .out(dbus)
     );
     

endmodule

module pc(pc_in, reset, clk, pc_out);
    input [31:0] pc_in;
    input reset;
    input clk;
    output reg [31:0] pc_out;
    
    initial begin
        pc_out = 32'b0;
    end
    
    always @ (posedge clk) begin
        if (reset == 1'b1)
            pc_out = 32'b0;
        else
            pc_out = pc_in;
    end
endmodule   


//Represents the first d flip-flop in the pipeline (IF/ID)
module fetch(ibus_in, pc_in, clk, ibus_out, pc_out);
    input [31:0] ibus_in, pc_in;
    input clk;
    output reg [31:0] ibus_out, pc_out;
    
    initial begin
        pc_out = 0;
    end

    
    always @(posedge clk) begin
        ibus_out = ibus_in;
        pc_out = pc_in;
    end
endmodule

module writeback(databus_in, daddrbus_in, lw_ctrl_in, sw_ctrl_in, Dselect_in, clk, databus_out, daddrbus_out, lw_ctrl_out, sw_ctrl_out, Dselect_out);
    input [31:0] databus_in, daddrbus_in;
    input [31:0] Dselect_in;
    input lw_ctrl_in, sw_ctrl_in;
    input clk;
    output reg [31:0] databus_out, daddrbus_out;
    output reg [31:0] Dselect_out;
    output reg lw_ctrl_out, sw_ctrl_out;
    
    always @(posedge clk) begin
        databus_out = databus_in;
        daddrbus_out = daddrbus_in;
        Dselect_out = Dselect_in;
        lw_ctrl_out = lw_ctrl_in;
        sw_ctrl_out = sw_ctrl_in;
    end
endmodule


//Creates the sign extended immediate value
module sign_extended_value(in, out);
    input [15:0] in;
    output [31:0] out;
    assign out = in[15] ? {16'hFFFF, in} : {16'h0000, in};
endmodule

//Creating the controller which grabs the values for Aselect, Bselect, and Dselect as well as Imm, S, and Cin.
//These are all intermediate values
module controller(ibus, Aselect, Bselect, Dselect, Imm, S, Cin, lw_ctrl, sw_ctrl, beq_ctrl, bne_ctrl, slt_ctrl, sle_ctrl);
    input [31:0] ibus;
    output [31:0] Aselect, Bselect;
    output [31:0] Dselect;
    output [2:0] S;
    output Imm, Cin;
    output lw_ctrl, sw_ctrl;
    output beq_ctrl, bne_ctrl;
    output slt_ctrl, sle_ctrl;
    
    
    wire [31:0] dsel_intermediate;
    wire [31:0] dsel_intermediate2;
    wire [5:0] opcode_decoded;
    
    //Creating the three decoders from 5-bit segments of the instruction bus to 31-bit numbers for use in the ALU Register File
    decoder_5_to_32 rs_decoder(
        .in(ibus[25:21]), 
        .out(Aselect)
    );
    decoder_5_to_32 rt_decoder(
        .in(ibus[20:16]), 
        .out(Bselect)
    );
    //Intermediate value used to keep exposed Dselect signal consistent with the value in the correct stage of the pipeline
    decoder_5_to_32 rd_decoder(
        .in(ibus[15:11]),
        .out(dsel_intermediate)
    );
    
    //Given the opcode segements of the instruction, find the control signal values for load word and store word.
    decode_lw_and_sw my_decode_lw_and_sw(
        .opcode(ibus[31:26]),
        .lw_ctrl(lw_ctrl),
        .sw_ctrl(sw_ctrl)
    );
        
    //Given the opcode and funct segments of the instruction, find the correct "opcode" for both R and I type instructions
    decode_opcode opcode_and_imm(
        .opcode(ibus[31:26]), 
        .funct(ibus[5:0]), 
        .Imm(Imm), 
        .opcode_decoded(opcode_decoded)
    );
    
    get_branch_sig_val get_branch(
        .opcode(opcode_decoded),
        .beq(beq_ctrl),
        .bne(bne_ctrl)
    );
    
    get_slt_sig_val get_slt(
        .opcode(opcode_decoded),
        .slt(slt_ctrl),
        .sle(sle_ctrl)
    );
    
    //Finds the correct S and Cin values given the current opcode. Values will be flushed through the pipeline once intermediate values are calcaulated 
    find_s_and_cin s_and_cin(
        .opcode(opcode_decoded), 
        .S(S), 
        .Cin(Cin)
    );
    //Selector for either the rd or rt registers
    mux_32bit_2_to_1 dselect_selector(
        .rt_decoded(Bselect),
        .rd_decoded(dsel_intermediate), 
        .Imm(Imm), 
        .out(dsel_intermediate2)
    );
    
    assign Dselect = (sw_ctrl | beq_ctrl | bne_ctrl) ? 32'b0 : dsel_intermediate2;
        
endmodule

//sets the slt and sle control signals
module get_slt_sig_val(opcode, slt, sle);
    input [5:0] opcode;
    output reg slt, sle;
    
    always @ (opcode, slt, sle) begin
        case (opcode)
            6'b110110: begin
                slt = 1;
                sle = 0;
            end
            6'b110111: begin
                slt = 0;
                sle = 1;
            end
            default: begin
                slt = 0;
                sle = 0;
            end
        endcase
    end
endmodule

//sets the branch control signals
module get_branch_sig_val(opcode, beq, bne);
    input [5:0] opcode;
    output reg beq, bne;
    
    always @ (opcode, beq, bne) begin
        case (opcode)
            6'b110000: begin
                beq = 1;
                bne = 0;
            end
            6'b110001: begin
                beq = 0;
                bne = 1;
            end
            default: begin
                beq = 0;
                bne = 0;
            end
        endcase
    end
endmodule

//Creates the branch logic given two inputs from regfile and the control signals from the decoded opcode
module branch_logic(beq_ctrl, bne_ctrl, in1, in2, branch);
    input beq_ctrl, bne_ctrl;
    input [31:0] in1, in2;
    output reg branch;
    
    initial begin
        branch = 0;
    end
    
    always @(beq_ctrl, bne_ctrl, in1, in2, branch) begin
        if ((in1 == in2) && (beq_ctrl == 1'b1))
            branch = 1;
        else if ((in1 != in2) && (bne_ctrl == 1'b1))
            branch = 1;
        else 
            branch = 0;
    end
endmodule

//Represents the second d flip-flop in the pipeline (ID/EX)
module decode(mux_in, S_in, Cin_in, Imm_in, abus_in, bbus_in, sign_extend_in, lw_ctrl_in, sw_ctrl_in, slt_ctrl_in, sle_ctrl_in, clk, mux_out, S_out, Cin_out, Imm_out, abus_out, bbus_out, sign_extend_out, lw_ctrl_out, sw_ctrl_out, slt_ctrl_out, sle_ctrl_out);
    input [31:0] mux_in;
    input [31:0] abus_in, bbus_in, sign_extend_in;

    input [2:0] S_in;
    input Cin_in, Imm_in, clk;
    input lw_ctrl_in, sw_ctrl_in;
    input slt_ctrl_in, sle_ctrl_in;
    
    output reg [31:0] mux_out;
    output reg [2:0] S_out;
    output reg Cin_out, Imm_out;
    output reg [31:0] abus_out, bbus_out, sign_extend_out;
    output reg lw_ctrl_out, sw_ctrl_out;
    output reg slt_ctrl_out, sle_ctrl_out;
   
    always @ (posedge clk) begin
        mux_out = mux_in;
        S_out = S_in;
        Cin_out = Cin_in;
        Imm_out = Imm_in;
        abus_out = abus_in;
        bbus_out = bbus_in;
        sign_extend_out = sign_extend_in;
        lw_ctrl_out = lw_ctrl_in;
        sw_ctrl_out = sw_ctrl_in;
        slt_ctrl_out = slt_ctrl_in;
        sle_ctrl_out = sle_ctrl_in;
    end
endmodule

//represents the third d flip-flop in the pipeline (EX/MEM)
module execute(dbus_in, Dselect_in, databus_in, lw_ctrl_in, sw_ctrl_in, clk, dbus_out, Dselect_out, databus_out, lw_ctrl_out, sw_ctrl_out);
    input [31:0] Dselect_in, dbus_in, databus_in;
    input lw_ctrl_in, sw_ctrl_in;
    input clk;
    output reg [31:0] Dselect_out, dbus_out, databus_out;
    output reg lw_ctrl_out, sw_ctrl_out;
    
    always @ (posedge clk) begin
        Dselect_out = Dselect_in;
        dbus_out = dbus_in;
        lw_ctrl_out = lw_ctrl_in;
        sw_ctrl_out = sw_ctrl_in;
        databus_out = databus_in;
    end
endmodule

module databus_value(databus_in, lw_ctrl, sw_ctrl, databus_out);
    input [31:0] databus_in;
    input lw_ctrl, sw_ctrl;
    output reg [31:0] databus_out;
    
    always @ (lw_ctrl, sw_ctrl, databus_in, databus_out) begin
        if (sw_ctrl == 1'b1) begin
            databus_out = databus_in;
        end
        else if (lw_ctrl == 1'b1) begin
            databus_out = 32'bz;
        end
        else begin
            databus_out = 32'bz;
        end
    end
endmodule

//Represents a 5-to-32 decoder
module decoder_5_to_32(in, out);
    input [4:0] in;
    output [31:0] out;
    assign out = 1 << in;
endmodule

module decode_lw_and_sw(opcode, lw_ctrl, sw_ctrl);
    input [5:0] opcode;
    output reg lw_ctrl;
    output reg sw_ctrl;
    
    always @ (opcode, lw_ctrl, sw_ctrl) begin
        case (opcode)
            6'b011110: begin
                lw_ctrl = 1;
                sw_ctrl = 0;
            end
            6'b011111: begin
                lw_ctrl = 0;
                sw_ctrl = 1;
            end
            default: begin
                lw_ctrl = 0;
                sw_ctrl = 0;
            end
        endcase 
    end
endmodule

//Calculates the correct "opcode" value that will determine the correct S and Cin values.
module decode_opcode(opcode, funct, Imm, opcode_decoded);
    input [5:0] opcode, funct;
    output reg Imm;
    output reg [5:0] opcode_decoded;
    always @(opcode or funct) begin
        if (!opcode) begin
            case (funct) //switch between the funct for R type instructions
                6'b000001: opcode_decoded = 6'b000001;
                6'b000010: opcode_decoded = 6'b000010;
                6'b000011: opcode_decoded = 6'b000011;
                6'b000100: opcode_decoded = 6'b001100; // not all match up, so check carefully
                6'b000111: opcode_decoded = 6'b001111;
                6'b110110: opcode_decoded = 6'b110110;
                6'b110111: opcode_decoded = 6'b110111;
                default: opcode_decoded = 6'b000000; //inactive value
            endcase
            Imm = 0;
        end
        else begin
            case (opcode)
                6'b000001: Imm = 1;
                6'b000010: Imm = 1;
                6'b000011: Imm = 1;
                6'b001100: Imm = 1;
                6'b001111: Imm = 1; //only assign imm to 1 for the correct opcodes given by the MIPS reference card
                6'b011110: Imm = 1;
                6'b011111: Imm = 1;
                6'b110000: Imm = 1;
                6'b110001: Imm = 1;
                default: Imm = 0;
            endcase
            opcode_decoded = opcode; //Value is OK at this point
        end
    end
endmodule

//represents a 32-bit 2-to-1 multiplexor that chooses between the rd and rt decoded values.
module mux_32bit_2_to_1(rt_decoded, rd_decoded, Imm, out);
    input [31:0] rt_decoded, rd_decoded;
    input Imm;
    output reg [31:0] out;
    //sensitive to changes in both the selector and the output
    always @ ( Imm or rt_decoded or rd_decoded ) begin
        if (Imm == 1'b0)
            out = rd_decoded;
        else
            out = rt_decoded;
    end 
endmodule

//given an opcode that is standard for both R and I type instructions, find Cin and S.
module find_s_and_cin(opcode, S, Cin);
    input [5:0] opcode;
    output reg [2:0] S;
    output reg Cin;
    
    always @(opcode) begin
        case (opcode) 
            6'b000001: begin
                S = 3'b000;
                Cin = 0;
            end
            6'b000010: begin
                S = 3'b011;
                Cin = 1;
            end
            6'b000011: begin
                S = 3'b010;
                Cin = 0;
            end
            6'b001100: begin
                S = 3'b100;
                Cin = 0;
            end
            6'b001111: begin
                S = 3'b110;
                Cin = 0;
            end
            6'b011110: begin
                S = 3'b010;
                Cin = 0;
            end
            6'b011111: begin
                S = 3'b010;
                Cin = 0;
            end
            6'b110110: begin
                S = 3'b011;
                Cin = 1;
            end
        endcase
    end
endmodule


//Creates the register file with 32, 32-bit registers
module regfile(Aselect, Bselect, Dselect, clk, abus, bbus, dbus);
    input [31:0] Aselect, Bselect, Dselect;
    input [31:0] dbus;
    input clk;
    output [31:0] abus, bbus;
    
    regfile_intermediate regfile_intermediate [31:1] (
        .Aselect(Aselect[31:1]), 
        .Bselect(Bselect[31:1]), 
        .Dselect(Dselect[31:1]), 
        .clk(clk), 
        .abus(abus), 
        .bbus(bbus), 
        .dbus(dbus)
     );
     assign abus = Aselect[0] ? 32'b0 : 32'bz;
     assign bbus = Bselect[0] ? 32'b0 : 32'bz;
endmodule

module mux_2_to_1(in1, in2, sel, out);
    input [31:0] in1, in2;
    input sel;
    output reg [31:0] out;
        
    
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
    input [31:0] dbus;
    output [31:0] abus, bbus;
    reg [31:0] q; //Creating intermediate value for the output from whatever is stored in the register
    always @ (negedge clk) begin
        if (Dselect == 1'b1)
            q = dbus; //grabs the value stored in the register
    end
    assign abus = Aselect ? q : 32'bz; //selects if this specific register value is being used, otherwise set as open circuit
    assign bbus = Bselect ? q : 32'bz;
    //since only one bit is being selected at once, need to assign every bus value not at that specific register index to an open circuit
endmodule

//Creates the alu module that calculates the value of D with combinational logic.
module alu (a, b, d, Cin, S, Cout);
    input [31:0] a, b;
    input [2:0] S;
    input Cin;
    output [31:0] d;
    output Cout;
    
    wire [31:0] c, g, p;
    wire gout, pout;
    wire V;
        
    
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

module slt_sle_ctrl(slt_ctrl, sle_ctrl, zero, Cout, d_in, d_out);
    input slt_ctrl, sle_ctrl, zero, Cout;
    input [31:0] d_in;
    
    output reg [31:0] d_out;
    
    always @ (slt_ctrl, sle_ctrl, zero, Cout, d_in, d_out) begin
        if (slt_ctrl == 1'b1) 
            d_out = {31'b0, (!Cout & !zero)};
        else if (sle_ctrl == 1'b1)
            d_out = {31'b0, (!Cout | zero)};
        else
            d_out = d_in;
    end
endmodule

module zero_detector (a, b, zero);
    input [31:0] a, b;
    output reg zero;
    
    always @ (a, b, zero) begin
        if (a == 32'b0 && b == 32'b0) 
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