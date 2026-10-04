`timescale 1ns/1ps

module router_tb;

  import noc_pkg::*;

  localparam int DW = 32;

  logic clk = 0;
  logic rst_n = 0;

  always #5 clk = ~clk;

  logic [4:0] in_valid = '0;

  logic [DW-1:0]
      in_flit [0:4];

  logic [4:0] in_ready;

  logic out_ready_local = 1'b1;

  logic [4:0] out_valid;

  logic [DW-1:0]
      out_flit [0:4];

  logic [4:0] credit_return;

  logic [4:0] credit_in = '0;

  logic [4:0] link_enable = '1;

  router_top #(
      .X_ADDR(1),
      .Y_ADDR(1),
      .X_SIZE(4),
      .Y_SIZE(4)
  ) dut (

      .clk(clk),
      .rst_n(rst_n),

      .in_valid(in_valid),
      .in_flit(in_flit),
      .in_ready(in_ready),

      .out_ready_local(out_ready_local),

      .out_valid(out_valid),
      .out_flit(out_flit),

      .credit_return(credit_return),
      .credit_in(credit_in),
      .link_enable(link_enable)
  );

  task automatic send_local(
      input logic [31:0] f
  );

    begin

      @(posedge clk);

      while (!in_ready[PORT_LOCAL])
        @(posedge clk);

      in_flit[PORT_LOCAL]  = f;
      in_valid[PORT_LOCAL] = 1'b1;

      @(posedge clk);

      in_valid[PORT_LOCAL] = 1'b0;

    end

  endtask

  initial begin

    for (int i = 0; i < 5; i++)
      in_flit[i] = '0;

    repeat (4)
      @(posedge clk);

    rst_n = 1'b1;

    send_local(
        make_flit(
            4'd1,
            4'd1,
            4'd2,
            4'd1,
            2'd0,
            1'b1,
            1'b1,
            12'h123
        )
    );

    send_local(
        make_flit(
            4'd1,
            4'd1,
            4'd1,
            4'd2,
            2'd0,
            1'b1,
            1'b1,
            12'h456
        )
    );

    send_local(
        make_flit(
            4'd1,
            4'd1,
            4'd1,
            4'd1,
            2'd0,
            1'b1,
            1'b1,
            12'h789
        )
    );

    repeat (20)
      @(posedge clk);

    $display("router_tb PASS");

    $finish;

  end

endmodule
