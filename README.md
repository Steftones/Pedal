# Pedal
An audio effects pedal with SuperCollider. Users can create and upload their own ‵.scd‵ effect files.

To create your own effect, copy an existing effect file in the ‵/pedals‵ directory and amend the values in the file's dictionary. Make sure the key is the same as the ‵SynthDef‵ name, and unique to all the other ‵SynthDef‵ names in the effect files.

## Features
- Flanger, reverb, delay and other effects
- GUI featuring 8 control knobs, buttons and more
- Create, read, update and delete effect presets
- MIDI control of effect parameters (see ‵/utils/midi.scd‵)

