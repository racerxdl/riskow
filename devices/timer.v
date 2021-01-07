module Timer (
  input                 clk,
  input                 rst,
  input                 chipSelect,
  input                 write,
  input                 writeCommand,
  input         [31:0]  dataIn,
  output        [31:0]  dataOut
);

reg timerRunning;

reg   [8:0]   divideBy;
reg   [8:0]   divider;
reg   [31:0]  counter;

wire  [2:0]   cmd;
wire  [29:0]  cmd_arg;

always @(posedge clk)
begin
  if (rst)
  begin
    divider       <= 0;
    counter       <= 0;
    divideBy      <= 64;
    timerRunning  <= 0;
  end
  else if (timerRunning)
  begin
    divider <= divider + 1;
    if (divider == divideBy -1)
    begin
      divider <= 0;
      counter <= counter + 1;
    end
  end

  if (~rst && chipSelect)
  begin
    if (write)
      counter <= dataIn;
    if (writeCommand)
    begin
      // data[2:0]  == CMD
      // data[31:3] == DATA
      case (cmd)
        0: // Reset
        begin
          divider       <= 0;
          counter       <= 0;
          timerRunning  <= 0;
        end
        1: // Set Divide By
        begin
          divideBy <= cmd_arg[8:0];
        end
        2: // Start Timer
        begin
          timerRunning <= 1;
        end
      endcase
    end
  end
end

assign dataOut  = counter;
assign cmd      = dataIn[2:0];
assign cmd_arg  = dataIn[31:3];

endmodule