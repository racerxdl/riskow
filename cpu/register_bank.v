module RegisterBank (
  input   wire          clk,
  input   wire          reset,

  // Port 0
  output  wire  [31:0]  dataOut0,
  input         [3:0]   regNum0,

  // Port 1
  output  wire  [31:0]  dataOut1,
  input         [3:0]   regNum1,

  // Write Port
  input         [31:0]  wDataIn,
  input         [3:0]   wRegNum,
  input                 writeEnable     // 1 => WRITE
);

reg [31:0] registers [0:15];

initial begin
  for ( i = 0; i < 16; i=i+1)  registers[i] = 0;
end

integer i;

always @(posedge clk)
begin
  if (!reset)
  begin
   if (writeEnable) registers[wRegNum] <= wRegNum > 0 ? wDataIn : 0;
  end
end

assign dataOut0 = registers[regNum0];
assign dataOut1 = registers[regNum1];

// Only for simulation expose the registers
generate
  genvar idx;
  for(idx = 0; idx < 16; idx = idx+1) begin: register
    wire [31:0] tmp;
    assign tmp = registers[idx];
  end
endgenerate

endmodule
