import("stdfaust.lib");


/* Inverts a boolean value. Makes a 0 out of a one and a one out of zero. */
invertBool = _ : _ - 1;

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
general_gain = hslider("gain", 1, 0, 10, 0.001) : si.smoo;
volume = vslider("volume", 1, 0, 1, 0.001) : si.smoo;
cue_a = checkbox("cue_a") : si.smoo;
cue_b = checkbox("cue_b") : si.smoo;
filter = hslider("filter", 1, 0, 2, 0.001) : si.smoo;




/* Splits a single signal into two signals at a given frequency (freq) with
 * order of q
 */
splitMono(freq, q) = _ <:
  fi.lowpass(q, freq),
  fi.highpass(q, freq) :
	  _,_;


/* Same as splitMono but for a stereo signal */
split(freq,q) = _,_ :
	splitMono(freq, q),
	splitMono(freq, q):
    _,_,_,_ <:
      ba.selector(0, 4),
      ba.selector(2, 4),
      ba.selector(1, 4),
      ba.selector(3, 4);

/* Splits a stereo signal into 6 signals, where the 1 & 2 signal are the low
 * frequencies (everything below low_cut), the 3 & 4 are everything below mid_cut
 * and 5 & 6 are the remaining high frequencies.
 */


_f(value) = _,_ : split((value*4646), 5):
	  _ * (value < 1),
		_ * (value < 1),
		_ * (value > 1),
		_ * (value > 1) :>
		  _,_;

f(value) = _,_ : ba.bypass2(value==1, _f(value));
	
ThreeBandSplitter = _,_ :
  fi.filterbank (5,(low_cut,mid_cut)),
  fi.filterbank (5,(low_cut,mid_cut)) <:
    ba.selector(2, 6),
    ba.selector(5, 6),
    ba.selector(1, 6),
    ba.selector(4, 6),
    ba.selector(0, 6),
		ba.selector(3, 6) :
		  _,_,_,_,_,_;

equalizer = _,_ :
  ThreeBandSplitter :
    gain(low_gain*low_kill),
	  gain(mid_gain*mid_kill),
	  gain(high_gain*high_kill) :>
	    _,
      _;

/* Boost a mono signal */
gainMono(gain) = _ :
	_ * gain :
	  _;
/* Boost a stereo signal */
gain(gain) = _,_ :
  gainMono(gain),
	gainMono(gain) :
	  _,
		_;

/* This function enables or disables the signal for the cue channel.
 * Internally the same as gain() but for the ease of readability.
 */
cue(activated) = gain(activated);

process = _,_ :
  gain(general_gain) :
	equalizer <:
		  gain(volume),
			cue(cue_a),
			cue(cue_b);





