/*
 *  Copyright (C) 2017  Claire Xenia Wolf <claire@yosyshq.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

// -----------------------------------------------------------------------------
// Copyright (C) 2024 Rohith V <vrohithkattimani@gmail.com>
// Implementation and Verification:
// The SCRV32I core was designed and formally verified using the RISC-V Formal
// Framework by Rohith V in 2024.
// LinkedIn: https://www.linkedin.com/in/v-rohith-km/
// -----------------------------------------------------------------------------

module rvfi_wrapper (
    input clock,
    input reset,
    `RVFI_OUTPUTS
);
  (* keep *)wire        mem_wstrb;

    assign rvfi_trap = 1'b0;
    assign rvfi_halt = 1'b0;
    assign rvfi_intr = 1'b0;
    assign rvfi_ixl = 2'b01;

  top uut (
      .clk      (clock),
      .reset    (reset),
      .WriteData(rvfi_mem_wdata),
      .DataAdr  (rvfi_mem_addr),
      .MemWrite (mem_wstrb),

      .rvfi_valid    (rvfi_valid),
      .rvfi_order    (rvfi_order),
      .rvfi_insn     (rvfi_insn),
      .rvfi_mode     (rvfi_mode),
      .rvfi_pc_rdata (rvfi_pc_rdata),
      .rvfi_pc_wdata (rvfi_pc_wdata),
      .rvfi_rs1_addr (rvfi_rs1_addr),
      .rvfi_rs2_addr (rvfi_rs2_addr),
      .rvfi_rs1_rdata(rvfi_rs1_rdata),
      .rvfi_rs2_rdata(rvfi_rs2_rdata),
      .rvfi_rd_addr  (rvfi_rd_addr),
      .rvfi_rd_wdata (rvfi_rd_wdata),
      .rvfi_mem_addr (rvfi_mem_addr),
      .rvfi_mem_rdata(rvfi_mem_rdata),
      .rvfi_mem_wdata(rvfi_mem_wdata)
  );

  // Fixed masks for word operations
  assign rvfi_mem_rmask = mem_wstrb ? 4'b0000 : 4'b1111;  // 1111 for lw, 0000 for sw
  assign rvfi_mem_wmask = mem_wstrb ? 4'b1111 : 4'b0000;  // 1111 for sw, 0000 for lw

endmodule
