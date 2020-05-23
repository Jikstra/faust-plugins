import("music.lib");
import("oscillator.lib");

gate = button("gate");
gain = hslider("gain[unit:dB][style:knob]", -10, -30, +10, 0.1) : db2linear : smooth(0.999);
freq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
prevfreq = nentry("prevfreq[unit:Hz]", 440, 20, 20000, 1);
portamento = vslider("[5] Portamento [unit:sec] [style:knob] [tooltip: Portamento (frequency-glide)time-constant in seconds]", 0.1,0.01,0.3,0.001);
pitchbend = vslider("pitchbend", 0, -1, 1, 0.01);
start_time = latch(freq == freq, time);
dt = time - start_time;
expo(tau) = exp(0-dt/(tau*SR));
mix(tau, f, pf) = f*(1 - expo(tau)) + pf*expo(tau);
bended_freq = freq + pitchbend * 20;
sfreq = mix(portamento, bended_freq, prevfreq) : min(20000) : max(20);
x = sawtooth(sfreq : smooth(0.999));
process = x * gain * (gate);
