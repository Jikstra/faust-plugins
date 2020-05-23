import("stdfaust.lib");

low_cut = hslider("cut", 10000, 1, 10000, 1);
low_gain = hslider("low_gain", 1, 0, 1, 0.001);
high_gain = hslider("high_gain", 1, 0, 1, 0.001);

process = _,_ <: _,_,_,_ : fi.lowpass6e(low_cut)*low_gain,fi.lowpass6e(low_cut)*low_gain,fi.highpass6e(low_cut)*high_gain,fi.highpass6e(low_cut)*high_gain : _,_,_,_;
