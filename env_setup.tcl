###--------------------------------------------------------###
# Absolutely ALL of these parameters should be reviewed and changed 
# Configurable Variables 
set project_name "reconfig_peripheral_prj"
## (PYNQ ZYBO or ZED)
set BOARD_GLOBAL "PYNQ"
## Reconfigurable Modules
array set reconf_mod_name {
    add
    mult
}
##                  vendor:library:name:version
set reconfig_ip "xilinx.com:XUP:math:1.0"
set reconfig_ip_name "math_0"
set reconfig_top_name "rp"
set reconfig_ip_axi_port "S_AXI"
set reconfig_top_label "math_v1_0_S_AXI_inst/rp_instance"
set reconfig_inst "inst"

set hdl_lang "verilog"

set reconf_part_name "add_mult_synth"
set reconf_chckpt_name "top_link_add"
set static_dsn "static_route_design"

###--------------------------------------------------------###
# This can also tecnically be configured but I dont recommend 
# it unless you know what you are doing

## Set paths
set proj_dir "./${project_name}"
set ip_repo_dir "./Sources/ip_repo"
set r_modules_dir "./Sources/reconfig_modules"
set fplan_dir "./Sources/xdc"
set testapp_dir "./Sources/TestApp/src"
set synth_static_dir "./Synth/Static"
set synth_reconfmod_dir "./Synth/reconfig_modules"
set chckpt_dir "./Checkpoint"
set impl_dir "./Implement"
set bitstr_dir "./Bitstreams"
set sdk_dir $proj_dir/$project_name.vitis

switch -exact $BOARD_GLOBAL {
    PYNQ {  set board_name  "www.digilentinc.com:pynq-z1:part0:1.0"
            set device_name "xc7z020clg400-1"}
    ZED {   set board_name "digilentinc.com:zedboard:part0:1.0"
            set device_name "xc7z020clg484-1"}
    default {set board_name "www.digilentinc.com:pynq-z1:part0:1.0"}
}
switch -exact $BOARD_GLOBAL {
    PYNQ {  set slice_plan "SLICE_X34Y109:SLICE_X39Y123"
            set dsp48_plan "DSP48_X2Y44:DSP48_X2Y47"}
    ZED {   set slice_plan "SLICE_X34Y109:SLICE_X39Y123"
            set dsp48_plan "DSP48_X2Y44:DSP48_X2Y47"}
    ZYBO {  set slice_plan "SLICE_X8Y50:SLICE_X13Y64"
            set dsp48_plan "DSP48_X0Y20:DSP48_X0Y25"}
    default {}
}
set bd_design_name "system"
set decouple_ip "xilinx.com:ip:pr_decoupler:1.0"
## Reconfig Module
## SDK variables
set bsp_fat "bsp_fat"
set app_name "TestApp"