`timescale 1ns/1ps

module mesh_tb;

  import noc_pkg::*;

  localparam int X = 4;
  localparam int Y = 4;
  localparam int N = X * Y;

  logic clk = 0;
  logic rst_n = 0;

  always #5 clk = ~clk;

  logic [N-1:0]
      in_valid = '0;

  logic [31:0]
      in_flit [0:N-1];

  logic [N-1:0]
      in_ready;

  logic [N-1:0]
      out_valid;

  logic [31:0]
      out_flit [0:N-1];

  logic [N-1:0]
      out_ready = '1;

  mesh_top #(
      .X_SIZE(X),
      .Y_SIZE(Y)
  ) dut (

      .clk(clk),
      .rst_n(rst_n),

      .local_in_valid(in_valid),
      .local_in_flit(in_flit),
      .local_in_ready(in_ready),

      .local_out_valid(out_valid),
      .local_out_flit(out_flit),
      .local_out_ready(out_ready)
  );

  task automatic inject(
      input int node,
      input logic [31:0] f
  );

    begin

      @(posedge clk);

      while (!in_ready[node])
        @(posedge clk);

      in_flit[node]  = f;
      in_valid[node] = 1'b1;

      @(posedge clk);

      in_valid[node] = 1'b0;

    end

  endtask

  integer received;

  always @(posedge clk) begin

    if (rst_n) begin

      for (int i = 0; i < N; i++) begin

        if (out_valid[i]) begin

          $display(
              "cycle=%0t node=%0d payload=0x%03h",
              $time,
              i,
              out_flit[i][11:0]
          );

          received = received + 1;

        end

      end

    end

  end

  initial begin

    for (int i = 0; i < N; i++)
      in_flit[i] = '0;

    received = 0;

    repeat (4)
      @(posedge clk);

    rst_n = 1'b1;

    // Node 0 -> node 15
    inject(
        0,
        make_flit(
            4'd0,
            4'd0,
            4'd3,
            4'd3,
            2'd0,
            1'b1,
            1'b1,
            12'h0A0
        )
    );

    // Node 3 -> node 8
    inject(
        3,
        make_flit(
            4'd3,
            4'd0,
            4'd0,
            4'd2,
            2'd0,
            1'b1,
            1'b1,
            12'h0B0
        )
    );

    // Node 12 -> node 6
    inject(
        12,
        make_flit(
            4'd0,
            4'd3,
            4'd2,
            4'd1,
            2'd0,
            1'b1,
            1'b1,
            12'h0C0
        )
    );

    repeat (80)
      @(posedge clk);

    if (received != 3)
      $fatal(
          1,
          "Expected 3 received flits, got %0d",
          received
      );

    $display("mesh_tb PASS");

    $finish;

  end

endmodule
