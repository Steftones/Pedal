p.add(
	\Flanger ->
	Dictionary.newFrom([
		\pedalName, "Flanger",
		\controlSpecs, [
			ControlSpec.new(0.001, 0.2, 'lin', 0.01, 0.3),
			ControlSpec.new(0.001, 1, 'lin', 0.001, 0.3),
			ControlSpec.new(0.001, 10, 'exp', 0.001, 0.3),
			ControlSpec.new(0.001, 1, 'lin', 0.01, 0.3),
			ControlSpec.new(0.001, 10, 'exp', 0.001, 0.02),
			ControlSpec.new(0.001, 10, 'exp', 0.001, 0.02),
			ControlSpec.new(0.001, 10, 'exp', 0.01, 0.3),
			ControlSpec.new(0.001, 10, 'exp', 0.01, 0.3),
			ControlSpec.new(0.001, 1, 'lin', 0.01, 0.3),
		],
		\popup1Items, ['Sine', 'Saw', 'Pulse', 'Noise'],
		\popup2Items, ['Sine', 'Saw', 'Pulse', 'Noise'],
		\activeText, [
			"Gain", "Wet", "Depth", "Feedback", "Min delay", "Max delay", "LFO 1", "LFO 2", "Frequency", "Frequency",
		],
		\color, Color.new(red: 1.0, alpha: 0.3),
		\synthDefHere, SynthDef('Flanger', {
			arg in, out = 0, knob1, knob2, knob3, knob4, knob5, knob6, knob7,
			lfo1Options, lfo2Options, isLfo1On, isLfo2On;
			var input, effect, dry, inputWithFeedback, lfo1, lfo2, lfoSelectFunction, signal;

			// mapping knob arguments
			var
			wet = knob1,
			depth = knob2,
			feedback = knob3,
			minDelay = knob4,
			maxDelay = knob5,
			flangefreq1 = knob6,
			flangefreq2 = knob7;

			dry = 1 - wet;

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

			lfo1 = lfoSelectFunction.value(flangefreq1, lfo1Options);
			lfo2 = lfoSelectFunction.value(flangefreq2, lfo2Options);

			dry = In.ar(0, 2);

			// original input
			input = if (isLfo1On, DelayN.ar(
				in: dry,
				maxdelaytime: maxDelay,
				delaytime: SinOsc.kr(
					freq: flangefreq1 * lfo1,
					phase: 0,
					mul: (maxDelay * 0.5) - (minDelay * 0.5),
					add: (maxDelay * 0.5) + (minDelay * 0.5),
				),
				),
				dry);

			inputWithFeedback = input + LocalIn.ar(2);

			// original input with feedback
			effect = DelayN.ar(
				in: inputWithFeedback,
				maxdelaytime: maxDelay,
				delaytime: SinOsc.kr(
					freq: if (isLfo2On, (depth * lfo2), depth),
					phase: 0,
					mul: (maxDelay * 0.5) - (minDelay * 0.5),
					add: (maxDelay * 0.5) - (minDelay * 0.5),
				),
			);
			LocalOut.ar(effect * feedback);
      effect = LeakDC.ar(effect);
			signal = XFade2.ar(dry, (effect * feedback) * wet);
			Out.ar(out, signal);

		}).add,
		\pedalPresets, [
			Dictionary.newFrom([
				\name, "Fun flange",
				\knobValues, [0.2, 0.5, 0.8, 0.72, 0.005, 0.007, 0.5, 0.5, 0.5],
				\button1State, 0,
				\button2State, 1,
				\popup1State, 2,
				\popup2State, 1
			]),
			Dictionary.newFrom([
				\name, "Beasty",
				\knobValues, [0.2, 0.8, 0.8, 0.9, 1, 1, 1, 9, 1],
				\button1State, 0,
				\button2State, 0,
				\popup1State, 3,
				\popup2State, 3
			]),
			Dictionary.newFrom([
				\name, "Mr dingus",
				\knobValues, [0.2, 0.966, 0.962, 0.97 , 0.005, 0.332, 0.68, 0.612],
				\button1State, 1,
				\button2State, 1,
				\popup1State, 0,
				\popup2State, 3
			]),
		],
	])
);

~readPreset.value(\Flanger);
