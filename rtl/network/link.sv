module link #(
    parameter int FLIT_WIDTH = 32
) (
    input  logic                  in_valid,
    input  logic [FLIT_WIDTH-1:0] in_flit,
    input  logic                  in_credit,

    output logic                  out_valid,
    output logic [FLIT_WIDTH-1:0] out_flit,
    output logic                  out_credit
);

  // Transparent physical link.
  // Buffering is handled by the routers.

  assign out_valid  = in_valid;
  assign out_flit   = in_flit;
  assign out_credit = in_credit;

endmodule
