# 1-1 -> 1-3 Create project add modules, decoupler, and make connections 
start_gui

## Create project
create_project $project_name ./$project_name -force

## Set project properties
set obj [current_project]
set_property board_part -value $board_name -objects $obj
set_property ip_repo_paths $ip_repo_dir $obj

# Create and construct system
update_ip_catalog
create_bd_design $bd_design_name

# Add and config ZYNQ PS
set obj_ps7 [get_bd_cells processing_system7_0]
startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup

apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

startgroup
    set_property -dict [list CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {0} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {0} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {0}] [get_bd_cells processing_system7_0]
    set_property -dict [list CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {0} CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} CONFIG.PCW_GPIO_EMIO_GPIO_IO {1}] [get_bd_cells processing_system7_0]
endgroup

# Add reconfig module and peripherals
startgroup
    create_bd_cell -type ip -vlnv $reconfig_ip $reconfig_ip_name
endgroup

set obj_decoupler [get_bd_cells pr_decoupler_0]
startgroup
    create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler:1.0 pr_decoupler_0
endgroup
startgroup
    set_property -dict [list CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 HAS_SIGNAL_CONTROL 1 INTF {intf_0 {ID 0 VLNV xilinx.com:interface:aximm_rtl:1.0 PROTOCOL axi4lite MODE slave}}}\
        CONFIG.GUI_HAS_AXI_LITE {false} \
        CONFIG.GUI_HAS_SIGNAL_CONTROL {1} \
        CONFIG.GUI_HAS_SIGNAL_STATUS {false} \
        CONFIG.GUI_INTERFACE_NAME {intf_0} \
        CONFIG.GUI_INTERFACE_PROTOCOL {axi4lite} \
        CONFIG.GUI_SELECT_INTERFACE {0} \
        CONFIG.GUI_SELECT_MODE {slave} \
        CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:aximm_rtl:1.0} \
] [get_bd_cells pr_decoupler_0]
endgroup

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins $reconfig_ip_name/S_AXI]

# Make connections
delete_bd_objs [get_bd_intf_nets ps7_0_axi_periph_M00_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins ps7_0_axi_periph/M00_AXI] [get_bd_intf_pins pr_decoupler_0/s_intf_0]
connect_bd_intf_net [get_bd_intf_pins pr_decoupler_0/rp_intf_0] [get_bd_intf_pins math_0/S_AXI]
connect_bd_net [get_bd_pins processing_system7_0/GPIO_O] [get_bd_pins pr_decoupler_0/decouple]

# Validate design
validate_bd_design
regenerate_bd_layout

# Wrap and save design
make_wrapper -files [get_files $bd_design_name.bd] -top
add_files -norecurse $proj_dir/$project_name.srcs/sources_1/bd/$bd_design_name/hdl/system_wrapper.v
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
save_bd_design

# I dont know why it creates this folder, I eliminate it
file delete -force NA

## Get device name from board
set device_name [get_parts -of_objects [get_projects]]

# 1-4 Synthesize project 
set synth_name synth_1
launch_runs $synth_name -j 4
## Wait run
wait_on_run $synth_name
## Save dcp files in directory
set dcpFiles [glob $proj_dir/$project_name.runs/*/*.dcp]
foreach file $dcpFiles {
   file copy -force $file $synth_static_dir
}
## Export HW
update_compile_order -fileset sources_1
file mkdir $sdk_dir
write_hwdef -force  -file $sdk_dir/system_wrapper.hdf
## Close project
close_project

