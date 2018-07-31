`timescale 1ns / 1ps

/**
    This file creates a register ALU design with a register file combined with a pipelined ALU.
    The purpose of this is to add 32, 32-bit registers to the ALU for storing and reading back values.
**/

module regalu(Aselect, Bselect, Dselect, clk, abus, bbus, dbus, S, Cin);
    input  [31:0] Aselect, Bselect, Dselect;
    input clk, Cin;
    output [31:0] abus, bbus, dbus;
    input  [2:0] S;
    
    //Instantiates a module that holds the intermediate structure and calculations for abus, bbus, and dbus.
    //This module also stores values in each register.
    regalu_intermediate regalu_inter [31:1] (Aselect[31:1], Bselect[31:1], Dselect[31:1], clk, abus, bbus, dbus);

    //The following two statements create the first register at logic 0 as a reference to every other register.
    assign abus = Aselect[0] ? 0 : 32'bz;
    assign bbus = Bselect[0] ? 0 : 32'bz;
    
    //Adds the pipelined ALU to the block of registers to support reading and writing to them    
    alupipe alu(.abus(abus), .bbus(bbus), .dbus(dbus), .Cin(Cin), .S(S), .clk(clk));

endmodule

//This module is responsible for storing values in the registers, as well as readback.
module regalu_intermediate(Aselect, Bselect, Dselect, clk, abus, bbus, dbus);
    input Aselect, Bselect, Dselect, clk;
    output [31:0] abus, bbus, dbus;
    reg [31:0] q; //Creating intermediate value for the output from whatever is stored in the register
    assign newclk = clk & Dselect;
    always @ (negedge newclk) begin
        q = dbus; //grabs the value stored in the register
    end
    assign abus = Aselect ? q : 32'bz; //selects if this specific register value is being used, otherwise set as open circuit
    assign bbus = Bselect ? q : 32'bz;
    //since only one bit is being selected at once, need to assign every bus value not at that specific register index to an open circuit
endmodule