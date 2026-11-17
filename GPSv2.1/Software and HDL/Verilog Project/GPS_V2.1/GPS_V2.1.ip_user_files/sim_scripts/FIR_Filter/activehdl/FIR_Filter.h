
//------------------------------------------------------------------------------
// (c) Copyright 2023 Advanced Micro Devices. All rights reserved.
//
// This file contains confidential and proprietary information
// of AMD, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//------------------------------------------------------------------------------ 
//
// C Model configuration for the "FIR_Filter" instance.
//
//------------------------------------------------------------------------------
//
// coefficients: 1.62616296e-04,1.22411370e-04,7.68063330e-05,2.65739220e-05,-2.73762833e-05,-8.39488201e-05,-1.41817037e-04,-1.99388470e-04,-2.54787599e-04,-3.05861883e-04,-3.50215650e-04,-3.85274667e-04,-4.08382052e-04,-4.16923852e-04,-4.08480106e-04,-3.80994816e-04,-3.32956061e-04,-2.63575649e-04,-1.72956435e-04,-6.22347514e-05,6.63144951e-05,2.09221680e-04,3.61825202e-04,5.18340664e-04,6.72000939e-04,8.15267951e-04,9.40113009e-04,1.03835828e-03,1.10206792e-03,1.12397336e-03,1.09791408e-03,1.01927218e-03,8.85377859e-04,6.95861563e-04,4.52929838e-04,1.61543111e-04,-1.70522965e-04,-5.32746884e-04,-9.12070331e-04,-1.29324972e-03,-1.65934628e-03,-1.99234364e-03,-2.27387492e-03,-2.48603436e-03,-2.61224276e-03,-2.63813099e-03,-2.55240195e-03,-2.34762966e-03,-2.02095366e-03,-1.57462865e-03,-1.01639300e-03,-3.59625078e-04,3.76736175e-04,1.16852131e-03,1.98691591e-03,2.79929561e-03,3.57029329e-03,4.26307003e-03,4.84075087e-03,5.26797674e-03,5.51251631e-03,5.54687510e-03,5.34983584e-03,4.90786291e-03,4.21630539e-03,3.28033763e-03,2.11558367e-03,7.48381695e-04,-7.84343568e-04,-2.43561820e-03,-4.14936891e-03,-5.86177199e-03,-7.50297157e-03,-8.99912217e-03,-1.02746955e-02,-1.12549789e-02,-1.18686832e-02,-1.20505683e-02,-1.17439936e-02,-1.09032965e-02,-9.49590736e-03,-7.50411507e-03,-4.92640748e-03,-1.77832409e-03,1.90722533e-03,6.08020460e-03,1.06742663e-02,1.56081266e-02,2.07874673e-02,2.61073136e-02,3.14548181e-02,3.67123641e-02,4.17608912e-02,4.64833341e-02,5.07680607e-02,5.45121960e-02,5.76247168e-02,6.00292137e-02,6.16662254e-02,6.24950628e-02,6.24950628e-02,6.16662254e-02,6.00292137e-02,5.76247168e-02,5.45121960e-02,5.07680607e-02,4.64833341e-02,4.17608912e-02,3.67123641e-02,3.14548181e-02,2.61073136e-02,2.07874673e-02,1.56081266e-02,1.06742663e-02,6.08020460e-03,1.90722533e-03,-1.77832409e-03,-4.92640748e-03,-7.50411507e-03,-9.49590736e-03,-1.09032965e-02,-1.17439936e-02,-1.20505683e-02,-1.18686832e-02,-1.12549789e-02,-1.02746955e-02,-8.99912217e-03,-7.50297157e-03,-5.86177199e-03,-4.14936891e-03,-2.43561820e-03,-7.84343568e-04,7.48381695e-04,2.11558367e-03,3.28033763e-03,4.21630539e-03,4.90786291e-03,5.34983584e-03,5.54687510e-03,5.51251631e-03,5.26797674e-03,4.84075087e-03,4.26307003e-03,3.57029329e-03,2.79929561e-03,1.98691591e-03,1.16852131e-03,3.76736175e-04,-3.59625078e-04,-1.01639300e-03,-1.57462865e-03,-2.02095366e-03,-2.34762966e-03,-2.55240195e-03,-2.63813099e-03,-2.61224276e-03,-2.48603436e-03,-2.27387492e-03,-1.99234364e-03,-1.65934628e-03,-1.29324972e-03,-9.12070331e-04,-5.32746884e-04,-1.70522965e-04,1.61543111e-04,4.52929838e-04,6.95861563e-04,8.85377859e-04,1.01927218e-03,1.09791408e-03,1.12397336e-03,1.10206792e-03,1.03835828e-03,9.40113009e-04,8.15267951e-04,6.72000939e-04,5.18340664e-04,3.61825202e-04,2.09221680e-04,6.63144951e-05,-6.22347514e-05,-1.72956435e-04,-2.63575649e-04,-3.32956061e-04,-3.80994816e-04,-4.08480106e-04,-4.16923852e-04,-4.08382052e-04,-3.85274667e-04,-3.50215650e-04,-3.05861883e-04,-2.54787599e-04,-1.99388470e-04,-1.41817037e-04,-8.39488201e-05,-2.73762833e-05,2.65739220e-05,7.68063330e-05,1.22411370e-04,1.62616296e-04
// chanpats: 173
// name: FIR_Filter
// filter_type: 2
// rate_change: 0
// interp_rate: 1
// decim_rate: 16
// zero_pack_factor: 1
// coeff_padding: 12
// num_coeffs: 200
// coeff_sets: 1
// reloadable: 0
// is_halfband: 0
// quantization: 1
// coeff_width: 25
// coeff_fract_width: 28
// chan_seq: 0
// num_channels: 1
// num_paths: 2
// data_width: 6
// data_fract_width: 0
// output_rounding_mode: 1
// output_width: 1
// output_fract_width: 0
// config_method: 0

const double FIR_Filter_coefficients[200] = {1.62616296e-04,1.22411370e-04,7.68063330e-05,2.65739220e-05,-2.73762833e-05,-8.39488201e-05,-1.41817037e-04,-1.99388470e-04,-2.54787599e-04,-3.05861883e-04,-3.50215650e-04,-3.85274667e-04,-4.08382052e-04,-4.16923852e-04,-4.08480106e-04,-3.80994816e-04,-3.32956061e-04,-2.63575649e-04,-1.72956435e-04,-6.22347514e-05,6.63144951e-05,2.09221680e-04,3.61825202e-04,5.18340664e-04,6.72000939e-04,8.15267951e-04,9.40113009e-04,1.03835828e-03,1.10206792e-03,1.12397336e-03,1.09791408e-03,1.01927218e-03,8.85377859e-04,6.95861563e-04,4.52929838e-04,1.61543111e-04,-1.70522965e-04,-5.32746884e-04,-9.12070331e-04,-1.29324972e-03,-1.65934628e-03,-1.99234364e-03,-2.27387492e-03,-2.48603436e-03,-2.61224276e-03,-2.63813099e-03,-2.55240195e-03,-2.34762966e-03,-2.02095366e-03,-1.57462865e-03,-1.01639300e-03,-3.59625078e-04,3.76736175e-04,1.16852131e-03,1.98691591e-03,2.79929561e-03,3.57029329e-03,4.26307003e-03,4.84075087e-03,5.26797674e-03,5.51251631e-03,5.54687510e-03,5.34983584e-03,4.90786291e-03,4.21630539e-03,3.28033763e-03,2.11558367e-03,7.48381695e-04,-7.84343568e-04,-2.43561820e-03,-4.14936891e-03,-5.86177199e-03,-7.50297157e-03,-8.99912217e-03,-1.02746955e-02,-1.12549789e-02,-1.18686832e-02,-1.20505683e-02,-1.17439936e-02,-1.09032965e-02,-9.49590736e-03,-7.50411507e-03,-4.92640748e-03,-1.77832409e-03,1.90722533e-03,6.08020460e-03,1.06742663e-02,1.56081266e-02,2.07874673e-02,2.61073136e-02,3.14548181e-02,3.67123641e-02,4.17608912e-02,4.64833341e-02,5.07680607e-02,5.45121960e-02,5.76247168e-02,6.00292137e-02,6.16662254e-02,6.24950628e-02,6.24950628e-02,6.16662254e-02,6.00292137e-02,5.76247168e-02,5.45121960e-02,5.07680607e-02,4.64833341e-02,4.17608912e-02,3.67123641e-02,3.14548181e-02,2.61073136e-02,2.07874673e-02,1.56081266e-02,1.06742663e-02,6.08020460e-03,1.90722533e-03,-1.77832409e-03,-4.92640748e-03,-7.50411507e-03,-9.49590736e-03,-1.09032965e-02,-1.17439936e-02,-1.20505683e-02,-1.18686832e-02,-1.12549789e-02,-1.02746955e-02,-8.99912217e-03,-7.50297157e-03,-5.86177199e-03,-4.14936891e-03,-2.43561820e-03,-7.84343568e-04,7.48381695e-04,2.11558367e-03,3.28033763e-03,4.21630539e-03,4.90786291e-03,5.34983584e-03,5.54687510e-03,5.51251631e-03,5.26797674e-03,4.84075087e-03,4.26307003e-03,3.57029329e-03,2.79929561e-03,1.98691591e-03,1.16852131e-03,3.76736175e-04,-3.59625078e-04,-1.01639300e-03,-1.57462865e-03,-2.02095366e-03,-2.34762966e-03,-2.55240195e-03,-2.63813099e-03,-2.61224276e-03,-2.48603436e-03,-2.27387492e-03,-1.99234364e-03,-1.65934628e-03,-1.29324972e-03,-9.12070331e-04,-5.32746884e-04,-1.70522965e-04,1.61543111e-04,4.52929838e-04,6.95861563e-04,8.85377859e-04,1.01927218e-03,1.09791408e-03,1.12397336e-03,1.10206792e-03,1.03835828e-03,9.40113009e-04,8.15267951e-04,6.72000939e-04,5.18340664e-04,3.61825202e-04,2.09221680e-04,6.63144951e-05,-6.22347514e-05,-1.72956435e-04,-2.63575649e-04,-3.32956061e-04,-3.80994816e-04,-4.08480106e-04,-4.16923852e-04,-4.08382052e-04,-3.85274667e-04,-3.50215650e-04,-3.05861883e-04,-2.54787599e-04,-1.99388470e-04,-1.41817037e-04,-8.39488201e-05,-2.73762833e-05,2.65739220e-05,7.68063330e-05,1.22411370e-04,1.62616296e-04};

const xip_fir_v7_2_pattern FIR_Filter_chanpats[1] = {P_BASIC};

static xip_fir_v7_2_config gen_FIR_Filter_config() {
  xip_fir_v7_2_config config;
  config.name                = "FIR_Filter";
  config.filter_type         = 2;
  config.rate_change         = XIP_FIR_INTEGER_RATE;
  config.interp_rate         = 1;
  config.decim_rate          = 16;
  config.zero_pack_factor    = 1;
  config.coeff               = &FIR_Filter_coefficients[0];
  config.coeff_padding       = 12;
  config.num_coeffs          = 200;
  config.coeff_sets          = 1;
  config.reloadable          = 0;
  config.is_halfband         = 0;
  config.quantization        = XIP_FIR_QUANTIZED_ONLY;
  config.coeff_width         = 25;
  config.coeff_fract_width   = 28;
  config.chan_seq            = XIP_FIR_BASIC_CHAN_SEQ;
  config.num_channels        = 1;
  config.init_pattern        = FIR_Filter_chanpats[0];
  config.num_paths           = 2;
  config.data_width          = 6;
  config.data_fract_width    = 0;
  config.output_rounding_mode= XIP_FIR_TRUNCATE_LSBS;
  config.output_width        = 1;
  config.output_fract_width  = 0,
  config.config_method       = XIP_FIR_CONFIG_SINGLE;
  return config;
}

const xip_fir_v7_2_config FIR_Filter_config = gen_FIR_Filter_config();

