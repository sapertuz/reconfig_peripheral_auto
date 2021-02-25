# 1-5 Synthesize RM
foreach module [array get reconf_mod_name] {
    read_verilog [glob $r_modules_dir/rp_${module}/*]
    synth_design -mode out_of_context -flatten_hierarchy rebuilt -top $reconfig_top_name -part $device_name
    file mkdir $synth_reconfmod_dir/rp_${module}
    write_checkpoint -force $synth_reconfmod_dir/rp_${module}/$reconf_part_name.dcp
    close_design
}
close_project

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