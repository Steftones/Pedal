s.boot;
s.plotTree;
s.meter;
s.options.memSize = 2.pow(20);
Server.killAll;

// ----- send below -----
(

~numberOfFactoryPresets = 3;

~folderPath = PathName(thisProcess.nowExecutingPath).parentPath;

// imports
(~folderPath ++ 'utils/crud.scd').load;

// sound input synth
SynthDef.new(\soundIn, {
	// default in of 1
	arg in = 1, buf = 0, rate = 1, knob0 = 0.2, out = 0, isDemo = 0;
	var sig;
	sig = SelectX.ar(
		isDemo,
		[
			PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, loop: 1, doneAction: 2),
			SoundIn.ar(in ! 2),
		]
	);
	sig = sig * knob0;
	Out.ar(out, sig);
}).add;

// for effect file data
p = Dictionary.new();

~folderPath = PathName(thisProcess.nowExecutingPath).parentPath;
~demoSound = Buffer.read(s, ~folderPath ++ "demosound.wav");

// load pedal files
~path = ~folderPath ++ "pedals/";
PathName(~path).entries.do{ |pedalFilePath| pedalFilePath.fullPath.load; };

// current pedal, defaults to the flanger pedal
~currentPedal = 'Flanger';

~saveNewButton = Button.new(w)
.states_([["Save new"]])
.action_({
	~createNameWindow.value(nameToDisplay: "");
});

~saveEditButton = Button.new(w)
.states_([["Save edit"]])
.action_({
	~updatePreset.value(~pedalFilePopup.item, ~presetPopUp.value);
});

~renameButton = Button.new(w)
.states_([["Rename"]])
.action_({
	~createNameWindow.value(~presetPopUp.item, isRename: true);
});

~deleteButton = Button.new(w)
.states_([["Delete"]])
.action_({
	~deletePreset.value(~pedalFilePopup.item, ~presetPopUp.value);
});

~audioInputPopUp = PopUpMenu(w)
.items_(['Demo sound'] ++ ServerOptions.devices)
.action_({
	arg menu;
	if (menu.item == 'Demo sound', {
		~inputSynth.set(
			\isDemo, 0,
			\buf, ~demoSound
		)
		}, {
			s.options.inDevice = menu.item;
			~inputSynth.set(\isDemo, 1);
	});
});

~setPresets = {
	var allPresets = [];
	p[~currentPedal][\pedalPresets].do({
		arg preset;
		allPresets = allPresets ++ [preset[\name]];
	});
	allPresets;
};

~setEffectSynth = {
	arg preset;
	~effectSynth.set(
		\isLfo1On, preset[\button1State],
		\isLfo2On, preset[\button2State],
		\lfo1Options, preset[\popup1State],
		\lfo2Options, preset[\popup2State]
	);
};

~setButtonValues = {
	arg preset;
	~toggle1.value_(preset[\button1State]);
	~toggle2.value_(preset[\button2State]);
};

~setPopupValues = {
	arg preset;
	~toggle1PopUp.value_(preset[\popup1State]);
	~toggle2PopUp.value_(preset[\popup2State]);
};

~pedalFilePopup = PopUpMenu(w)
.items_(['Audio muted'] ++ p.keys.asArray)
.action_({
	arg menu;
	var firstPreset;

	if (menu.item == 'Audio muted', ~inputSynth.set(\knob0, 0), {
		firstPreset = p[menu.item][\pedalPresets][0];

		// free synths
		~inputSynth.free;
		~effectSynth.free;

		~currentPedal = menu.item;

		~effectSynth = Synth(
			menu.item, [\in, ~inputSynth]
		);

		// create new input synth
		~inputSynth = Synth(\soundIn, [
			\buf, ~demoSound,
			\knob0, 0.2,
			\amp, firstPreset[\knobValues][0]
		]);

		// set knob and synth values
		~arrayOfKnobs.do({
			arg knob, index;
			var settings = firstPreset[\knobValues][index];
			~arrayOfKnobs[index].value_(settings);
			~effectSynth.set("knob%".format(index), settings);
		});

		~setButtonValues.value(firstPreset);

		// set popup items and values
		~toggle1PopUp.items_(p[menu.item][\popup1Items]);
		~toggle2PopUp.items_(p[menu.item][\popup2Items]);
		~setPopupValues.value(firstPreset);

		~setEffectSynth.value(firstPreset);

		// set text values
		p[menu.item][\activeText].do({
			arg item, i;
			~arrayOfText[i].string_(item).align_(\center);
		});

		// set pedal name
		~pedalName.string_(p[~currentPedal][\pedalName]);

		// set presets
		~presetPopUp.items_(~setPresets.value);

	});
});

~presetPopUp = PopUpMenu(w)
.items_(~allPresets)
.action_({
	arg menu;
	var thePreset = p[~currentPedal][\pedalPresets][menu.value];

	~setButtonValues.value(thePreset);
	~setPopupValues.value(thePreset);
	~setEffectSynth.value(thePreset);

	// map knob valyes to knobs and set synths
	thePreset[\knobValues].do({
		arg i, j;
		~arrayOfKnobs[j].value_(i);
		if (j == 0, ~inputSynth, ~effectSynth).set("knob%".format(j), i);
	});
});


~toggleStates = [["Off"], ["On"]];

~toggle1 = Button.new(w)
.states_(~toggleStates)
.action_({
	~effectSynth.set(\isLfo1On, ~toggle1.value);
});

~toggle2 = Button.new(w)
.states_(~toggleStates)
.action_({
	~effectSynth.set(\isLfo2On, ~toggle2.value);
});

~toggle1PopUp = PopUpMenu(w)
.items_(p[~currentPedal][\popup1Items])
.action_({
	~effectSynth.set(\lfo1Options, ~toggle1PopUp.value);
});

~toggle2PopUp = PopUpMenu(w)
.items_(p[~currentPedal][\popup2Items])
.action_({
	~effectSynth.set(\lfo2Options, ~toggle2PopUp.value);
});

~pedalName = StaticText(w)
.string_(p[~currentPedal][\pedalName])
.align_(\center)
.font_(Font("Monaco", 30));

~arrayOfText = [];
p[~currentPedal][\activeText].do({
	arg item, i;
	~arrayOfText = ~arrayOfText ++ StaticText.new(w).string_(item).align_(\center);
});

~knobAction = {
	arg value, toSet, spec, synthDefToSet;
	[toSet, spec.map(value.value)].postln;
	synthDefToSet.set(toSet, spec.map(value.value));
};

~arrayOfKnobs = Array.fill(9,
	{
		arg i;
		var settings = p[~currentPedal][\pedalPresets][0][\knobValues][i];
		Knob.new(w)
		.value_(settings)
		.action_(
			{
				~knobAction.value(
					~arrayOfKnobs[i].value, "knob%".format(i),
					p[~currentPedal][\controlSpecs][i],
					if (i == 0, ~inputSynth, ~effectSynth) // knob 0 is the gain knob
				)
			}
		);
	}
);

// ----- UI -----

~createNameWindow = {
	arg nameToDisplay = "", isRename;
	var saveButton, exitButton, nameWindow, textField;

	textField = TextField.new(w).value_(nameToDisplay);

	saveButton = Button.new(w)
	.states_([["Save"]])
	.action_({
		~pedalFilePopup.item.postln;
		isRename.postln;
		(isRename == true).if({
			~updatePreset.value(~pedalFilePopup.item, ~presetPopUp.value, textField.value);
			}, {
				~createPreset.value(~pedalFilePopup.item, textField.value);
		});
		nameWindow.visible_(false);
	});

	exitButton = Button.new(w)
	.states_([["Exit"]])
	.action_({
		nameWindow.visible_(false);
	});

	nameWindow = Window.new(
		name: "Name Preset",
		bounds: Rect(200,200,200,200),
		resizable: true
	)
	.front
	.alwaysOnTop_(true)
	.visible_(true)
	.layout_(
		VLayout(
			HLayout(StaticText(w), StaticText(w).string_("Enter name"), StaticText(w)),
			textField,
			saveButton,
			exitButton,
		);
	);

	nameWindow;
};

// main window
w = Window.new(
	name: "Pedal",
	bounds: Rect(300,300,500,300),
	resizable: true
)
.front
.alwaysOnTop_(true)
.layout_(
	VLayout(
		HLayout(~saveNewButton, ~saveEditButton, StaticText(w), ~audioInputPopUp),
		HLayout(~renameButton, ~deleteButton, StaticText(w), StaticText(w), ~pedalFilePopup),
		HLayout(StaticText(w), StaticText(w), StaticText(w)),
		HLayout(StaticText(w), ~pedalName, StaticText(w)),
		HLayout(StaticText(w)),
		HLayout(StaticText(w), ~presetPopUp, StaticText(w)),
		HLayout(StaticText(w)),
		HLayout(~arrayOfKnobs[0], ~arrayOfKnobs[1], ~arrayOfKnobs[2]),
		HLayout(~arrayOfText[0], ~arrayOfText[1], ~arrayOfText[2]),
		HLayout(~arrayOfKnobs[3], ~arrayOfKnobs[4], ~arrayOfKnobs[5]),
		HLayout(~arrayOfText[3], ~arrayOfText[4], ~arrayOfText[5]),
		HLayout(StaticText(w)),
		HLayout(~arrayOfText[6], ~arrayOfText[7]),
		HLayout(~toggle1, ~toggle2),
		HLayout(~toggle1PopUp, ~toggle2PopUp),
		HLayout(~arrayOfKnobs[6], ~arrayOfKnobs[7]),
		HLayout(~arrayOfText[8], ~arrayOfText[9])
	);
);

)

