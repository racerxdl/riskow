`timescale 1 ns/1 ns  // time-unit = 1 ns, precision = 10 ps

module TimerTest;

  localparam ms = 1e6;
  localparam us = 1e3;

  integer i, j;
  reg                 clk;
  reg                 reset;
  reg                 chipSelect;
  reg                 write;
  reg                 writeCommand;
  reg         [31:0]  dataIn;
  wire        [31:0]  dataOut;


  // Our device under test
  Timer dut(clk, reset, chipSelect, write, writeCommand, dataIn, dataOut);

  initial begin
    $dumpfile("timer_tb.vcd");
    $dumpvars(0, TimerTest);

    reset = 1;
    clk = 0;
    chipSelect = 0;
    write = 0;
    writeCommand = 0;
    dataIn = 0;

    #10
    clk = 1;
    #10
    clk = 0;

    reset = 0;

    // Set Divider
    writeCommand = 1;
    chipSelect = 1;
    //          XXXX    DATA    CMD
    dataIn = { 20'b0, 9'h80, 3'b001};

    #10
    clk = 1;
    #10
    clk = 0;

    if (dut.divideBy != 9'h80) $error("Expected dut.divideBy to be %02x but got %02x." , 9'h80, dut.divideBy);

    // Set Timer
    writeCommand = 1;
    chipSelect = 1;
    //          XXXX    DATA    CMD
    dataIn = { 29'b0, 3'h2};
    #10
    clk = 1;
    #10
    clk = 0;

    if (dut.timerRunning != 1) $error("Expected dut.timerRunning to be %01x but got %01x." , 1, dut.timerRunning);

    i = 0;
    writeCommand = 0;
    chipSelect = 0;

    repeat(127)
    begin
      if (dut.divider != i) $error("Expected dut.divider to be %02x but got %02x." , i, dut.divider);
      #10
      clk = 1;
      #10
      clk = 0;
      i = i + 1;
    end

    #10
    clk = 1;
    #10
    clk = 0;

    if (dut.divider != 0) $error("Expected dut.divider to be %02x but got %02x." , 0, dut.divider);
    if (dut.counter != 1) $error("Expected dut.counter to be %02x but got %02x." , 1, dut.counter);

    // Test Set Timer
    write = 1;
    chipSelect = 1;
    dataIn = 32'hFFFFF000;

    #10
    clk = 1;
    #10
    clk = 0;

    if (dut.counter != 32'hFFFFF000) $error("Expected dut.counter to be %02x but got %02x." , 32'hFFFFF000, dut.counter);

    write = 0;
    chipSelect = 0;

    repeat(32'h1000 * 128)
    begin
      #10
      clk = 1;
      #10
      clk = 0;
    end
    if (dut.counter != 32'h0) $error("Expected dut.counter to be %02x but got %02x." , 32'h0, dut.counter);

    $finish;
  end

endmodule

