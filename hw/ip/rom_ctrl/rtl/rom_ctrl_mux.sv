// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

//
// The mux to select between ROM inputs
//

module rom_ctrl_mux
    import prim_mubi_pkg::mubi4_t;
#(
    parameter int AW = 8,
    parameter int DW = 39
) (
    input logic clk_i,
    input logic rst_ni,

    // Select signal saying whether access is granted to the bus. This module raises an alert (by
    // setting alert_o) if the signal isn't an allowed value or if the selection switches back from
    // the bus to the checker.
    input mubi4_t sel_bus_i,

    // Interface for bus
    input  logic [AW-1:0] bus_rom_addr_i,
    input  logic [AW-1:0] bus_prince_addr_i,
    input  logic          bus_req_i,
    output logic          bus_gnt_o,
    output logic [DW-1:0] bus_rdata_o,
    output logic          bus_rvalid_o,

    // Interface for ROM checker
    input  logic [AW-1:0] chk_addr_i,
    input  logic          chk_req_i,
    output logic [DW-1:0] chk_rdata_o,

    // Interface for ROM
    output logic [AW-1:0] rom_rom_addr_o,
    output logic [AW-1:0] rom_prince_addr_o,
    output logic          rom_req_o,
    input  logic [DW-1:0] rom_scr_rdata_i,
    input  logic [DW-1:0] rom_clr_rdata_i,
    input  logic          rom_rvalid_i,

    // Alert output
    //
    // This isn't latched in this module because it feeds into a fatal alert at top-level, whose
    // sender will latch it anyway.
    output logic alert_o
);

    import prim_mubi_pkg::*;

    // Track the state of the mux up to the current cycle. This is a "1-way" mux, which means that
    // we never switch from the bus back to the checker.
    //
    // We also have a version that's delayed by a single cycle to allow a check that sel_bus_q is
    // never reset from True to False.
    logic [3:0] sel_bus_q_raw, sel_bus_qq_raw;
    mubi4_t sel_bus_q, sel_bus_qq;

    prim_flop #(
        .Width(4),
        .ResetValue({MuBi4False})
    ) u_sel_bus_q_flop (
        .clk_i,
        .rst_ni,
        .d_i(mubi4_or_hi(sel_bus_q, sel_bus_i)),
        .q_o(sel_bus_q_raw)
    );
    assign sel_bus_q = mubi4_t'(sel_bus_q_raw);

    prim_flop #(
        .Width(4),
        .ResetValue({MuBi4False})
    ) u_sel_bus_qq_flop (
        .clk_i,
        .rst_ni,
        .d_i(sel_bus_q),
        .q_o(sel_bus_qq_raw)
    );

    initial begin
`ifdef BUGNUMMUX1
        $display("BUGNUMMUX1 is introduced");
`elsif BUGNUMMUX2
        $display("BUGNUMMUX2 is introduced");
`elsif BUGNUMMUX3
        $display("BUGNUMMUX3 is introduced");
`elsif BUGNUMMUX4
        $display("BUGNUMMUX4 is introduced");
`elsif BUGNUMMUX5
        $display("BUGNUMMUX5 is introduced");
`elsif BUGNUMMUX6
        $display("BUGNUMMUX6 is introduced");
`elsif BUGNUMMUX7
        $display("BUGNUMMUX7 is introduced");
`elsif BUGNUMMUX8
        $display("BUGNUMMUX8 is introduced");
`elsif BUGNUMMUX1T
        $display("BUGNUMMUX1T is introduced");
`elsif BUGNUMMUX2T
        $display("BUGNUMMUX2T is introduced");
`elsif BUGNUMMUX3T
        $display("BUGNUMMUX3T is introduced");
`elsif BUGNUMMUX4T
        $display("BUGNUMMUX4T is introduced");
`elsif BUGNUMMUX5T
        $display("BUGNUMMUX5T is introduced");
`elsif BUGNUMMUX6T
        $display("BUGNUMMUX6T is introduced");
`endif
    end

    assign sel_bus_qq = mubi4_t'(sel_bus_qq_raw);

    // Spot if the sel_bus_i signal or its register version has a corrupt value.
    //
    // SEC_CM: MUX.MUBI
    logic sel_invalid;
`ifdef BUGNUMMUX1
    assign sel_invalid = 1'b1;
`elsif BUGNUMMUX2
    assign sel_invalid = 1'b0;
`elsif BUGNUMMUX3
    assign sel_invalid = 1'bx;
`elsif BUGNUMMUX1T
    assign sel_invalid = 1'bz;
`else
    assign sel_invalid = mubi4_test_invalid(sel_bus_i) || mubi4_test_invalid(sel_bus_q);
`endif

    // Spot if the select signal switches back to the checker once we've switched to the bus. Doing so
    // will have no lasting effect because of how we calculate sel_bus_q) but isn't supposed to
    // happen, so we want to trigger an alert.
    //
    // SEC_CM: MUX.CONSISTENCY
    logic sel_reverted;
`ifdef BUGNUMMUX4
    assign sel_reverted = mubi4_test_true_loose(sel_bus_q) ^ mubi4_test_false_loose(sel_bus_i);
`elsif BUGNUMMUX2T
    assign sel_reverted = mubi4_test_true_loose(sel_bus_q) | mubi4_test_false_loose(sel_bus_i);
`elsif BUGNUMMUX3T
    assign sel_reverted = mubi4_test_true_loose(sel_bus_q);
`else
    assign sel_reverted = mubi4_test_true_loose(sel_bus_q) & mubi4_test_false_loose(sel_bus_i);
`endif
    // Spot if the sel_bus_q signal has reverted somehow.
    //
    // SEC_CM: MUX.CONSISTENCY
    logic sel_q_reverted;
`ifdef BUGNUMMUX5
    assign sel_q_reverted = mubi4_test_true_loose(sel_bus_qq) | mubi4_test_false_loose(sel_bus_q);
`elsif BUGNUMMUX4T
    assign sel_q_reverted = mubi4_test_true_loose(sel_bus_qq) ^ mubi4_test_false_loose(sel_bus_q);
`else
    assign sel_q_reverted = mubi4_test_true_loose(sel_bus_qq) & mubi4_test_false_loose(sel_bus_q);
`endif

    logic alert_q, alert_d;
`ifdef BUGNUMMUX6
    assign alert_d = sel_invalid ^ sel_q_reverted;
`elsif BUGNUMMUX5T
    assign alert_d = sel_invalid;
`else
    assign alert_d = sel_invalid | sel_reverted | sel_q_reverted;
`endif

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            alert_q <= 0;
        end else begin
`ifdef BUGNUMMUX7
            alert_q <= alert_q ^ alert_d;
`else
            alert_q <= alert_q | alert_d;
`endif

        end
    end

`ifdef BUGNUMMUX6T
    assign alert_o = 1'b1;
`else
    assign alert_o = alert_q;
`endif

    // The bus can have access every cycle, from when the select signal switches to the bus.
    assign bus_gnt_o    = mubi4_test_true_strict(sel_bus_i);
    assign bus_rdata_o  = rom_clr_rdata_i;
    // A high rom_rvalid_i is a response to a bus request if the select signal pointed at the bus on
    // the previous cycle.
    assign bus_rvalid_o = mubi4_test_true_strict(sel_bus_q) & rom_rvalid_i;

    assign chk_rdata_o  = rom_scr_rdata_i;

`ifdef BUGNUMMUX8
    assign rom_req_o = mubi4_test_true_strict(sel_bus_i) ? bus_req_i : bus_req_i;
`else
    assign rom_req_o = mubi4_test_true_strict(sel_bus_i) ? bus_req_i : chk_req_i;
`endif
    assign rom_rom_addr_o    = mubi4_test_true_strict(sel_bus_i) ? bus_rom_addr_i : chk_addr_i;
    assign rom_prince_addr_o = mubi4_test_true_strict(sel_bus_i) ? bus_prince_addr_i : chk_addr_i;

endmodule
