p.add(
	\CombDelay ->
	Dictionary.newFrom([
		\pedalName, "Comb Delay",
		\controlSpecs, [
			ControlSpec.new(0.001, 0.2, 'lin', 0.01, 0.3),
			ControlSpec.new(0.001, 1, 'lin', 0.001, 0.3),
			ControlSpec.new(0.001, 20, 'exp', 0.001, 0.3),
			ControlSpec.new(0.001, 20, 'exp', 0.001, 0.3),
			ControlSpec.new(0.001, 20, 'exp', 0.001, 0.02),
			ControlSpec.new(),
			ControlSpec.new(1, 500, 'exp', 0.5, 1),
			ControlSpec.new(1, 500, 'exp', 0.5, 1)
		],
		\popup1Items, ['Sine', 'Saw', 'Pulse', 'Noise'],
		\popup2Items, ['Sine', 'Saw', 'Pulse', 'Noise'],
		\activeText, [
			"Gain", "Wet", "Min delay", "Max delay", "Decay time", "-", "Delay LFO", "Decay LFO", "Frequency", "Frequency",
		],
		\synthDefHere, SynthDef('CombDelay', {
			arg out = 0, knob1, knob2, knob3, knob4, knob6, knob7,
			lfo1Options, lfo2Options, isLfo1On, isLfo2On;
			var signal, delay, inputWithFeedback, lfoSelectFunction, lfo1, lfo2;

			// mapping knob arguments
			var
			wet = knob1,
			minDelay = knob2,
			maxDelay = knob3,
			decayTime = knob4,
			delayLFO = knob6,
			decayLFO = knob7;

			lfoSelectFunction = {
				arg freq, options;
				SelectX.ar(
					options,
					[
						SinOsc.ar(freq),
						LFSaw.ar(freq),
						LFPulse.ar(freq),
						LFNoise0.ar(freq)
					]
				);
			};

			lfo1 = lfoSelectFunction.value([delayLFO, delayLFO * 0.8], lfo1Options);
			lfo2 = lfoSelectFunction.value(decayLFO, lfo2Options);

			signal = In.ar(0, 2);
			delay = CombL.ar(
				signal * 0.5,
				maxDelay,
				if (isLfo1On, lfo1.exprange(minDelay, maxDelay), exprange(minDelay, maxDelay)),
				decayTime * if (isLfo2On, lfo2, 1),
				mul: 3
			);
			signal = XFade2.ar(signal, (delay * wet));
			Out.ar(out, signal);
		}).add,
		\pedalPresets, [
			Dictionary.newFrom([
				\name, "King blorp",
				\knobValues, [0.2, 1, 0.5, 0.72, 6, 3, 0.5, 1, 2.5],
				\button1State, 1,
				\button2State, 1,
				\popup1State, 0,
				\popup2State, 0
			]),
			Dictionary.newFrom([
				\name, "Foreign shimmer",
				\knobValues, [0.2, 1, 0.004, 0.006, 7, 0, 0, 0, 0],
				\button1State, 0,
				\button2State, 0,
				\popup1State, 0,
				\popup2State, 0
			]),
			Dictionary.newFrom([
				\name, "Lump in my throat",
				\knobValues, [0.09, 1, 0.003, 0.002, 20, 0, 0.5, 0.5, 0.5],
				\button1State, 1,
				\button2State, 1,
				\popup1State, 0,
				\popup2State, 0
			]),
		],
	])
);

"Comb delay pedal loaded".postln;
