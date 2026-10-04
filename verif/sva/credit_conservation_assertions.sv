module credit_conservation_assertions #(
    parameter int DEPTH = 4,
    parameter int CW = $clog2(DEPTH+1)
) (
    input logic clk,
    input logic rst_n,

    input logic [CW-1:0] count,

    input logic send,
    input logic return_credit
);

  property p_credit_in_range;

    @(posedge clk)
      disable iff (!rst_n)

      count <= DEPTH;

  endproperty

  assert property (p_credit_in_range);

endmodule
