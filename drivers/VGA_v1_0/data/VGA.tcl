

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "VGA" "NUM_INSTANCES" "DEVICE_ID"  "C_s_axi_config_BASEADDR" "C_s_axi_config_HIGHADDR"
}
