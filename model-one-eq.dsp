declare options "[midi:on]";

import("stdfaust.lib");


hp_fq_midi = hslider("[1]hp freq midi[midi:ctrl 1]", 0, 0, 127, 1):float;
hp_fq = ba.midikey2hz(hp_fq_midi) : si.smoo;
hp_fq_ui = hp_fq : hbargraph("[2]HP Freq", 0, 21000);


hp_bypass_toggle = checkbox("[4]hp bypass[3]");
hp_bypass = (hp_bypass_toggle == 1) | (hp_fq_midi == 0);
hp_bypass_ui = hp_bypass : hbargraph("[3]HP Bypass", 0, 1);

lp_fq_midi = hslider("[4]lp freq midi[midi:ctrl 4]", 127, 0, 127, 1):float;
lp_fq = ba.midikey2hz(lp_fq_midi) : si.smoo;
lp_fq_ui = lp_fq : hbargraph("[5]LP Freq", 0, 21000);

lp_bypass_toggle = checkbox("[6]lp bypass[3]");
lp_bypass = (lp_bypass_toggle == 1) | (lp_fq_midi == 127);
lp_bypass_ui = lp_bypass : hbargraph("[7]LP Bypass", 0, 1);

mute = (hp_fq_midi == 127) | (lp_fq_midi == 0);
mute_ui = mute : hbargraph("[8]Mute", 0, 1);

smooth_bypass(bpc, e) = _,_ : ba.bypass_fade(500, bpc, e) : _,_;

hp_mono = _ : fi.highpass3e(hp_fq) : _;
hp = _ , _ : smooth_bypass(hp_bypass, (hp_mono, hp_mono)) : _, _;

lp_mono = _ : fi.lowpass3e(lp_fq) : _;
lp = _ , _ : smooth_bypass(lp_bypass, (lp_mono, lp_mono)) : _, _;

muter = _,_ : ba.bypass_fade(300, (mute == 0), (_ * 0, _ * 0)) : _,_;


process = _,_ : hp : lp : muter : _, attach(_, hp_fq_ui) : _, attach(_, hp_bypass_ui) : _, attach(_, lp_bypass_ui) :  _, attach(_, mute_ui);
