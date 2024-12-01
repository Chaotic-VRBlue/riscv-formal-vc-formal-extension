# Simple TCL script for VC Formal

# Set reset behavior without permanent constraint
set reset_without_constraint 1

# Configure VC Formal environment and application variables
setenv VERDI_COLOR_THEME brightPlus
set_fml_appmode FPV
set_app_var apply_bind_in_all_units true
set_app_var analyze_skip_translate_body false
set_app_var fml_auto_save default
set_app_var fml_composite_trace true
set_fml_var fml_witness_on true
set_fml_var fml_vacuity_on true

# Set paths to libraries and design files
cd [file dirname [info script]]

# Analyze design files
analyze -format sverilog -vcs -verbose {
    ../../../../checks/rvfi_macros.vh
    defines.sv
    ../../../../checks/rvfi_channel.sv
    ../../../../checks/rvfi_testbench.sv
    ../../../../checks/rvfi_reg_check.sv
    ../../wrapper.sv
    ../../scrv32i.sv
}

# Set the correct top module
set top rvfi_testbench

# Elaborate the top module
set elaborateOption -verbose 
elaborate $top -verbose -sva

create_clock clock -period 200
if {$reset_without_constraint} {
    sim_force reset -apply 1'b1
} else {
    create_reset reset -sense high
}

# For Batch
check_fv -block
report_fv -list > reg_ch0_results.txt
save_session -session reg_ch0_results

