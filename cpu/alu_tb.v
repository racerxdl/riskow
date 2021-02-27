`timescale 1 ns/1 ns  // time-unit = 1 ns, precision = 10 ps

module ALUTest;

  localparam ms = 1e6;
  localparam us = 1e3;
  localparam numIterations = 32;

  integer i;

  reg   [3:0]   operation;
  reg   [31:0]  X;
  reg   [31:0]  Y;
  wire  [31:0]  O;

  // Our device under test
  ALU dut(operation, X, Y, O);

  initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, ALUTest);
    operation = 0;
    X = 0;
    Y = 0;

    // Test operation ADD
    operation = dut.ADD;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != (X + Y)) $error("Expected O to be %d but got %d.", X + Y, O);
    end

    // Test operation SUB
    operation = dut.SUB;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != (X - Y)) $error("Expected O to be %d but got %d.", X - Y, O);
    end

    // Test operation OR
    operation = dut.OR;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != (X | Y)) $error("Expected O to be %d but got %d.", X | Y, O);
    end

    // Test operation XOR
    operation = dut.XOR;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != (X ^ Y)) $error("Expected O to be %d but got %d.", X ^ Y, O);
    end

    // Test operation AND
    operation = dut.AND;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != (X & Y)) $error("Expected O to be %d but got %d.", X & Y, O);
    end

    // Test operation LesserThanUnsigned
    operation = dut.LesserThanUnsigned;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != (X < Y)) $error("Expected O to be %d but got %d.", X < Y, O);
    end

    // Test operation LesserThanSigned
    operation = dut.LesserThanSigned;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != ($signed(X) < $signed(Y))) $error("Expected O to be %d but got %d.", $signed(X) < $signed(Y), O);
    end

    // Test operation ShiftRightUnsigned
    operation = dut.ShiftRightUnsigned;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != (X >> (Y % 32))) $error("Expected O to be %d but got %d.", X >> (Y % 32), O);
    end

    // Test operation ShiftLeftUnsigned
    operation = dut.ShiftLeftUnsigned;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != (X << (Y % 32))) $error("Expected O to be %d but got %d.", X << (Y % 32), O);
    end

    // Test operation ShiftRightSigned
    operation = dut.ShiftRightSigned;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != $unsigned($signed(X) >>> (Y % 32))) $error("Expected O to be %d but got %d.", $signed(X) >>> (Y % 32), O);
    end

    // Test operation ShiftLeftSigned
    operation = dut.ShiftLeftSigned;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != $unsigned($signed(X) <<< (Y % 32))) $error("Expected O to be %d but got %d.", $signed(X) <<< (Y % 32), O);
    end

    // Test operation GreaterThanOrEqualUnsigned
    operation = dut.GreaterThanOrEqualUnsigned;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != (X >= Y)) $error("Expected O to be %d but got %d.", X >= Y, O);
    end

    // Test operation GreaterThanOrEqualUnsigned
    operation = dut.GreaterThanOrEqualSigned;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != ($signed(X) >= $signed(Y))) $error("Expected O to be %d but got %d.", $signed(X) >= $signed(Y), O);
    end

    // Test operation Equal
    operation = dut.Equal;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != (X == Y)) $error("Expected O to be %d but got %d.", (X == Y), O);
    end

    // Test operation NotEqual
    operation = dut.NotEqual;
    for (i = 0; i < numIterations; i=i+1)
    begin
      X = $random;
      Y = $random;
      #10
      if (O != (X != Y)) $error("Expected O to be %d but got %d.", (X != Y), O);
    end


    #100

    $finish;
  end
endmodule
