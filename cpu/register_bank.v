module RegisterBank (
  input   wire          clk,
  input   wire          reset,
  input         [31:0]  dataIn,
  output  wire  [31:0]  dataOut,
  input         [3:0]   regNum,
  input                 writeEnable     // 1 => WRITE, 0 => READ
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
  else if (writeEnable && regNum != 0) registers[regNum] <= dataIn;
end

assign dataOut = registers[regNum];

// Only for simulation expose the registers
generate
  genvar idx;
  for(idx = 0; idx < 16; idx = idx+1) begin: register
    wire [31:0] tmp;
    assign tmp = registers[idx];
  end
endgenerate

endmodule
