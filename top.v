module top (
  input         clk,
  input         rst,
  inout         led,
  inout [5:0]   lcd
);

parameter EXCEPTION_HANDLING = 0;

// self-reset w/ self-detect logic
// self-reset just start w/ a value and decrement it until zero; at same time, sample the
// default external reset value at startup, supposing that you are not pressing the button
// at the programming moment! supposed to work in *any* board!

reg [3:0] reset_counter = 15; // self-reset
reg reset  = 1; // global reset
reg extrst = 1; // external reset default value (sampled at startup)

always@(posedge clk)
begin
    reset_counter <= reset_counter ? reset_counter-1 : // while(reset_counter--);
                     extrst!=rst ? 13 : 0; // rst != extrst -> restart counter
    reset <= reset_counter ? 1 : 0; // while not zero, reset = 1, after that use extrst
    extrst <= (reset_counter==14) ? rst : extrst; // sample the reset button and store the value when not in reset
end

// BUS
wire  [31:0]  busAddress;
wire  [31:0]  busWriteEnable;
wire  [31:0]  busDataIn;
reg   [31:0]  busDataOut = 0;
wire          busValid;           // 1 => Start bus transaction, 0 => Don't use bus
wire          busInstr;           // 1 => Instruction, 0 => Data
reg           busReady = 0;       // 1 => Bus is ready with data, 0 => If bus is busy

// CPU
wire  [31:0]  cpuDataIn;
wire  [31:0]  cpuDataOut;
wire  [31:0]  cpuAddress;
wire          cpuBusWriteEnable;
wire          cpuBusValid;
wire          cpuBusInstr;
wire          cpuBusReady;

// PORT
wire  [31:0]  portDataOutA;
wire  [31:0]  portDataOutB;
wire  [31:0]  portDataIn;
wire          portChipSelectA;
wire          portChipSelectB;
wire          portWriteIO;
wire          portWriteDirection;
wire  [31:0]  portDirectionA;
wire  [31:0]  portDirectionB;
wire  [31:0]  _IOPortA;
wire  [31:0]  _IOPortB;

// Timer 0
wire  [31:0]  t0DataIn;
wire  [31:0]  t0DataOut;
wire          t0ChipSelect;
wire          t0Write;
wire          t0WriteCommand;

// CSR
reg   [31:0]  csrDataIn;
wire  [63:0]  instructionsExecuted;
wire  [31:0]  csrDataOut;
wire  [11:0]  csrNumber;
wire          csrWriteEnable;
reg   [63:0]  cycleCount;

CPU # (
  .EXCEPTION_HANDLING(EXCEPTION_HANDLING)
) cpu (
  clk,
  reset,
  cpuDataIn,
  cpuDataOut,
  cpuAddress,
  cpuBusValid,
  cpuBusInstr,
  cpuBusReady,
  cpuBusWriteEnable,
  csrDataIn,
  csrDataOut,
  csrNumber,
  csrWriteEnable,
  instructionsExecuted
);

DigitalPort portA (clk, reset, portChipSelectA, portWriteIO, portWriteDirection, portDataIn, portDataOutA, portDirectionA, _IOPortA);
DigitalPort portB (clk, reset, portChipSelectB, portWriteIO, portWriteDirection, portDataIn, portDataOutB, portDirectionB, _IOPortB);
Timer       t0    (clk, reset, t0ChipSelect, t0Write, t0WriteCommand, t0DataIn, t0DataOut);

assign led = _IOPortB[0];
assign lcd = _IOPortA[5:0];

// assign IOPortA = {_IOPortA[0], 31'b0};
// assign IOPortB = {_IOPortB[0], 31'b0};


// Memory
reg [31:0]  ROM   [0:8191];  // 32KB
reg [31:0]  RAM   [0:8191];  // 32KB
reg [31:0]  EXCP  [0:15];    // 1KB

reg [31:0]  ROMFF;
reg [31:0]  RAMFF;
reg [31:0]  EXCPF;

wire romChipSelect;
wire ramChipSelect;
wire excpChipSelect;


initial begin
    $readmemh("gcc/rom.mem", ROM);
    if (EXCEPTION_HANDLING == 1)  $readmemh("gcc/excp.mem", EXCP);
end

always @(posedge clk)
begin
  if (!reset)
  begin
    if (!busValid)
    begin
      busReady <= 0;
    end
    else
    begin
      if (busWriteEnable)
      begin
        if      (romChipSelect)   ROM[busAddress[15:2]]         <= busDataIn;
        else if (ramChipSelect)   RAM[busAddress[14:2]]         <= busDataIn;
        else if (excpChipSelect && EXCEPTION_HANDLING == 1)  EXCP[busAddress[9:2]-10'h1E0] <= busDataIn;
        else if (portChipSelectA || portChipSelectB)
        begin
          `ifdef SIMULATION
          if (portChipSelectA) $info("Wrote %08x on PORTA (IO=%01d, DIR=%01d, PC=%08x)", busDataIn, portWriteIO, portWriteDirection, cpu.PC.programCounter);
          if (portChipSelectB) $info("Wrote %08x on PORTB (IO=%01d, DIR=%01d, PC=%08x)", busDataIn, portWriteIO, portWriteDirection, cpu.PC.programCounter);
          `endif
        end
        else if (t0ChipSelect)
        begin
          // Nothing
        end
        else
        begin
          `ifdef SIMULATION
          $error("Ummapped Memory Write at 0x%08x", busAddress);
          $finish;
          `endif
        end
      end
      busReady <= 1;
    end
    case (csrNumber)
      12'hB00: // Machine Cycle counter L
        csrDataIn <= cycleCount[31:0];
      12'hB02: // Machine Instruction Counter L
        csrDataIn <= instructionsExecuted[31:0];
      12'hB80: // Machine Cycle counter H
        csrDataIn <= cycleCount[63:32];
      12'hB82: // Machine Instruction Counter H
        csrDataIn <= instructionsExecuted[63:32];
      default:
        csrDataIn <= 0;
    endcase
  end
  else
  begin
    busReady    <= 0;
    cycleCount  <= 0;
  end

  `ifdef SIMULATION
  if (busInstr && busValid)
  begin
    $info("Reading at PC %08x", busAddress);
    // ROM[busAddress[15:2]]
  end
  `endif
  ROMFF <= ROM[busAddress[15:2]]; // ROMFF is part of BRAM
  RAMFF <= RAM[busAddress[14:2]]; // RAMFF is part of BRAM
  if (EXCEPTION_HANDLING == 1) EXCPF <= EXCP[busAddress[9:2]-10'h1E0]; // 0x53F0DE0 offset
end

always @(*)
begin
  if      (romChipSelect)   busDataOut <= ROMFF;
  else if (ramChipSelect)   busDataOut <= RAMFF;
  else if (excpChipSelect && EXCEPTION_HANDLING == 1)  busDataOut <= EXCPF;
  else if (portChipSelectA) busDataOut <= portDirection ? portDirectionA : portDataOutA;
  else if (portChipSelectB) busDataOut <= portDirection ? portDirectionB : portDataOutB;
  else if (t0ChipSelect)    busDataOut <= t0DataOut;
  else
  begin
    busDataOut <= 0;
    `ifdef SIMULATION
    $error("Ummapped Memory Access at 0x%08x", busAddress);
    $finish;
    `endif
  end
end

// IO
// IO ADDR = 0xF0000000 // 8 bytes, lower 4 bytes == value, upper 4 bytes = dir
assign portIO             = busAddress[2:0]   == 3'b000;
assign portDirection      = busAddress[2:0]   == 3'b100;

assign portWriteIO        = portIO && busWriteEnable;
assign portWriteDirection = portDirection && busWriteEnable;
assign portChipSelectA    = {busAddress[31:3], 3'b000} == 32'hF0000000;
assign portChipSelectB    = {busAddress[31:3], 3'b000} == 32'hF0000008;
assign portDataIn         = busDataIn;

// BUS Assign
assign busWriteEnable     = cpuBusWriteEnable;
assign busAddress         = cpuAddress;
assign cpuDataIn          = busDataOut;
assign busDataIn          = cpuDataOut;
assign busValid           = cpuBusValid;
assign busInstr           = cpuBusInstr;
assign cpuBusReady        = busReady;
// Memory CS
assign romChipSelect      = {busAddress[31:16], 16'b0} == 32'h00000000;
assign ramChipSelect      = {busAddress[31:16], 16'b0} == 32'h00010000;
assign excpChipSelect     = {busAddress[31:16], 16'b0} == 32'h05E00000 && EXCEPTION_HANDLING == 1;

// Timer 0
// IO ADDR = 0xF1000000
// Data => 0xF1000000
// CMD  => 0xF1000001
assign t0ChipSelect       = {busAddress[31:3], 3'b000} == 32'hF1000000;
assign t0Write            = busAddress[2:0]   == 3'h0 && busWriteEnable;
assign t0WriteCommand     = busAddress[2:0]   == 3'h4 && busWriteEnable;
assign t0DataIn           = busDataIn;


endmodule
