import("stdfaust.lib");
process = _ : dm.mth_octave_filterbank_demo(1) : _ : dm.filterbank_demo : _;
