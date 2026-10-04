package flit_defs_pkg;

  typedef struct packed {
    logic [3:0]  src_x;
    logic [3:0]  src_y;
    logic [3:0]  dst_x;
    logic [3:0]  dst_y;
    logic [1:0]  vc;
    logic        head;
    logic        tail;
    logic [11:0] payload;
  } flit_t;

endpackage
