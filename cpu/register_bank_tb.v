`timescale 1 ns/1 ns  // time-unit = 1 ns, precision = 10 ps

module RegisterBankTest;

  localparam ms = 1e6;
  localparam us = 1e3;

  integer i, j;

  reg           clk = 0;
  reg           reset = 0;
  wire  [31:0]  dataOut0;
  wire  [31:0]  dataOut1;
  reg   [3:0]   regNum0;
  reg   [3:0]   regNum1;
  reg   [3:0]   wRegNum;
  reg   [31:0]  wDataIn;
  reg           writeEnable;     // 1 => WRITE, 0 => READ

  // Our device under test
  RegisterBank dut(clk, reset, dataOut0, regNum0, dataOut1, regNum1, wDataIn, wRegNum, writeEnable);

  initial begin
    $dumpfile("register_bank_tb.vcd");
    $dumpvars(0, RegisterBankTest);
    // Set Reset conditions
    clk = 0;
    reset = 1;
    wRegNum = 0;
    wDataIn = 0;
    regNum0 = 0;
    regNum1 = 0;
    writeEnable = 0;

    for (i = 1; i < 16; i=i+1)
    begin
      dut.registers[i] = 0;
    end

    // Pulse Clock
    #10
    clk = 1;
    #10
    clk = 0;

    for (i = 1; i < 16; i=i+1)
    begin
      // Reset
      clk = 0;
      reset = 1;
      wDataIn = 0;
      wRegNum = 0;
      writeEnable = 0;

      for (j = 1; j < 16; j=j+1)
      begin
        dut.registers[j] = 0;
      end

      // Pulse Clock
      #10
      clk = 1;
      #10
      clk = 0;

      // Set Register Value
      wDataIn = 32'hFFFFFFFF;
      reset = 0;
      wRegNum = i;
      regNum0 = i;
      regNum1 = i;
      writeEnable = 1;

      // Pulse Clock
      #10
      clk = 1;
      #10
      clk = 0;

      // Verify Registers Internally
      for (j = 1; j < 16; j=j+1)
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
      wDataIn = 32'hF0F0F0F0;

      // Pulse Clock
      #10
      clk = 1;
      #10
      clk = 0;

      if (dataOut0 != 32'hFFFFFFFF)
        $error("Expected dataOut0 to be %d but got %d.", 32'hFFFFFFFF, dataOut0);
      if (dut.registers[i] != 32'hFFFFFFFF)
        $error("Expected registers[%d] to be %d but got %d.", 32'hFFFFFFFF, i, dut.registers[i]);
    end

    #100

    $finish;
  end
endmodule