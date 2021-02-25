# Set some info of the project
source env_setup.tcl

# 1-1 -> 1-3 Create project add modules, decoupler, and make connections 
source ps7_create.tcl

# 1-5 Synthesize RM
source synth_reconfig_modules.tcl

# 2 Load Static RM for the RP in Vivado (check rp_instance IS_BLACKBOX checkbox is checked)
source load_design_checkpoints.tcl

# 6 - 7 Create and Implement Reconfigurable and Blanking Configurations
open_checkpoint $chckpt_dir/$reconf_chckpt_name.dcp
read_xdc  $fplan_dir/fplan.xdc
source create_modules_configuration.tcl
source create_blanking_configuration.tcl

# 8 Verify configurations
source verify_configurations.tcl

# 9 Generate Bitstream
source generate_bitstreams.tcl

