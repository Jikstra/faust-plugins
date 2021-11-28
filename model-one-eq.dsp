declare options "[midi:on]";

import("stdfaust.lib");

invertBool = _ : _;

lsf_toggle = checkbox("[3]lsf disable") : invertBool;
lsf_fc     = hslider(" [1]lsf fc[midi:ctrl 1]", 21000, 30, 21000, 1) : si.smoo;
lsf_n      = 3;
//lsf_gain   = hslider(" [2]lsf gain", -75, -200, 6, 0.001) : si.smoo;
lsf_gain = ma.INFINITY * -1; 


sculpt_eq_toggle = checkbox("[20]sculpt disable") : invertBool;
sculpt_eq_fc     = hslider(" [21]sculpt fc[midi:ctrl 2]", 1300, 30, 20000, 1) : si.smoo;
sculpt_eq_width  = hslider(" [22]sculpt width", 100, 1, 3000, 1) : si.smoo;
sculpt_eq_n      = 5;
sculpt_eq_gain   = hslider(" [23]sculpt gain[midi:ctrl 3]", 0, -70, 30, 0.001) : si.smoo;

hsf_toggle = checkbox("[20]hsf disable") : invertBool;
hsf_fc     = hslider(" [21]hsf fc[midi:ctrl 4]", 30, 30, 20000, 1) : si.smoo;
hsf_n      = 5;
//hsf_gain   = hslider(" [23]hsf gain", -75, -200, 6, 0.001) : si.smoo;
hsf_gain = ma.INFINITY * -1;


_lsf_mono = _ : fi.lowshelf(lsf_n, lsf_gain, lsf_fc) : fi.lowshelf(lsf_n, lsf_gain, lsf_fc)  : fi.lowshelf(lsf_n, lsf_gain, lsf_fc) : fi.lowshelf(lsf_n, lsf_gain, lsf_fc) : _;
_lsf_stereo = _,_ : _lsf_mono,_lsf_mono : _,_;
lsf = _,_ : ba.bypass2(lsf_toggle, _lsf_stereo) : _,_;


_hsf_mono = _ : fi.highshelf(hsf_n, hsf_gain, hsf_fc) : fi.highshelf(hsf_n, hsf_gain, hsf_fc) : fi.highshelf(hsf_n, hsf_gain, hsf_fc) : fi.highshelf(hsf_n, hsf_gain, hsf_fc) : _;
_hsf_stereo = _,_ : _hsf_mono, _hsf_mono : _,_;
hsf = _,_ : ba.bypass2(hsf_toggle, _hsf_stereo) : _,_;
         
_sculpt_eq2 = _ : fi.peak_eq(sculpt_eq_gain, sculpt_eq_fc, sculpt_eq_width) : fi.peak_eq(sculpt_eq_gain, sculpt_eq_fc, sculpt_eq_width) : _;
_sculpt_eq_mono = _ : _sculpt_eq2 : _sculpt_eq2 : _sculpt_eq2  : _;
_sculpt_eq_stereo = _,_ : _sculpt_eq_mono, _sculpt_eq_mono : _,_;
sculpt_eq = _,_ : ba.bypass2(sculpt_eq_toggle, _sculpt_eq_stereo) : _,_;

process = _,_ : sculpt_eq : lsf : hsf : _,_ : _,_;
