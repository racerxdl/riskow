module InstructionDecoder (
  input   wire          clk,
  input   wire          reset,

  // BUS
  input   wire  [31:0]  dataIn,
  output  reg   [31:0]  dataOut,
  output  reg   [31:0]  address,
  output                busWriteEnable,     // 1 => WRITE, 0 => READ

  // PC Control
  input   wire  [31:0]  pcDataOut,
  output  reg           pcWriteEnable,
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


localparam Fetch   = 3'b000;
localparam Decode  = 3'b001;
localparam Execute = 3'b010;

reg   [2:0]  currentState;

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

always @(posedge clk)
begin
  if (reset)
  begin
    currentState <= Fetch;
  end
  else
  begin
    if (currentState == Fetch)        //  1. Set Bus Address = PC, Set PC Count = 1
    begin
        address       <= pcDataIn;
        pcCountEnable <= 1;
        currentState  <= Decode;
    end
    else if (currentState == Decode)  //  2. READ Bus Data -> Instruction Holder, Set PC Count = 0
    begin
      // Disable Program Counter Count
      pcCountEnable <= 0;

      // Decode Instruction
      opcode        <= inputOpcode;
      funct3        <= inputFunct3;
      funct7        <= inputFunct7;
      rd            <= inputRd;
      rs1           <= inputRs1;
      rs2           <= inputRs2;

      // Decode IMM where relevant
      if (opcode == 7'b0010011 || opcode == 7'b1100111)       // Type I instructions
      begin
        if (funct3 == 3'b001 || funct3 == 3'b101) // Direct
          imm <= immTypeI;
        else // Sign Extend
          imm <= { {20{immTypeI[11]}}, immTypeI[11:0] };
      end
      else if (opcode == 7'b0100011)                          // Type S instructions
      begin
          imm <= { {20{immTypeS[11]}}, immTypeS[11:0] };
      end
      else if (opcode == 7'b1100011)                          // Type B instructions
      begin
          imm <= { {19{immTypeB[12]}}, immTypeB[12:0] };
      end
      else if (opcode == 7'b0010111 || opcode == 7'b0110111)  // Type U instructions
      begin
          imm <= { immTypeU[19:0], 11'b0 };
      end
      else if (opcode == 7'b1101111)                          // Type J instructions
      begin
          imm <= { {11{immTypeJ[19]}}, immTypeJ[19:0] };
      end
      currentState  <= Execute;
    end
    else // Execute State
    begin
        if (opcode == 7'b0010011) // addi, slti, sltiu, xori, ori, andi, slli, srli, srai
        begin
          case (currentState)
            3: // 3. Set regNum = rs1, Set ALU OP = CORRECT OPER, Set ALU Y = IMM
            begin
              regNum          <= rs1;
              case (funct3)
                0: aluOp      <= alu.ADD;
                1: aluOp      <= alu.ShiftLeftUnsigned;
                2: aluOp      <= alu.LesserThanSigned;
                3: aluOp      <= alu.LesserThanUnsigned;
                4: aluOp      <= alu.XOR;
                5: aluOp      <= imm[30] ? alu.ShiftRightSigned : alu.ShiftRightUnsigned;
                6: aluOp      <= alu.OR;
                7: aluOp      <= alu.AND;
              endcase
              aluY            <= funct3 == 5 ? {27'b0, imm[4:0]} : imm;
              currentState    <= currentState + 1;
            end
            4: // 4. Read regOut store in ALU X, Set regNum = rd
            begin
              aluX            <= regOut;
              regNum          <= rd;
              currentState    <= currentState + 1;
            end
            5: // 5. Read ALU O store in regIn, Set regWriteEnable = 1
            begin
              regIn           <= aluO;
              regWriteEnable  <= 1;
              currentState    <= currentState + 1;
            end
            6: // 6. Set regWriteEnable = 0
            begin
              regWriteEnable  <= 0;
              currentState    <= Fetch;
            end
          endcase
        end
        else if (opcode == 7'b0110011) // add, sub, sll, slt, sltu, xor, srl, sra, or, and
        begin
          case (currentState)
            3: // 3. Set regNum = rs1, Set ALU OP = CORRECT OPER
            begin
              regNum          <= rs1;
              case (funct3)
                0: aluOp      <= imm[30] ? alu.ADD : alu.SUB;
                1: aluOp      <= alu.ShiftLeftUnsigned;
                2: aluOp      <= alu.LesserThanSigned;
                3: aluOp      <= alu.LesserThanUnsigned;
                4: aluOp      <= alu.XOR;
                5: aluOp      <= imm[30] ? alu.ShiftRightSigned : alu.ShiftRightUnsigned;
                6: aluOp      <= alu.OR;
                7: aluOp      <= alu.AND;
              endcase
              currentState    <= currentState + 1;
            end
            4: // 4. Read regOut store in ALU X, Set regNum = rs2
            begin
              aluX            <= regOut;
              regNum          <= rs2;
              currentState    <= currentState + 1;
            end
            5: // 5. Read regOut store in ALU Y, Set regNum = rd
            begin
              aluY            <= regOut;
              regNum          <= rd;
              currentState    <= currentState + 1;
            end
            6: // 6. Read ALU O store in regIn, Set regWriteEnable = 1
            begin
              regIn           <= aluO;
              regWriteEnable  <= 1;
              currentState    <= currentState + 1;
            end
            7: // 7. Set regWriteEnable = 0
            begin
              regWriteEnable  <= 0;
              currentState    <= Fetch;
            end
          endcase
        end
    end
  end
end


endmodule
