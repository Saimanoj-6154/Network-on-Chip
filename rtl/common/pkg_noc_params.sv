package noc_pkg;

  localparam int FLIT_WIDTH = 32;
  localparam int NUM_PORTS  = 5;

  localparam int PORT_NORTH = 0;
  localparam int PORT_SOUTH = 1;
  localparam int PORT_EAST  = 2;
  localparam int PORT_WEST  = 3;
  localparam int PORT_LOCAL = 4;

  localparam logic [2:0] PORT_CODE_NORTH = 3'd0;
  localparam logic [2:0] PORT_CODE_SOUTH = 3'd1;
  localparam logic [2:0] PORT_CODE_EAST  = 3'd2;
  localparam logic [2:0] PORT_CODE_WEST  = 3'd3;
  localparam logic [2:0] PORT_CODE_LOCAL = 3'd4;

  function automatic logic [31:0] make_flit(
      input logic [3:0]  src_x,
      input logic [3:0]  src_y,
      input logic [3:0]  dst_x,
      input logic [3:0]  dst_y,
      input logic [1:0]  vc,
      input logic        head,
      input logic        tail,
      input logic [11:0] payload
  );
    logic [31:0] f;

    f = '0;

    f[31:28] = src_x;
    f[27:24] = src_y;
    f[23:20] = dst_x;
    f[19:16] = dst_y;
    f[15:14] = vc;
    f[13]    = head;
    f[12]    = tail;
    f[11:0]  = payload;

    return f;
  endfunction

  function automatic logic [3:0] src_x(input logic [31:0] f);
    return f[31:28];
  endfunction

  function automatic logic [3:0] src_y(input logic [31:0] f);
    return f[27:24];
  endfunction

  function automatic logic [3:0] dst_x(input logic [31:0] f);
    return f[23:20];
  endfunction

  function automatic logic [3:0] dst_y(input logic [31:0] f);
    return f[19:16];
  endfunction

  function automatic logic [1:0] flit_vc(input logic [31:0] f);
    return f[15:14];
  endfunction

  function automatic logic flit_head(input logic [31:0] f);
    return f[13];
  endfunction

  function automatic logic flit_tail(input logic [31:0] f);
    return f[12];
  endfunction

  function automatic logic [11:0] payload(input logic [31:0] f);
    return f[11:0];
  endfunction

endpackage
