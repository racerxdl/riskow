module InstructionDecoder (
  input   wire          clk,
  input   wire          reset,

  // BUS
  input   wire  [31:0]  dataIn,
  output  reg   [31:0]  dataOut,
  output  reg   [31:0]  address,
  output  reg           busWriteEnable,     // 1 => WRITE, 0 => READ

  // PC Control
  input   wire  [31:0]  pcDataOut,
  output  reg           pcWriteEnable,
  output  reg           pcWriteAdd,
  output  reg           pcCountEnable,
  output  reg   [31:0]  pcDataIn,

  // Register Bank Control
  output  reg   [31:0]  regIn,
  input   wire  [31:0]  regOut,
  output  reg   [3:0]   regNum,
  output  reg           regWriteEnable,

  // ALU Control
  input   wire  [31:0]   aluO,
  output  reg   [3:0]    aluOp,
  output  reg   [31:0]   aluX,
  output  reg   [31:0]   aluY
);

localparam Fetch0   = 4'h0;
localparam Fetch1   = 4'h1;
localparam Decode   = 4'h2;
localparam Execute0 = 4'h3;
localparam Execute1 = 4'h4;
localparam Execute2 = 4'h5;
localparam Execute3 = 4'h6;
localparam Execute4 = 4'h7;
localparam Execute5 = 4'h8;

reg   [3:0]  currentState;

// Input alias
wire  [6:0]  inputOpcode = dataIn[6:0];
wire  [2:0]  inputFunct3 = dataIn[14:12];
wire  [6:0]  inputFunct7 = dataIn[31:25];
wire  [4:0]  inputRd     = dataIn[11:7];
wire  [4:0]  inputRs1    = dataIn[19:15];
wire  [4:0]  inputRs2    = dataIn[24:20];
wire  [11:0] immTypeI    = dataIn[31:20];
wire  [11:0] immTypeS    = {dataIn[31:25], dataIn[11:7]};
wire  [12:0] immTypeB    = {dataIn[31], dataIn[7], dataIn[30:25], dataIn[11:8], 1'b0};
wire  [19:0] immTypeU    = dataIn[31:12];
wire  [19:0] immTypeJ    = {dataIn[31], dataIn[19:12], dataIn[20], dataIn[30:12], 1'b0};

// Instruction Arguments
reg   [4:0]   rs1;
reg   [4:0]   rs2;
reg   [4:0]   rd;
reg   [31:0]  imm;

// Instruction
reg   [6:0]   opcode;
reg   [2:0]   funct3;
reg   [6:0]   funct7;
reg   [31:0]  tmpInstruction; // Only used in simulation

always @(posedge clk)
begin
  if (reset)
  begin
    // Instruction Decoder
    currentState    <= Fetch0;
    rs1             <= 0;
    rs2             <= 0;
    rd              <= 0;
    imm             <= 0;

    opcode          <= 0;
    funct3          <= 0;
    funct7          <= 0;
    tmpInstruction  <= 0;

    // BUS
    dataOut         <= 0;
    address         <= 0;
    busWriteEnable  <= 0;

    // ALU
    aluX            <= 0;
    aluY            <= 0;
    aluOp           <= 0;

    // Program Counter
    pcCountEnable   <= 0;
    pcWriteEnable   <= 0;
    pcDataIn        <= 0;
    pcWriteAdd      <= 0;

    // Register Bank
    regIn           <= 0;
    regNum          <= 0;
    regWriteEnable  <= 0;
  end
  else
  begin
    if (currentState == Fetch0)        //  1. Set Bus Address = PC, Set PC Count = 1
    begin
        address       <= pcDataOut;
        pcCountEnable <= 1;
        currentState  <= Fetch1;
    end
    else if (currentState == Fetch1)
    begin
      // Disable Program Counter Count
      pcCountEnable   <= 0;
      // BUS Data should be ready in next cycle
      currentState    <= Decode;
    end
    else if (currentState == Decode)  //  2. READ Bus Data -> Instruction Holder, Set PC Count = 0
    begin

      // Decode Instruction
      tmpInstruction  <= dataIn;
      opcode          <= inputOpcode;
      funct3          <= inputFunct3;
      funct7          <= inputFunct7;
      rd              <= inputRd;
      rs1             <= inputRs1;
      rs2             <= inputRs2;

      // Decode IMM where relevant
      if (inputOpcode == 7'b0010011 || inputOpcode == 7'b1100111)       // Type I instructions
      begin
        if (inputFunct3 == 3'b001 || inputFunct3 == 3'b101) // Direct
          imm <= immTypeI;
        else // Sign Extend
          imm <= { {20{immTypeI[11]}}, immTypeI[11:0] };
      end
      else if (inputOpcode == 7'b0100011)                          // Type S instructions
      begin
          imm <= { {20{immTypeS[11]}}, immTypeS[11:0] };
      end
      else if (inputOpcode == 7'b1100011)                          // Type B instructions
      begin
          imm <= { {19{immTypeB[12]}}, immTypeB[12:0] };
      end
      else if (inputOpcode == 7'b0010111 || inputOpcode == 7'b0110111)  // Type U instructions
      begin
          imm <= { immTypeU[19:0], 11'b0 };
      end
      else if (inputOpcode == 7'b1101111)                          // Type J instructions
      begin
          imm <= { {11{immTypeJ[19]}}, immTypeJ[19:0] };
      end
      currentState  <= Execute0;
    end
    else // Execute State
    begin
        if (opcode == 7'b0010011) // addi, slti, sltiu, xori, ori, andi, slli, srli, srai
        begin
          case (currentState)
            Execute0: // 3. Set regNum = rs1, Set ALU OP = CORRECT OPER, Set ALU Y = IMM
            begin
              regNum          <= rs1;
              case (funct3)
                0: aluOp      <= alu.ADD;
                1: aluOp      <= alu.ShiftLeftUnsigned;
                2: aluOp      <= alu.LesserThanSigned;
                3: aluOp      <= alu.LesserThanUnsigned;
                4: aluOp      <= alu.XOR;
                5: aluOp      <= imm[10] ? alu.ShiftRightSigned : alu.ShiftRightUnsigned;
                6: aluOp      <= alu.OR;
                7: aluOp      <= alu.AND;
              endcase
              aluY            <= funct3 == 5 ? {27'b0, imm[4:0]} : imm;
              currentState    <= currentState + 1;
            end
            Execute1: // 4. Read regOut store in ALU X, Set regNum = rd
            begin
              aluX            <= regOut;
              regNum          <= rd;
              currentState    <= currentState + 1;
            end
            Execute2: // 5. Read ALU O store in regIn, Set regWriteEnable = 1
            begin
              regIn           <= aluO;
              regWriteEnable  <= 1;
              currentState    <= currentState + 1;
            end
            Execute3: // 6. Set regWriteEnable = 0
            begin
              regWriteEnable  <= 0;
              currentState    <= Fetch0;
            end
          endcase
        end
        else if (opcode == 7'b0110011) // add, sub, sll, slt, sltu, xor, srl, sra, or, and
        begin
          case (currentState)
            Execute0: // 3. Set regNum = rs1, Set ALU OP = CORRECT OPER
            begin
              regNum          <= rs1;
              case (funct3)
                0: aluOp      <= funct7[5] ? alu.SUB : alu.ADD;
                1: aluOp      <= alu.ShiftLeftUnsigned;
                2: aluOp      <= alu.LesserThanSigned;
                3: aluOp      <= alu.LesserThanUnsigned;
                4: aluOp      <= alu.XOR;
                5: aluOp      <= funct7[5] ? alu.ShiftRightSigned : alu.ShiftRightUnsigned;
                6: aluOp      <= alu.OR;
                7: aluOp      <= alu.AND;
              endcase
              currentState    <= currentState + 1;
            end
            Execute1: // 4. Read regOut store in ALU X, Set regNum = rs2
            begin
              aluX            <= regOut;
              regNum          <= rs2;
              currentState    <= currentState + 1;
            end
            Execute2: // 5. Read regOut store in ALU Y, Set regNum = rd
            begin
              aluY            <= regOut;
              regNum          <= rd;
              currentState    <= currentState + 1;
            end
            Execute3: // 6. Read ALU O store in regIn, Set regWriteEnable = 1
            begin
              regIn           <= aluO;
              regWriteEnable  <= 1;
              currentState    <= currentState + 1;
            end
            Execute4: // 7. Set regWriteEnable = 0
            begin
              regWriteEnable  <= 0;
              currentState    <= Fetch0;
            end
          endcase
        end
        else if (opcode == 7'b1100011) // beq, bne, blt, bge, bltu, bgeu
        begin
          case (currentState)
            Execute0: // 3. Set regNum = rs1, Set ALU OP = CORRECT OPER
            begin
              regNum          <= rs1;
              case (funct3)
                0: aluOp      <= alu.Equal;
                1: aluOp      <= alu.NotEqual;
                4: aluOp      <= alu.LesserThanSigned;
                5: aluOp      <= alu.GreaterThanOrEqualSigned;
                6: aluOp      <= alu.LesserThanUnsigned;
                7: aluOp      <= alu.GreaterThanOrEqualUnsigned;
              endcase
              currentState    <= currentState + 1;
            end
            Execute1: // 4. Read regOut store in ALU X, Set regNum = rs2
            begin
              aluX            <= regOut;
              regNum          <= rs2;
              currentState    <= currentState + 1;
            end
            Execute2: // 5. Read regOut store in ALU Y
            begin
              aluY            <= regOut;
              currentState    <= currentState + 1;
            end
            Execute3: // 6. If ALU O[0], pcWriteEnable = 1, pcWriteAdd = 1, pcDataIn = offset
            begin
              if (aluO[0])
              begin
                pcWriteEnable <= 1;
                pcWriteAdd    <= 1;
                pcDataIn      <= imm;
                currentState  <= currentState + 1;
              end
              else
                currentState  <= Fetch0;
            end
            Execute4:
            begin
                pcWriteEnable <= 0;
                pcWriteAdd    <= 0;
                currentState  <= Fetch0;
            end
          endcase
        end
    end
  end
end

/*
imm[12|10:5]          rs2   rs1 000 imm[4:1|11] 1100011 B beq     || if (rs1 == rs2) pc += sext(offset)
imm[12|10:5]          rs2   rs1 001 imm[4:1|11] 1100011 B bne     || if (rs1 != rs2) pc += sext(offset)
imm[12|10:5]          rs2   rs1 100 imm[4:1|11] 1100011 B blt     || if (rs1 < rs2)  pc += sext(offset)   [  SIGNED  ]
imm[12|10:5]          rs2   rs1 101 imm[4:1|11] 1100011 B bge     || if (rs1 ≥ rs2)  pc += sext(offset)   [  SIGNED  ]
imm[12|10:5]          rs2   rs1 110 imm[4:1|11] 1100011 B bltu    || if (rs1 < rs2)  pc += sext(offset)   [ UNSIGNED ]
imm[12|10:5]          rs2   rs1 111 imm[4:1|11] 1100011 B bgeu    || if (rs1 ≥ rs2)  pc += sext(offset)   [ UNSIGNED ]
    3. Set regNum = rs1, Set ALU OP = CORRECT OPER
    4. Read regOut store in ALU X, Set regNum = rs2
    5. Read regOut store in ALU Y
    6. If ALU O[0], pcWriteEnable = 1, pcWriteAdd = 1, pcDataIn = offset
    7. Set pcWriteEnable = 0, pcWriteAdd = 0
*/

endmodule
