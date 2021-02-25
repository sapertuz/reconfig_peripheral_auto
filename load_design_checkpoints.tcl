open_checkpoint $synth_static_dir/system_wrapper.dcp
set chckpntFiles [glob $synth_static_dir/*.dcp]
foreach file $chckpntFiles {
    if {$file != "${synth_static_dir}/system_wrapper.dcp"} {
        read_checkpoint $file
    } 
}