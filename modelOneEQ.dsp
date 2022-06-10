declare options "[midi:on]";

import("stdfaust.lib");

midikey2hz(m) = lowestValue * pow(2.0, k * m)
with {
    //lowestValue = 2000;
    lowestValue = 20;
    offset = 0;
    k = log(((ma.SR/2)+offset)/lowestValue) / log(2) / 127;
};

midikey2hzHP(m) = lowestValue * pow(l, k * (m - 1))
with {
    l = 2;
    lowestValue = 20;
    offset = 0;
    highestValue = ma.SR/2;
    k = log(((highestValue)+offset)/lowestValue) / log(l) / 125;
};

midikey2hzLP(m) = lowestValue * pow(2.0, k * m)
with {
    lowestValue = 500;
    //lowestValue = 4000;
    offset = 0;
    k = log(((ma.SR/2)+offset)/lowestValue) / log(2) / 126;
};

midikey2hzBell(m) = lowestValue * pow(2.0, k * m)
with {
    lowestValue = 20;
    //lowestValue = 4000;
    offset = -2000;
    k = log(((ma.SR/2)+offset)/lowestValue) / log(2) / 126;
};

betterSmoo = si.smooth(0.001);

hp_fq_midi = hslider("[1]hp freq midi[midi:ctrl 1]", 0, 0, 127, 1):float;
hp_fq = midikey2hzHP(hp_fq_midi) : betterSmoo;
hp_fq_ui = hp_fq : hbargraph("[2]HP Freq", 0, 21000);


hp_bypass_toggle = checkbox("[4]hp bypass[3]");
hp_bypass = (hp_bypass_toggle == 1) | (hp_fq_midi == 0);
hp_bypass_ui = hp_bypass : hbargraph("[3]HP Bypass", 0, 1);

lp_fq_midi = hslider("[4]lp freq midi[midi:ctrl 4]", 127, 0, 127, 1):float;
lp_fq = midikey2hzLP(lp_fq_midi) : betterSmoo;
lp_fq_ui = lp_fq : hbargraph("[5]LP Freq", 0, 21000);

lp_bypass_toggle = checkbox("[6]lp bypass[3]");
lp_bypass = (lp_bypass_toggle == 1) | (lp_fq_midi == 127);
lp_bypass_ui = lp_bypass : hbargraph("[7]LP Bypass", 0, 1);

bell_fq_midi =  hslider("[8]bell freq midi[midi:ctrl 3]", 64, 0, 127, 1):float;
bell_fq = midikey2hzBell(bell_fq_midi) : betterSmoo;
bell_fq_ui = bell_fq : hbargraph("[9]Bell Freq", 0, 25000);

bell_gain_midi =  hslider("[10]bell gain midi[midi:ctrl 2]", 64, 0, 127, 1):float;
bell_gain = select2(bell_gain_midi > 64, ((bell_gain_midi - 64)), ((bell_gain_midi - 64) / 5));
bell_gain_ui = bell_gain : hbargraph("[11]Bell Gain", -100, 100);

bell_q = select2(bell_gain_midi > 64, 4, 1);
bell_q_ui = bell_q : hbargraph("[12]Bell Q", 0, 32);


mute = (hp_fq_midi == 127) | (lp_fq_midi == 0);
mute_ui = mute : hbargraph("[13]Mute", 0, 1);

smooth_bypass(bpc, e) = _,_ : ba.bypass_fade(500, bpc, e) : _,_;

oberheim_hp(freq, q) = _ : seq(i, 8, ve.oberheimHPF(normalized_freq, q)) : _
with {
    normalized_freq = min((freq/(ma.SR/2)), 1);
};
hp_mono = _ : oberheim_hp(hp_fq, 0.7) : _;

//hp_mono = _ : seq(i, 8, fi.svf.hp(hp_fq, 0.5)) : _;
hp = _ , _ : smooth_bypass(hp_bypass, (hp_mono, hp_mono)) : _, _;

oberheim_lp(freq, q) = _ : seq(i, 8, ve.oberheimLPF(normalized_freq, q)) : _
with {
    normalized_freq = min((freq/(ma.SR/2)), 1);
};
lp_mono = _ : oberheim_lp(lp_fq, 0.7) : _;
lp = _ , _ : smooth_bypass(lp_bypass, (lp_mono, lp_mono)) : _, _;

bell_mono =  _ <:
                    (_ : fi.svf.bell(bell_fq, 1, bell_gain / 2) : fi.svf.bell(bell_fq, 1, bell_gain / 2) : _),
                    (_ : fi.svf.bell(bell_fq, 1, bell_gain) : _)
                        : select2(bell_gain_midi < 64)
                            : _;
bell = _,_ : bell_mono,bell_mono: _,_;

muter = _,_ : ba.bypass_fade(2500, (mute == 0), (_ * 0, _ * 0)) : _,_;


process = _,_ : hp : lp : bell : muter : _, _ :
    _, attach(_, hp_fq_ui) :
    _, attach(_, hp_bypass_ui) :
    _, attach(_, lp_fq_ui) :
    _, attach(_, lp_bypass_ui) :
    _, attach(_, bell_fq_ui) :
    _, attach(_, bell_q_ui) :
    _, attach(_, bell_gain_ui) :
    _, attach(_, mute_ui);
