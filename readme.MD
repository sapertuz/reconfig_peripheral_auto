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
### 7 Create app and boot files in sdk
* First open a terminal and go to SDK installation folder and run `./xsct`
```
$ cd $SDK_install_dir/bin
$ ./xsct
$ xsct% source sdk_setup.tcl
```
## NOTES
* You can source `reconfig_master.tcl` to do all the steps automatically. However, I don't recomend this since the computer migth run out of memory.
* Every word are 32 bits and every byte are 8 bits. So, you need to divide the bin file size in bytes by four to get its length. In the example, the size is `110,984 bytes / 4 = 27,746 words -> 0x6c62 hex`

At the end copy `BOOT.bin` (in the main folder), `blank.bin` (in the Bitstream folder) and `$reconf_mod_name.bin` (Also in the Bitstream folder, remember these ara as many as included in the array) in the SD card.

## Relevant links
* [TCL commands guide (Vivado 2019.1)](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug835-vivado-tcl-commands.pdf)
* [XSCT reference guide (SDK 2019.1)](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug1208-xsct-reference-guide.pdf)
* [BOOTGEN user guide (SDK 2019.1)](/www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug1283-bootgen-user-guide.pdf)
