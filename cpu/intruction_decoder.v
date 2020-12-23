module InstructionDecoder (
  input   wire          clk,
  input   wire          reset,

  // BUS
  input         [31:0]  dataIn,
  output  wire  [31:0]  dataOut,
  output  wire  [31:0]  address,
  output                busWriteEnable,     // 1 => WRITE, 0 => READ

  // PC Control
  input         [31:0]  pcDataOut,
  output  wire          pcWriteEnable,
  output  wire          pcCountEnable,
  output  wire  [31:0]  pcDataIn,

  // Register Bank Control
  output  wire  [31:0]  regIn,
  input         [31:0]  regOut,
  output  wire  [3:0]   regNum,
  output  wire          regWriteEnable,

  // ALU Control
  input         [31:0]   aluO,
  output  wire  [3:0]    aluOp,
  output  wire  [31:0]   aluX,
  output  wire  [31:0]   aluY,
);




endmodule