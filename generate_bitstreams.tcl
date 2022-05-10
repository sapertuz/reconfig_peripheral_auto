open_checkpoint $impl_dir/Config_blank/top_route_design.dcp 
write_bitstream -file $bitstr_dir/blanking.bit -force
write_cfgmem -format BIN -interface SMAPx32 -disablebitswap -loadbit "up 0 $bitstr_dir/blanking_pblock_rp_instance_partial.bit" $bitstr_dir/blank.bin -force
close_project 
foreach {module} [array get reconf_mod_name] {
    open_checkpoint $impl_dir/Config_$module/top_route_design.dcp 
    write_bitstream -file $bitstr_dir/Config_${module}.bit -force 
    write_cfgmem -format BIN -interface SMAPx32 -disablebitswap -loadbit "up 0 $bitstr_dir/Config_${module}_pblock_rp_instance_partial.bit" $bitstr_dir/${module}.bin -force
    close_project 
}