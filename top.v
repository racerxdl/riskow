module Riskow (
  input         clk,
  input         reset,
  inout [31:0]  IOPortA,
  inout [31:0]  IOPortB
);

// BUS
wire  [31:0]  busAddress;
wire  [31:0]  busWriteEnable;
wire  [31:0]  busDataIn;
reg   [31:0]  busDataOut;

// CPU
reg   [31:0]  cpuDataIn;
wire  [31:0]  cpuDataOut;
wire  [31:0]  cpuAddress;
wire          cpuBusWriteEnable;

// PORT
wire  [31:0]  portDataOutA;
wire  [31:0]  portDataOutB;
wire  [31:0]  portDataIn;
wire          portChipSelectA;
wire          portChipSelectB;
wire          portWriteIO;
wire          portWriteDirection;

CPU         cpu   (clk, reset, cpuDataIn, cpuDataOut, cpuAddress, cpuBusWriteEnable);
DigitalPort portA (clk, reset, portChipSelectA, portWriteIO, portWriteDirection, portDataIn, portDataOutA, IOPortA);
DigitalPort portB (clk, reset, portChipSelectB, portWriteIO, portWriteDirection, portDataIn, portDataOutB, IOPortB);


// Memory
reg [31:0]  ROM   [0:16383]; // 64KB
reg [31:0]  RAM   [0:8191];  // 32KB
reg [31:0]  EXCP  [0:255];   // 1KB

wire romChipSelect;
wire ramChipSelect;
wire excpChipSelect;


initial begin
    $readmemh("gcc/rom.mem", ROM);
    $readmemh("gcc/excp.mem", EXCP);
end

always @(posedge clk)
begin
  if (!reset)
  begin
    if (busWriteEnable)
    begin
      if      (romChipSelect)   ROM[busAddress[15:2]]         <= busDataIn;
      else if (ramChipSelect)   RAM[busAddress[14:2]]         <= busDataIn;
      else if (excpChipSelect)  EXCP[busAddress[9:2]-10'h1E0] <= busDataIn;
      else if (portChipSelectA || portChipSelectB)
      begin
        if (portChipSelectA) $info("Wrote %08x on PORTA (IO=%01d, DIR=%01d, PC=%08x)", busDataIn, portWriteIO, portWriteDirection, cpu.PC.programCounter);
        if (portChipSelectB) $info("Wrote %08x on PORTB (IO=%01d, DIR=%01d, PC=%08x)", busDataIn, portWriteIO, portWriteDirection, cpu.PC.programCounter);
      end
      else
      begin
        $error("Ummapped Memory Write at 0x%08x", busAddress);
        $finish;
      end
    end
    else
    begin
      if      (romChipSelect)   busDataOut <= ROM[busAddress[15:2]];
      else if (ramChipSelect)   busDataOut <= RAM[busAddress[14:2]];
      else if (excpChipSelect)  busDataOut <= EXCP[busAddress[9:2]-10'h1E0]; // 0x53F0DE0 offset
      else if (portChipSelectA) busDataOut <= portDataOutA;
      else if (portChipSelectB) busDataOut <= portDataOutB;
      else
      begin
        $error("Ummapped Memory Access at 0x%08x", busAddress);
        busDataOut <= 0;
        $finish;
      end
    end
  end
  else
  begin
    busDataOut <= 0;
  end
end


// IO
// IO ADDR = 0xF0000000 // 8 bytes, lower 4 bytes == value, upper 4 bytes = dir
assign portWriteIO        = busAddress[2:0]   == 3'b000 && busWriteEnable;
assign portWriteDirection = busAddress[2:0]   == 3'b100 && busWriteEnable;
assign portChipSelectA    = {busAddress[31:3], 3'b000} == 32'hF0000000;
assign portChipSelectB    = {busAddress[31:3], 3'b000} == 32'hF0000008;
assign portDataIn         = busDataIn;

// BUS Assign
assign busWriteEnable     = cpuBusWriteEnable;
assign busAddress         = cpuAddress;
assign cpuDataIn          = busDataOut;
assign busDataIn          = cpuDataOut;

// Memory CS
assign romChipSelect      = {busAddress[31:16], 16'b0} == 32'h00000000;
assign ramChipSelect      = {busAddress[31:16], 16'b0} == 32'h00010000;
assign excpChipSelect     = {busAddress[31:16], 16'b0} == 32'h05E00000;

endmodule
