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

reg [31:0] result;

integer i;

always @(*)
begin
  case (operation)
    ADD:                result = X +  Y;
    SUB:                result = X -  Y;
    OR:                 result = X |  Y;
    XOR:                result = X ^  Y;
    AND:                result = X &  Y;
    LesserThanUnsigned: result = X <  Y;
    LesserThanSigned:   result = $signed(X) < $signed(Y);
    ShiftRightUnsigned: X >> (Y % 32);                    //for (i=0; i < 32; i++) if (i == Y[4:0]) result = X >> i;            // OMG THATS HORRIBLE
    ShiftRightSigned:   $signed(X) >>> (Y % 32);          //for (i=0; i < 32; i++) if (i == Y[4:0]) result = $signed(X) >>> i;  // OMG THATS HORRIBLE
    ShiftLeftUnsigned:  X << (Y % 32);                    //for (i=0; i < 32; i++) if (i == Y[4:0]) result = X << i;            // OMG THATS HORRIBLE
    ShiftLeftSigned:    $signed(X) <<< (Y % 32);          //for (i=0; i < 32; i++) if (i == Y[4:0]) result = $signed(X) <<< i;  // OMG THATS HORRIBLE
    default:            result = 0;
  endcase
end

assign O = result;

endmodule

/*
---- ALU Operations       ---
0:  ADD
1:  SUB
2:  OR
3:  XOR
4:  AND
5:  Lesser Than Unsigned
6:  Lesser Than Signed
7:  Shift Right Unsigned
8:  Shift Right Signed
9:  Shift Left Unsigned
10: Shift Left Signed

---- Processor Operations ---

imm[11:0]       rs1 000 rd 0010011 I addi     x[rd] = x[rs1] +   sext(immediate)
imm[11:0]       rs1 010 rd 0010011 I slti     x[rd] = x[rs1] <   sext(immediate)    signed
imm[11:0]       rs1 011 rd 0010011 I sltiu    x[rd] = x[rs1] <   sext(immediate)  unsigned
imm[11:0]       rs1 100 rd 0010011 I xori     x[rd] = x[rs1] ^   sext(immediate)
imm[11:0]       rs1 110 rd 0010011 I ori      x[rd] = x[rs1] |   sext(immediate)
imm[11:0]       rs1 111 rd 0010011 I andi     x[rd] = x[rs1] &   sext(immediate)
0000000   shamt rs1 001 rd 0010011 I slli     x[rd] = x[rs1] <<  shamt
0000000   shamt rs1 101 rd 0010011 I srli     x[rd] = x[rs1] >>  shamt            unsigned
0100000   shamt rs1 101 rd 0010011 I srai     x[rd] = x[rs1] >>  shamt              signed

0000000   rs2   rs1 000 rd 0110011 R add      x[rd] = x[rs1] +  x[rs2]
0100000   rs2   rs1 000 rd 0110011 R sub      x[rd] = x[rs1] -  x[rs2]
0000000   rs2   rs1 001 rd 0110011 R sll      x[rd] = x[rs1] << x[rs2]            unsigned
0000000   rs2   rs1 010 rd 0110011 R slt      x[rd] = x[rs1] <  x[rs2]              signed
0000000   rs2   rs1 011 rd 0110011 R sltu     x[rd] = x[rs1] <  x[rs2]            unsigned
0000000   rs2   rs1 100 rd 0110011 R xor      x[rd] = x[rs1] ˆ  x[rs2]
0000000   rs2   rs1 101 rd 0110011 R srl      x[rd] = x[rs1] >> x[rs2]            unsigned
0100000   rs2   rs1 101 rd 0110011 R sra      x[rd] = x[rs1] >> x[rs2]              signed
0000000   rs2   rs1 110 rd 0110011 R or       x[rd] = x[rs1] |  x[rs2]
0000000   rs2   rs1 111 rd 0110011 R and      x[rd] = x[rs1] &  x[rs2]
 */
