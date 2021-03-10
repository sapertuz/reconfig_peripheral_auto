# 1-5 Synthesize RM
foreach {n module} [array get reconf_mod_name] {
    if {$hdl_lang == "vhdl"} {      read_vhdl [glob $r_modules_dir/rp_${module}/*] }
    if {$hdl_lang == "verilog"} {   read_verilog [glob $r_modules_dir/rp_${module}/*] }
    synth_design -mode out_of_context -flatten_hierarchy rebuilt -top $reconfig_top_name -part $device_name
    file mkdir $synth_reconfmod_dir/rp_${module}
    write_checkpoint -force $synth_reconfmod_dir/rp_${module}/$reconf_part_name.dcp
    close_design
    set old_sources [glob $r_modules_dir/rp_${module}/*]
    foreach old_source $old_sources { 
        export_ip_user_files -of_objects [get_files $old_source] -no_script -reset -force -quiet
        remove_files $old_source
    }
}   
close_project