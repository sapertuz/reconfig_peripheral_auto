set project_name "reconfig_peripheral_prj"

## Set paths
set proj_dir "./${project_name}"
set ip_repo_dir "./Sources/ip_repo"
set r_modules_dir "./Sources/reconfig_modules"
set fplan_dir "./Sources/xdc"
set synth_static_dir "./Synth/Static"
set synth_reconfmod_dir "./Synth/reconfig_modules"
set chckpt_dir "./Checkpoint"
set impl_dir "./Implement"
set bitstr_dir "./Bitstreams"
## Reconfigurable Modules
array set reconf_mod_name {
    add
    mult
}
set reconf_part_name "add_mult_synth"
set reconf_chckpt_name "top_link_add"
set static_dsn "static_route_design"

## Project Variables
set board_name "www.digilentinc.com:pynq-z1:part0:1.0"
set bd_design_name "system"
##                   vendor:library:name:version
set reconfig_ip "xilinx.com:XUP:math:1.0"
set decouple_ip "xilinx.com:ip:pr_decoupler:1.0"
## Reconfig Module
set reconfig_ip_name "math_0"
set reconfig_top_name "rp"
set reconfig_top_label "math_v1_0_S_AXI_inst/rp_instance"