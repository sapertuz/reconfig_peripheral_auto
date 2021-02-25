# Set some info of the project
source start_variables.tcl

# Clear file system
catch {file delete -force {*}[glob -nocomplain $impl_dir/*]}
catch {file delete -force {*}[glob -nocomplain $synth_static_dir/*]}
catch {file delete -force {*}[glob -nocomplain $synth_reconfmod_dir/*]}
catch {file delete -force {*}[glob -nocomplain $bitstr_dir/*]}
catch {file delete -force {*}[glob -nocomplain $chckpt_dir/*]}

# 1-1 -> 1-3 Create project add modules, decoupler, and make connections 
source ps7_create.tcl
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
## Close project
close_project

# 1-5 Synthesize RM
source synth_reconfig_modules.tcl

# 2 Load Static RM for the RP in Vivado (check rp_instance IS_BLACKBOX checkbox is checked)
source load_design_checkpoints.tcl

# 3 Define Reconfigurable Properties on each RM
set_property HD.RECONFIGURABLE 1 [get_cells system_i/$reconfig_ip_name/inst/$reconfig_top_label]
write_checkpoint -force $chckpt_dir/$reconf_chckpt_name.dcp

# 4 - 5 Define Reconfigurable Properties on each RM
## Here I have to check the size
set pblock_name pblock_rp_instance
set pblock_slice_dsp {SLICE_X34Y109:SLICE_X47Y124 DSP48_X2Y44:DSP48_X2Y49}
startgroup
    create_pblock $pblock_name
    resize_pblock $pblock_name -add $pblock_slice_dsp
    add_cells_to_pblock $pblock_name [get_cells [list system_i/$reconfig_ip_name/inst/$reconfig_top_label]] -clear_locs
endgroup
## save pblock and properties
write_xdc $fplan_dir/fplan.xdc -force
close_project

# 6 - 7 Create and Implement Reconfigurable and Blanking Configurations
open_checkpoint $chckpt_dir/$reconf_chckpt_name.dcp
read_xdc  $fplan_dir/fplan.xdc

source create_modules_configuration.tcl
source create_blanking_configuration.tcl

# 8 Verify configurations
source verify_configurations.tcl

# 9 Generate Bitstream
source generate_bitstreams.tcl
