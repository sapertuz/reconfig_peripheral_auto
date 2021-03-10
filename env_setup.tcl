# Configurable Variables 
set project_name "reconfig_peripheral_prj"
## (PYNQ ZYBO or ZED)
set BOARD_GLOBAL "PYNQ"
## Reconfigurable Modules
array set reconf_mod_name {
    1 magnet_1
    2 magnet_2
    3 magnet_3
    4 magnet_4
    5 magnet_5
}
##                  vendor:library:name:version
set reconfig_ip "user.org:user:ml_regressor:1.0"
set reconfig_ip_name "ml_regressor_0"
set reconfig_top_name "wrapper_regressor"
set reconfig_ip_axi_port "S00_AXI"
set reconfig_top_label "ml_regressor_v1_0_${reconfig_ip_axi_port}_inst/my_regressor"
set reconfig_inst "U0"

set hdl_lang "vhdl"

set reconf_part_name "magnet_synth"
set reconf_chckpt_name "top_link_magnet"
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
set sdk_dir $proj_dir/$project_name.sdk

switch -exact $BOARD_GLOBAL {
    PYNQ {  set board_name  "www.digilentinc.com:pynq-z1:part0:1.0"
            set device_name "xc7z020clg400-1"}
    default {}
}
switch -exact $BOARD_GLOBAL {
    PYNQ {  set slice_plan "SLICE_X52Y1:SLICE_X111Y48"
            set dsp48_plan "DSP48_X3Y2:DSP48_X4Y17"}
    default {}
}
set bd_design_name "system"
set decouple_ip "xilinx.com:ip:pr_decoupler:1.0"
## Reconfig Module
## SDK variables
set bsp_fat "bsp_fat"
set app_name "TestApp"