# execute this script with this command "xsdk -batch -source sdk_setup.tcl"
source start_variables.tcl

# delete the old except hdf
set allfiles [glob -nocomplain $sdk_dir/*]
set idX [lsearch $allfiles "$sdk_dir/system_wrapper.hdf"]
set allfiles [lreplace $alldcp $idX $idX]
catch {file delete -force $allfiles}

# 10-1. Create workspace and import the project into
setws $sdk_dir
createhw -name hw -hwspec $sdk_dir/system_wrapper.hdf 

# 10-2. Create a Board Support Package enabling generic FAT file system library
createbsp -name $bsp_fat -hwproject hw -proc ps7_cortexa9_0 -os standalone
setlib -bsp $bsp_fat -lib xilffs
updatemss -mss $sdk_dir/$bsp_fat/system.mss   
regenbsp -bsp $bsp_fat 

# 10-3. Create Application
createapp -name $app_name -app {Empty Application} -bsp $bsp_fat -hwproject hw -proc ps7_cortexa9_0
importsources -name $app_name -path $testapp_dir
configapp -app $app_name define-compiler-symbols $BOARD_GLOBAL

# 10-4. Create a zynq_fsbl application.
createapp -name fsbl -app {Zynq FSBL} -proc ps7_cortexa9_0 -hwproject hw -os standalone

## Build all projects
projects -build

# 10-5. Create a Zynq boot image.
exec bootgen -arch zynq -image output.bif -w -o BOOT.bin
