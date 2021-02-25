# Clear file system
catch {file delete -force {*}[glob -nocomplain $impl_dir/*]}
catch {file delete -force {*}[glob -nocomplain $synth_static_dir/*]}
catch {file delete -force {*}[glob -nocomplain $synth_reconfmod_dir/*]}
catch {file delete -force {*}[glob -nocomplain $bitstr_dir/*]}
catch {file delete -force {*}[glob -nocomplain $chckpt_dir/*]}
