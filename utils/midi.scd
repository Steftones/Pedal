// MIDIIn.doNoteOnAction(1, ~midiChannel, 60, 66); // spoof a midi note to test

~midiChannel = 5;

~scrollThrough = {
	arg varToUpdate, isDirectionUp;

	var
	theIndex = varToUpdate.value + (isDirectionUp !? 1 ?? -1),
	updateValue;

	updateValue = switch (
		theIndex,
		varToUpdate.items.size, 0,
		-1, varToUpdate.items.size - 1,
		{theIndex}
	);

	varToUpdate.value_(updateValue);
};

MIDIdef.noteOn(\noteOnControl, {
	arg velocity, noteNumber;
	[velocity, noteNumber].postln;
	switch (
		noteNumber,
		60, { ~inputSynth.set(\isMuted, (~pedalFilePopup.value == 0).if(false, true)) },
		61, {
			~scrollThrough.value(~pedalFilePopup, true);
			~pedalFilePopupFunction.value(~pedalFilePopup);
		},
		62, {
			~scrollThrough.value(~pedalFilePopup);
			~pedalFilePopupFunction.value(~pedalFilePopup);
		},
		63, { ~scrollThrough.value(~presetPopUp, true) },
		64, { ~scrollThrough.value(~presetPopUp) },
		73, { ~toggle1.value_(~toggle1.value.neg + 1) },
		74, { ~toggle2.value_(~toggle2.value.neg + 1) },
		75, { ~scrollThrough.value(~toggle1PopUp, true) },
		76, { ~scrollThrough.value(~toggle1PopUp) },
		77, { ~scrollThrough.value(~toggle2PopUp, true) },
		78, { ~scrollThrough.value(~toggle2PopUp) },
		{ }
	);
}, chan: ~midiChannel);

// control knobs 1 - 8
{
	arg i;
	MIDIdef.cc("knob%".format(i), {
		arg vel, noteNumber, channel;
		vel = vel.linlin(0, 16383, 0, 1);
		[vel, noteNumber, channel].postln;
		~knobAction.value(
			vel, "knob%".format(i),
			p[~currentPedal][\controlSpecs][i],
			if (i == 0, ~inputSynth, ~effectSynth)
		);
	}, 65 + i, ~midiChannel);
}.dup(8);

