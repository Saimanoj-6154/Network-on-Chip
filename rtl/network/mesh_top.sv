module mesh_top #(
    parameter int X_SIZE       = 4,
    parameter int Y_SIZE       = 4,
    parameter int FLIT_WIDTH   = 32,
    parameter int BUFFER_DEPTH = 4
) (
    input logic clk,
    input logic rst_n,

    input logic [X_SIZE*Y_SIZE-1:0]
        local_in_valid,

    input logic [FLIT_WIDTH-1:0]
        local_in_flit [0:X_SIZE*Y_SIZE-1],

    output logic [X_SIZE*Y_SIZE-1:0]
        local_in_ready,

    output logic [X_SIZE*Y_SIZE-1:0]
        local_out_valid,

    output logic [FLIT_WIDTH-1:0]
        local_out_flit [0:X_SIZE*Y_SIZE-1],

    input logic [X_SIZE*Y_SIZE-1:0]
        local_out_ready
);

  import noc_pkg::*;

  localparam int NODES = X_SIZE * Y_SIZE;

  logic [4:0] r_in_valid [0:NODES-1];
  logic [4:0] r_out_valid [0:NODES-1];

  logic [FLIT_WIDTH-1:0]
      r_in_flit [0:NODES-1][0:4];

  logic [FLIT_WIDTH-1:0]
      r_out_flit [0:NODES-1][0:4];

  logic [4:0] r_credit_in [0:NODES-1];
  logic [4:0] r_credit_out [0:NODES-1];

  logic [4:0] r_link_enable [0:NODES-1];
  logic [4:0] r_in_ready [0:NODES-1];

  genvar x;
  genvar y;

  generate

    for (y = 0; y < Y_SIZE; y = y + 1) begin : GY

      for (x = 0; x < X_SIZE; x = x + 1) begin : GX

        localparam int ID = y * X_SIZE + x;

        assign r_in_valid[ID][PORT_LOCAL] =
            local_in_valid[ID];

        assign r_in_flit[ID][PORT_LOCAL] =
            local_in_flit[ID];

        assign local_in_ready[ID] =
            r_in_ready[ID][PORT_LOCAL];

        assign r_link_enable[ID][PORT_LOCAL] =
            1'b1;

        assign local_out_valid[ID] =
            r_out_valid[ID][PORT_LOCAL];

        assign local_out_flit[ID] =
            r_out_flit[ID][PORT_LOCAL];

        assign r_link_enable[ID][PORT_NORTH] =
            (y > 0);

        assign r_link_enable[ID][PORT_SOUTH] =
            (y < Y_SIZE - 1);

        assign r_link_enable[ID][PORT_EAST] =
            (x < X_SIZE - 1);

        assign r_link_enable[ID][PORT_WEST] =
            (x > 0);

        // North boundary
        if (y == 0) begin : TIE_NORTH

          assign r_in_valid[ID][PORT_NORTH] = 1'b0;
          assign r_in_flit[ID][PORT_NORTH] = '0;
          assign r_credit_in[ID][PORT_NORTH] = 1'b0;

        end

        // South boundary
        if (y == Y_SIZE - 1) begin : TIE_SOUTH

          assign r_in_valid[ID][PORT_SOUTH] = 1'b0;
          assign r_in_flit[ID][PORT_SOUTH] = '0;
          assign r_credit_in[ID][PORT_SOUTH] = 1'b0;

        end

        // East boundary
        if (x == X_SIZE - 1) begin : TIE_EAST

          assign r_in_valid[ID][PORT_EAST] = 1'b0;
          assign r_in_flit[ID][PORT_EAST] = '0;
          assign r_credit_in[ID][PORT_EAST] = 1'b0;

        end

        // West boundary
        if (x == 0) begin : TIE_WEST

          assign r_in_valid[ID][PORT_WEST] = 1'b0;
          assign r_in_flit[ID][PORT_WEST] = '0;
          assign r_credit_in[ID][PORT_WEST] = 1'b0;

        end

        router_top #(
            .FLIT_WIDTH(FLIT_WIDTH),
            .BUFFER_DEPTH(BUFFER_DEPTH),

            .X_ADDR(x),
            .Y_ADDR(y),

            .X_SIZE(X_SIZE),
            .Y_SIZE(Y_SIZE)
        ) u_router (

            .clk(clk),
            .rst_n(rst_n),

            .in_valid(r_in_valid[ID]),
            .in_flit(r_in_flit[ID]),
            .in_ready(r_in_ready[ID]),

            .out_ready_local(
                local_out_ready[ID]
            ),

            .out_valid(
                r_out_valid[ID]
            ),

            .out_flit(
                r_out_flit[ID]
            ),

            .credit_return(
                r_credit_out[ID]
            ),

            .credit_in(
                r_credit_in[ID]
            ),

            .link_enable(
                r_link_enable[ID]
            )
        );

      end

    end

  endgenerate

  // Horizontal and vertical point-to-point links.

  genvar n;

  generate

    for (n = 0; n < NODES; n = n + 1) begin : GL

      localparam int XN = n % X_SIZE;
      localparam int YN = n / X_SIZE;

      // EAST
      if (XN < X_SIZE - 1) begin : EAST_LINK

        localparam int NB = n + 1;

        link #(
            .FLIT_WIDTH(FLIT_WIDTH)
        ) l_e (

            .in_valid(
                r_out_valid[n][PORT_EAST]
            ),

            .in_flit(
                r_out_flit[n][PORT_EAST]
            ),

            .in_credit(
                r_credit_out[NB][PORT_WEST]
            ),

            .out_valid(
                r_in_valid[NB][PORT_WEST]
            ),

            .out_flit(
                r_in_flit[NB][PORT_WEST]
            ),

            .out_credit(
                r_credit_in[n][PORT_EAST]
            )
        );

      end

      // WEST
      if (XN > 0) begin : WEST_LINK

        localparam int NB = n - 1;

        link #(
            .FLIT_WIDTH(FLIT_WIDTH)
        ) l_w (

            .in_valid(
                r_out_valid[n][PORT_WEST]
            ),

            .in_flit(
                r_out_flit[n][PORT_WEST]
            ),

            .in_credit(
                r_credit_out[NB][PORT_EAST]
            ),

            .out_valid(
                r_in_valid[NB][PORT_EAST]
            ),

            .out_flit(
                r_in_flit[NB][PORT_EAST]
            ),

            .out_credit(
                r_credit_in[n][PORT_WEST]
            )
        );

      end

      // SOUTH
      if (YN < Y_SIZE - 1) begin : SOUTH_LINK

        localparam int NB = n + X_SIZE;

        link #(
            .FLIT_WIDTH(FLIT_WIDTH)
        ) l_s (

            .in_valid(
                r_out_valid[n][PORT_SOUTH]
            ),

            .in_flit(
                r_out_flit[n][PORT_SOUTH]
            ),

            .in_credit(
                r_credit_out[NB][PORT_NORTH]
            ),

            .out_valid(
                r_in_valid[NB][PORT_NORTH]
            ),

            .out_flit(
                r_in_flit[NB][PORT_NORTH]
            ),

            .out_credit(
                r_credit_in[n][PORT_SOUTH]
            )
        );

      end

      // NORTH
      if (YN > 0) begin : NORTH_LINK

        localparam int NB = n - X_SIZE;

        link #(
            .FLIT_WIDTH(FLIT_WIDTH)
        ) l_n (

            .in_valid(
                r_out_valid[n][PORT_NORTH]
            ),

            .in_flit(
                r_out_flit[n][PORT_NORTH]
            ),

            .in_credit(
                r_credit_out[NB][PORT_SOUTH]
            ),

            .out_valid(
                r_in_valid[NB][PORT_SOUTH]
            ),

            .out_flit(
                r_in_flit[NB][PORT_SOUTH]
            ),

            .out_credit(
                r_credit_in[n][PORT_NORTH]
            )
        );

      end

    end

  endgenerate

endmodule
