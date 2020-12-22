`timescale 1 ns/1 ns  // time-unit = 1 ns, precision = 10 ps

module ALUTest;

  localparam ms = 1e6;
  localparam us = 1e3;

  reg   [3:0]   operation;
  reg   [31:0]  X;
  reg   [31:0]  Y;
  wire  [31:0]  O;

  // Our device under test
  ALU dut(operation, X, Y, O);

/*
  parameter ADD = 4'h0;
  parameter SUB = 4'h1;
  parameter OR  = 4'h2;
  parameter XOR = 4'h3;
  parameter AND = 4'h4;
  parameter LesserThanUnsigned = 4'h5;
  parameter LesserThanSigned = 4'h6;
  parameter ShiftRightUnsigned = 4'h7;
  parameter ShiftRightSigned = 4'h8;
  parameter ShiftLeftUnsigned = 4'h9;
  parameter ShiftLeftSigned = 4'hA;
 */

  initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, ALUTest);
    operation = 0;
    X = 0;
    Y = 0;

    operation = ALU.ADD;

    // TODO

    #100

    $finish;
  end
endmodule
