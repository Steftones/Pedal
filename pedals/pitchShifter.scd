p.add(
	\PitchShifter ->
	Dictionary.newFrom([
		\pedalName, "Pitch Shifter",
		\controlSpecs, [
			ControlSpec.new(0.001, 0.2, 'lin', 0.01, 0.3),
			ControlSpec.new(0, 4, 'lin', 0.1, 0.05),
			ControlSpec.new(0.001, 10, 'exp', 0.001, 0.3),
			ControlSpec.new(0.001, 20, 'exp', 0.01, 0.3),
			ControlSpec.new(0.001, 3, 'exp', 0.1, 0.2),
			ControlSpec.new(0.001, 1, 'exp', 0.001, 0.02),
			ControlSpec.new(),
			ControlSpec.new(),
		],
		\popup1Items, ['-'],
		\popup2Items, ['-'],
		\activeText, [
			"Gain", "Pitch ratio", "Pitch Dispersion", "Time Dispersion", "Window Size", "Mix", "-", "-", "-", "-",
		],
    \color, Color.new(red: 1.0, blue: 1.0, alpha: 0.3),
		\synthDefHere, SynthDef("PitchShifter", {
			arg in = 0, out = 0, knob1, knob2, knob3, knob4 = 0.2, knob5;
			var dry, temp, signal, wet, mix = 1;

			var
			pitchRatio = knob1, // must be 0 to 4
			pitchDispersion = knob2,
			timeDispersion = knob3,
			windowSize = knob4;
			mix = knob5;

			dry = In.ar(0, 2);
			wet = PitchShift.ar(dry, windowSize, pitchRatio, pitchDispersion, timeDispersion);
			wet = LeakDC.ar(wet);

			signal = XFade2.ar(dry, wet, mix * 2 - 1);
			Out.ar(out, signal);
		}).add,
		\pedalPresets, [
			Dictionary.newFrom([
				\name, "Ratio 2",
				\knobValues, [0.2, 2, 0, 0, 0.2, 0, 0, 0, 0],
				\button1State, 0,
				\button2State, 0,
				\popup1State, 0,
				\popup2State, 0
			]),
			Dictionary.newFrom([
				\name, "Ratio 3",
				\knobValues, [0.2, 3, 0, 0, 0.2, 0, 0, 0, 0],
				\button1State, 0,
				\button2State, 0,
				\popup1State, 0,
				\popup2State, 0
			]),
			Dictionary.newFrom([
				\name, "Ratio 4",
				\knobValues, [0.2, 4, 0, 0, 0.2, 0, 0, 0, 0],
				\button1State, 0,
				\button2State, 0,
				\popup1State, 0,
				\popup2State, 0
			]),
		]
	])
);

~readPreset.value(\PitchShifter);