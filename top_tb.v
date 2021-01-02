`timescale 1 ns/1 ns  // time-unit = 1 ns, precision = 10 ps

module RiskowTest;

  localparam ms = 1e6;
  localparam us = 1e3;

  integer i, j;
  reg                 clk;
  reg                 reset;
  wire        [31:0]  IOPortA;
  wire        [31:0]  IOPortB;

  generate
    genvar idx;
    for(idx = 0; idx < 32; idx = idx+1) begin: register
      assign IOPortA[idx] = dut.portA.direction[idx] ? 1'bZ : 1'b1;
      assign IOPortB[idx] = dut.portB.direction[idx] ? 1'bZ : 1'b1;
    end
  endgenerate

  // Our device under test
  Riskow dut(clk, reset, IOPortA, IOPortB);

  initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, RiskowTest);

    $readmemh("gcc/rom.mem", dut.ROM);
    $readmemh("gcc/excp.mem", dut.EXCP);

    for (i = 0; i < 8192; i++)
    begin
      dut.RAM[i] = 0;
    end

    reset = 1;
    clk = 0;

    #10
    clk = 1;
    #10
    clk = 0;

    reset = 0;

    repeat(1000000)
    begin
      #10
      clk = 1;
      #10
      clk = 0;
    end

    $finish;
  end

endmodule

