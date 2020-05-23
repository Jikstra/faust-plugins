import("stdfaust.lib");
decimalpart(x) = x - int(x);
sawtooth(reset, stepSize) = ((+(stepSize)) , 0 : select2(reset)) ~ ma.decimal;
ms = 1 / (nentry("ms", 1000, 1, 100000, 1) * (ma.SR / 1000));
reset = button("reset");
process = sawtooth(reset, ms), sawtooth(reset, ms) : _,_;
