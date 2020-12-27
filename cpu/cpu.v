module CPU (
  input   wire          clk,
  input   wire          reset,

  // BUS
  input         [31:0]  dataIn,
  output  wire  [31:0]  dataOut,
  output  wire  [31:0]  address,
  output                busWriteEnable     // 1 => WRITE, 0 => READ
);

// Program Counter
wire  [31:0]   pcOut;
wire  [31:0]   pcDataIn;
wire           pcWriteEnable;
wire           pcCountEnable;
ProgramCounter PC(clk, reset, pcDataIn, pcOut, pcWriteEnable, pcCountEnable);

// Register Bank
wire  [31:0]  regIn;
wire  [31:0]  regOut;
wire  [3:0]   regNum;
wire          regWriteEnable;
RegisterBank registers(clk, reset, regIn, regOut, regNum, regWriteEnable);

// ALU
wire  [3:0]   aluOp;
wire  [31:0]  aluX;
wire  [31:0]  aluY;
wire  [31:0]  aluO;
ALU alu(aluOp, aluX, aluY, aluO);

// Instruction Decoder
InstructionDecoder ins(
  // Global Control
  clk,
  reset,

  // BUS
  dataIn,
  dataOut,
  address,
  busWriteEnable,

  // PC Control
  pcOut,
  pcWriteEnable,
  pcCountEnable,
  pcDataIn,

  // Register Bank Control
  regIn,
  regOut,
  regNum,
  regWriteEnable,

  // ALU Control
  aluO,
  aluOp,
  aluX,
  aluY
);

endmodule