// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class rv_dm_base_vseq extends cip_base_vseq #(
    .RAL_T               (rv_dm_regs_reg_block),
    .CFG_T               (rv_dm_env_cfg),
    .COV_T               (rv_dm_env_cov),
    .VIRTUAL_SEQUENCER_T (rv_dm_virtual_sequencer)
  );
  `uvm_object_utils(rv_dm_base_vseq)
  `uvm_object_new

  // Randomize the initial inputs to the DUT.
  rand lc_ctrl_pkg::lc_tx_t   lc_hw_debug_en;
  rand prim_mubi_pkg::mubi4_t scanmode;
  rand logic [NUM_HARTS-1:0]  unavailable;

  rand int unsigned tck_period_ps;
  constraint tck_period_ps_c {
    tck_period_ps dist {
      [100_000:200_000] :/ 1,  // 5-10MHz
      [200_001:420_000] :/ 1,  // 2.4-5MHz
      [420_001:1000_000] :/ 1  // 1-2.4MHz
    };
  }

  // SBA TL device sequence. Class member for more controllability.
  protected cip_tl_device_seq m_tl_sba_device_seq;

  // Handles for convenience.
  jtag_dtm_reg_block jtag_dtm_ral;
  jtag_dmi_reg_block jtag_dmi_ral;
  rv_dm_mem_reg_block tl_mem_ral;
  dv_base_reg_block dv_base_ral;

  virtual function void set_handles();
    super.set_handles();
    jtag_dtm_ral = cfg.m_jtag_agent_cfg.jtag_dtm_ral;
    jtag_dmi_ral = cfg.jtag_dmi_ral;
    dv_base_ral = cfg.ral_models["rv_dm_mem_reg_block"];
    `downcast(tl_mem_ral,dv_base_ral);
  endfunction

  task pre_start();
    // Initialize the input signals with defaults at the start of the sim.
    `DV_CHECK_MEMBER_RANDOMIZE_FATAL(lc_hw_debug_en)
    `DV_CHECK_MEMBER_RANDOMIZE_FATAL(scanmode)
    `DV_CHECK_MEMBER_RANDOMIZE_FATAL(unavailable)

    cfg.rv_dm_vif.lc_hw_debug_en <= lc_hw_debug_en;
    cfg.rv_dm_vif.scanmode <= scanmode;
    cfg.rv_dm_vif.unavailable <= unavailable;

    // TODO(#23096): We're currently wiring all the enable signals to match lc_hw_debug_en and
    //               hard-coding the late debug enable flag to be true. These eventually need to be
    //               separately controlled.
    cfg.rv_dm_vif.pinmux_hw_debug_en       <= lc_hw_debug_en;
    cfg.rv_dm_vif.lc_dft_en                <= lc_hw_debug_en;
    cfg.rv_dm_vif.otp_dis_rv_dm_late_debug <= prim_mubi_pkg::MuBi8True;

    // If we've just enabled debug, it might be that the JTAG interface was previously disconnected
    // and we need to tell the jtag driver (which monitors its internal state) to start again.
    //
    // Note that we also want to do this at the start of the simulation. If this doesn't happen, you
    // can end up in a situation where jtag_driver sees the posedge on trst_n (not yet connected)
    // and starts to run reset_internal_state. After a few cycles, the debug enable signal makes it
    // through u_prim_lc_sync_lc_hw_debug_en and the jtag interface gets connected to the DAP... for
    // the second half of the reset sequence.
    if (lc_ctrl_pkg::lc_tx_test_true_strict(lc_hw_debug_en)) begin
      cfg.m_jtag_agent_cfg.jtag_if_connected.trigger();
    end

    super.pre_start();
  endtask

  virtual task dut_init(string reset_kind = "HARD");
    super.dut_init();
    // TODO: Randomize the contents of the debug ROM & the program buffer once out of reset.

    // We would like to do a DMI transaction here. If this vseq is the first with debug enabled, the
    // "enable" signal will need to make it through the a prim_lc_sync in the design before it takes
    // effect. Fortunately, we can see that this has happened by looking at the trst_n signal: it
    // will go high once everything has been connected. *That* signal is exposed through jtag_mon_if
    // in the tb, which is visible through the jtag agent's mon_vif interface.
    wait(cfg.m_jtag_agent_cfg.mon_vif.trst_n);

    // "Activate" the DM to facilitate ease of testing.
    csr_wr(.ptr(jtag_dmi_ral.dmcontrol.dmactive), .value(1), .blocking(1), .predict(1));

    // Start the SBA TL device seq.
    sba_tl_device_seq_start();
  endtask

  // Have scan reset also applied at the start.
  virtual task apply_reset(string kind = "HARD");
    cfg.m_jtag_agent_cfg.vif.set_tck_period_ps(tck_period_ps);
    fork
      if (kind inside {"HARD", "TRST"}) begin
        jtag_dtm_ral.reset("HARD");
        jtag_dmi_ral.reset("HARD");
        cfg.m_jtag_agent_cfg.vif.do_trst_n();
      end
      if (kind inside {"HARD", "SCAN"}) apply_scan_reset();
      super.apply_reset(kind);
    join
  endtask

  // Apply scan reset.
  virtual task apply_scan_reset();
    uint delay;
    `DV_CHECK_STD_RANDOMIZE_WITH_FATAL(delay, delay inside {[0:1000]};) // ns
    #(delay * 1ns);
    cfg.rv_dm_vif.cb.scan_rst_n <= 1'b0;
    // Wait for core clock cycles.
    `DV_CHECK_STD_RANDOMIZE_WITH_FATAL(delay, delay inside {[2:50]};) // cycles
    cfg.clk_rst_vif.wait_clks(delay);
    `DV_CHECK_STD_RANDOMIZE_WITH_FATAL(delay, delay inside {[0:1000]};) // ns
    cfg.rv_dm_vif.cb.scan_rst_n <= 1'b1;
  endtask

  virtual task apply_resets_concurrently(int reset_duration_ps = 0);
    int trst_n_duration_ps = cfg.m_jtag_agent_cfg.vif.tck_period_ps * $urandom_range(5, 20) *
        1000_000;
    cfg.rv_dm_vif.cb.scan_rst_n <= 1'b0;
    cfg.m_jtag_agent_cfg.vif.trst_n <= 1'b0;
    super.apply_resets_concurrently(dv_utils_pkg::max2(reset_duration_ps, trst_n_duration_ps));
    cfg.m_jtag_agent_cfg.vif.trst_n <= 1'b1;
    cfg.rv_dm_vif.cb.scan_rst_n <= 1'b1;
  endtask

  virtual task dut_shutdown();
    sba_tl_device_seq_stop();
    // Check for pending rv_dm operations and wait for them to complete.
    // TODO: Improve this later.
    cfg.clk_rst_vif.wait_clks(200);
  endtask

  // Spawns off a thread to auto-respond to incoming TL accesses on the SBA host interface.
  virtual task sba_tl_device_seq_start(int min_rsp_delay = 0,
                                       int max_rsp_delay = 80,
                                       int rsp_abort_pct = 25,
                                       int d_error_pct = 0,
                                       int d_chan_intg_err_pct = 0);
    m_tl_sba_device_seq = cip_tl_device_seq::type_id::create("m_tl_sba_device_seq");
    m_tl_sba_device_seq.min_rsp_delay = min_rsp_delay;
    m_tl_sba_device_seq.max_rsp_delay = max_rsp_delay;
    m_tl_sba_device_seq.rsp_abort_pct = rsp_abort_pct;
    m_tl_sba_device_seq.d_error_pct = d_error_pct;
    m_tl_sba_device_seq.d_chan_intg_err_pct = d_chan_intg_err_pct;
    `DV_CHECK_RANDOMIZE_FATAL(m_tl_sba_device_seq)
    `uvm_info(`gfn, "Started running m_tl_sba_device_seq", UVM_MEDIUM)
    fork m_tl_sba_device_seq.start(p_sequencer.tl_sba_sequencer_h); join_none
    // To ensure the seq above starts executing before the code following it starts executing.
    #0;
    // TODO: sba_tl_device_seq_disable_tlul_assert_host_sba_resp_svas();
  endtask

  // Stop running the m_tl_sba_device_seq seq.
  virtual task sba_tl_device_seq_stop();
    m_tl_sba_device_seq.seq_stop();
    `uvm_info(`gfn, "Stopped running m_tl_sba_device_seq", UVM_MEDIUM)
  endtask

  // Task forked off to disable TLUL host SBA assertions when injecting intg errors on the response
  // channel.
  virtual task sba_tl_device_seq_disable_tlul_assert_host_sba_resp_svas();
    fork
      begin: isolation_thread
        fork
          forever @m_tl_sba_device_seq.inject_d_chan_intg_err begin
            cfg.rv_dm_vif.disable_tlul_assert_host_sba_resp_svas =
                m_tl_sba_device_seq.inject_d_chan_intg_err;
          end
          m_tl_sba_device_seq.wait_for_sequence_state(UVM_FINISHED);
        join_any
        disable fork;
      end
    join_none
  endtask
  task write_chk (input uvm_object ptr,input int cmderr,input int command);
    uvm_reg_data_t data;
    uvm_reg_data_t rdata;
    repeat ($urandom_range(1, 10)) begin
      data = $urandom;
      request_halt();
      cfg.clk_rst_vif.wait_clks($urandom_range(0, 1000));
      csr_wr(.ptr(jtag_dmi_ral.command), .value(command));
      csr_wr(.ptr(ptr), .value(data));
      cfg.clk_rst_vif.wait_clks($urandom_range(0, 1000));
      csr_rd(.ptr(jtag_dmi_ral.abstractcs), .value(rdata));
      cfg.clk_rst_vif.wait_clks($urandom_range(0, 1000));
      `DV_CHECK_EQ(cmderr,get_field_val(jtag_dmi_ral.abstractcs.cmderr,rdata));
      cfg.clk_rst_vif.wait_clks($urandom_range(1, 10));
    end
  endtask
  task read_chk (input uvm_object ptr,input int cmderr,input int command);
    uvm_reg_data_t data;
    uvm_reg_data_t rdata;
    repeat ($urandom_range(1, 10)) begin
      data = $urandom;
      request_halt();
      cfg.clk_rst_vif.wait_clks($urandom_range(0, 1000));
      csr_wr(.ptr(jtag_dmi_ral.command), .value(command));
      csr_rd(.ptr(ptr), .value(data));
      cfg.clk_rst_vif.wait_clks($urandom_range(0, 1000));
      csr_rd(.ptr(jtag_dmi_ral.abstractcs), .value(rdata));
      cfg.clk_rst_vif.wait_clks($urandom_range(0, 1000));
      `DV_CHECK_EQ(cmderr,get_field_val(jtag_dmi_ral.abstractcs.cmderr,rdata));
      cfg.clk_rst_vif.wait_clks($urandom_range(1, 10));
    end
  endtask

  // Task to halt the hart.
  task request_halt();
    csr_wr(.ptr(jtag_dmi_ral.dmcontrol.haltreq), .value(1));
    `DV_CHECK_EQ(cfg.rv_dm_vif.cb.debug_req, 1)
    cfg.clk_rst_vif.wait_clks($urandom_range(1, 10));
    csr_wr(.ptr(tl_mem_ral.halted), .value(0));
  endtask

endclass : rv_dm_base_vseq
