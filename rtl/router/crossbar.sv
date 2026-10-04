module crossbar #(
    parameter int FLIT_WIDTH = 32,
    parameter int NUM_PORTS  = 5,
    parameter int SEL_W =
        (NUM_PORTS <= 2) ? 1 : $clog2(NUM_PORTS)
) (
    input logic [FLIT_WIDTH-1:0]
        data_in [0:NUM_PORTS-1],

    input logic
        grant_valid [0:NUM_PORTS-1],

    input logic [SEL_W-1:0]
        grant_in [0:NUM_PORTS-1],

    output logic [FLIT_WIDTH-1:0]
        data_out [0:NUM_PORTS-1]
);

  integer o;

  always_comb begin

    for (o = 0; o < NUM_PORTS; o = o + 1) begin

      if (grant_valid[o])
        data_out[o] = data_in[grant_in[o]];
      else
        data_out[o] = '0;

    end

  end

endmodule
