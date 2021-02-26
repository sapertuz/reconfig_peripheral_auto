file delete output0.bif

set fid [open output.bif w]

puts $fid "the_ROM_image:"
puts $fid "{"
puts $fid "	\[bootloader\]${sdk_dir}/fsbl/Debug/fsbl.elf"
puts $fid "	${bitstr_dir}/blanking.bit"
puts $fid "	${sdk_dir}/${app_name}/Debug/${app_name}.elf"
puts $fid "}"

close $fid