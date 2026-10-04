module vc_allocation_assertions #(
    parameter int N = 5
) (
    input logic clk,
    input logic rst_n,

    input logic grant [0:N-1][0:N-1]
);

  genvar o;

  generate

    for (o = 0; o < N; o = o + 1) begin : G

      property p_one_grant_per_output;

        @(posedge clk)
          disable iff (!rst_n)

          $onehot0({
              grant[0][o],
              grant[1][o],
              grant[2][o],
              grant[3][o],
              grant[4][o]
          });

      endproperty

      assert property (p_one_grant_per_output);

    end

  endgenerate

endmodule
