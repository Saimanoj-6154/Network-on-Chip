module deadlock_freedom_assertions #(
    parameter int WATCHDOG = 100
) (
    input logic clk,
    input logic rst_n,

    input logic outstanding,
    input logic progress
);

  integer stall_count;

  always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n)
      stall_count <= 0;

    else if (!outstanding || progress)
      stall_count <= 0;

    else
      stall_count <= stall_count + 1;

  end

  property p_no_long_stall;

    @(posedge clk)
      disable iff (!rst_n)

      outstanding |-> (stall_count < WATCHDOG);

  endproperty

  assert property (p_no_long_stall);

endmodule
