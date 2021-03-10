open_checkpoint $chckpt_dir/static_route_design.dcp
update_design -buffer_ports -cell system_i/$reconfig_ip_name/$reconfig_inst/$reconfig_top_label 
place_design 
route_design
file mkdir $impl_dir/Config_blank
write_checkpoint -force $impl_dir/Config_blank/top_route_design.dcp
close_project
