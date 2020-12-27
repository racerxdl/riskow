`timescale 1 ns/1 ns  // time-unit = 1 ns, precision = 10 ps

module ProgramCounterTest;

  localparam ms = 1e6;
  localparam us = 1e3;
  localparam numTest = 15;

  integer i, j;

  reg           clk = 0;
  reg           reset = 0;
  reg   [31:0]  dataIn;
  wire  [31:0]  dataOut;
  wire  [31:0]  address;
  wire          busWriteEnable;     // 1 => WRITE, 0 => READ

  reg [31:0] memory [0:256];

  // Our device under test
  CPU cpu(clk, reset, dataIn, dataOut, address, busWriteEnable);

  initial begin
    $dumpfile("program_counter_tb.vcd");
    $dumpvars(0, ProgramCounterTest);

    // Test ALU
    $readmemh("testdata/test_alu.mem", memory);

    #100

    $finish;
  end
endmodule