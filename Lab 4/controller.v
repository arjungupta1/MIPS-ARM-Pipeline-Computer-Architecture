`timescale 1ns / 1ps

/**
    This file represents the controller for the pipelined ALU. This sets up piplines between the instruction bus 
    and the decoding stages, between the decoding stages and the execution stages, and between the execution s tages and memory writeback stages.
    This controller is only used to set up the control points for the actual pipeline which will be implemented in a future lab. 
**/

module controller(ibus, clk, Aselect, Bselect, Dselect, Imm, S, Cin);
    input [31:0] ibus;
    input clk;
    output [31:0] Aselect, Bselect;
    output reg [31:0] Dselect;
    output reg [2:0] S;
    output reg Imm, Cin;
    
    wire [31:0] dsel_intermediate;
    wire [31:0] mux_output;
    reg [31:0] mux_post_clock;
    reg [31:0] ibus_intermediate;
    wire [5:0] opcode_decoded;
    wire imm_intermediate;
    wire [2:0] s_intermediate;
    wire cin_intermediate;
    
    //Assigning inactive values to the control lines to keep these from being undefined
    initial begin
        S = 0;
        Imm = 0;
        Cin = 0;
    end
    
    //Creating the first pipline from the instruction bus to the decoding stage
    always @(posedge clk) begin
        ibus_intermediate <= ibus;
    end
    
    //Creating the three decoders from 5-bit segments of the instruction bus to 31-bit numbers for use in the ALU Register File
    decoder_5_to_32 rs_decoder(ibus_intermediate[25:21], Aselect);
    decoder_5_to_32 rt_decoder(ibus_intermediate[20:16], Bselect);
    //Intermediate value used to keep exposed Dselect signal consistent with the value in the correct stage of the pipeline
    decoder_5_to_32 rd_decoder(ibus_intermediate[15:11], dsel_intermediate);
    
    //Given the opcode and funct segments of the instruction, find the correct "opcode" for both R and I type instructions
    decode_opcode opcode_and_imm(ibus_intermediate[31:26], ibus_intermediate[5:0], imm_intermediate, opcode_decoded);
    //Finds the correct S and Cin values given the current opcode. Values will be flushed through the pipeline once intermediate values are calcaulated 
    find_s_and_cin s_and_cin(.opcode(opcode_decoded), .S(s_intermediate), .Cin(cin_intermediate));
    //Selector for either the rd or rt registers
    mux_32bit_2_to_1 dselect_selector(Bselect, dsel_intermediate, imm_intermediate, mux_output);
    
    //creating the second pipeline, and another intermediate value to hold the value of Dselect
    always @(posedge clk) begin
        mux_post_clock <= mux_output;
        Imm <= imm_intermediate;
        S <= s_intermediate;
        Cin <= cin_intermediate;
    end
    
    //Flushing Dselect to the output
    always @ (posedge clk) begin
        Dselect <= mux_post_clock;

    end
    
endmodule

//Represents a 5-to-32 decoder
module decoder_5_to_32(in, out);
    input [4:0] in;
    output [31:0] out;
    assign out = 1 << in;
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
            default: begin
                S = 3'b111;
                Cin = 0;
            end
        endcase
    end
endmodule
