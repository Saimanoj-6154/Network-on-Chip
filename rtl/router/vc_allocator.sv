module vc_allocator #(
    parameter int NUM_PORTS = 5
) (
    input  logic req [0:NUM_PORTS-1][0:NUM_PORTS-1],

    input  logic out_available [0:NUM_PORTS-1],

    output logic grant [0:NUM_PORTS-1][0:NUM_PORTS-1]
);

  integer i;
  integer o;

  always_comb begin

    for (i = 0; i < NUM_PORTS; i = i + 1) begin
      for (o = 0; o < NUM_PORTS; o = o + 1) begin

        grant[i][o] =
            req[i][o] &&
            out_available[o];

      end
    end

  end

endmodule
