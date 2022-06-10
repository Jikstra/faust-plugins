import("stdfaust.lib");

channel(i) = vgroup("%i", _*gain,_*gain <: _*volume,_*volume,_*monitor,_*monitor)
with {    
    volume = vslider("Volume [unit:dB]", 1, 0, 1, 0.1);
    gain = vslider("Gain [unit:dB][style:knob]", 0, -10, 10, 0.1): ba.db2linear;
    monitor = checkbox("monitor") : si.smoo;
};

process = hgroup("", par(i, 2, channel(i + 1))) :> _,_,_,_;
