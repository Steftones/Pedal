p.add(
	\Reverb ->
	Dictionary.newFrom([
		\pedalName, "Reverb",
		\controlSpecs, [
			ControlSpec.new(0.001, 0.2, 'lin', 0.01, 0.3),
			ControlSpec.new(0.0001, 20, 'exp', 0.001, 0.05),
			ControlSpec.new(0.001, 10, 'exp', 0.001, 0.3),
			ControlSpec.new(0.001, 20, 'exp', 0.01, 0.3),
			ControlSpec.new(200, 15000, 'exp', 10, 4500),
			ControlSpec.new(0.001, 1, 'exp', 0.001, 0.02),
			ControlSpec.new(),
			ControlSpec.new(),
		],
		\popup1Items, ['-'],
		\popup2Items, ['-'],
		\activeText, [
			"Gain", "Rev time", "Pre delay","Rev decay", "Damping", "Mix", "-", "-", "-", "-",
		],
		\color, Color.new(green: 1, alpha: 0.2),
		\synthDefHere, SynthDef("Reverb", {
			arg in, out = 0, knob1, knob2, knob3, knob4, knob5;
			var dry, temp, signal, wet;

			// mapping knob arguments
			var
			delayTime = knob1,
			preDelay = knob2,
			revDecay = knob3,
			damping = knob4,
			mix = knob5;

			dry = In.ar(0, 2);
			temp = In.ar(0, 2);
			wet = 0;
			temp = DelayN.ar(temp, 0.2, preDelay);
			18.do({
				temp = AllpassN.ar(temp, 0.05, { Rand(0.001, delayTime) } ! 2, revDecay);
				temp = LPF.ar(temp, damping);
				wet = wet + temp;
			});
			wet = LeakDC.ar(wet);
			signal = XFade2.ar(dry, wet, mix * 2 - 1);
			Out.ar(out, signal);
		}).add,
		\pedalPresets, [
			Dictionary.newFrom([
				\name, "Big ship",
				\knobValues, [0.2, 10, 0.6, 20, 15000, 0.9, 0, 0],
				\button1State, 1,
				\button2State, 1,
				\popup1State, 3,
				\popup2State, 3
			]),
			Dictionary.newFrom([
				\name, "Tin room",
				\knobValues, [0.2, 0.05, 0, 0.02, 600, 1, 0, 0],
				\button1State, 0,
				\button2State, 0,
				\popup1State, 1,
				\popup2State, 1
			]),
			Dictionary.newFrom([
				\name, "ZoigVerb",
				\knobValues, [0.2, 0.5, 0, 0.2, 900, 1, 0, 0],
				\button1State, 0,
				\button2State, 0,
				\popup1State, 1,
				\popup2State, 1
			]),
		]
	])
);

~readPreset.value(\Reverb);