declare options "[midi:on]";

import("stdfaust.lib");

midikey2hz(m) = lowestValue * pow(2.0, k * m)
with {
    lowestValue = 2000;
    k = log((ma.SR/2)/lowestValue) / log(2) / 127;
};

hp_fq_midi = hslider("[1]hp freq midi[midi:ctrl 1]", 0, 0, 127, 1):float;
hp_fq = midikey2hz(hp_fq_midi) : si.smoo;
hp_fq_ui = hp_fq : hbargraph("[2]HP Freq", 0, 21000);


hp_bypass_toggle = checkbox("[4]hp bypass[3]");
hp_bypass = (hp_bypass_toggle == 1) | (hp_fq_midi == 0);
hp_bypass_ui = hp_bypass : hbargraph("[3]HP Bypass", 0, 1);

lp_fq_midi = hslider("[4]lp freq midi[midi:ctrl 4]", 127, 0, 127, 1):float;
lp_fq = midikey2hz(lp_fq_midi) : si.smoo;
lp_fq_ui = lp_fq : hbargraph("[5]LP Freq", 0, 21000);

lp_bypass_toggle = checkbox("[6]lp bypass[3]");
lp_bypass = (lp_bypass_toggle == 1) | (lp_fq_midi == 127);
lp_bypass_ui = lp_bypass : hbargraph("[7]LP Bypass", 0, 1);

bell_fq_midi =  hslider("[8]bell freq midi[midi:ctrl 3]", 64, 0, 127, 1):float;
bell_fq = midikey2hz(bell_fq_midi) : si.smoo;
bell_fq_ui = bell_fq : hbargraph("[9]Bell Freq", 0, 21000);

bell_gain_midi =  hslider("[10]bell gain midi[midi:ctrl 2]", 64, 0, 127, 1):float;
bell_gain = select2(bell_gain_midi > 64, ((bell_gain_midi - 64)), ((bell_gain_midi - 64) / 5));
bell_gain_ui = bell_gain : hbargraph("[11]Bell Gain", -100, 100);

bell_q = select2(bell_gain_midi > 64, 4, 1);
bell_q_ui = bell_q : hbargraph("[12]Bell Q", 0, 32);


mute = (hp_fq_midi == 127) | (lp_fq_midi == 0);
mute_ui = mute : hbargraph("[13]Mute", 0, 1);

smooth_bypass(bpc, e) = _,_ : ba.bypass_fade(500, bpc, e) : _,_;

oberheim_hp(freq, q) = _ : seq(i, N, ve.oberheimHPF(normalized_freq, q)) : _
with {
		N = 8;
    normalized_freq = min((freq)/(ma.SR/2), 1);
};
hp_mono = _ : oberheim_hp(hp_fq, 0.75) : _;
hp = _ , _ : smooth_bypass(hp_bypass, (hp_mono, hp_mono)) : _, _;

oberheim_lp(freq, q) = _ : seq(i, N, ve.oberheimLPF(normalized_freq, q)) : _
with {
		N = 8;
    normalized_freq = min((freq)/(ma.SR/2), 1);
};
lp_mono = _ : oberheim_lp(lp_fq, 0.75) : _;
lp = _ , _ : smooth_bypass(lp_bypass, (lp_mono, lp_mono)) : _, _;

bell_mono =  _ <:
                    (_ : fi.svf.bell(bell_fq, 1, bell_gain / 2) : fi.svf.bell(bell_fq, 1, bell_gain / 2) : _),
                    (_ : fi.svf.bell(bell_fq, 1, bell_gain) : _)
                        : select2(bell_gain_midi < 64)
                            : _;
bell = _,_ : bell_mono,bell_mono: _,_;

muter = _,_ : ba.bypass_fade(300, (mute == 0), (_ * 0, _ * 0)) : _,_;


process = _,_ : hp : lp : bell : muter : _, _ :
    _, attach(_, hp_fq_ui) :
    _, attach(_, hp_bypass_ui) :
    _, attach(_, lp_bypass_ui) :
    _, attach(_, bell_fq_ui) :
    _, attach(_, bell_q_ui) :
    _, attach(_, bell_gain_ui) :
    _, attach(_, mute_ui);
