~makePresetDictionary = {
	var knobValues = [], dict;
	~arrayOfKnobs.do({ |knob| knobValues = knobValues ++ knob.value; });

	// make preset dictionary
	dict = Dictionary.newFrom([
		\name, ~presetPopUp.item,
		\knobValues, knobValues,
		\button1State, ~toggle1.value,
		\button2State, ~toggle2.value,
		\popup1State, ~toggle1PopUp.value,
		\popup2State, ~toggle2PopUp.value,
	]);
	dict;
};

~getPathAndPresets = {
	arg effect;
	var path = ~folderPath ++ "pedals/%.preset".format(effect);
	[path, Object.readArchive(path)];
};

~createPreset = {
	arg effect, presetName;
	var path, tempAllPresets, knobValues, newPreset, presetPopUpItems = ~setPresets.value;
	# path, tempAllPresets = ~getPathAndPresets.value(effect);

	// create temp preset
	newPreset = ~makePresetDictionary.value;
	newPreset[\name] = presetName;

	newPreset.postcs;

	// update preset PopUp
	presetPopUpItems = presetPopUpItems ++ [presetName];
	~presetPopUp.items_(presetPopUpItems);

	// add a new preset to a temp array all presets
	tempAllPresets = tempAllPresets ++ [newPreset];

	// add a new preset to the global effect file variable
	p[effect][\pedalPresets] = p[effect][\pedalPresets] ++ [newPreset];

	// save the temp array of all presets to a preset file
	tempAllPresets.writeArchive(path);
};

~readPreset = {
	arg effect;
	var path, tempAllPresets;
	# path, tempAllPresets = ~getPathAndPresets.value(effect);

	tempAllPresets !? {
		p[effect][\pedalPresets] = p[effect][\pedalPresets] ++ tempAllPresets;
	};
};

~updatePreset = {
	arg effect, presetIndex, newPresetName = nil;
	var path, tempAllPresets, presetPopUpItems = ~setPresets.value, newPreset, knobValues;
	# path, tempAllPresets = ~getPathAndPresets.value(effect);

	// all pedals have the a number of factory presets that can't be deleted
	(presetIndex > (~numberOfFactoryPresets - 1)) !? {

		newPreset = ~makePresetDictionary.value;

		newPresetName !? {
			newPreset[\name] = newPresetName;
			presetPopUpItems.value[presetIndex] = newPresetName;
			~presetPopUp.items_(presetPopUpItems);
		};

		p[effect][\pedalPresets][presetIndex] = newPreset;
		tempAllPresets[presetIndex - (~numberOfFactoryPresets)] = newPreset;

		tempAllPresets.writeArchive(path);
	};
};

~deletePreset = {
	arg effect, presetIndex;
	var path, tempAllPresets, presetPopUpItems = ~setPresets.value;
	# path, tempAllPresets = ~getPathAndPresets.value(effect);

	(presetIndex > (~numberOfFactoryPresets - 1)) !? {
		p[effect][\pedalPresets].removeAt(presetIndex);
		tempAllPresets.removeAt(presetIndex - (~numberOfFactoryPresets));

		presetPopUpItems.value.removeAt(presetIndex);
		~presetPopUp.items_(presetPopUpItems);

		tempAllPresets.writeArchive(path);
	};

};