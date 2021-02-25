foreach module [array get reconf_mod_name] {
    #$r_modules_dir/rp_${reconf_mod_name($index)}/rp_${reconf_mod_name($index)}.v
    read_verilog [glob $r_modules_dir/rp_${module}/*]
    synth_design -mode out_of_context -flatten_hierarchy rebuilt -top $reconfig_top_name -part $device_name
    file mkdir $synth_reconfmod_dir/rp_${module}
    write_checkpoint -force $synth_reconfmod_dir/rp_${module}/$reconf_part_name.dcp
    close_design
}
close_project

