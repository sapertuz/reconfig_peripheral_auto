# 2 Load Static RM for the RP in Vivado (check rp_instance IS_BLACKBOX checkbox is checked)
source load_design_checkpoints.tcl

# 3 Define Reconfigurable Properties on each RM
set_property HD.RECONFIGURABLE 1 [get_cells system_i/$reconfig_ip_name/$reconfig_inst/$reconfig_top_label]
write_checkpoint -force $chckpt_dir/$reconf_chckpt_name.dcp

# 4 - 5 Define Reconfigurable Properties on each RM
## Here I have to check the size
set pblock_name pblock_rp_instance
startgroup
    create_pblock $pblock_name
    resize_pblock $pblock_name -add $slice_plan
    resize_pblock $pblock_name -add $dsp48_plan
    add_cells_to_pblock $pblock_name [get_cells [list system_i/$reconfig_ip_name/$reconfig_inst/$reconfig_top_label]] -clear_locs
endgroup
## save pblock and properties
write_xdc $fplan_dir/fplan.xdc -force
close_project