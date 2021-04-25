module InstructionDecoder (
  input   wire          clk,
  input   wire          reset,

  // BUS
  input   wire  [31:0]  dataIn,
  output  reg   [31:0]  dataOut,
  output  reg   [31:0]  address,
  output  reg           busValid,          // 1 => Start bus transaction, 0 => Don't use bus
  output  reg           busInstr,          // 1 => Instruction, 0 => Data
  input   wire          busReady,          // 1 => Bus is ready with data, 0 => If bus is busy
  output  reg           busWriteEnable,    // 1 => WRITE, 0 => READ

  // PC Control
  input   wire  [31:0]  pcDataOut,
  output  reg           pcWriteEnable,
  output  reg           pcWriteAdd,
  output  reg           pcCountEnable,
  output  reg   [31:0]  pcDataIn,

  // Register Bank Control
  input   wire  [31:0]  regOutA,
  output  reg   [3:0]   regNumA,

  input   wire  [31:0]  regOutB,
  output  reg   [3:0]   regNumB,

  output  reg   [31:0]  wRegDataIn,
  output  reg   [3:0]   wRegRegNum,
  output  reg           wRegWriteEnable,

  // ALU Control
  input   wire  [31:0]   aluO,
  output  reg   [3:0]    aluOp,
  output  reg   [31:0]   aluX,
  output  reg   [31:0]   aluY,

  // CSR
  input   wire [31:0]   csrDataIn,
  output  reg  [31:0]   csrDataOut,
  output  reg  [11:0]   csrNumber,
  output  reg           csrWriteEnable,

  // Core CSRs
  output  reg  [63:0]   instructionsExecuted
);

parameter EXCEPTION_HANDLING = 0;

localparam ADD = 4'h0;
localparam SUB = 4'h1;
localparam OR = 4'h2;
localparam XOR = 4'h3;
localparam AND = 4'h4;
localparam LesserThanUnsigned = 4'h5;
localparam LesserThanSigned = 4'h6;
localparam ShiftRightUnsigned = 4'h7;
localparam ShiftRightSigned = 4'h8;
localparam ShiftLeftUnsigned = 4'h9;
localparam ShiftLeftSigned = 4'hA;
localparam GreaterThanOrEqualUnsigned = 4'hB;
localparam GreaterThanOrEqualSigned = 4'hC;
localparam Equal = 4'hD;
localparam NotEqual = 4'hE;

localparam ExceptionHandlerAddress = 32'h5E_F0DE0;

localparam Fetch0   = 4'h0;
localparam Fetch1   = 4'h1;
localparam Decode   = 4'h2;
localparam Execute0 = 4'h3;
localparam Execute1 = 4'h4;
localparam Execute2 = 4'h5;
localparam Execute3 = 4'h6;

reg   [3:0]  currentState;

// Input alias
wire  [6:0]  inputOpcode      = dataIn[6:0];
wire  [2:0]  inputFunct3      = dataIn[14:12];
wire  [6:0]  inputFunct7      = dataIn[31:25];
wire  [4:0]  inputRd          = dataIn[11:7];
wire  [4:0]  inputRs1         = dataIn[19:15];
wire  [4:0]  inputRs2         = dataIn[24:20];
wire  [11:0] immTypeI         = dataIn[31:20];
wire  [11:0] immTypeS         = {dataIn[31:25], dataIn[11:7]};
wire  [12:0] immTypeB         = {dataIn[31], dataIn[7], dataIn[30:25], dataIn[11:8], 1'b0};
wire  [19:0] immTypeU         = dataIn[31:12];
wire  [19:0] immTypeJ         = {dataIn[31], dataIn[19:12], dataIn[20], dataIn[30:21], 1'b0};
wire  [11:0] csrIns           = dataIn[31:20];
wire  [4:0]  immCsr           = dataIn[19:15];
wire  [31:0] csrOpField       = funct3[2] == 1 ? {27'b0, immCsr} : regOutA;

// Alias for using on load/store
wire  [1:0]  inputByteOffset  = aluO[1:0];
wire  [1:0]  numberOfBytes    = funct3[1:0]; // Actuallly 2^numberOfBytes

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

initial begin
  // For simulation
  rs1                   = 0;
  rs2                   = 0;
  rd                    = 0;
  imm                   = 0;
  funct3                = 0;
  funct7                = 0;
  tmpInstruction        = 0;
  dataOut               = 0;
  address               = 0;
  busWriteEnable        = 0;
  busValid              = 0;
  busInstr              = 0;
  aluX                  = 0;
  aluY                  = 0;
  aluOp                 = 0;
  pcCountEnable         = 0;
  pcWriteEnable         = 0;
  pcDataIn              = 0;
  pcWriteAdd            = 0;
  regNumA               = 0;
  regNumB               = 0;
  wRegDataIn            = 0;
  wRegRegNum            = 0;
  wRegWriteEnable       = 0;
  instructionsExecuted  = 0;
  csrWriteEnable        = 0;
  csrNumber             = 0;
  instructionsExecuted  = 0;

  opcode                = 7'b0110011; // ALU Op (add)
  currentState          = Execute1;
end

always @(posedge clk)
begin
  if (reset)
  begin
    // Instruction Decoder
    rs1             <= 0;
    rs2             <= 0;
    rd              <= 0;
    imm             <= 0;

    funct3          <= 0;
    funct7          <= 0;
    tmpInstruction  <= 0;

    // BUS
    dataOut         <= 0;
    address         <= 0;
    busWriteEnable  <= 0;
    busValid        <= 0;
    busInstr        <= 0;

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
    regNumA         <= 0;
    regNumB         <= 0;

    wRegRegNum      <= 0;
    wRegWriteEnable <= 0;

    // Initial Instruction for Prefetch
    // Can be anything thats NO-OP due init regNumA = x0, regNumB = x0, wRegRegNum = x0
	  // then it will do add x0, x0, x0
    opcode          <= 7'b0110011; // ALU Op (add)
    currentState    <= Execute1;

    // CSR
    instructionsExecuted <= 0;
    csrWriteEnable       <= 0;
  end
  else
  begin
    if (currentState == Fetch0)        //  1. Set Bus Address = PC, Set PC Count = 1
    begin
      pcCountEnable   <= 0;
      pcWriteEnable   <= 0;
      pcWriteAdd      <= 0;
      wRegWriteEnable <= 0;
      csrWriteEnable  <= 0;
      if (busReady) // Wait bus
      begin
        busValid              <= 0;
        busInstr              <= 0;
        currentState          <= Decode;
        instructionsExecuted  <= instructionsExecuted + 1;
      end
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
      regNumA         <= inputRs1[3:0];
      regNumB         <= inputRs2[3:0];
      wRegRegNum      <= inputRd[3:0];

      // Decode IMM where relevant
      if (inputOpcode == 7'b0010011 || inputOpcode == 7'b1100111 || inputOpcode == 7'b0000011)       // Type I instructions
      begin
        if (inputFunct3 == 3'b001 || inputFunct3 == 3'b101) // Direct
          imm <= immTypeI;
        else // Sign Extend
          imm <= { {20{immTypeI[11]}}, immTypeI[11:0] };
      end
      else if (inputOpcode == 7'b0100011)                               // Type S instructions
      begin
          imm <= { {20{immTypeS[11]}}, immTypeS[11:0] };
      end
      else if (inputOpcode == 7'b1100011)                               // Type B instructions
      begin
          imm <= { {19{immTypeB[12]}}, immTypeB[12:0] };
      end
      else if (inputOpcode == 7'b0010111 || inputOpcode == 7'b0110111)  // Type U instructions
      begin
          imm <= { immTypeU[19:0], 12'b0 };
      end
      else if (inputOpcode == 7'b1101111)                               // Type J instructions
      begin
          imm <= { {12{immTypeJ[19]}}, immTypeJ[19:0] };
      end
      else if (inputOpcode == 7'b1110011)                               // CSR
      begin
          csrNumber <= csrIns;
      end
      currentState  <= Execute0;
    end
    else // Execute State
    begin
        if (opcode == 7'b0010011) // addi, slti, sltiu, xori, ori, andi, slli, srli, srai
        begin
          case (currentState)
            Execute0: // 3. Already set regNumA = rs1, Set regNumB = rd, Set ALU OP = CORRECT OPER, Set ALU Y = IMM
            begin
              case (funct3)
                0: aluOp      <= ADD;
                1: aluOp      <= ShiftLeftUnsigned;
                2: aluOp      <= LesserThanSigned;
                3: aluOp      <= LesserThanUnsigned;
                4: aluOp      <= XOR;
                5: aluOp      <= imm[10] ? ShiftRightSigned : ShiftRightUnsigned;
                6: aluOp      <= OR;
                7: aluOp      <= AND;
              endcase
              aluY            <= imm;
              aluX            <= regOutA;
              currentState    <= Execute1;
            end
            Execute1: // 4. Read ALU O store in regIn, Set regWriteEnable = 1
            begin
              wRegDataIn        <= aluO;
              wRegWriteEnable   <= 1;
              currentState      <= Fetch0;

              // Fetch Next
              address         <= pcDataOut;
              pcCountEnable   <= 1;
              busValid        <= 1;
              busInstr        <= 1;
            end
          endcase
        end
        else if (opcode == 7'b0110011) // add, sub, sll, slt, sltu, xor, srl, sra, or, and
        begin
          case (currentState)
            Execute0: // 3. Set aluX = regOutA, aluY = regOutB, regNumB = rd, Set ALU OP = CORRECT OPER
            begin
              case (funct3)
                0: aluOp      <= funct7[5] ? SUB : ADD;
                1: aluOp      <= ShiftLeftUnsigned;
                2: aluOp      <= LesserThanSigned;
                3: aluOp      <= LesserThanUnsigned;
                4: aluOp      <= XOR;
                5: aluOp      <= funct7[5] ? ShiftRightSigned : ShiftRightUnsigned;
                6: aluOp      <= OR;
                7: aluOp      <= AND;
              endcase
              aluX            <= regOutA;
              aluY            <= regOutB;
              currentState    <= Execute1;
            end
            Execute1: // 4. Read regOut store in ALU X, Set regNum = rs2
            begin
              wRegDataIn        <= aluO;
              wRegWriteEnable   <= 1;
              currentState      <= Fetch0;

              // Fetch Next
              address         <= pcDataOut;
              pcCountEnable   <= 1;
              busValid        <= 1;
              busInstr        <= 1;
            end
          endcase
        end
        else if (opcode == 7'b1100011) // beq, bne, blt, bge, bltu, bgeu
        begin
          case (currentState)
            Execute0: // 3. Set regNum = rs1, Set ALU OP = CORRECT OPER
            begin
              case (funct3)
                0: aluOp      <= Equal;
                1: aluOp      <= NotEqual;
                4: aluOp      <= LesserThanSigned;
                5: aluOp      <= GreaterThanOrEqualSigned;
                6: aluOp      <= LesserThanUnsigned;
                7: aluOp      <= GreaterThanOrEqualUnsigned;
              endcase
              aluX            <= regOutA;
              aluY            <= regOutB;
              currentState    <= Execute1;
            end
            Execute1: // 4. Read regOut store in ALU X, Set regNum = rs2
            begin
              if (aluO[0])
              begin
                pcWriteEnable   <= 1;
                pcWriteAdd      <= 1;
                pcDataIn        <= imm;
                currentState    <= Execute2;
              end
              else
              begin
                //pcWriteEnable   <= 0;
                //pcWriteAdd      <= 0;
                address         <= pcDataOut;
                pcCountEnable   <= 1;
                busWriteEnable  <= 0;
                currentState    <= Fetch0;
                busValid        <= 1;
                busInstr        <= 1;
              end
            end
            Execute2:
            begin
              currentState    <= Execute3;
              pcWriteEnable   <= 0;
              pcWriteAdd      <= 0;
            end
            Execute3:
            begin
              address         <= pcDataOut;
              pcCountEnable   <= 1;
              busWriteEnable  <= 0;
              currentState    <= Fetch0;
              busValid        <= 1;
              busInstr        <= 1;
            end
          endcase
        end
        else if (opcode == 7'b0010111) // auipc
        begin
          case (currentState)
            Execute0: // 3. Set regNum = rd, Set ALU X = pcDataOut - 4, Set ALU Y = (IMM << 12) Set ALU OP = ADD
            begin
              aluX            <= pcDataOut - 4;
              aluY            <= imm;
              aluOp           <= ADD;
              currentState    <= Execute1;
            end
            Execute1: // 4. Set regIn = ALU O, Set regWriteEnable = 1
            begin
              wRegDataIn      <= aluO;
              wRegWriteEnable <= 1;
              currentState    <= Fetch0;

              // Fetch Next
              //busWriteEnable  <= 0;
              //pcWriteEnable   <= 0;
              //pcWriteAdd      <= 0;
              address         <= pcDataOut;
              pcCountEnable   <= 1;
              busValid        <= 1;
              busInstr        <= 1;
            end
          endcase
        end
        else if (opcode == 7'b0110111) // lui
        begin
          case (currentState)
            Execute0: // 3. Set regNum = rd, Set regIn = sign extend ( dataOut << 12 ), Set regWriteEnable = 1
            begin
              wRegDataIn      <= imm;
              wRegWriteEnable <= 1;
              currentState    <= Fetch0;

              // Fetch Next
              //busWriteEnable  <= 0;
              //pcWriteEnable   <= 0;
              //pcWriteAdd      <= 0;
              address         <= pcDataOut;
              pcCountEnable   <= 1;
              busValid        <= 1;
              busInstr        <= 1;
            end
          endcase
        end
        else if (opcode == 7'b1101111) // jal
        begin
          case (currentState)
            Execute0:
            begin
              wRegDataIn      <= pcDataOut;
              wRegWriteEnable <= 1;
              aluX            <= pcDataOut;   // 3.4 Set ALU X = pcDataOut
              aluY            <= imm;         // 3.5 Set ALU Y = sign extend (offset)
              aluOp           <= ADD;         // 3.6 Set ALU OP = ADD
              currentState    <= Execute1;
            end
            Execute1:
            begin
              wRegWriteEnable <= 0;           // 4.1 Set regWriteEnable = 0,
              pcDataIn        <= aluO;        // 4.2 Set pcDataIn = ALU O,
              address         <= aluO - 4;
              pcWriteEnable   <= 1;           // 4.3 Set pcWriteEnable = 1
              currentState    <= Fetch0;

              //busWriteEnable  <= 0;
              //pcWriteAdd      <= 0;
              busValid        <= 1;
              busInstr        <= 1;
            end
          endcase
        end
        else if (opcode == 7'b1100111) // jalr
        begin
          case (currentState)
            Execute0:
            begin
              aluX            <= imm;         // 3.4 Set ALU X = sign extend (offset)
              aluY            <= regOutA;     // 4.1 Set ALU Y = regOut
              aluOp           <= ADD;         // 3.6 Set ALU OP = ADD
              currentState    <= Execute1;
            end
            Execute1:
            begin
              wRegDataIn      <= pcDataOut + 4;
              wRegWriteEnable <= 1;
              pcDataIn        <= {aluO[31:1], 1'b0} + 4;   // 5.2 Set pcDataIn = ALU O & ~1,
              address         <= {aluO[31:1], 1'b0};
              pcWriteEnable   <= 1;           // 5.3 Set pcWriteEnable = 1
              //busWriteEnable  <= 0;
              busValid        <= 1;
              currentState    <= Fetch0;
              busInstr        <= 1;
            end
          endcase
        end
        else if (opcode == 7'b0000011) // lb, lh, lw, lbu, lhu
        begin
          case (currentState)
            Execute0: // 3. Set regNum = rs1, aluX = imm, aluOp = ADD
            begin
              aluX          <= imm;
              aluY          <= regOutA;
              aluOp         <= ADD;
              currentState  <= Execute1;
            end
            Execute1: // 4. Alu Y = regOut, regNum = rd
            begin
              if (
                  (EXCEPTION_HANDLING == 1) && (
                    (inputByteOffset != 0 && numberOfBytes == 2) || // 32 bit read beyond boundary
                    (inputByteOffset == 3 && numberOfBytes == 1)    // 16 bit read beyond boundary
                  )
                )
              begin
                  // Misaligned Exception
                  // TODO: Better diagnostics
                  currentState    <= Fetch0;
                  pcDataIn        <= ExceptionHandlerAddress + 4;

                  wRegDataIn      <= pcDataOut - 4;
                  wRegRegNum      <= 1;
                  wRegWriteEnable <= 1;
                  pcWriteEnable   <= 1;

                  // Fetch Next
                  //busWriteEnable  <= 0;
                  //pcWriteAdd      <= 0;
                  address         <= ExceptionHandlerAddress;
                  busValid        <= 1;
                  busInstr        <= 1;
              end
              else
              begin
                address       <= {aluO[31:2], 2'b00};
                busInstr      <= 0;
                busValid      <= 1;

                if (busReady && busValid) // Wait bus
                begin
                  currentState  <= Execute2;
                  busValid      <= 0;
                end
              end
            end
            Execute2:
            begin
              case (inputByteOffset)
                0:
                begin
                  case (numberOfBytes)
                    0: wRegDataIn <= (funct3[2]) ? dataIn[7:0]  : { {24{dataIn[7]}},  dataIn[7:0]  }; // 1 byte
                    1: wRegDataIn <= (funct3[2]) ? dataIn[15:0] : { {16{dataIn[15]}}, dataIn[15:0] }; // 2 bytes
                    2: wRegDataIn <= dataIn;                                                          // 4 bytes
                  endcase
                end
                1:
                begin
                  case (numberOfBytes)
                    0: wRegDataIn <= (funct3[2]) ? dataIn[15:8]  : { {24{dataIn[15]}},  dataIn[15:8]  }; // 1 byte
                    1: wRegDataIn <= (funct3[2]) ? dataIn[23:8]  : { {16{dataIn[23]}},  dataIn[23:8]  }; // 2 bytes
                  endcase
                end
                2:
                begin
                  case (numberOfBytes)
                    0: wRegDataIn <= (funct3[2]) ? dataIn[23:16] : { {24{dataIn[23]}},  dataIn[23:16] };  // 1 byte
                    1: wRegDataIn <= (funct3[2]) ? dataIn[31:16] : { {16{dataIn[31]}},  dataIn[31:16] };  // 2 bytes
                  endcase
                end
                3:
                begin
                  wRegDataIn <= (funct3[2]) ? dataIn[31:24]  : { {24{dataIn[31]}},  dataIn[31:24]  };   // 1 byte
                end
              endcase
              wRegWriteEnable  <= 1;
              currentState     <= Fetch0;
              // Fetch Next
              //busWriteEnable  <= 0;
              //pcWriteEnable   <= 0;
              //pcWriteAdd      <= 0;
              address         <= pcDataOut;
              pcCountEnable   <= 1;
              busValid        <= 1;
              busInstr        <= 1;
            end
          endcase
        end
        else if (opcode == 7'b0100011) // sw, sh, sb
        begin // M[x[rs1] + sext(imm)] = x[rs2][n:0]
          case (currentState)
            Execute0: // 3. Set regNum = rs1, aluX = imm, aluOp = ADD
            begin
              aluX            <= imm;
              aluY            <= regOutA;
              aluOp           <= ADD;
              currentState    <= Execute1;
            end
            Execute1: // 4. aluY = regOut, regNum = rs2
            begin
              if (
                  (EXCEPTION_HANDLING == 1) && (
                    (inputByteOffset != 0 && numberOfBytes == 2) || // 32 bit write beyond boundary
                    (inputByteOffset == 3 && numberOfBytes == 1)    // 16 bit write beyond boundary
                  )
                )
              begin
                  // Misaligned Exception
                  // TODO: Better diagnostics
                  currentState    <= Fetch0;
                  pcDataIn        <= ExceptionHandlerAddress + 4;
                  wRegDataIn      <= pcDataOut - 4;
                  wRegRegNum      <= 1;
                  wRegWriteEnable <= 1;
                  pcWriteEnable   <= 1;

                  // Fetch Next
                  //busWriteEnable  <= 0;
                  //pcWriteAdd      <= 0;
                  address         <= ExceptionHandlerAddress;
                  busValid        <= 1;
                  busInstr        <= 1;
              end
              else
              begin
                address       <= {aluO[31:2], 2'b00};
                busInstr      <= 0;
                busValid      <= 1;
                if (busValid && busReady) // Wait bus for ready
                begin
                  currentState  <= Execute2;
                  busValid      <= 0;
                end
              end
            end
            Execute2: // 6.
            begin
              case (inputByteOffset)    // Input Byte
                0:
                begin
                  case (numberOfBytes)  // Number of bytes
                    0: dataOut <= {dataIn[31:8], regOutB[7:0]};    // 1 byte
                    1: dataOut <= {dataIn[31:16], regOutB[15:0]};  // 2 bytes
                    2: dataOut <= regOutB;                         // 4 bytes
                  endcase
                end
                1:
                begin
                  case (numberOfBytes)
                    0: dataOut <= {dataIn[31:16], regOutB[7:0], dataIn[7:0]};  // 1 byte
                    1: dataOut <= {dataIn[31:24], regOutB[15:0], dataIn[7:0]}; // 2 bytes
                  endcase
                end
                2:
                begin
                  case (numberOfBytes)
                    0: dataOut <= {dataIn[31:24], regOutB[7:0], dataIn[15:0]}; // 1 byte
                    1: dataOut <= {regOutB[15:0], dataIn[15:0]};               // 2 bytes
                  endcase
                end
                3:
                begin
                  dataOut <= {regOutB[7:0], dataIn[23:0]}; // 1 byte
                end
              endcase
              busWriteEnable  <= 1;
              busValid        <= 1;
              if (busReady && busValid) // Wait bus
              begin
                currentState  <= Execute3;
                busValid      <= 0;
              end
            end
            Execute3:
            begin
              currentState    <= Fetch0;

              // Fetch Next
              busWriteEnable  <= 0;
              address         <= pcDataOut;
              pcCountEnable   <= 1;
              busValid        <= 1;
              busInstr        <= 1;
            end
          endcase
        end
        else if (inputOpcode == 7'b1110011)
        begin
          if (funct3 == 3'b000) // ecall / ebreak. no-op here
          begin
            currentState    <= Fetch0;
            address         <= pcDataOut;
            pcCountEnable   <= 1;
            busValid        <= 1;
            busInstr        <= 1;
          end
          else
          begin
            wRegWriteEnable <= 1;
            wRegDataIn      <= csrDataIn;
            csrWriteEnable  <= 1;

            case (funct3[1:0]) // Immediate vs register already defined at csrOpField
              2'b01: // csr rw   // t = CSRs[csr]; CSRs[csr] = csrOpField; x[rd] = t
                csrDataOut      <= csrOpField;
              2'b10: // csr rs   // t = CSRs[csr]; CSRs[csr] = t | csrOpField; x[rd] = t
                csrDataOut      <= csrDataIn | csrOpField;
              2'b11: // csr rc   // t = CSRs[csr]; CSRs[csr] = t &∼ csrOpField; x[rd] = t
                csrDataOut      <= csrDataIn & ~(csrOpField);
            endcase

            // Single cycle :D
            currentState    <= Fetch0;
            address         <= pcDataOut;
            pcCountEnable   <= 1;
            busValid        <= 1;
            busInstr        <= 1;
          end
        end
    end
  end
end


endmodule
