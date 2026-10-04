module route_compute #(
    parameter int X_ADDR = 0,
    parameter int Y_ADDR = 0,
    parameter int X_SIZE = 4,
    parameter int Y_SIZE = 4
) (
    input  logic [31:0] flit,
    output logic [2:0]  out_port
);

  import noc_pkg::*;

  logic [3:0] dx;
  logic [3:0] dy;

  localparam logic [3:0] X_COORD = X_ADDR;
  localparam logic [3:0] Y_COORD = Y_ADDR;

  always_comb begin

    dx = flit[23:20];
    dy = flit[19:16];

    out_port = PORT_CODE_LOCAL;

    // XY dimension-order routing.
    // X dimension is completed before Y dimension.

    if (dx > X_COORD)
      out_port = PORT_CODE_EAST;

    else if (dx < X_COORD)
      out_port = PORT_CODE_WEST;

    else if (dy > Y_COORD)
      out_port = PORT_CODE_SOUTH;

    else if (dy < Y_COORD)
      out_port = PORT_CODE_NORTH;

  end

endmodule
