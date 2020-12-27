module RegisterBank (
  input   wire          clk,
  input   wire          reset,
  input         [31:0]  dataIn,
  output  wire  [31:0]  dataOut,
  input         [3:0]   regNum,
  input                 writeEnable     // 1 => WRITE, 0 => READ
);

reg [31:0] registers [0:15];

integer i;

always @(posedge clk)
begin
  if (reset)
  begin
      for (i = 0; i < 16; i++)
      begin
        registers[i] <= 0;
      end
  end
  else if (writeEnable && regNum != 0) registers[regNum] <= dataIn;
end

assign dataOut = registers[regNum];

endmodule
