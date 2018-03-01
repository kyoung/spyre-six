# Spyre, Attempt Six

_Latest release hosted [here](http://LeagueOfVillainy.com/spyre_six)_

The Sixth attempt made at writing a program to generally compose music based
on a simple set of input parameters. Originally intended to be a tool used to
fill out texture and sound for accompaniment by a limited number of live
musicians.

The basic idea is that each "Cloud" is a set of points in three dimensional
space, with each axis representing timber (duration of identity of a sound;
think percussion versus pads), time (location of the point of sound in time; aka
it's sequence and rhythm), and frequency (aka it's note).

Each of the three dimensions can be combed and biased (eg. How rhythmic do you
want it? What key should it be in?).

Finally, Clouds can be globally sequenced, and looped.

Each Cloud has a set of registers, which can be tuned to capture points of
specific timber ranges (and may overlap). This way you can program different
sounds for different types of notes (eg. Short attacks for percussive sounds).

Each register can have multiple voices, consisting of a simple oscillator and
ADSR filter, combined through a basic biquad filter. _NB. Eventually
cross-oscillator behaviour will be supported._


## Dragons

Known bugs, problems, and plans...
- It's surprisingly easy to max out the audio context destination node; we'll need to add some compression mechanism to compensate
- The Elm code is in desperate need of refactor (and the JS and CSS as well)
- Eventually it would be nice to move the cloud generation code back into Elm once the limitations of the random number generation are sorted out
- It would be nice to support a wider variety of musical scales and systems--the whole thing is terribly Western-centric at the moment
- The timing on trigger Loop and Play behavior has some strange interactions and needs to be resolved
- Dance party mode? (Would probably need the ability to have sub-clouds, or to at least layer a drum machine / simple step sequencer.)
