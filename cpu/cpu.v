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
  output                busWriteEnable,    // 1 => WRITE, 0 => READ

  // CSR
  input        [31:0]   csrDataIn,
  output       [31:0]   csrDataOut,
  output       [11:0]   csrNumber,
  output                csrWriteEnable,

  // Core CSRs
  output  wire [63:0]   instructionsExecuted
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
wire  [31:0]  regOut0;
wire  [3:0]   regNum0;

wire  [31:0]  regOut1;
wire  [3:0]   regNum1;

wire  [31:0]  wDataIn;
wire  [3:0]   wRegNum;
wire          writeEnable;

RegisterBank registers(
  .clk(clk),
  .reset(reset),
  // Port 0
  .dataOut0(regOut0),
  .regNum0(regNum0),

  // Port 1
  .dataOut1(regOut1),
  .regNum1(regNum1),

  // Write Port
  .wDataIn(wDataIn),
  .wRegNum(wRegNum),
  .writeEnable(writeEnable)
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
  .clk(clk),
  .reset(reset),

  // BUS
  .dataIn(dataIn),
  .dataOut(dataOut),
  .address(address),
  .busValid(busValid),
  .busInstr(busInstr),
  .busReady(busReady),
  .busWriteEnable(busWriteEnable),

  // PC Control
  .pcDataOut(pcDataOut),
  .pcWriteEnable(pcWriteEnable),
  .pcWriteAdd(pcWriteAdd),
  .pcCountEnable(pcCountEnable),
  .pcDataIn(pcDataIn),

  // Register Bank Control
  // Port 0
  .regOutA(regOut0),
  .regNumA(regNum0),

  // Port 1
  .regOutB(regOut1),
  .regNumB(regNum1),

  // Write Port
  .wRegDataIn(wDataIn),
  .wRegRegNum(wRegNum),
  .wRegWriteEnable(writeEnable),

  // ALU Control
  .aluO(aluO),
  .aluOp(aluOp),
  .aluX(aluX),
  .aluY(aluY),

  // CSR
  .csrDataIn(csrDataIn),
  .csrDataOut(csrDataOut),
  .csrNumber(csrNumber),
  .csrWriteEnable(csrWriteEnable),

  // Core CSRs
  .instructionsExecuted(instructionsExecuted)
);

endmodule