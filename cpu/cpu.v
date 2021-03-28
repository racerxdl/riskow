module CPU (
  input   wire          clk,
  input   wire          reset,

  // BUS
  input         [31:0]  dataIn,
  output  wire  [31:0]  dataOut,
  output  wire  [31:0]  address,
  output  wire          busValid,          // 1 => Start bus transaction, 0 => Don't use bus
  output  wire          busInstr,          // 1 => Instruction, 0 => Data
  input   wire          busReady,          // 1 => Bus is ready with data, 0 => If bus is busy
  output                busWriteEnable     // 1 => WRITE, 0 => READ
);

parameter EXCEPTION_HANDLING = 1;

// Program Counter
wire  [31:0]   pcDataOut;
wire  [31:0]   pcDataIn;
wire           pcWriteEnable;
wire           pcWriteAdd;
wire           pcCountEnable;
ProgramCounter PC(clk, reset, pcDataIn, pcDataOut, pcWriteEnable, pcWriteAdd, pcCountEnable);

// Register Bank
wire  [31:0]  regIn0;
wire  [31:0]  regOut0;
wire  [3:0]   regNum0;
wire          regWriteEnable0;
wire  [31:0]  regIn1;
wire  [31:0]  regOut1;
wire  [3:0]   regNum1;
wire          regWriteEnable1;
DPRegisterBank registers(
  clk, 
  reset,
  // Port 0 
  regIn0, 
  regOut0, 
  regNum0, 
  regWriteEnable0, 

  // Port 1
  regIn1, 
  regOut1, 
  regNum1, 
  regWriteEnable1
);

// ALU
wire  [3:0]   aluOp;
wire  [31:0]  aluX;
wire  [31:0]  aluY;
wire  [31:0]  aluO;
ALU alu(aluOp, aluX, aluY, aluO);

// Instruction Decoder
InstructionDecoder # (
  .EXCEPTION_HANDLING(EXCEPTION_HANDLING)
) ins (
  // Global Control
  clk,
  reset,

  // BUS
  dataIn,
  dataOut,
  address,
  busValid,
  busInstr,
  busReady,
  busWriteEnable,

  // PC Control
  pcDataOut,
  pcWriteEnable,
  pcWriteAdd,
  pcCountEnable,
  pcDataIn,

  // Register Bank Control
  // Port 0 
  regIn0, 
  regOut0, 
  regNum0, 
  regWriteEnable0, 

  // Port 1
  regIn1, 
  regOut1, 
  regNum1, 
  regWriteEnable1,

  // ALU Control
  aluO,
  aluOp,
  aluX,
  aluY
);

endmodule