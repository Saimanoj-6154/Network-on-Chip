module input_buffer #(
    parameter int FLIT_WIDTH = 32,
    parameter int DEPTH      = 4
) (
    input  logic                           clk,
    input  logic                           rst_n,

    input  logic                           push_valid,
    input  logic [FLIT_WIDTH-1:0]           push_data,
    output logic                           push_ready,

    input  logic                           pop_valid,
    output logic [FLIT_WIDTH-1:0]           pop_data,

    output logic                           empty,
    output logic                           full,
    output logic [$clog2(DEPTH+1)-1:0]      count
);

  localparam int PTR_W = (DEPTH <= 1) ? 1 : $clog2(DEPTH);

  logic [FLIT_WIDTH-1:0] mem [0:DEPTH-1];

  logic [PTR_W-1:0] wr_ptr;
  logic [PTR_W-1:0] rd_ptr;

  logic do_push;
  logic do_pop;

  assign empty      = (count == 0);
  assign full       = (count == DEPTH);

  // Permit push when there is space, or when a pop happens
  // in the same cycle.
  assign push_ready = !full || pop_valid;

  assign do_push = push_valid && push_ready;
  assign do_pop  = pop_valid && !empty;

  assign pop_data = empty ? '0 : mem[rd_ptr];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
      count  <= '0;
    end
    else begin

      if (do_push) begin
        mem[wr_ptr] <= push_data;

        if (wr_ptr == DEPTH-1)
          wr_ptr <= '0;
        else
          wr_ptr <= wr_ptr + 1'b1;
      end

      if (do_pop) begin
        if (rd_ptr == DEPTH-1)
          rd_ptr <= '0;
        else
          rd_ptr <= rd_ptr + 1'b1;
      end

      case ({do_push, do_pop})

        2'b10:
          count <= count + 1'b1;

        2'b01:
          count <= count - 1'b1;

        default:
          count <= count;

      endcase
    end
  end

endmodule
