# Pedal
An audio effects pedal with SuperCollider. Users can create and upload their own `.scd` effect files.

To create your own effect, copy an existing effect file in the `/pedals` directory and amend the values in the file's dictionary. Make sure the key is the same as the `SynthDef` name, and unique to all the other `SynthDef` names in the effect files.

[View a YouTube demo here](https://www.youtube.com/watch?v=iO_jPU0kNQc)


## Features
- Flanger, reverb, delay and other effects
- GUI featuring 8 control knobs, buttons and more
- Create, read, update and delete effect presets
- MIDI control of effect parameters (see `/utils/midi.scd`)


<img width="472" alt="Screenshot 2022-09-19 at 17 21 21" src="https://user-images.githubusercontent.com/68643643/191065591-582c674b-9d4f-4ede-a7a8-6bceb150329f.png">
