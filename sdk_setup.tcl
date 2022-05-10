# execute this script with this command "xsdk -batch -source sdk_setup.tcl"
source env_setup.tcl

# delete the old except hdf
set allfiles [glob -nocomplain $sdk_dir/*]
set idX [lsearch $allfiles $sdk_dir/system_wrapper.xsa]
set allfiles [lreplace $allfiles $idX $idX]
foreach file_folder $allfiles {
    catch {file delete -force -- $file_folder}
}
catch {file delete -force -- $sdk_dir/.metadata}
catch {file delete -force -- $sdk_dir/.analytics}


# 10-1. Create workspace and import the project into
setws -switch $sdk_dir
#platform remove "hw"
    #createhw -name hw -hwspec $sdk_dir/system_wrapper.xsa 
platform create -name "hw" -hw $sdk_dir/system_wrapper.xsa -proc ps7_cortexa9_0 -arch 32-bit -os standalone

# 10-2. Create a Board Support Package enabling generic FAT file system library
    #createbsp -name $bsp_fat -hwproject hw -proc ps7_cortexa9_0 -os standalone

    #setlib -bsp $bsp_fat -lib xilffs
bsp setlib -name xilffs
    #updatemss -mss $sdk_dir/$bsp_fat/system.mss   
platform write
    #regenbsp -bsp $bsp_fat 
platform generate

# 10-3. Create Application
    #createapp -name $app_name -app {Empty Application} -bsp $bsp_fat -hwproject hw -proc ps7_cortexa9_0
app create -name $app_name -template "Empty Application(C)" -platform "hw" -os standalone                                                                                  
importsources -name $app_name -path $testapp_dir
    #configapp -app $app_name define-compiler-symbols $BOARD_GLOBAL
app config -name $app_name define-compiler-symbols $BOARD_GLOBAL

# 10-4. Create a zynq_fsbl application.
    #createapp -name fsbl -app {Zynq FSBL} -proc ps7_cortexa9_0 -hwproject hw -os standalone
app create -name fsbl -app "Zynq FSBL" -proc ps7_cortexa9_0 -platform "hw" -os standalone

## Build all projects
    #projects -build
app build -all

# 10-5. Create a Zynq boot image.
source create_bif_file.tcl
exec bootgen -arch zynq -image output.bif -w -o BOOT.bin
