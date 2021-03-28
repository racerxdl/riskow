module Comparator (
  input         [3:0]   operation,
  input         [31:0]  X,
  input         [31:0]  Y,
  output        [31:0]  O
);

// Comparator Operations
// Matches funct3 from RISC-V ISA

parameter Equal = 4'h0;
parameter NotEqual = 4'h1;
parameter LesserThanSigned = 4'h4;
parameter GreaterThanOrEqualSigned = 4'h5;
parameter LesserThanUnsigned = 4'h6;
parameter GreaterThanOrEqualUnsigned = 4'h7;

reg [31:0] result;

integer i;

always @(*)
begin
  case (operation)
    LesserThanUnsigned:         result = X <  Y;
    LesserThanSigned:           result = $signed(X) < $signed(Y);
    GreaterThanOrEqualUnsigned: result = X >= Y;
    GreaterThanOrEqualSigned:   result = $signed(X) >= $signed(Y);
    Equal:                      result = X == Y;
    NotEqual:                   result = X != Y;
    default:                    result = 0;
  endcase
end

assign O = result;

endmodule

