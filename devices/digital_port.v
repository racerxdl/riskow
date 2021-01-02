module DigitalPort (
  input                 clk,
  input                 rst,
  input                 chipSelect,
  input                 writeIO,
  input                 writeDirection,
  input         [31:0]  dataIn,
  output        [31:0]  dataOut,

  inout         [31:0]  IO                // Connected to FPGA pins
);

reg [31:0] direction;
reg [31:0] value;

always @(posedge clk)
begin
  if (rst)
  begin
    direction <= 0;
    value     <= 0;
  end
  else if (chipSelect)
  begin
    if (writeIO)          value     <= dataIn;
    if (writeDirection)   direction <= dataIn;
  end
end

generate
  genvar idx;
  for(idx = 0; idx < 32; idx = idx+1) begin: register
    assign IO[idx] = direction[idx] ? value[idx] : 1'bZ;
  end
endgenerate

assign dataOut = IO;

endmodule