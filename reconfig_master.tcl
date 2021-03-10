# Set some info of the project
source env_setup.tcl
source clean_file_system.tcl

# 1-1 -> 1-3 Create project add modules, decoupler, and make connections 
source ps7_create.tcl

# 1-5 Synthesize RM
source synth_reconfig_modules.tcl

# 2 Floorplanning
source design_floorplanning.tcl

# 6 - 7 Create and Implement Reconfigurable and Blanking Configurations
open_checkpoint $chckpt_dir/$reconf_chckpt_name.dcp
read_xdc  $fplan_dir/fplan.xdc
source create_modules_configuration.tcl
source create_blanking_configuration.tcl

# 8 Verify configurations
source verify_configurations.tcl

# 9 Generate Bitstream
source generate_bitstreams.tcl

