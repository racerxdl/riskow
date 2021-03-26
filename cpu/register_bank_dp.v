module DPRegisterBank (
  input   wire          clk,
  input   wire          reset,

  // Port 0
  input         [31:0]  dataIn0,
  output  wire  [31:0]  dataOut0,
  input         [3:0]   regNum0,
  input                 writeEnable0,     // 1 => WRITE, 0 => READ

  // Port 1
  input         [31:0]  dataIn1,
  output  wire  [31:0]  dataOut1,
  input         [3:0]   regNum1,
  input                 writeEnable1     // 1 => WRITE, 0 => READ
);

reg [31:0] registers [0:15];

initial begin
  for ( i = 0; i < 16; i=i+1)
  begin
    registers[i] = 0;
  end
end

integer i;

always @(posedge clk)
begin
  if (reset)
  begin
    // No need for reset registers
    // for (i = 0; i < 16; i=i+1)
    // begin
    //   registers[i] <= 0;
    // end
  end
  else
  begin
   if (writeEnable0 && regNum0 != 0) registers[regNum0] <= dataIn0;
   if (writeEnable1 && regNum1 != 0) registers[regNum1] <= dataIn1;
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
