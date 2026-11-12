
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2025.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:axis_clock_converter:1.1\
xilinx.com:ip:axi_fifo_mm_s:4.3\
xilinx.com:ip:clk_wiz:6.0\
pavel-demin:user:redp_adc:1.0\
pavel-demin:user:redp_dac:1.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:axi_clock_converter:2.1\
pavel-demin:user:axi_ctl_register:1.0\
pavel-demin:user:axi_sts_register:1.0\
xilinx.com:ip:xlconcat:2.1\
koheron:user:agc_mux:1.0\
xilinx.com:ip:cordic:6.0\
koheron:user:delay:1.0\
xilinx.com:ip:c_addsub:12.0\
xilinx.com:ip:c_accum:12.0\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:mult_gen:12.0\
xilinx.com:ip:cic_compiler:4.0\
xilinx.com:ip:fir_compiler:7.2\
xilinx.com:ip:util_vector_logic:2.0\
koheron:user:register:1.0\
koheron:user:one_clock_pulse:1.0\
xilinx.com:ip:c_counter_binary:12.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: Signal_level_detect
proc create_hier_cell_Signal_level_detect { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Signal_level_detect() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I Sample_clock
  create_bd_pin -dir I -from 31 -to 0 Signal_toDetect
  create_bd_pin -dir O -from 31 -to 0 Signal_level

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_0


  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {31} \
    CONFIG.DIN_TO {31} \
  ] $xlslice_1


  # Create instance: register_0, and set properties
  set register_0 [ create_bd_cell -type ip -vlnv koheron:user:register:1.0 register_0 ]

  # Create instance: one_clock_pulse_0, and set properties
  set one_clock_pulse_0 [ create_bd_cell -type ip -vlnv koheron:user:one_clock_pulse:1.0 one_clock_pulse_0 ]

  # Create instance: xlslice_2, and set properties
  set xlslice_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_2 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {15} \
    CONFIG.DIN_TO {15} \
    CONFIG.DIN_WIDTH {16} \
  ] $xlslice_2


  # Create instance: c_accum_0, and set properties
  set c_accum_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_accum:12.0 c_accum_0 ]
  set_property -dict [list \
    CONFIG.Accum_Mode {Add_Subtract} \
    CONFIG.Bypass {false} \
    CONFIG.Input_Width {16} \
    CONFIG.Output_Width {32} \
    CONFIG.SCLR {true} \
  ] $c_accum_0


  # Create instance: c_counter_binary_0, and set properties
  set c_counter_binary_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_counter_binary:12.0 c_counter_binary_0 ]

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {31} \
    CONFIG.DIN_TO {16} \
  ] $xlslice_0


  # Create port connections
  connect_bd_net -net Sample_clock_1  [get_bd_pins Sample_clock] \
  [get_bd_pins c_counter_binary_0/CLK] \
  [get_bd_pins c_accum_0/CLK] \
  [get_bd_pins one_clock_pulse_0/clk] \
  [get_bd_pins register_0/clk]
  connect_bd_net -net Signal_toDetect_1  [get_bd_pins Signal_toDetect] \
  [get_bd_pins xlslice_0/Din] \
  [get_bd_pins xlslice_1/Din]
  connect_bd_net -net c_accum_0_Q  [get_bd_pins c_accum_0/Q] \
  [get_bd_pins register_0/din]
  connect_bd_net -net c_counter_binary_0_Q  [get_bd_pins c_counter_binary_0/Q] \
  [get_bd_pins xlslice_2/Din]
  connect_bd_net -net one_clock_pulse_0_pulse  [get_bd_pins one_clock_pulse_0/pulse] \
  [get_bd_pins register_0/en] \
  [get_bd_pins c_accum_0/SCLR]
  connect_bd_net -net register_0_dout  [get_bd_pins register_0/dout] \
  [get_bd_pins Signal_level]
  connect_bd_net -net util_vector_logic_0_Res  [get_bd_pins util_vector_logic_0/Res] \
  [get_bd_pins c_accum_0/ADD]
  connect_bd_net -net xlslice_0_Dout  [get_bd_pins xlslice_0/Dout] \
  [get_bd_pins c_accum_0/B]
  connect_bd_net -net xlslice_1_Dout  [get_bd_pins xlslice_1/Dout] \
  [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net xlslice_2_Dout  [get_bd_pins xlslice_2/Dout] \
  [get_bd_pins one_clock_pulse_0/trig]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: Mixer_LPF_Q
proc create_hier_cell_Mixer_LPF_Q { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Mixer_LPF_Q() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I SampleClock
  create_bd_pin -dir I -from 13 -to 0 AntennaInput
  create_bd_pin -dir I -from 15 -to 0 LocalOscillator
  create_bd_pin -dir O -from 31 -to 0 DemodulatedSignal
  create_bd_pin -dir O Tvalid

  # Create instance: mult_gen_0, and set properties
  set mult_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mult_gen:12.0 mult_gen_0 ]
  set_property -dict [list \
    CONFIG.PortAType {Signed} \
    CONFIG.PortAWidth {14} \
    CONFIG.PortBType {Signed} \
    CONFIG.PortBWidth {16} \
  ] $mult_gen_0


  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {28} \
    CONFIG.DIN_TO {13} \
    CONFIG.DIN_WIDTH {30} \
  ] $xlslice_0


  # Create instance: cic_compiler_0, and set properties
  set cic_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_compiler_0 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {125} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Fixed_Or_Initial_Rate {651} \
    CONFIG.Input_Data_Width {16} \
    CONFIG.Input_Sample_Frequency {125} \
    CONFIG.Maximum_Rate {651} \
    CONFIG.Minimum_Rate {651} \
    CONFIG.Output_Data_Width {32} \
    CONFIG.Quantization {Truncation} \
    CONFIG.SamplePeriod {1} \
  ] $cic_compiler_0


  # Create instance: fir_compiler_0, and set properties
  set fir_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_compiler_0 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {125} \
    CONFIG.CoefficientVector {-239, -215, -275, -312, -309, -247, -111, 108, 414, 802, 1256, 1752, 2260, 2744, 3168, 3499, 3709, 3781, 3709, 3499, 3168, 2744, 2260, 1752, 1256, 802, 414, 108, -111, -247,\
-309, -312, -275, -215, -239} \
    CONFIG.Coefficient_Fractional_Bits {0} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Inferred} \
    CONFIG.Coefficient_Width {16} \
    CONFIG.Data_Width {32} \
    CONFIG.Decimation_Rate {6} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Interpolation_Rate {1} \
    CONFIG.Number_Channels {1} \
    CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Even} \
    CONFIG.Output_Width {32} \
    CONFIG.Quantization {Integer_Coefficients} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.Sample_Frequency {0.192} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $fir_compiler_0


  # Create interface connections
  connect_bd_intf_net -intf_net cic_compiler_0_M_AXIS_DATA [get_bd_intf_pins cic_compiler_0/M_AXIS_DATA] [get_bd_intf_pins fir_compiler_0/S_AXIS_DATA]

  # Create port connections
  connect_bd_net -net AntennaInput_1  [get_bd_pins AntennaInput] \
  [get_bd_pins mult_gen_0/A]
  connect_bd_net -net LocalOscillator_1  [get_bd_pins LocalOscillator] \
  [get_bd_pins mult_gen_0/B]
  connect_bd_net -net SampleClock_1  [get_bd_pins SampleClock] \
  [get_bd_pins mult_gen_0/CLK] \
  [get_bd_pins fir_compiler_0/aclk] \
  [get_bd_pins cic_compiler_0/aclk]
  connect_bd_net -net cic_compiler_0_s_axis_data_tready  [get_bd_pins cic_compiler_0/s_axis_data_tready] \
  [get_bd_pins cic_compiler_0/s_axis_data_tvalid]
  connect_bd_net -net fir_compiler_0_m_axis_data_tdata  [get_bd_pins fir_compiler_0/m_axis_data_tdata] \
  [get_bd_pins DemodulatedSignal]
  connect_bd_net -net fir_compiler_0_m_axis_data_tvalid  [get_bd_pins fir_compiler_0/m_axis_data_tvalid] \
  [get_bd_pins Tvalid]
  connect_bd_net -net mult_gen_0_P  [get_bd_pins mult_gen_0/P] \
  [get_bd_pins xlslice_0/Din]
  connect_bd_net -net xlslice_0_Dout  [get_bd_pins xlslice_0/Dout] \
  [get_bd_pins cic_compiler_0/s_axis_data_tdata]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: Mixer_LPF_I
proc create_hier_cell_Mixer_LPF_I { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Mixer_LPF_I() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I SampleClock
  create_bd_pin -dir I -from 13 -to 0 AntennaInput
  create_bd_pin -dir I -from 15 -to 0 LocalOscillator
  create_bd_pin -dir O -from 31 -to 0 DemodulatedSignal
  create_bd_pin -dir O Tvalid

  # Create instance: mult_gen_0, and set properties
  set mult_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mult_gen:12.0 mult_gen_0 ]
  set_property -dict [list \
    CONFIG.PortAType {Signed} \
    CONFIG.PortAWidth {14} \
    CONFIG.PortBType {Signed} \
    CONFIG.PortBWidth {16} \
  ] $mult_gen_0


  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {28} \
    CONFIG.DIN_TO {13} \
    CONFIG.DIN_WIDTH {30} \
  ] $xlslice_0


  # Create instance: cic_compiler_0, and set properties
  set cic_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_compiler_0 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {125} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Fixed_Or_Initial_Rate {651} \
    CONFIG.Input_Data_Width {16} \
    CONFIG.Input_Sample_Frequency {125} \
    CONFIG.Maximum_Rate {651} \
    CONFIG.Minimum_Rate {651} \
    CONFIG.Output_Data_Width {32} \
    CONFIG.Quantization {Truncation} \
    CONFIG.SamplePeriod {1} \
  ] $cic_compiler_0


  # Create instance: fir_compiler_0, and set properties
  set fir_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_compiler_0 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {125} \
    CONFIG.CoefficientVector {-239, -215, -275, -312, -309, -247, -111, 108, 414, 802, 1256, 1752, 2260, 2744, 3168, 3499, 3709, 3781, 3709, 3499, 3168, 2744, 2260, 1752, 1256, 802, 414, 108, -111, -247,\
-309, -312, -275, -215, -239} \
    CONFIG.Coefficient_Fractional_Bits {0} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Inferred} \
    CONFIG.Coefficient_Width {16} \
    CONFIG.Data_Width {32} \
    CONFIG.Decimation_Rate {6} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Interpolation_Rate {1} \
    CONFIG.Number_Channels {1} \
    CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Even} \
    CONFIG.Output_Width {32} \
    CONFIG.Quantization {Integer_Coefficients} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.Sample_Frequency {0.192} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $fir_compiler_0


  # Create interface connections
  connect_bd_intf_net -intf_net cic_compiler_0_M_AXIS_DATA [get_bd_intf_pins cic_compiler_0/M_AXIS_DATA] [get_bd_intf_pins fir_compiler_0/S_AXIS_DATA]

  # Create port connections
  connect_bd_net -net AntennaInput_1  [get_bd_pins AntennaInput] \
  [get_bd_pins mult_gen_0/A]
  connect_bd_net -net LocalOscillator_1  [get_bd_pins LocalOscillator] \
  [get_bd_pins mult_gen_0/B]
  connect_bd_net -net SampleClock_1  [get_bd_pins SampleClock] \
  [get_bd_pins mult_gen_0/CLK] \
  [get_bd_pins fir_compiler_0/aclk] \
  [get_bd_pins cic_compiler_0/aclk]
  connect_bd_net -net cic_compiler_0_s_axis_data_tready  [get_bd_pins cic_compiler_0/s_axis_data_tready] \
  [get_bd_pins cic_compiler_0/s_axis_data_tvalid]
  connect_bd_net -net fir_compiler_0_m_axis_data_tdata  [get_bd_pins fir_compiler_0/m_axis_data_tdata] \
  [get_bd_pins DemodulatedSignal]
  connect_bd_net -net fir_compiler_0_m_axis_data_tvalid  [get_bd_pins fir_compiler_0/m_axis_data_tvalid] \
  [get_bd_pins Tvalid]
  connect_bd_net -net mult_gen_0_P  [get_bd_pins mult_gen_0/P] \
  [get_bd_pins xlslice_0/Din]
  connect_bd_net -net xlslice_0_Dout  [get_bd_pins xlslice_0/Dout] \
  [get_bd_pins cic_compiler_0/s_axis_data_tdata]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: Baseline_subtract
proc create_hier_cell_Baseline_subtract { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Baseline_subtract() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -from 31 -to 0 Din
  create_bd_pin -dir I SampleClock
  create_bd_pin -dir I -type ce CE
  create_bd_pin -dir O -from 15 -to 0 Speaker_out

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property CONFIG.DIN_FROM {15} $xlslice_0


  # Create instance: c_addsub_0, and set properties
  set c_addsub_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_addsub:12.0 c_addsub_0 ]
  set_property -dict [list \
    CONFIG.A_Type {Signed} \
    CONFIG.A_Width {16} \
    CONFIG.Add_Mode {Subtract} \
    CONFIG.B_Type {Signed} \
    CONFIG.B_Value {0000000000000000} \
    CONFIG.B_Width {16} \
    CONFIG.CE {false} \
    CONFIG.Latency {1} \
    CONFIG.Out_Width {16} \
  ] $c_addsub_0


  # Create instance: c_accum_0, and set properties
  set c_accum_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_accum:12.0 c_accum_0 ]
  set_property -dict [list \
    CONFIG.Bypass {false} \
    CONFIG.CE {true} \
    CONFIG.Input_Width {16} \
    CONFIG.Output_Width {32} \
  ] $c_accum_0


  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {31} \
    CONFIG.DIN_TO {16} \
  ] $xlslice_1


  # Create port connections
  connect_bd_net -net Mixer_LPF_I_Tvalid  [get_bd_pins CE] \
  [get_bd_pins c_accum_0/CE]
  connect_bd_net -net adc_dac_adc_clk  [get_bd_pins SampleClock] \
  [get_bd_pins c_accum_0/CLK] \
  [get_bd_pins c_addsub_0/CLK]
  connect_bd_net -net c_accum_0_Q  [get_bd_pins c_accum_0/Q] \
  [get_bd_pins xlslice_1/Din]
  connect_bd_net -net c_addsub_0_S  [get_bd_pins c_addsub_0/S] \
  [get_bd_pins c_accum_0/B] \
  [get_bd_pins Speaker_out]
  connect_bd_net -net cordic_0_m_axis_dout_tdata  [get_bd_pins Din] \
  [get_bd_pins xlslice_0/Din]
  connect_bd_net -net xlslice_0_Dout  [get_bd_pins xlslice_0/Dout] \
  [get_bd_pins c_addsub_0/A]
  connect_bd_net -net xlslice_1_Dout  [get_bd_pins xlslice_1/Dout] \
  [get_bd_pins c_addsub_0/B]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: Local_Oscillator
proc create_hier_cell_Local_Oscillator { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Local_Oscillator() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I Sample_clock
  create_bd_pin -dir I -from 31 -to 0 Set_Freq
  create_bd_pin -dir O -from 15 -to 0 LO_Q
  create_bd_pin -dir O -from 15 -to 0 LO_I

  # Create instance: delay_0, and set properties
  set delay_0 [ create_bd_cell -type ip -vlnv koheron:user:delay:1.0 delay_0 ]

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {31} \
    CONFIG.DIN_TO {21} \
  ] $xlslice_0


  # Create instance: c_addsub_0, and set properties
  set c_addsub_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_addsub:12.0 c_addsub_0 ]
  set_property -dict [list \
    CONFIG.A_Type {Unsigned} \
    CONFIG.A_Width {11} \
    CONFIG.B_Constant {true} \
    CONFIG.B_Type {Unsigned} \
    CONFIG.B_Value {01000000000} \
    CONFIG.B_Width {11} \
    CONFIG.CE {false} \
    CONFIG.Latency {1} \
    CONFIG.Out_Width {11} \
  ] $c_addsub_0


  # Create instance: c_accum_0, and set properties
  set c_accum_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_accum:12.0 c_accum_0 ]
  set_property CONFIG.Input_Width {32} $c_accum_0


  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [list \
    CONFIG.Coe_File {/home/wshamsi/workspace/koheron-sdk/instruments/sdr/sinewave.coe} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Memory_Type {Dual_Port_ROM} \
    CONFIG.Write_Depth_A {2048} \
    CONFIG.Write_Width_A {16} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $blk_mem_gen_0


  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create port connections
  connect_bd_net -net Sample_clock_1  [get_bd_pins Sample_clock] \
  [get_bd_pins c_accum_0/CLK] \
  [get_bd_pins delay_0/clk] \
  [get_bd_pins c_addsub_0/CLK] \
  [get_bd_pins blk_mem_gen_0/clka] \
  [get_bd_pins blk_mem_gen_0/clkb]
  connect_bd_net -net Set_Freq_1  [get_bd_pins Set_Freq] \
  [get_bd_pins c_accum_0/B]
  connect_bd_net -net blk_mem_gen_0_douta  [get_bd_pins blk_mem_gen_0/douta] \
  [get_bd_pins LO_Q]
  connect_bd_net -net blk_mem_gen_0_doutb  [get_bd_pins blk_mem_gen_0/doutb] \
  [get_bd_pins LO_I]
  connect_bd_net -net c_accum_0_Q  [get_bd_pins c_accum_0/Q] \
  [get_bd_pins xlslice_0/Din]
  connect_bd_net -net c_addsub_0_S  [get_bd_pins c_addsub_0/S] \
  [get_bd_pins blk_mem_gen_0/addra]
  connect_bd_net -net delay_0_dout  [get_bd_pins delay_0/dout] \
  [get_bd_pins blk_mem_gen_0/addrb]
  connect_bd_net -net xlconstant_0_dout  [get_bd_pins xlconstant_0/dout] \
  [get_bd_pins blk_mem_gen_0/ena] \
  [get_bd_pins blk_mem_gen_0/enb]
  connect_bd_net -net xlslice_0_Dout  [get_bd_pins xlslice_0/Dout] \
  [get_bd_pins c_addsub_0/A] \
  [get_bd_pins delay_0/din]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: Radio
proc create_hier_cell_Radio { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Radio() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I SampleClock
  create_bd_pin -dir O Strobe
  create_bd_pin -dir O -from 31 -to 0 Signal_level
  create_bd_pin -dir O -from 7 -to 0 led_o1
  create_bd_pin -dir O -from 15 -to 0 Speaker_out
  create_bd_pin -dir O -from 31 -to 0 Data2Stream
  create_bd_pin -dir O -from 13 -to 0 AfterMixerLPF
  create_bd_pin -dir I -from 31 -to 0 Volume
  create_bd_pin -dir I -from 13 -to 0 AntennaInput
  create_bd_pin -dir I -from 15 -to 0 LocalOscillator_I
  create_bd_pin -dir I -from 15 -to 0 LocalOscillator_Q

  # Create instance: agc_mux_0, and set properties
  set agc_mux_0 [ create_bd_cell -type ip -vlnv koheron:user:agc_mux:1.0 agc_mux_0 ]

  # Create instance: agc_mux_1, and set properties
  set agc_mux_1 [ create_bd_cell -type ip -vlnv koheron:user:agc_mux:1.0 agc_mux_1 ]

  # Create instance: cordic_0, and set properties
  set cordic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cordic:6.0 cordic_0 ]
  set_property -dict [list \
    CONFIG.Compensation_Scaling {No_Scale_Compensation} \
    CONFIG.Data_Format {SignedFraction} \
    CONFIG.Functional_Selection {Translate} \
    CONFIG.Phase_Format {Scaled_Radians} \
  ] $cordic_0


  # Create instance: slice_7_0_ctl_led1, and set properties
  set slice_7_0_ctl_led1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_7_0_ctl_led1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {20} \
    CONFIG.DIN_TO {13} \
    CONFIG.DIN_WIDTH {32} \
  ] $slice_7_0_ctl_led1


  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create instance: xlconcat_1, and set properties
  set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {31} \
    CONFIG.DIN_TO {18} \
  ] $xlslice_0


  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property CONFIG.DIN_FROM {3} $xlslice_1


  # Create instance: Baseline_subtract
  create_hier_cell_Baseline_subtract $hier_obj Baseline_subtract

  # Create instance: Mixer_LPF_I
  create_hier_cell_Mixer_LPF_I $hier_obj Mixer_LPF_I

  # Create instance: Mixer_LPF_Q
  create_hier_cell_Mixer_LPF_Q $hier_obj Mixer_LPF_Q

  # Create instance: Signal_level_detect
  create_hier_cell_Signal_level_detect $hier_obj Signal_level_detect

  # Create port connections
  connect_bd_net -net Baseline_subtract_Speaker_out  [get_bd_pins Baseline_subtract/Speaker_out] \
  [get_bd_pins Speaker_out] \
  [get_bd_pins xlconcat_1/In1]
  connect_bd_net -net Local_Oscillator_LO_I  [get_bd_pins LocalOscillator_I] \
  [get_bd_pins Mixer_LPF_I/LocalOscillator]
  connect_bd_net -net Local_Oscillator_LO_Q  [get_bd_pins LocalOscillator_Q] \
  [get_bd_pins Mixer_LPF_Q/LocalOscillator]
  connect_bd_net -net Mixer_LPF_I_DemodulatedSignal  [get_bd_pins Mixer_LPF_I/DemodulatedSignal] \
  [get_bd_pins agc_mux_1/din]
  connect_bd_net -net Mixer_LPF_I_Tvalid  [get_bd_pins Mixer_LPF_I/Tvalid] \
  [get_bd_pins Strobe] \
  [get_bd_pins Baseline_subtract/CE] \
  [get_bd_pins cordic_0/s_axis_cartesian_tvalid]
  connect_bd_net -net Signal_level_detect_Signal_level  [get_bd_pins Signal_level_detect/Signal_level] \
  [get_bd_pins Signal_level] \
  [get_bd_pins slice_7_0_ctl_led1/Din]
  connect_bd_net -net Signal_toDetect_1  [get_bd_pins Mixer_LPF_Q/DemodulatedSignal] \
  [get_bd_pins Signal_level_detect/Signal_toDetect] \
  [get_bd_pins agc_mux_0/din] \
  [get_bd_pins xlslice_0/Din]
  connect_bd_net -net Volume_1  [get_bd_pins Volume] \
  [get_bd_pins xlslice_1/Din]
  connect_bd_net -net adc_dac_adc2  [get_bd_pins AntennaInput] \
  [get_bd_pins Mixer_LPF_Q/AntennaInput] \
  [get_bd_pins Mixer_LPF_I/AntennaInput]
  connect_bd_net -net adc_dac_adc_clk1  [get_bd_pins SampleClock] \
  [get_bd_pins Mixer_LPF_I/SampleClock] \
  [get_bd_pins Mixer_LPF_Q/SampleClock] \
  [get_bd_pins Signal_level_detect/Sample_clock] \
  [get_bd_pins cordic_0/aclk] \
  [get_bd_pins Baseline_subtract/SampleClock] \
  [get_bd_pins agc_mux_1/clk] \
  [get_bd_pins agc_mux_0/clk]
  connect_bd_net -net agc_mux_0_dout  [get_bd_pins agc_mux_0/dout] \
  [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net agc_mux_1_dout  [get_bd_pins agc_mux_1/dout] \
  [get_bd_pins xlconcat_0/In1] \
  [get_bd_pins xlconcat_1/In0]
  connect_bd_net -net cordic_0_m_axis_dout_tdata  [get_bd_pins cordic_0/m_axis_dout_tdata] \
  [get_bd_pins Baseline_subtract/Din]
  connect_bd_net -net slice_7_0_ctl_led_Dout1  [get_bd_pins slice_7_0_ctl_led1/Dout] \
  [get_bd_pins led_o1]
  connect_bd_net -net xlconcat_0_dout  [get_bd_pins xlconcat_0/dout] \
  [get_bd_pins cordic_0/s_axis_cartesian_tdata]
  connect_bd_net -net xlconcat_1_dout  [get_bd_pins xlconcat_1/dout] \
  [get_bd_pins Data2Stream]
  connect_bd_net -net xlconstant_0_dout  [get_bd_pins xlconstant_0/dout] \
  [get_bd_pins agc_mux_0/clken] \
  [get_bd_pins agc_mux_1/clken]
  connect_bd_net -net xlslice_0_Dout  [get_bd_pins xlslice_0/Dout] \
  [get_bd_pins AfterMixerLPF]
  connect_bd_net -net xlslice_1_Dout  [get_bd_pins xlslice_1/Dout] \
  [get_bd_pins agc_mux_0/sel] \
  [get_bd_pins agc_mux_1/sel]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: sts
proc create_hier_cell_sts { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_sts() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI


  # Create pins
  create_bd_pin -dir I -from 31 -to 0 signal_strength
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir I -type clk m_axi_aclk
  create_bd_pin -dir I -type rst m_axi_aresetn

  # Create instance: axi_clock_converter_0, and set properties
  set axi_clock_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 axi_clock_converter_0 ]

  # Create instance: axi_sts_register_0, and set properties
  set axi_sts_register_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axi_sts_register:1.0 axi_sts_register_0 ]
  set_property CONFIG.STS_DATA_WIDTH {32} $axi_sts_register_0


  # Create instance: concat_concat, and set properties
  set concat_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_concat ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {32} \
    CONFIG.NUM_PORTS {1} \
  ] $concat_concat


  # Create instance: concat_0, and set properties
  set concat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_0 ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {32} \
    CONFIG.NUM_PORTS {1} \
  ] $concat_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_clock_converter_0/S_AXI] [get_bd_intf_pins S_AXI]
  connect_bd_intf_net -intf_net axi_clock_converter_0_M_AXI [get_bd_intf_pins axi_sts_register_0/S_AXI] [get_bd_intf_pins axi_clock_converter_0/M_AXI]

  # Create port connections
  connect_bd_net -net concat_0_dout  [get_bd_pins concat_0/dout] \
  [get_bd_pins concat_concat/In0]
  connect_bd_net -net concat_concat_dout  [get_bd_pins concat_concat/dout] \
  [get_bd_pins axi_sts_register_0/sts_data]
  connect_bd_net -net m_axi_aclk_1  [get_bd_pins m_axi_aclk] \
  [get_bd_pins axi_clock_converter_0/m_axi_aclk] \
  [get_bd_pins axi_sts_register_0/aclk]
  connect_bd_net -net m_axi_aresetn_1  [get_bd_pins m_axi_aresetn] \
  [get_bd_pins axi_clock_converter_0/m_axi_aresetn] \
  [get_bd_pins axi_sts_register_0/aresetn]
  connect_bd_net -net s_axi_aclk_1  [get_bd_pins s_axi_aclk] \
  [get_bd_pins axi_clock_converter_0/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1  [get_bd_pins s_axi_aresetn] \
  [get_bd_pins axi_clock_converter_0/s_axi_aresetn]
  connect_bd_net -net signal_strength_1  [get_bd_pins signal_strength] \
  [get_bd_pins concat_0/In0]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: ctl
proc create_hier_cell_ctl { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_ctl() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI


  # Create pins
  create_bd_pin -dir O -from 31 -to 0 led
  create_bd_pin -dir O -from 31 -to 0 receive_frequency
  create_bd_pin -dir O -from 31 -to 0 volume
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir I -type clk m_axi_aclk
  create_bd_pin -dir I -type rst m_axi_aresetn

  # Create instance: axi_clock_converter_0, and set properties
  set axi_clock_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 axi_clock_converter_0 ]

  # Create instance: axi_ctl_register, and set properties
  set axi_ctl_register [ create_bd_cell -type ip -vlnv pavel-demin:user:axi_ctl_register:1.0 axi_ctl_register ]
  set_property CONFIG.CTL_DATA_WIDTH {96} $axi_ctl_register


  # Create instance: slice_31_0_axi_ctl_register_ctl_data, and set properties
  set slice_31_0_axi_ctl_register_ctl_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_31_0_axi_ctl_register_ctl_data ]
  set_property -dict [list \
    CONFIG.DIN_FROM {31} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {96} \
  ] $slice_31_0_axi_ctl_register_ctl_data


  # Create instance: slice_63_32_axi_ctl_register_ctl_data, and set properties
  set slice_63_32_axi_ctl_register_ctl_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_63_32_axi_ctl_register_ctl_data ]
  set_property -dict [list \
    CONFIG.DIN_FROM {63} \
    CONFIG.DIN_TO {32} \
    CONFIG.DIN_WIDTH {96} \
  ] $slice_63_32_axi_ctl_register_ctl_data


  # Create instance: slice_95_64_axi_ctl_register_ctl_data, and set properties
  set slice_95_64_axi_ctl_register_ctl_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_95_64_axi_ctl_register_ctl_data ]
  set_property -dict [list \
    CONFIG.DIN_FROM {95} \
    CONFIG.DIN_TO {64} \
    CONFIG.DIN_WIDTH {96} \
  ] $slice_95_64_axi_ctl_register_ctl_data


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_clock_converter_0/S_AXI] [get_bd_intf_pins S_AXI]
  connect_bd_intf_net -intf_net axi_clock_converter_0_M_AXI [get_bd_intf_pins axi_ctl_register/S_AXI] [get_bd_intf_pins axi_clock_converter_0/M_AXI]

  # Create port connections
  connect_bd_net -net axi_ctl_register_ctl_data  [get_bd_pins axi_ctl_register/ctl_data] \
  [get_bd_pins slice_31_0_axi_ctl_register_ctl_data/Din] \
  [get_bd_pins slice_63_32_axi_ctl_register_ctl_data/Din] \
  [get_bd_pins slice_95_64_axi_ctl_register_ctl_data/Din]
  connect_bd_net -net m_axi_aclk_1  [get_bd_pins m_axi_aclk] \
  [get_bd_pins axi_clock_converter_0/m_axi_aclk] \
  [get_bd_pins axi_ctl_register/aclk]
  connect_bd_net -net m_axi_aresetn_1  [get_bd_pins m_axi_aresetn] \
  [get_bd_pins axi_clock_converter_0/m_axi_aresetn] \
  [get_bd_pins axi_ctl_register/aresetn]
  connect_bd_net -net s_axi_aclk_1  [get_bd_pins s_axi_aclk] \
  [get_bd_pins axi_clock_converter_0/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1  [get_bd_pins s_axi_aresetn] \
  [get_bd_pins axi_clock_converter_0/s_axi_aresetn]
  connect_bd_net -net slice_31_0_axi_ctl_register_ctl_data_Dout  [get_bd_pins slice_31_0_axi_ctl_register_ctl_data/Dout] \
  [get_bd_pins led]
  connect_bd_net -net slice_63_32_axi_ctl_register_ctl_data_Dout  [get_bd_pins slice_63_32_axi_ctl_register_ctl_data/Dout] \
  [get_bd_pins receive_frequency]
  connect_bd_net -net slice_95_64_axi_ctl_register_ctl_data_Dout  [get_bd_pins slice_95_64_axi_ctl_register_ctl_data/Dout] \
  [get_bd_pins volume]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: adc_dac
proc create_hier_cell_adc_dac { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_adc_dac() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -from 13 -to 0 dac1
  create_bd_pin -dir O -from 13 -to 0 adc1
  create_bd_pin -dir I -from 13 -to 0 dac2
  create_bd_pin -dir O -from 13 -to 0 adc2
  create_bd_pin -dir O adc_clk
  create_bd_pin -dir O ser_clk
  create_bd_pin -dir O pwm_clk
  create_bd_pin -dir I -type clk adc_clk_p_i
  create_bd_pin -dir I -type clk adc_clk_n_i
  create_bd_pin -dir O adc_cdcs_o
  create_bd_pin -dir O -from 1 -to 0 adc_clk_source
  create_bd_pin -dir I -from 13 -to 0 adc_dat_a_i
  create_bd_pin -dir I -from 13 -to 0 adc_dat_b_i
  create_bd_pin -dir O dac_clk_o
  create_bd_pin -dir O -from 13 -to 0 dac_dat_o
  create_bd_pin -dir O dac_rst_o
  create_bd_pin -dir O dac_sel_o
  create_bd_pin -dir O dac_wrt_o

  # Create instance: pll, and set properties
  set pll [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 pll ]
  set_property -dict [list \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125.0} \
    CONFIG.CLKOUT1_USED {true} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125.0} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {250.0} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {250.0} \
    CONFIG.CLKOUT4_REQUESTED_PHASE {-45} \
    CONFIG.CLKOUT4_USED {true} \
    CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {250.0} \
    CONFIG.CLKOUT5_USED {true} \
    CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {250.0} \
    CONFIG.CLKOUT6_USED {true} \
    CONFIG.PRIMITIVE {PLL} \
    CONFIG.PRIM_IN_FREQ {125.0} \
    CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
    CONFIG.USE_RESET {false} \
  ] $pll


  # Create instance: adc, and set properties
  set adc [ create_bd_cell -type ip -vlnv pavel-demin:user:redp_adc:1.0 adc ]

  # Create instance: dac, and set properties
  set dac [ create_bd_cell -type ip -vlnv pavel-demin:user:redp_dac:1.0 dac ]

  # Create instance: adc_rst, and set properties
  set adc_rst [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 adc_rst ]

  # Create port connections
  connect_bd_net -net adc_adc_cdcs_o  [get_bd_pins adc/adc_cdcs_o] \
  [get_bd_pins adc_cdcs_o]
  connect_bd_net -net adc_adc_clk_source  [get_bd_pins adc/adc_clk_source] \
  [get_bd_pins adc_clk_source]
  connect_bd_net -net adc_adc_dat_a_o  [get_bd_pins adc/adc_dat_a_o] \
  [get_bd_pins adc1]
  connect_bd_net -net adc_adc_dat_b_o  [get_bd_pins adc/adc_dat_b_o] \
  [get_bd_pins adc2]
  connect_bd_net -net adc_clk_n_i_1  [get_bd_pins adc_clk_n_i] \
  [get_bd_pins pll/clk_in1_n]
  connect_bd_net -net adc_clk_p_i_1  [get_bd_pins adc_clk_p_i] \
  [get_bd_pins pll/clk_in1_p]
  connect_bd_net -net adc_dat_a_i_1  [get_bd_pins adc_dat_a_i] \
  [get_bd_pins adc/adc_dat_a_i]
  connect_bd_net -net adc_dat_b_i_1  [get_bd_pins adc_dat_b_i] \
  [get_bd_pins adc/adc_dat_b_i]
  connect_bd_net -net adc_rst_dout  [get_bd_pins adc_rst/dout] \
  [get_bd_pins adc/adc_rst_i]
  connect_bd_net -net dac1_1  [get_bd_pins dac1] \
  [get_bd_pins dac/dac_dat_a_i]
  connect_bd_net -net dac2_1  [get_bd_pins dac2] \
  [get_bd_pins dac/dac_dat_b_i]
  connect_bd_net -net dac_dac_clk_o  [get_bd_pins dac/dac_clk_o] \
  [get_bd_pins dac_clk_o]
  connect_bd_net -net dac_dac_dat_o  [get_bd_pins dac/dac_dat_o] \
  [get_bd_pins dac_dat_o]
  connect_bd_net -net dac_dac_rst_o  [get_bd_pins dac/dac_rst_o] \
  [get_bd_pins dac_rst_o]
  connect_bd_net -net dac_dac_sel_o  [get_bd_pins dac/dac_sel_o] \
  [get_bd_pins dac_sel_o]
  connect_bd_net -net dac_dac_wrt_o  [get_bd_pins dac/dac_wrt_o] \
  [get_bd_pins dac_wrt_o]
  connect_bd_net -net pll_clk_out1  [get_bd_pins pll/clk_out1] \
  [get_bd_pins adc_clk] \
  [get_bd_pins adc/adc_clk]
  connect_bd_net -net pll_clk_out2  [get_bd_pins pll/clk_out2] \
  [get_bd_pins dac/dac_clk_1x]
  connect_bd_net -net pll_clk_out3  [get_bd_pins pll/clk_out3] \
  [get_bd_pins dac/dac_clk_2x]
  connect_bd_net -net pll_clk_out4  [get_bd_pins pll/clk_out4] \
  [get_bd_pins dac/dac_clk_2p]
  connect_bd_net -net pll_clk_out5  [get_bd_pins pll/clk_out5] \
  [get_bd_pins ser_clk]
  connect_bd_net -net pll_clk_out6  [get_bd_pins pll/clk_out6] \
  [get_bd_pins pwm_clk]
  connect_bd_net -net pll_locked  [get_bd_pins pll/locked] \
  [get_bd_pins dac/dac_locked]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set Vp_Vn [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn ]

  set Vaux0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux0 ]

  set Vaux1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux1 ]

  set Vaux9 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux9 ]

  set Vaux8 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux8 ]

  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]


  # Create ports
  set adc_dat_a_i [ create_bd_port -dir I -from 13 -to 0 adc_dat_a_i ]
  set adc_dat_b_i [ create_bd_port -dir I -from 13 -to 0 adc_dat_b_i ]
  set adc_clk_p_i [ create_bd_port -dir I adc_clk_p_i ]
  set adc_clk_n_i [ create_bd_port -dir I adc_clk_n_i ]
  set adc_clk_source [ create_bd_port -dir O -from 1 -to 0 adc_clk_source ]
  set adc_cdcs_o [ create_bd_port -dir O adc_cdcs_o ]
  set dac_dat_o [ create_bd_port -dir O -from 13 -to 0 dac_dat_o ]
  set dac_clk_o [ create_bd_port -dir O dac_clk_o ]
  set dac_rst_o [ create_bd_port -dir O dac_rst_o ]
  set dac_sel_o [ create_bd_port -dir O dac_sel_o ]
  set dac_wrt_o [ create_bd_port -dir O dac_wrt_o ]
  set dac_pwm_o [ create_bd_port -dir O -from 3 -to 0 dac_pwm_o ]
  set led_o [ create_bd_port -dir O -from 7 -to 0 led_o ]

  # Create instance: ps_0, and set properties
  set ps_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps_0 ]
  set_property -dict [list \
    CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
    CONFIG.PCW_ACT_CAN0_PERIPHERAL_FREQMHZ {23.8095} \
    CONFIG.PCW_ACT_CAN1_PERIPHERAL_FREQMHZ {23.8095} \
    CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
    CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
    CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {166.666672} \
    CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_I2C_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {125.000000} \
    CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {166.666672} \
    CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_USB0_PERIPHERAL_FREQMHZ {60} \
    CONFIG.PCW_ACT_USB1_PERIPHERAL_FREQMHZ {60} \
    CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} \
    CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} \
    CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_CAN_PERIPHERAL_VALID {0} \
    CONFIG.PCW_CLK0_FREQ {166666672} \
    CONFIG.PCW_CLK1_FREQ {200000000} \
    CONFIG.PCW_CLK2_FREQ {10000000} \
    CONFIG.PCW_CLK3_FREQ {10000000} \
    CONFIG.PCW_CORE0_FIQ_INTR {0} \
    CONFIG.PCW_CORE0_IRQ_INTR {0} \
    CONFIG.PCW_CORE1_FIQ_INTR {0} \
    CONFIG.PCW_CORE1_IRQ_INTR {0} \
    CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} \
    CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
    CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
    CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
    CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
    CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
    CONFIG.PCW_DDR_RAM_BASEADDR {0x00100000} \
    CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
    CONFIG.PCW_DM_WIDTH {4} \
    CONFIG.PCW_DQS_WIDTH {4} \
    CONFIG.PCW_DQ_WIDTH {32} \
    CONFIG.PCW_ENET0_BASEADDR {0xE000B000} \
    CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
    CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
    CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
    CONFIG.PCW_ENET0_HIGHADDR {0xE000BFFF} \
    CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
    CONFIG.PCW_ENET0_RESET_ENABLE {0} \
    CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_ENET_RESET_ENABLE {1} \
    CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
    CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
    CONFIG.PCW_EN_4K_TIMER {0} \
    CONFIG.PCW_EN_CAN0 {0} \
    CONFIG.PCW_EN_CAN1 {0} \
    CONFIG.PCW_EN_CLK0_PORT {1} \
    CONFIG.PCW_EN_CLK1_PORT {1} \
    CONFIG.PCW_EN_CLK2_PORT {0} \
    CONFIG.PCW_EN_CLK3_PORT {0} \
    CONFIG.PCW_EN_CLKTRIG0_PORT {0} \
    CONFIG.PCW_EN_CLKTRIG1_PORT {0} \
    CONFIG.PCW_EN_CLKTRIG2_PORT {0} \
    CONFIG.PCW_EN_CLKTRIG3_PORT {0} \
    CONFIG.PCW_EN_DDR {1} \
    CONFIG.PCW_EN_EMIO_CAN0 {0} \
    CONFIG.PCW_EN_EMIO_CAN1 {0} \
    CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_CD_SDIO1 {0} \
    CONFIG.PCW_EN_EMIO_ENET0 {0} \
    CONFIG.PCW_EN_EMIO_ENET1 {0} \
    CONFIG.PCW_EN_EMIO_GPIO {0} \
    CONFIG.PCW_EN_EMIO_I2C0 {0} \
    CONFIG.PCW_EN_EMIO_I2C1 {0} \
    CONFIG.PCW_EN_EMIO_MODEM_UART0 {0} \
    CONFIG.PCW_EN_EMIO_MODEM_UART1 {0} \
    CONFIG.PCW_EN_EMIO_PJTAG {0} \
    CONFIG.PCW_EN_EMIO_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_SDIO1 {0} \
    CONFIG.PCW_EN_EMIO_SPI0 {1} \
    CONFIG.PCW_EN_EMIO_SPI1 {0} \
    CONFIG.PCW_EN_EMIO_SRAM_INT {0} \
    CONFIG.PCW_EN_EMIO_TRACE {0} \
    CONFIG.PCW_EN_EMIO_TTC0 {1} \
    CONFIG.PCW_EN_EMIO_TTC1 {0} \
    CONFIG.PCW_EN_EMIO_UART0 {0} \
    CONFIG.PCW_EN_EMIO_UART1 {0} \
    CONFIG.PCW_EN_EMIO_WDT {0} \
    CONFIG.PCW_EN_EMIO_WP_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_WP_SDIO1 {0} \
    CONFIG.PCW_EN_ENET0 {1} \
    CONFIG.PCW_EN_ENET1 {0} \
    CONFIG.PCW_EN_GPIO {1} \
    CONFIG.PCW_EN_I2C0 {1} \
    CONFIG.PCW_EN_I2C1 {0} \
    CONFIG.PCW_EN_MODEM_UART0 {0} \
    CONFIG.PCW_EN_MODEM_UART1 {0} \
    CONFIG.PCW_EN_PJTAG {0} \
    CONFIG.PCW_EN_PTP_ENET0 {0} \
    CONFIG.PCW_EN_PTP_ENET1 {0} \
    CONFIG.PCW_EN_QSPI {1} \
    CONFIG.PCW_EN_RST0_PORT {1} \
    CONFIG.PCW_EN_RST1_PORT {0} \
    CONFIG.PCW_EN_RST2_PORT {0} \
    CONFIG.PCW_EN_RST3_PORT {0} \
    CONFIG.PCW_EN_SDIO0 {1} \
    CONFIG.PCW_EN_SDIO1 {0} \
    CONFIG.PCW_EN_SMC {0} \
    CONFIG.PCW_EN_SPI0 {1} \
    CONFIG.PCW_EN_SPI1 {1} \
    CONFIG.PCW_EN_TRACE {0} \
    CONFIG.PCW_EN_TTC0 {1} \
    CONFIG.PCW_EN_TTC1 {0} \
    CONFIG.PCW_EN_UART0 {1} \
    CONFIG.PCW_EN_UART1 {1} \
    CONFIG.PCW_EN_USB0 {1} \
    CONFIG.PCW_EN_USB1 {0} \
    CONFIG.PCW_EN_WDT {0} \
    CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK_CLK0_BUF {TRUE} \
    CONFIG.PCW_FCLK_CLK1_BUF {TRUE} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {166} \
    CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {200} \
    CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {200} \
    CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
    CONFIG.PCW_FPGA_FCLK1_ENABLE {1} \
    CONFIG.PCW_GP0_EN_MODIFIABLE_TXN {1} \
    CONFIG.PCW_GP0_NUM_READ_THREADS {4} \
    CONFIG.PCW_GP0_NUM_WRITE_THREADS {4} \
    CONFIG.PCW_GP1_EN_MODIFIABLE_TXN {1} \
    CONFIG.PCW_GP1_NUM_READ_THREADS {4} \
    CONFIG.PCW_GP1_NUM_WRITE_THREADS {4} \
    CONFIG.PCW_GPIO_BASEADDR {0xE000A000} \
    CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {0} \
    CONFIG.PCW_GPIO_HIGHADDR {0xE000AFFF} \
    CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
    CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
    CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_I2C0_BASEADDR {0xE0004000} \
    CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
    CONFIG.PCW_I2C0_HIGHADDR {0xE0004FFF} \
    CONFIG.PCW_I2C0_I2C0_IO {MIO 50 .. 51} \
    CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_I2C0_RESET_ENABLE {0} \
    CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_I2C_RESET_ENABLE {1} \
    CONFIG.PCW_I2C_RESET_POLARITY {Active Low} \
    CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} \
    CONFIG.PCW_IMPORT_BOARD_PRESET {None} \
    CONFIG.PCW_INCLUDE_ACP_TRANS_CHECK {0} \
    CONFIG.PCW_IRQ_F2P_INTR {1} \
    CONFIG.PCW_IRQ_F2P_MODE {DIRECT} \
    CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_0_PULLUP {disabled} \
    CONFIG.PCW_MIO_0_SLEW {slow} \
    CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_10_PULLUP {enabled} \
    CONFIG.PCW_MIO_10_SLEW {slow} \
    CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_11_PULLUP {enabled} \
    CONFIG.PCW_MIO_11_SLEW {slow} \
    CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_12_PULLUP {enabled} \
    CONFIG.PCW_MIO_12_SLEW {slow} \
    CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_13_PULLUP {enabled} \
    CONFIG.PCW_MIO_13_SLEW {slow} \
    CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_14_PULLUP {enabled} \
    CONFIG.PCW_MIO_14_SLEW {slow} \
    CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_15_PULLUP {enabled} \
    CONFIG.PCW_MIO_15_SLEW {slow} \
    CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_16_PULLUP {disabled} \
    CONFIG.PCW_MIO_16_SLEW {fast} \
    CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_17_PULLUP {disabled} \
    CONFIG.PCW_MIO_17_SLEW {fast} \
    CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_18_PULLUP {disabled} \
    CONFIG.PCW_MIO_18_SLEW {fast} \
    CONFIG.PCW_MIO_19_IOTYPE {out} \
    CONFIG.PCW_MIO_19_PULLUP {disabled} \
    CONFIG.PCW_MIO_19_SLEW {fast} \
    CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_1_PULLUP {enabled} \
    CONFIG.PCW_MIO_1_SLEW {slow} \
    CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_20_PULLUP {disabled} \
    CONFIG.PCW_MIO_20_SLEW {fast} \
    CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_21_PULLUP {disabled} \
    CONFIG.PCW_MIO_21_SLEW {fast} \
    CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_22_PULLUP {disabled} \
    CONFIG.PCW_MIO_22_SLEW {fast} \
    CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_23_PULLUP {disabled} \
    CONFIG.PCW_MIO_23_SLEW {fast} \
    CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_24_PULLUP {disabled} \
    CONFIG.PCW_MIO_24_SLEW {fast} \
    CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_25_PULLUP {disabled} \
    CONFIG.PCW_MIO_25_SLEW {fast} \
    CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_26_PULLUP {disabled} \
    CONFIG.PCW_MIO_26_SLEW {fast} \
    CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_27_PULLUP {disabled} \
    CONFIG.PCW_MIO_27_SLEW {fast} \
    CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_28_PULLUP {enabled} \
    CONFIG.PCW_MIO_28_SLEW {fast} \
    CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_29_PULLUP {enabled} \
    CONFIG.PCW_MIO_29_SLEW {fast} \
    CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_2_SLEW {slow} \
    CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_30_PULLUP {enabled} \
    CONFIG.PCW_MIO_30_SLEW {fast} \
    CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_31_PULLUP {enabled} \
    CONFIG.PCW_MIO_31_SLEW {fast} \
    CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_32_PULLUP {enabled} \
    CONFIG.PCW_MIO_32_SLEW {fast} \
    CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_33_PULLUP {enabled} \
    CONFIG.PCW_MIO_33_SLEW {fast} \
    CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_34_PULLUP {enabled} \
    CONFIG.PCW_MIO_34_SLEW {fast} \
    CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_35_PULLUP {enabled} \
    CONFIG.PCW_MIO_35_SLEW {fast} \
    CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_36_PULLUP {enabled} \
    CONFIG.PCW_MIO_36_SLEW {fast} \
    CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_37_PULLUP {enabled} \
    CONFIG.PCW_MIO_37_SLEW {fast} \
    CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_38_PULLUP {enabled} \
    CONFIG.PCW_MIO_38_SLEW {fast} \
    CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_39_PULLUP {enabled} \
    CONFIG.PCW_MIO_39_SLEW {fast} \
    CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_3_SLEW {slow} \
    CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_40_PULLUP {enabled} \
    CONFIG.PCW_MIO_40_SLEW {slow} \
    CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_41_PULLUP {enabled} \
    CONFIG.PCW_MIO_41_SLEW {slow} \
    CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_42_PULLUP {enabled} \
    CONFIG.PCW_MIO_42_SLEW {slow} \
    CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_43_PULLUP {enabled} \
    CONFIG.PCW_MIO_43_SLEW {slow} \
    CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_44_PULLUP {enabled} \
    CONFIG.PCW_MIO_44_SLEW {slow} \
    CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_45_PULLUP {enabled} \
    CONFIG.PCW_MIO_45_SLEW {slow} \
    CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_46_PULLUP {enabled} \
    CONFIG.PCW_MIO_46_SLEW {slow} \
    CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_47_PULLUP {enabled} \
    CONFIG.PCW_MIO_47_SLEW {slow} \
    CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_48_PULLUP {enabled} \
    CONFIG.PCW_MIO_48_SLEW {slow} \
    CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_49_PULLUP {enabled} \
    CONFIG.PCW_MIO_49_SLEW {slow} \
    CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_4_SLEW {slow} \
    CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_50_PULLUP {enabled} \
    CONFIG.PCW_MIO_50_SLEW {slow} \
    CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_51_PULLUP {enabled} \
    CONFIG.PCW_MIO_51_SLEW {slow} \
    CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_52_PULLUP {enabled} \
    CONFIG.PCW_MIO_52_SLEW {slow} \
    CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_53_PULLUP {enabled} \
    CONFIG.PCW_MIO_53_SLEW {slow} \
    CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_5_SLEW {slow} \
    CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_6_SLEW {slow} \
    CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_7_SLEW {slow} \
    CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_8_SLEW {slow} \
    CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_9_PULLUP {enabled} \
    CONFIG.PCW_MIO_9_SLEW {slow} \
    CONFIG.PCW_MIO_PRIMITIVE {54} \
    CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO#UART 1#UART 1#SPI 1#SPI 1#SPI 1#SPI 1#UART 0#UART 0#Enet 0#Enet\
0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#USB Reset#GPIO#I2C\
0#I2C 0#Enet 0#Enet 0} \
    CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#gpio[7]#tx#rx#mosi#miso#sclk#ss[0]#rx#tx#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#cd#wp#reset#gpio[49]#scl#sda#mdc#mdio}\
\
    CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {0} \
    CONFIG.PCW_M_AXI_GP0_ID_WIDTH {12} \
    CONFIG.PCW_M_AXI_GP0_SUPPORT_NARROW_BURST {0} \
    CONFIG.PCW_M_AXI_GP0_THREAD_ID_WIDTH {12} \
    CONFIG.PCW_NAND_CYCLES_T_AR {1} \
    CONFIG.PCW_NAND_CYCLES_T_CLR {1} \
    CONFIG.PCW_NAND_CYCLES_T_RC {11} \
    CONFIG.PCW_NAND_CYCLES_T_REA {1} \
    CONFIG.PCW_NAND_CYCLES_T_RR {1} \
    CONFIG.PCW_NAND_CYCLES_T_WC {11} \
    CONFIG.PCW_NAND_CYCLES_T_WP {1} \
    CONFIG.PCW_NOR_CS0_T_CEOE {1} \
    CONFIG.PCW_NOR_CS0_T_PC {1} \
    CONFIG.PCW_NOR_CS0_T_RC {11} \
    CONFIG.PCW_NOR_CS0_T_TR {1} \
    CONFIG.PCW_NOR_CS0_T_WC {11} \
    CONFIG.PCW_NOR_CS0_T_WP {1} \
    CONFIG.PCW_NOR_CS0_WE_TIME {0} \
    CONFIG.PCW_NOR_CS1_T_CEOE {1} \
    CONFIG.PCW_NOR_CS1_T_PC {1} \
    CONFIG.PCW_NOR_CS1_T_RC {11} \
    CONFIG.PCW_NOR_CS1_T_TR {1} \
    CONFIG.PCW_NOR_CS1_T_WC {11} \
    CONFIG.PCW_NOR_CS1_T_WP {1} \
    CONFIG.PCW_NOR_CS1_WE_TIME {0} \
    CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_RC {11} \
    CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_WC {11} \
    CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} \
    CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {0} \
    CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_RC {11} \
    CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_WC {11} \
    CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} \
    CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {0} \
    CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} \
    CONFIG.PCW_P2F_ENET0_INTR {0} \
    CONFIG.PCW_P2F_GPIO_INTR {0} \
    CONFIG.PCW_P2F_I2C0_INTR {0} \
    CONFIG.PCW_P2F_QSPI_INTR {0} \
    CONFIG.PCW_P2F_SDIO0_INTR {0} \
    CONFIG.PCW_P2F_SPI0_INTR {0} \
    CONFIG.PCW_P2F_SPI1_INTR {0} \
    CONFIG.PCW_P2F_UART0_INTR {0} \
    CONFIG.PCW_P2F_UART1_INTR {0} \
    CONFIG.PCW_P2F_USB0_INTR {0} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.080} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.063} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.057} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.068} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.047} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.025} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.006} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.017} \
    CONFIG.PCW_PACKAGE_NAME {clg400} \
    CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
    CONFIG.PCW_PERIPHERAL_BOARD_PRESET {None} \
    CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} \
    CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
    CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 2.5V} \
    CONFIG.PCW_PS7_SI_REV {PRODUCTION} \
    CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} \
    CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
    CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
    CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
    CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
    CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} \
    CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {125} \
    CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
    CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
    CONFIG.PCW_SD0_GRP_CD_IO {MIO 46} \
    CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
    CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
    CONFIG.PCW_SD0_GRP_WP_IO {MIO 47} \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
    CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SDIO0_BASEADDR {0xE0100000} \
    CONFIG.PCW_SDIO0_HIGHADDR {0xE0100FFF} \
    CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
    CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} \
    CONFIG.PCW_SMC_CYCLE_T0 {NA} \
    CONFIG.PCW_SMC_CYCLE_T1 {NA} \
    CONFIG.PCW_SMC_CYCLE_T2 {NA} \
    CONFIG.PCW_SMC_CYCLE_T3 {NA} \
    CONFIG.PCW_SMC_CYCLE_T4 {NA} \
    CONFIG.PCW_SMC_CYCLE_T5 {NA} \
    CONFIG.PCW_SMC_CYCLE_T6 {NA} \
    CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SMC_PERIPHERAL_VALID {0} \
    CONFIG.PCW_SPI0_BASEADDR {0xE0006000} \
    CONFIG.PCW_SPI0_HIGHADDR {0xE0006FFF} \
    CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
    CONFIG.PCW_SPI1_BASEADDR {0xE0007000} \
    CONFIG.PCW_SPI1_GRP_SS1_ENABLE {0} \
    CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0} \
    CONFIG.PCW_SPI1_HIGHADDR {0xE0007FFF} \
    CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SPI1_SPI1_IO {MIO 10 .. 15} \
    CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
    CONFIG.PCW_SPI_PERIPHERAL_VALID {1} \
    CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_TRACE_INTERNAL_WIDTH {2} \
    CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_TTC0_BASEADDR {0xE0104000} \
    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_HIGHADDR {0xE0104fff} \
    CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_TTC0_TTC0_IO {EMIO} \
    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_UART0_BASEADDR {0xE0000000} \
    CONFIG.PCW_UART0_BAUD_RATE {115200} \
    CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
    CONFIG.PCW_UART0_HIGHADDR {0xE0000FFF} \
    CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
    CONFIG.PCW_UART1_BASEADDR {0xE0001000} \
    CONFIG.PCW_UART1_BAUD_RATE {115200} \
    CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
    CONFIG.PCW_UART1_HIGHADDR {0xE0001FFF} \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART1_UART1_IO {MIO 8 .. 9} \
    CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
    CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
    CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
    CONFIG.PCW_UIPARAM_DDR_AL {0} \
    CONFIG.PCW_UIPARAM_DDR_BL {8} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {101.239} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {79.5025} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {60.536} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {71.7715} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {104.5365} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {70.676} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {59.1615} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {81.319} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
    CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
    CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
    CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
    CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
    CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
    CONFIG.PCW_UIPARAM_GENERATE_SUMMARY {NA} \
    CONFIG.PCW_USB0_BASEADDR {0xE0102000} \
    CONFIG.PCW_USB0_HIGHADDR {0xE0102fff} \
    CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_USB0_RESET_ENABLE {1} \
    CONFIG.PCW_USB0_RESET_IO {MIO 48} \
    CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
    CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_USB_RESET_ENABLE {1} \
    CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
    CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
    CONFIG.PCW_USE_AXI_FABRIC_IDLE {0} \
    CONFIG.PCW_USE_AXI_NONSECURE {0} \
    CONFIG.PCW_USE_CORESIGHT {0} \
    CONFIG.PCW_USE_CROSS_TRIGGER {0} \
    CONFIG.PCW_USE_CR_FABRIC {1} \
    CONFIG.PCW_USE_DDR_BYPASS {0} \
    CONFIG.PCW_USE_DEBUG {0} \
    CONFIG.PCW_USE_DMA0 {0} \
    CONFIG.PCW_USE_DMA1 {0} \
    CONFIG.PCW_USE_DMA2 {0} \
    CONFIG.PCW_USE_DMA3 {0} \
    CONFIG.PCW_USE_EXPANDED_IOP {0} \
    CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
    CONFIG.PCW_USE_HIGH_OCM {0} \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
    CONFIG.PCW_USE_M_AXI_GP1 {0} \
    CONFIG.PCW_USE_PROC_EVENT_BUS {0} \
    CONFIG.PCW_USE_PS_SLCR_REGISTERS {0} \
    CONFIG.PCW_USE_S_AXI_ACP {0} \
    CONFIG.PCW_USE_S_AXI_GP0 {0} \
    CONFIG.PCW_USE_S_AXI_GP1 {0} \
    CONFIG.PCW_USE_S_AXI_HP0 {0} \
    CONFIG.PCW_USE_S_AXI_HP1 {0} \
    CONFIG.PCW_USE_S_AXI_HP2 {0} \
    CONFIG.PCW_USE_S_AXI_HP3 {0} \
    CONFIG.PCW_USE_TRACE {0} \
    CONFIG.PCW_VALUE_SILVERSION {3} \
    CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} \
  ] $ps_0


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: axi_mem_intercon_0, and set properties
  set axi_mem_intercon_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon_0 ]
  set_property CONFIG.NUM_MI {3} $axi_mem_intercon_0


  # Create instance: adc_dac
  create_hier_cell_adc_dac [current_bd_instance .] adc_dac

  # Create instance: proc_sys_reset_adc_clk, and set properties
  set proc_sys_reset_adc_clk [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_adc_clk ]

  # Create instance: ctl
  create_hier_cell_ctl [current_bd_instance .] ctl

  # Create instance: sts
  create_hier_cell_sts [current_bd_instance .] sts

  # Create instance: slice_7_0_ctl_led, and set properties
  set slice_7_0_ctl_led [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_7_0_ctl_led ]
  set_property -dict [list \
    CONFIG.DIN_FROM {7} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {32} \
  ] $slice_7_0_ctl_led


  # Create instance: adc_clock_converter, and set properties
  set adc_clock_converter [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 adc_clock_converter ]
  set_property CONFIG.TDATA_NUM_BYTES {4} $adc_clock_converter


  # Create instance: adc_axis_fifo, and set properties
  set adc_axis_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.3 adc_axis_fifo ]
  set_property -dict [list \
    CONFIG.C_RX_FIFO_DEPTH {16384} \
    CONFIG.C_RX_FIFO_PF_THRESHOLD {8192} \
    CONFIG.C_USE_RX_CUT_THROUGH {true} \
    CONFIG.C_USE_TX_CTRL {0} \
    CONFIG.C_USE_TX_DATA {0} \
  ] $adc_axis_fifo


  # Create instance: Radio
  create_hier_cell_Radio [current_bd_instance .] Radio

  # Create instance: Local_Oscillator
  create_hier_cell_Local_Oscillator [current_bd_instance .] Local_Oscillator

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {15} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {16} \
  ] $xlslice_0


  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_mem_intercon_0/S00_AXI] [get_bd_intf_pins ps_0/M_AXI_GP0]
  connect_bd_intf_net -intf_net adc_clock_converter_M_AXIS [get_bd_intf_pins adc_axis_fifo/AXI_STR_RXD] [get_bd_intf_pins adc_clock_converter/M_AXIS]
  connect_bd_intf_net -intf_net axi_mem_intercon_0_M00_AXI [get_bd_intf_pins axi_mem_intercon_0/M00_AXI] [get_bd_intf_pins ctl/S_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_0_M01_AXI [get_bd_intf_pins axi_mem_intercon_0/M01_AXI] [get_bd_intf_pins sts/S_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_0_M02_AXI [get_bd_intf_pins adc_axis_fifo/S_AXI] [get_bd_intf_pins axi_mem_intercon_0/M02_AXI]
  connect_bd_intf_net -intf_net ps_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins ps_0/DDR]
  connect_bd_intf_net -intf_net ps_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins ps_0/FIXED_IO]

  # Create port connections
  connect_bd_net -net ARESETN_1  [get_bd_pins proc_sys_reset_0/interconnect_aresetn] \
  [get_bd_pins axi_mem_intercon_0/ARESETN]
  connect_bd_net -net Local_Oscillator_LO_I  [get_bd_pins Local_Oscillator/LO_I] \
  [get_bd_pins Radio/LocalOscillator_I]
  connect_bd_net -net Local_Oscillator_LO_Q  [get_bd_pins Local_Oscillator/LO_Q] \
  [get_bd_pins Radio/LocalOscillator_Q]
  connect_bd_net -net Radio_AfterMixerLPF  [get_bd_pins Radio/AfterMixerLPF] \
  [get_bd_pins adc_dac/dac2]
  connect_bd_net -net Radio_Data2Stream  [get_bd_pins Radio/Data2Stream] \
  [get_bd_pins adc_clock_converter/s_axis_tdata]
  connect_bd_net -net Radio_Signal_level  [get_bd_pins Radio/Signal_level] \
  [get_bd_pins sts/signal_strength]
  connect_bd_net -net Radio_Speaker_out  [get_bd_pins Radio/Speaker_out] \
  [get_bd_pins xlslice_0/Din]
  connect_bd_net -net Radio_Strobe  [get_bd_pins Radio/Strobe] \
  [get_bd_pins adc_clock_converter/s_axis_tvalid]
  connect_bd_net -net S00_ARESETN_1  [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins axi_mem_intercon_0/S00_ARESETN] \
  [get_bd_pins axi_mem_intercon_0/M00_ARESETN] \
  [get_bd_pins ctl/s_axi_aresetn] \
  [get_bd_pins axi_mem_intercon_0/M01_ARESETN] \
  [get_bd_pins sts/s_axi_aresetn] \
  [get_bd_pins axi_mem_intercon_0/M02_ARESETN] \
  [get_bd_pins adc_clock_converter/m_axis_aresetn] \
  [get_bd_pins adc_axis_fifo/s_axi_aresetn]
  connect_bd_net -net Set_Freq_1  [get_bd_pins ctl/receive_frequency] \
  [get_bd_pins Local_Oscillator/Set_Freq]
  connect_bd_net -net adc_clk_n_i_1  [get_bd_ports adc_clk_n_i] \
  [get_bd_pins adc_dac/adc_clk_n_i]
  connect_bd_net -net adc_clk_p_i_1  [get_bd_ports adc_clk_p_i] \
  [get_bd_pins adc_dac/adc_clk_p_i]
  connect_bd_net -net adc_dac_adc1  [get_bd_pins adc_dac/adc1] \
  [get_bd_pins Radio/AntennaInput]
  connect_bd_net -net adc_dac_adc_cdcs_o  [get_bd_pins adc_dac/adc_cdcs_o] \
  [get_bd_ports adc_cdcs_o]
  connect_bd_net -net adc_dac_adc_clk  [get_bd_pins adc_dac/adc_clk] \
  [get_bd_pins proc_sys_reset_adc_clk/slowest_sync_clk] \
  [get_bd_pins ctl/m_axi_aclk] \
  [get_bd_pins sts/m_axi_aclk] \
  [get_bd_pins adc_clock_converter/s_axis_aclk] \
  [get_bd_pins Radio/SampleClock] \
  [get_bd_pins Local_Oscillator/Sample_clock]
  connect_bd_net -net adc_dac_adc_clk_source  [get_bd_pins adc_dac/adc_clk_source] \
  [get_bd_ports adc_clk_source]
  connect_bd_net -net adc_dac_dac_clk_o  [get_bd_pins adc_dac/dac_clk_o] \
  [get_bd_ports dac_clk_o]
  connect_bd_net -net adc_dac_dac_dat_o  [get_bd_pins adc_dac/dac_dat_o] \
  [get_bd_ports dac_dat_o]
  connect_bd_net -net adc_dac_dac_rst_o  [get_bd_pins adc_dac/dac_rst_o] \
  [get_bd_ports dac_rst_o]
  connect_bd_net -net adc_dac_dac_sel_o  [get_bd_pins adc_dac/dac_sel_o] \
  [get_bd_ports dac_sel_o]
  connect_bd_net -net adc_dac_dac_wrt_o  [get_bd_pins adc_dac/dac_wrt_o] \
  [get_bd_ports dac_wrt_o]
  connect_bd_net -net adc_dat_a_i_1  [get_bd_ports adc_dat_a_i] \
  [get_bd_pins adc_dac/adc_dat_a_i]
  connect_bd_net -net adc_dat_b_i_1  [get_bd_ports adc_dat_b_i] \
  [get_bd_pins adc_dac/adc_dat_b_i]
  connect_bd_net -net ctl_led  [get_bd_pins ctl/led] \
  [get_bd_pins slice_7_0_ctl_led/Din]
  connect_bd_net -net ctl_volume  [get_bd_pins ctl/volume] \
  [get_bd_pins Radio/Volume]
  connect_bd_net -net proc_sys_reset_adc_clk_peripheral_aresetn  [get_bd_pins proc_sys_reset_adc_clk/peripheral_aresetn] \
  [get_bd_pins ctl/m_axi_aresetn] \
  [get_bd_pins sts/m_axi_aresetn] \
  [get_bd_pins adc_clock_converter/s_axis_aresetn]
  connect_bd_net -net ps_0_FCLK_CLK0  [get_bd_pins ps_0/FCLK_CLK0] \
  [get_bd_pins ps_0/M_AXI_GP0_ACLK] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
  [get_bd_pins axi_mem_intercon_0/ACLK] \
  [get_bd_pins axi_mem_intercon_0/S00_ACLK] \
  [get_bd_pins axi_mem_intercon_0/M00_ACLK] \
  [get_bd_pins ctl/s_axi_aclk] \
  [get_bd_pins axi_mem_intercon_0/M01_ACLK] \
  [get_bd_pins sts/s_axi_aclk] \
  [get_bd_pins axi_mem_intercon_0/M02_ACLK] \
  [get_bd_pins adc_clock_converter/m_axis_aclk] \
  [get_bd_pins adc_axis_fifo/s_axi_aclk]
  connect_bd_net -net ps_0_FCLK_RESET0_N  [get_bd_pins ps_0/FCLK_RESET0_N] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in] \
  [get_bd_pins proc_sys_reset_adc_clk/ext_reset_in]
  connect_bd_net -net slice_7_0_ctl_led_Dout  [get_bd_pins slice_7_0_ctl_led/Dout] \
  [get_bd_ports led_o]
  connect_bd_net -net xlslice_0_Dout  [get_bd_pins xlslice_0/Dout] \
  [get_bd_pins adc_dac/dac1]

  # Create address segments
  assign_bd_address -offset 0x43C10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs adc_axis_fifo/S_AXI/Mem0] -force
  assign_bd_address -offset 0x60000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs ctl/axi_ctl_register/s_axi/reg0] -force
  assign_bd_address -offset 0x50000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs sts/axi_sts_register_0/s_axi/reg0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


