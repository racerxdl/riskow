`timescale 1 ns/1 ns  // time-unit = 1 ns, precision = 10 ps

module DigitalPortTest;

  localparam ms = 1e6;
  localparam us = 1e3;

  integer i, j;
  reg                 clk;
  reg                 reset;
  reg                 chipSelect;
  reg                 writeIO;
  reg                 writeDirection;
  reg         [31:0]  dataIn;
  wire        [31:0]  dataOut;
  wire        [31:0]  directionOut;
  wire        [31:0]  IO_OUT;
  wire        [31:0]  IO_IN;

  reg         [31:0]  simulatedIOInput;


  // Our device under test
  DigitalPort dutIn(clk, reset, chipSelect, writeIO, writeDirection, dataIn, dataOut, directionOut, IO_IN);
  DigitalPort dutOut(clk, reset, chipSelect, writeIO, writeDirection, dataIn, dataOut, directionOut, IO_OUT);

  initial begin
    $dumpfile("digital_port_tb.vcd");
    $dumpvars(0, DigitalPortTest);

    reset = 1;
    clk = 0;
    chipSelect = 0;
    writeDirection = 0;
    writeIO = 0;
    dataIn = 0;
    simulatedIOInput = 0;

    #10
    clk = 1;
    #10
    clk = 0;

    reset = 0;

    // Test Write Direction
    writeDirection = 1;
    chipSelect = 1;
    dataIn = 32'hFF00FF00;

    #10
    clk = 1;
    #10
    clk = 0;

    writeDirection = 0;
    dataIn = 0;
    simulatedIOInput = 32'hFFFFFFFF;

    #10
    clk = 1;
    #10
    clk = 0;

    if (dutIn.direction != 32'hFF00FF00)  $error("Expected dutIn.direction to be %08x but got %08x." , 32'hFF00FF00, dutIn.direction);
    if (dutOut.direction != 32'hFF00FF00) $error("Expected dutOut.direction to be %08x but got %08x.", 32'hFF00FF00, dutOut.direction);
    if (IO_IN  != 32'hxxFFxxFF) $error("Expected IO_IN to be %08x but got %08x.", 32'hxxFFxxFF, IO_IN);
    if (IO_OUT != 32'h00zz00zz) $error("Expected IO_OUT to be %08x but got %08x.", 32'h00zz00zz, IO_OUT);

    simulatedIOInput = 32'h12345678;
    dataIn = 32'hFFFFFFFF;
    writeIO = 1;
    #10
    clk = 1;
    #10
    clk = 0;

    dataIn = 32'h0;
    writeIO = 0;

    #10
    clk = 1;
    #10
    clk = 0;

    if (dutIn.direction != 32'hFF00FF00)  $error("Expected dutIn.direction to be %08x but got %08x." , 32'hFF00FF00, dutIn.direction);
    if (dutOut.direction != 32'hFF00FF00) $error("Expected dutOut.direction to be %08x but got %08x.", 32'hFF00FF00, dutOut.direction);
    if (IO_IN  != 32'hxx34xx78) $error("Expected IO_IN to be %08x but got %08x.", 32'hxx34xx78, IO_IN);
    if (IO_OUT != 32'hFFzzFFzz) $error("Expected IO_OUT to be %08x but got %08x.", 32'hFFzzFFzz, IO_OUT);

    $finish;
  end


  assign IO_IN  = simulatedIOInput;
endmodule

