# Requirements
* Vivado 2019.1
* Install board_files in Vivado and SDK installation folder

# Steps Partial Reconfiguration
### 1. Get in project directory clean file system (optional) and setup variables 
 ```
 cd $project dir
 source clean_file_system.tcl
 source env_setup.tcl
 ```
NOTES: 
* Inside env_setup.tcl you can chose the board
* There you also can modify the modules you will use (remember to add the source in the `Source/reconfig_modules` folder in different folders)
### 2. Create System and Synthesize whole system OOC
```
 source ps7_create.tcl
 ```
### 3. Synthesize Reconfigurable modules
```
source synth_reconfig_modules.tcl
```
NOTES
* Here you should be carefull to pick the placement of the reconfigurable partition.
### 4. Create and Implement Reconfigurable and Blanking Configurations
```
# 6 - 7 
open_checkpoint $chckpt_dir/$reconf_chckpt_name.dcp
read_xdc  $fplan_dir/fplan.xdc
source create_modules_configuration.tcl
source create_blanking_configuration.tcl
```
### 5 Verify configurations
```
source verify_configurations.tcl
```
### 6 Generate Bitstream
```
source generate_bitstreams.tcl
```
### 7 Create SDK workspace and boot files
```
source sdk_source.tcl
```
## NOTE
You can source `reconfig_master.tcl` to do all the steps automatically but I don't recomend this since the computer migth run out of memory
