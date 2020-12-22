`timescale 1 ns/1 ns  // time-unit = 1 ns, precision = 10 ps

module ProgramCounterTest;

  localparam ms = 1e6;
  localparam us = 1e3;

  integer i, j;

  reg           clk = 0;
  reg           reset = 0;
  reg   [31:0]  dataIn;
  wire  [31:0]  dataOut;
  reg           writeEnable;     // 1 => WRITE, 0 => READ
  reg           countEnable;     // 1 => COUNT UP, 0 => STOPPED

  // Our device under test
  ProgramCounter dut(clk, reset, dataIn, dataOut, writeEnable, countEnable);

  initial begin
    $dumpfile("program_counter_tb.vcd");
    $dumpvars(0, ProgramCounterTest);
    // Set Reset conditions
    clk = 0;
    reset = 1;
    dataIn = 0;
    writeEnable = 0;
    countEnable = 0;

    // Pulse Clock
    #10
    clk = 1;
    #10
    clk = 0;

    // Test reset
    if (dataOut != 0) $error("Expected dataOut to be %d but got %d.", 0, dataOut);
    if (dut.programCounter != 0) $error("Expected dut.programCounter to be %d but got %d.", 0, dut.programCounter);

    // Test Jump (Write)
    dataIn = 32'hDEADBEEF;
    writeEnable = 1;
    reset = 0;

    // Pulse Clock
    #10
    clk = 1;
    #10
    clk = 0;

    dataIn = 0;

    if (dataOut != 32'hDEADBEEF) $error("Expected dataOut to be %d but got %d.", 32'hDEADBEEF, dataOut);
    if (dut.programCounter != 32'hDEADBEEF) $error("Expected dut.programCounter to be %d but got %d.", 32'hDEADBEEF, dut.programCounter);

    // Test Counter
    dataIn = 32'h00000004;
    writeEnable = 1;
    // Pulse Clock
    #10
    clk = 1;
    #10
    clk = 0;

    writeEnable = 0;
    countEnable = 1;

    for (i = 0; i < 16; i++)
    begin
      if (dataOut != dataIn + i * 4) $error("Expected dataOut to be %d but got %d.", dataIn + i * 4, dataOut);
      // Pulse Clock
      #10
      clk = 1;
      #10
      clk = 0;
    end

    #100

    $finish;
  end
endmodule