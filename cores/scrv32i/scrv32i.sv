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
// Reference:
// Digital Design and Computer Architecture: RISC-V Edition
// Authors: David Harris, Sarah L. Harris
// Publisher: Morgan Kaufmann; (2022)
// ISBN-13: 978-0128200643
//
// This design is inspired by and based on concepts presented in the above book.
// ----------------------------------------------------------------------------- 
// -----------------------------------------------------------------------------
// Copyright (C) 2024 Rohith V <vrohithkattimani@gmail.com>
// Implementation and Verification:
// The SCRV32I core was designed and formally verified using the RISC-V Formal
// Framework by Rohith V in 2024.
// LinkedIn: https://www.linkedin.com/in/v-rohith-km/
// -----------------------------------------------------------------------------

// Contents of top.sv
module top (
    input  logic        clk,
    input  logic	reset,
    output logic [31:0] WriteData,
    output logic [31:0] DataAdr,
    output logic        MemWrite,
`ifdef RISCV_FORMAL
    output logic        rvfi_valid,
    output logic [63:0] rvfi_order,
    output logic [31:0] rvfi_insn,
    // output logic        rvfi_trap
    // output logic        rvfi_halt
    // output logic        rvfi_intr
    output logic [ 1:0] rvfi_mode,
    output logic [31:0] rvfi_pc_rdata,
    output logic [31:0] rvfi_pc_wdata,
    output logic [ 4:0] rvfi_rs1_addr,
    output logic [ 4:0] rvfi_rs2_addr,
    output logic [31:0] rvfi_rs1_rdata,
    output logic [31:0] rvfi_rs2_rdata,
    output logic [ 4:0] rvfi_rd_addr,
    output logic [31:0] rvfi_rd_wdata,
    output logic [31:0] rvfi_mem_addr,
    // output logic [ 3:0] rvfi_mem_rmask
    // output logic [ 3:0] rvfi_mem_wmask
    output logic [31:0] rvfi_mem_rdata,
    output logic [31:0] rvfi_mem_wdata
`endif
);

  logic [31:0] PC, Instr, ReadData;

  // instantiate processor and memories
  riscvsingle rvsingle (
      clk,
      reset,
      Instr,
      ReadData,
      PC,
      MemWrite,
      DataAdr,
      WriteData,
`ifdef RISCV_FORMAL
      rvfi_valid,
      rvfi_order,
      rvfi_insn,
      // rvfi_trap
      // rvfi_halt
      // rvfi_intr
      rvfi_mode,
      rvfi_pc_rdata,
      rvfi_pc_wdata,
      rvfi_rs1_addr,
      rvfi_rs2_addr,
      rvfi_rs1_rdata,
      rvfi_rs2_rdata,
      rvfi_rd_addr,
      rvfi_rd_wdata,
      rvfi_mem_addr,
      // rvfi_mem_rmask
      // rvfi_mem_wmask
      rvfi_mem_rdata,
      rvfi_mem_wdata
`endif
  );
  imem imem (
      PC,
      Instr
  );
  dmem dmem (
      clk,
      MemWrite,
      DataAdr,
      WriteData,
      ReadData
  );

endmodule

// Contents of riscvsingle.sv and datapath.sv combined
module riscvsingle (
    input  logic        clk,
    reset,
    input  logic [31:0] Instr,
    input  logic [31:0] ReadData,
    output logic [31:0] PC,
    output logic        MemWrite,
    output logic [31:0] ALUResult,
    WriteData,
`ifdef RISCV_FORMAL
    output logic        rvfi_valid,
    output logic [63:0] rvfi_order,
    output logic [31:0] rvfi_insn,
    // output logic        rvfi_trap
    // output logic        rvfi_halt
    // output logic        rvfi_intr
    output logic [ 1:0] rvfi_mode,
    output logic [31:0] rvfi_pc_rdata,
    output logic [31:0] rvfi_pc_wdata,
    output logic [ 4:0] rvfi_rs1_addr,
    output logic [ 4:0] rvfi_rs2_addr,
    output logic [31:0] rvfi_rs1_rdata,
    output logic [31:0] rvfi_rs2_rdata,
    output logic [ 4:0] rvfi_rd_addr,
    output logic [31:0] rvfi_rd_wdata,
    output logic [31:0] rvfi_mem_addr,
    // output logic [ 3:0] rvfi_mem_rmask
    // output logic [ 3:0] rvfi_mem_wmask
    output logic [31:0] rvfi_mem_rdata,
    output logic [31:0] rvfi_mem_wdata
`endif
);

  logic ALUSrc, RegWrite, Jump, Zero, PCSrc;
  logic [1:0] ResultSrc, ImmSrc;
  logic [2:0] ALUControl;

  controller c (
      Instr[6:0],
      Instr[14:12],
      Instr[30],
      Zero,
      ResultSrc,
      MemWrite,
      PCSrc,
      ALUSrc,
      RegWrite,
      Jump,
      ImmSrc,
      ALUControl
  );

  datapath dp (
      clk,
      reset,
      ResultSrc,
      PCSrc,
      ALUSrc,
      RegWrite,
      ImmSrc,
      ALUControl,
      Instr,
      ReadData,
      Zero,
      PC,
      ALUResult,
      WriteData,
`ifdef RISCV_FORMAL
      rvfi_valid,
      rvfi_order,
      rvfi_insn,
      // rvfi_trap
      // rvfi_halt
      // rvfi_intr
      rvfi_mode,
      rvfi_pc_rdata,
      rvfi_pc_wdata,
      rvfi_rs1_addr,
      rvfi_rs2_addr,
      rvfi_rs1_rdata,
      rvfi_rs2_rdata,
      rvfi_rd_addr,
      rvfi_rd_wdata,
      rvfi_mem_addr,
      // rvfi_mem_rmask
      // rvfi_mem_wmask
      rvfi_mem_rdata,
      rvfi_mem_wdata
`endif
  );

endmodule

module datapath (
    input  logic        clk,
    reset,
    input  logic [ 1:0] ResultSrc,
    input  logic        PCSrc,
    ALUSrc,
    input  logic        RegWrite,
    input  logic [ 1:0] ImmSrc,
    input  logic [ 2:0] ALUControl,
    input  logic [31:0] Instr,
    input  logic [31:0] ReadData,
    output logic        Zero,
    output logic [31:0] PC,
    output logic [31:0] ALUResult,
    WriteData,
`ifdef RISCV_FORMAL
    output logic        rvfi_valid,
    output logic [63:0] rvfi_order,
    output logic [31:0] rvfi_insn,
    // output logic        rvfi_trap
    // output logic        rvfi_halt
    // output logic        rvfi_intr
    output logic [ 1:0] rvfi_mode,
    output logic [31:0] rvfi_pc_rdata,
    output logic [31:0] rvfi_pc_wdata,
    output logic [ 4:0] rvfi_rs1_addr,
    output logic [ 4:0] rvfi_rs2_addr,
    output logic [31:0] rvfi_rs1_rdata,
    output logic [31:0] rvfi_rs2_rdata,
    output logic [ 4:0] rvfi_rd_addr,
    output logic [31:0] rvfi_rd_wdata,
    output logic [31:0] rvfi_mem_addr,
    // output logic [ 3:0] rvfi_mem_rmask
    // output logic [ 3:0] rvfi_mem_wmask
    output logic [31:0] rvfi_mem_rdata,
    output logic [31:0] rvfi_mem_wdata
`endif
);

  logic [31:0] PCNext, PCPlus4, PCTarget;
  logic [31:0] ImmExt;
  logic [31:0] SrcA, SrcB;
  logic [31:0] Result;

  // next PC logic
  flopr #(32) pcreg (
      clk,
      reset,
      PCNext,
      PC
  );
  adder pcadd4 (
      PC,
      32'd4,
      PCPlus4
  );
  adder pcaddbranch (
      PC,
      ImmExt,
      PCTarget
  );
  mux2 #(32) pcmux (
      PCPlus4,
      PCTarget,
      PCSrc,
      PCNext
  );

  // register file logic
  regfile rf (
      clk,
      RegWrite,
      Instr[19:15],
      Instr[24:20],
      Instr[11:7],
      Result,
      SrcA,
      WriteData
  );
  extend ext (
      Instr[31:7],
      ImmSrc,
      ImmExt
  );

  // ALU logic
  mux2 #(32) srcbmux (
      WriteData,
      ImmExt,
      ALUSrc,
      SrcB
  );
  alu alu (
      SrcA,
      SrcB,
      ALUControl,
      ALUResult,
      Zero
  );
  mux3 #(32) resultmux (
      ALUResult,
      ReadData,
      PCPlus4,
      ResultSrc,
      Result
  );

  reg [31:0] rvfi_order_reg;
  always @(posedge clk or posedge reset) begin
    if (reset) rvfi_order_reg <= 32'b0;  // Reset order to 0
    else if (rvfi_valid)
      rvfi_order_reg <= rvfi_order_reg + 1;  // Increment order on valid instruction
  end

  // RVFI interface logic
`ifdef RISCV_FORMAL
  assign rvfi_valid = 1'b1;  // Check
  assign rvfi_order = rvfi_order_reg;  // Placeholder, should be replaced with actual order logic
  assign rvfi_insn = Instr;
  // assign rvfi_trap = 1'b0;
  // assign rvfi_halt = 1'b0;
  // assign rvfi_intr = 1'b0;
  assign rvfi_mode = 2'b11;  // Assuming M-Mode (3)
  assign rvfi_pc_rdata = PC;
  assign rvfi_pc_wdata = PCNext;
  assign rvfi_rs1_addr = Instr[19:15];
  assign rvfi_rs2_addr = Instr[24:20];
  assign rvfi_rs1_rdata = SrcA;
  assign rvfi_rs2_rdata = WriteData;
  assign rvfi_rd_addr = Instr[11:7];
  assign rvfi_rd_wdata = Instr[11:7] != 5'b0 ? Result : 0;
  assign rvfi_mem_addr = ALUResult;
  // assign rvfi_mem_rmask = (MemWrite) ? 4'b0000 : 4'b1111;
  // assign rvfi_mem_wmask = (MemWrite) ? 4'b1111 : 4'b0000;
  assign rvfi_mem_rdata = ReadData;
  assign rvfi_mem_wdata = WriteData;
`endif

endmodule

// Contents of imem.sv
module imem (
    input  logic [31:0] a,
    output logic [31:0] rd
);

  logic [31:0] RAM[63:0];

  //initial
    // $readmemh("/home/trainee11/rohith/RISC-V/single_cycle_processor_risc_v/Single_Cycle_Processor/riscvtest.txt", RAM);

  assign rd = RAM[a[31:2]];  // word aligned

endmodule


// Contents of dmem.sv
module dmem (
    input  logic        clk,
    we,
    input  logic [31:0] a,
    wd,
    output logic [31:0] rd
);

  logic [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]];  // word aligned


  //only for testing, wont synthesize
  //addi s0, zero, 0
  //lw s0, 0(s0)
  //lh s1, 0(s0)
  //lb s2, 0(s0)
  //sw s0, 63(s0)

  /*initial begin
   RAM[32'h00_00_00_00]  = 32'hFACEFACE;
   RAM[1]  = 32'h00000002; 
   RAM[2]  = 32'h00000003; 
   
   RAM[63] = 32'h00000063;  // Should be replaced by FACE
end*/



  always @(posedge clk) if (we) RAM[a[31:2]] <= wd;

endmodule


// Contents of controller.sv
module controller (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic       Zero,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic       PCSrc,
    ALUSrc,
    output logic       RegWrite,
    Jump,  // Jump extra
    output logic [1:0] ImmSrc,
    output logic [2:0] ALUControl
);

  logic [1:0] ALUOp;
  logic       Branch;

  maindec md (
      op,
      ResultSrc,
      MemWrite,
      Branch,
      ALUSrc,
      RegWrite,
      Jump,
      ImmSrc,
      ALUOp
  );

  aludec ad (
      op[5],
      funct3,
      funct7b5,
      ALUOp,
      ALUControl
  );

  assign PCSrc = Branch & Zero | Jump;

endmodule


// Contents of maindec.sv
module maindec (
    input  logic [6:0] op,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic       Branch,
    ALUSrc,
    output logic       RegWrite,
    Jump,
    output logic [1:0] ImmSrc,
    output logic [1:0] ALUOp
);

  logic [10:0] controls;

  assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

  always_comb
    case (op)  // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R–type
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I–type ALU
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      default:    controls = 11'bx_xx_x_x_xx_x_xx_x; // ??? 
    endcase

endmodule


// Contents of aludec.sv
module aludec (
    input  logic       opb5,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic [1:0] ALUOp,
    output logic [2:0] ALUControl
);

  logic RtypeSub;

  assign RtypeSub = funct7b5 & opb5;  // TRUE for R–type subtract

  always_comb
    case (ALUOp)
      2'b00: ALUControl = 3'b000;  // addition
      2'b01: ALUControl = 3'b001;  // subtraction
      default:
      case (funct3)  // R–type or I–type ALU
        3'b000:
        if (RtypeSub) ALUControl = 3'b001;  // sub
        else ALUControl = 3'b000;  // add, addi
        3'b010: ALUControl = 3'b101;  // slt, slti
        3'b110: ALUControl = 3'b011;  // or, ori
        3'b111: ALUControl = 3'b010;  // and, andi
        default: ALUControl = 3'bxxx;  // ??? 
      endcase
    endcase

endmodule



// Contents of flopr.sv
module flopr #(
    parameter WIDTH = 8
) (
    input logic clk,
    reset,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else q <= d;

endmodule


// Contents of adder.sv
module adder (
    input  [31:0] a,
    b,
    output [31:0] y
);

  assign y = a + b;

endmodule


// Contents of mux2.sv
module mux2 #(
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0] d0,
    d1,
    input  logic             s,
    output logic [WIDTH-1:0] y
);

  assign y = s ? d1 : d0;

endmodule


// Contents of regfile.sv
module regfile (
    input logic clk,
    input logic we3,
    input logic [4:0] a1,
    a2,
    a3,  // Changed
    input logic [31:0] wd3,
    output logic [31:0] rd1,
    rd2
);

  logic [31:0] rf[31:0];

  // three ported register file
  // read two ports combinationally (A1/RD1, A2/RD2)
  // write third port on rising edge of clock (A3/WD3/WE3)
  // register 0 hardwired to 0
  always_ff @(posedge clk) if (we3 && a3 != 5'b0) rf[a3] <= wd3;

  assign rd1 = (a1 != 0) ? rf[a1] : 0;
  assign rd2 = (a2 != 0) ? rf[a2] : 0;

endmodule


// Contents of extend.sv
module extend (
    input  logic [31:7] instr,
    input  logic [ 1:0] immsrc,
    output logic [31:0] immext
);

  always_comb
    case (immsrc)
      2'b00: immext = {{20{instr[31]}}, instr[31:20]};  // I−type
      2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};  // S−type (stores)
      2'b10:
      immext = {
        {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0
      };  // B−type (branches)
      2'b11:
      immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};  // J−type (jal)
      default: immext = 32'bx;  // undefined
    endcase

endmodule


// Contents of alu.sv
module alu (
    input  logic [31:0] SrcA,
    SrcB,
    input  logic [ 2:0] ALUControl,
    output logic [31:0] ALUResult,
    output logic        Zero
);


  //logic [31:0]	ResultReg;
  logic [31:0] temp, Sum;
  logic V, slt, sltu;  //overflow

  //~SrcB if SrcALUControl[0] is set 1 for subtraction (R Type]
  assign temp = ALUControl[0] ? ~SrcB : SrcB;

  //Sum is SrcAddition of A + SrcB + 0 or
  //Sum is suSrcBtrSrcAction of A + ~B + 1 <2's complement>
  assign Sum = SrcA + temp + ALUControl[0];

  //checks for overflow if result hSrcAs different sign than operands  
  assign slt = (SrcA[31] == SrcB[31]) ? (SrcA < SrcB) : SrcA[31]; // because for signed numbers, of both are of same sign, we can compare A and B, but if they are of different sign we can take the MSB of A
  //if SrcA is positive and SrcB is negative => A is not less than B, slt = 0 ie. A[31]
  //if SrcA is negative and SrcB is positive -> A is definitely lass than B, so slt = 1 ie. A[31]

  assign sltu = SrcA < SrcB; //for unsigned number comparison, this will give a boolean output (true - 1, false - 0)



  assign Zero = (ALUResult == 32'b0);

  always_comb
    case (ALUControl)
      3'b000: ALUResult <= Sum;  // Add
      3'b001: ALUResult <= Sum;  // Sub
      3'b010: ALUResult <= SrcA & SrcB;  // and
      3'b011: ALUResult <= SrcA | SrcB;  // or
      3'b100: ALUResult <= SrcA ^ SrcB;  // xor Extra

      3'b101:  ALUResult <= {31'b0, slt};  //slt
      3'b110:  ALUResult <= {31'b0, sltu};  // sltu Extra
      3'b111:  ALUResult <= {SrcA[31:12], 12'b0};  //lui Extra
      default: ALUResult <= 31'bx;
    endcase
endmodule


// Contents of mux3.sv
module mux3 #(
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0] d0,
    d1,
    d2,
    input  logic [      1:0] s,
    output logic [WIDTH-1:0] y
);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0);

endmodule


