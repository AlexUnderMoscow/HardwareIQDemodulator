module bin2tcv
#(
  parameter WIDT = 16
)
(
  input  wire [WIDT-1:0] x,
  output wire [WIDT-1:0] y
);

  assign y =x[WIDT-1]? {x[WIDT-1],(~x[WIDT-2:0]) + 1}: x;

endmodule


module tcv2bin
#(
  parameter WIDT = 16
)
(
  input  wire [WIDT-1:0] x,
  output wire [WIDT-1:0] y
);

  assign y =x[WIDT-1]? {x[WIDT-1],~(x[WIDT-2:0]-1)}: x;

endmodule