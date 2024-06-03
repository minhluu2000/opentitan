// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

//
// A counter module that drives the ROM accesses from the checker.
//
// This module doesn't need state hardening: an attacker that glitches its behaviour can stall the
// chip or read ROM data in the wrong order. Assuming we've picked a key for the ROM that ensures
// all words have different values, exploiting a glitch in this module to hide a ROM modification
// would still need a pre-image attack on SHA-3.
//
// RomDepth is the number of words in the ROM. RomTopCount is the number of those words (at the top
// of the address space) that are considered part of the expected hash.
//
// When it comes out of reset, the module starts reading from address zero. Once the reading is
// done, it will signal done_o. The surrounding (hardened) design should check that done_o never has
// a high -> low transition.
//
// The read_addr_o signal should be connected to the stateful mux that controls access to ROM. This
// mux gives access to the rom_ctrl_counter until done_o is asserted. The data_addr_o signal gives
// the address of the ROM word that was just read.
//
// The data_* signals are used to handshake with KMAC, although the surrounding FSM will step in
// once we've got to the top of memory. The counter uses the output buffer on the ROM instance to
// hold data and drives rom_addr_o and data_vld_o to make a rdy/vld interface with the ROM output.
// This interface should signal things correctly until done_o goes high. data_last_nontop_o is set
// on the last word before the top RomTopCount words.
//

`include "prim_assert.sv"

module rom_ctrl_counter
    import prim_util_pkg::vbits;
#(
    parameter int RomDepth = 16,
    parameter int RomTopCount = 2
) (
    input clk_i,
    input rst_ni,

    output done_o,

    output [vbits(RomDepth)-1:0] read_addr_o,
    output                       read_req_o,

    output [vbits(RomDepth)-1:0] data_addr_o,

    input  data_rdy_i,
    output data_last_nontop_o
);

    // The number of ROM entries that should be hashed. We assume there are at least 2, so that we can
    // register the data_last_nontop_o signal.
    localparam int RomNonTopCount = RomDepth - RomTopCount;

    `ASSERT_INIT(TopCountValid_A, 1 <= RomTopCount && RomTopCount < RomDepth)
    `ASSERT_INIT(NonTopCountValid_A, 2 <= RomNonTopCount)

    localparam int AW = vbits(RomDepth);

    localparam int unsigned TopAddrInt = RomDepth - 1;
    localparam int unsigned TNTAddrInt = RomNonTopCount - 2;

    localparam bit [AW-1:0] TopAddr = TopAddrInt[AW-1:0];
    localparam bit [AW-1:0] TNTAddr = TNTAddrInt[AW-1:0];

    logic go;
    logic req_q, vld_q;
    logic [AW-1:0] addr_q, addr_d;
    logic done_q, done_d;
    logic last_nontop_q, last_nontop_d;

    assign done_d = addr_q == TopAddr;

    initial begin
`ifdef BUGNUMCNR1
        $display("BUGNUMCNR1 is introduced");
`elsif BUGNUMCNR2
        $display("BUGNUMCNR2 is introduced");
`elsif BUGNUMCNR3
        $display("BUGNUMCNR3 is introduced");
`elsif BUGNUMCNR4
        $display("BUGNUMCNR4 is introduced");
`elsif BUGNUMCNR5
        $display("BUGNUMCNR5 is introduced");
`elsif BUGNUMCNR6
        $display("BUGNUMCNR6 is introduced");
`elsif BUGNUMCNR7
        $display("BUGNUMCNR7 is introduced");
`elsif BUGNUMCNR8
        $display("BUGNUMCNR8 is introduced");
`elsif BUGNUMCNR9
        $display("BUGNUMCNR9 is introduced");
`elsif BUGNUMCNR1T
        $display("BUGNUMCNR1T is introduced");
`elsif BUGNUMCNR2T
        $display("BUGNUMCNR2T is introduced");
`elsif BUGNUMCNR3T
        $display("BUGNUMCNR3T is introduced");
`elsif BUGNUMCNR4T
        $display("BUGNUMCNR4T is introduced");
`elsif BUGNUMCNR5T
        $display("BUGNUMCNR5T is introduced");
`endif
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
`ifdef BUGNUMCNR1
            done_q <= 1'b1;  // Bug 1: Buggy code
`elsif BUGNUMCNR1T
            done_q <= addr_q == TopAddr;  // Bug 1T: Test code
`else
            done_q <= 1'b0;  // Bug 1: Original code
`endif
        end else begin
`ifdef BUGNUMCNR2
            done_q <= last_nontop_d;
`else
            done_q <= done_d;
`endif
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
`ifdef BUGNUMCNR3
            addr_q <= 1'b1;  // Bug 3: Buggy code
`else
            addr_q <= '0;  // Bug 3: Original code
`endif
            last_nontop_q <= 1'b0;
        end else if (go) begin
`ifdef BUGNUMCNR4
            addr_q <= TNTAddr;  // Bug 4: Buggy code
`else
            addr_q <= addr_d;  // Bug 4: Original code
`endif
            last_nontop_q <= last_nontop_d;
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            req_q <= 1'b0;
            vld_q <= 1'b0;
        end else begin
            // The first ROM request goes out immediately after reset (once we reach the top of ROM, we
            // signal done_o, after which the request signal is unused). We could clear it again when we
            // are done, but there's no need: the mux will switch away from us anyway.
`ifdef BUGNUMCNR2T
            req_q <= 1'b0;
`elsif BUGNUMCNR5
            req_q <= 1'bz;
`else
            req_q <= 1'b1;
`endif

            // ROM data is valid from one cycle after the request goes out.
`ifdef BUGNUMCNR6
            vld_q <= 1'b0;  // Bug 6: Buggy code
`elsif BUGNUMCNR3T
            vld_q <= done_d;  // Bug 6: Test code
`else
            vld_q <= req_q;  // Bug 6: Original code
`endif
        end
    end
`ifdef BUGNUMCNR7
    assign go = data_rdy_i & vld_q;  // Bug 7: Buggy code
`elsif BUGNUMCNR3T
    assign go = data_rdy_i & ~done_d;  // Bug 7: Test code
`elsif BUGNUMCNR4T
    assign go = data_rdy_i;  // Bug 7: Test code
`else
    assign go = data_rdy_i & vld_q & ~done_d;  // Bug 7: Original code
`endif

`ifdef BUGNUMCNR8
    assign addr_d = addr_q + {{AW - 1{1'b1}}, 1'b1};  // Bug 8: Buggy code
`else
    assign addr_d = addr_q + {{AW - 1{1'b0}}, 1'b1};  // Bug 8: Original code
`endif
`ifdef BUGNUMCNR5T
    assign last_nontop_d = addr_q != TNTAddr;  // Bug 5: Test code
`else
    assign last_nontop_d = addr_q == TNTAddr;  // Bug 5: Original code
`endif
    assign done_o = done_q;
`ifdef BUGNUMCNR9
    assign read_addr_o = addr_d;  // Bug 9: Buggy code
`else
    assign read_addr_o = go ? addr_d : addr_q;  // Bug 9: Original code
`endif
    assign read_req_o         = req_q;
    assign data_addr_o        = addr_q;
    assign data_last_nontop_o = last_nontop_q;

endmodule
