import("stdfaust.lib");


low_cut = nentry("[0]low cut", 300, 1, 20000, 1) : si.smoo;
mid_cut = nentry("[1]mid cut", 1000, 1, 20000, 1) : si.smoo;
low_gain = hslider("[2]low_gain", 1, 0, 2, 0.001) : si.smoo;
mid_gain = hslider("[3]mid_gain", 1, 0, 2, 0.001) : si.smoo;
high_gain = hslider("[4]]high_gain", 1, 0, 2, 0.001) : si.smoo;


splitLowAndRest(low_cut) = _,_,_,_,_,_ :
  fi.lowpass6e(low_cut),
  fi.lowpass6e(low_cut),
  fi.highpass6e(low_cut),
  fi.highpass6e(low_cut),
  fi.highpass6e(low_cut),
  fi.highpass6e(low_cut);

splitMidAndRest(mid_cut) = _,_,_,_,_,_ :
  _,
  _,
  fi.lowpass6e(mid_cut),
  fi.lowpass6e(mid_cut),
  fi.highpass6e(mid_cut),
  fi.highpass6e(mid_cut);


  

process = _,_ <: splitLowAndRest(low_cut) : splitMidAndRest(mid_cut) : 
  _ * low_gain,
  _ * low_gain,
  _ * mid_gain,
  _ * mid_gain,
  _ * high_gain,
	_ * high_gain :> _,_;
