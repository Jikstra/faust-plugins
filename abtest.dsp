import("stdfaust.lib");
left = checkbox("Left");

process = _,_,_,_ : ba.select2stereo(left==0) : _,_;
