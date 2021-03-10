foreach {n module} [array get reconf_mod_name] {
    read_checkpoint -cell system_i/$reconfig_ip_name/$reconfig_inst/$reconfig_top_label \
                        $synth_reconfmod_dir/rp_${module}/$reconf_part_name.dcp
    opt_design
    place_design 
    route_design
    file mkdir $impl_dir/Config_${module}
    write_checkpoint -force $impl_dir/Config_${module}/top_route_design.dcp 
    write_checkpoint -force -cell system_i/$reconfig_ip_name/$reconfig_inst/$reconfig_top_label \
                                    $chckpt_dir/rp_instance_${module}_route_design.dcp

    source lock_placement_with_blackbox.tcl
}
write_checkpoint -force $chckpt_dir/$static_dsn.dcp

close_project
