module ALU (
  input         [3:0]   operation,
  input         [31:0]  X,
  input         [31:0]  Y,
  output        [31:0]  O
);

// ALU Operations
parameter ADD = 4'h0;
parameter SUB = 4'h1;
parameter OR = 4'h2;
parameter XOR = 4'h3;
parameter AND = 4'h4;
parameter LesserThanUnsigned = 4'h5;
parameter LesserThanSigned = 4'h6;
parameter ShiftRightUnsigned = 4'h7;
parameter ShiftRightSigned = 4'h8;
parameter ShiftLeftUnsigned = 4'h9;
parameter ShiftLeftSigned = 4'hA;
parameter GreaterThanOrEqualUnsigned = 4'hB;
parameter GreaterThanOrEqualSigned = 4'hC;
parameter Equal = 4'hD;
parameter NotEqual = 4'hE;

reg [31:0] result;

always @(*)
begin
  case (operation)
    ADD:                        result = X +  Y;
    SUB:                        result = X -  Y;
    OR:                         result = X |  Y;
    XOR:                        result = X ^  Y;
    AND:                        result = X &  Y;
    LesserThanUnsigned:         result = X <  Y;
    LesserThanSigned:           result = $signed(X) < $signed(Y);
    ShiftRightUnsigned:         result = X >> (Y[4:0]);
    ShiftRightSigned:           result = $signed(X) >>> (Y[4:0]);
    ShiftLeftUnsigned:          result = X << (Y[4:0]);
    ShiftLeftSigned:            result = $signed(X) <<< (Y[4:0]);
    GreaterThanOrEqualUnsigned: result = X >= Y;
    GreaterThanOrEqualSigned:   result = $signed(X) >= $signed(Y);
    Equal:                      result = X == Y;
    NotEqual:                   result = X != Y;
    // default:                    result = 0;
  endcase
end

assign O = result;

endmodule

