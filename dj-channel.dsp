import("stdfaust.lib");

splitMono(freq, q) = _ <:
  fi.lowpass(q, freq),
  fi.highpass(q, freq) :
	_,_;

invertBool = _ : _ - 1;

split(freq,q) = _,_ :
	splitMono(freq, q),
	splitMono(freq, q):
    _,_,_,_ <:
      ba.selector(0, 4),
      ba.selector(2, 4),
      ba.selector(1, 4),
      ba.selector(3, 4);

low_cut = nentry("[0]low cut", 300, 1, 20000, 1) : si.smoo;
low_q = nentry("[1]low q", 6, 1, 16, 2);
mid_cut = nentry("[2]mid cut", 1500, 1, 20000, 1) : si.smoo;
high_q = nentry("[3]high q", 4, 1, 16, 1);
low_gain = hslider("[4]low_gain", 1, 0, 2, 0.001) : si.smoo;
low_kill = checkbox("[5]low_kill") : invertBool : si.smoo;
mid_gain = hslider("[6]mid_gain", 1, 0, 2, 0.001) : si.smoo;
mid_kill = checkbox("[7]mid_kill") : invertBool :  si.smoo;
high_gain = hslider("[8]high_gain", 1, 0, 2, 0.001) : si.smoo;
high_kill = checkbox("[9]high_kill") : invertBool : si.smoo;
volume = vslider("volume", 1, 0, 1, 0.001) : si.smoo;

gainMono(gain) = _ * gain;
gain(gain) = _,_ : gainMono(gain), gainMono(gain): _,_;

equalizer = _,_ :
  split((low_cut,mid_cut:min), 2) :
	  _,
		_,
		split((low_cut,mid_cut: max), 5) :
    	gain(low_gain*low_kill),
	    gain(mid_gain*mid_kill),
	    gain(high_gain*high_kill) :>
	      _,_;

vol = _,_ :
	_ * volume,
  _ * volume :
	  _,_;


process = _,_ : vol : equalizer;
