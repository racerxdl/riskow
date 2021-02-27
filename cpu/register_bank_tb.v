`timescale 1 ns/1 ns  // time-unit = 1 ns, precision = 10 ps

module RegisterBankTest;

  localparam ms = 1e6;
  localparam us = 1e3;

  integer i, j;

  reg           clk = 0;
  reg           reset = 0;
  reg   [31:0]  dataIn;
  wire  [31:0]  dataOut;
  reg   [3:0]   regNum;
  reg           writeEnable;     // 1 => WRITE, 0 => READ

  // Our device under test
  RegisterBank dut(clk, reset, dataIn, dataOut, regNum, writeEnable);

  initial begin
    $dumpfile("register_bank_tb.vcd");
    $dumpvars(0, RegisterBankTest);
    // Set Reset conditions
    clk = 0;
    reset = 1;
    dataIn = 0;
    regNum = 0;
    writeEnable = 0;

    // Pulse Clock
    #10
    clk = 1;
    #10
    clk = 0;

    // Test reset
    if (dataOut != 0) $error("Expected dataOut to be %d but got %d.", 0, dataOut);
    for (i = 1; i < 16; i=i+1)
    begin
      if (dut.registers[i] != 0) $error("Expected registers[%d] to be %d but got %d.", i, 0, dut.registers[i]);
    end

    for (i = 1; i < 16; i=i+1)
    begin
      // Reset
      clk = 0;
      reset = 1;
      dataIn = 0;
      regNum = 0;
      writeEnable = 0;

      // Pulse Clock
      #10
      clk = 1;
      #10
      clk = 0;

      // Set Register Value
      dataIn = 32'hFFFFFFFF;
      reset = 0;
      regNum = i;
      writeEnable = 1;

      // Pulse Clock
      #10
      clk = 1;
      #10
      clk = 0;

      // Verify Registers Internally
      for (j = 0; j < 16; j=j+1)
      begin
        if (j == i)
        begin
          if (dut.registers[j] != 32'hFFFFFFFF) $error("Expected registers[%d] to be %d but got %d.", j, 32'hFFFFFFFF, dut.registers[j]);
        end
        else
        begin
          if (dut.registers[j] != 0) $error("Expected registers[%d] to be %d but got %d.", j, 0, dut.registers[j]);
        end
      end

      // Test Read Only
      writeEnable = 0;
      dataIn = 32'hF0F0F0F0;

      // Pulse Clock
      #10
      clk = 1;
      #10
      clk = 0;

      if (dataOut != 32'hFFFFFFFF)
        $error("Expected dataOut to be %d but got %d.", 32'hFFFFFFFF, dataOut);
      if (dut.registers[i] != 32'hFFFFFFFF)
        $error("Expected registers[%d] to be %d but got %d.", 32'hFFFFFFFF, i, dut.registers[i]);
    end

    #100

    $finish;
  end
endmodule