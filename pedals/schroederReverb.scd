p.add(
	\SchroederReverb ->
	Dictionary.newFrom([
		\pedalName, "Schroeder Reverb",
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
			"Gain", "Rev time", "Pre delay", "LPF 1", "LPF 2", "Mix", "-", "-", "-", "-",
		],
		\color, Color.new(green: 0.7, alpha: 0.2),
		\synthDefHere, SynthDef("SchroederReverb", {
			arg in = 0, out = 0, knob1, knob2, knob3, knob4, knob5;
			var dry, temp, signal, wet;

			var
			reverbTime = knob1,
			preDelay = knob2,
			lpf1 = knob3,
			lpf2 = knob4,
			mix = knob5;

			dry = In.ar(0, 2);
			wet = In.ar(0, 2);
			wet = DelayN.ar(wet, 0.5, preDelay.clip(0.0001, 0.5));
			wet = 16.collect({
				var temp;
				temp = CombL.ar(
					wet, 0.1,
					LFNoise1.kr({ ExpRand(0.02, 0.04) } ! 2).exprange(0.02, 0.098),
					reverbTime
				);
				temp = LPF.ar(temp, lpf1);
			}).sum * 0.25;
			8.do({
				wet = AllpassL.ar(
					wet, 0.1,
					LFNoise1.kr({ ExpRand(0.02, 0.04) } ! 2).exprange(0.02, 0.098),
					reverbTime
				);
			});
			wet = LeakDC.ar(wet);
			wet = LPF.ar(wet, lpf2, 0.5);

			signal = XFade2.ar(dry, wet, mix * 2 - 1);
			Out.ar(out, signal);
		}).add,
		\pedalPresets, [
			Dictionary.newFrom([
				\name, "Big hall",
				\knobValues, [0.2, 3.5, 0.025, 2000, 6000, 0.8, 0, 0, 0],
				\button1State, 0,
				\button2State, 0,
				\popup1State, 0,
				\popup2State, 0
			]),
			Dictionary.newFrom([
				\name, "Weird room",
				\knobValues, [0.2, 0.5, 10, 2000, 6000, 0.8, 0, 0, 0],
				\button1State, 0,
				\button2State, 0,
				\popup1State, 0,
				\popup2State, 0
			]),
			Dictionary.newFrom([
				\name, "Huge hall",
				\knobValues, [0.2, 10, 0.025, 2000, 8000, 0.8, 0, 0, 0],
				\button1State, 0,
				\button2State, 0,
				\popup1State, 0,
				\popup2State, 0
			]),
		]
	])
);

~readPreset.value(\SchroederReverb);