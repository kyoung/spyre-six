const majorKey = [ 0, 2, 4, 5, 7, 9, 11, 12 ];
const keyMap = {
    'Ab':20,
    'A': 21,
    'A#':22,
    'Bb':22,
    'B': 23,
    'C': 24,
    'C#':25,
    'Db':25,
    'D': 26,
    'D#':27,
    'Eb':27,
    'E': 28,
    'F': 29,
    'F#':30,
    'Gb':30,
    'G': 31,
    'G#':32
}

function randInt(min, max) {
  return Math.floor( Math.random() * ( max - min ) ) + min;
}

function randChoice(list) {
  let r = Math.floor( Math.random() * list.length )
  return list[r];
}

function noteToFreq(note) {
  /*
  Accepts MIDI note values * 10, to allow for some inter-note frequencies.

  EG. MIDI 52 would be 520.

  Assumes 440 tuning for MVP.
  */
  return Math.round( Math.pow( 2, ( note - 690 ) / 120 ) * 440 );
}

function beatToTime(beat, tempo) {
  // we're going to assume beats are expressed as 16th notes
  // by convension

  // the magic '4' is to map from quarter note beats to sixteenth notes

  return Math.round( beat / ( tempo / 60 / 1000 * 4 ) )
}

function beatToVelocity(beat) {
  /*
  -- assume a 4/4, 120bpm
  -- 100 at each note, ie when beatVal modulo 16 == 0
  -- 80 at each beat, ie when beatVal modulo 4 == 0
  -- 50 at each demi, ie when beatVal modulo 2 == 0
  -- 30 else

  A bar is assumed to be 16 beats long here... for MVP simplicity (IE each
  beat is a 16th note value, and we're trying to bias the velocity to the bar).
  */
  switch (true) {
    case beat % 16 == 0:
      return 100
    case beat % 4 == 0:
      return 50
    case beat % 2 == 0:
      return 30
    default:
      return 10
  }
}

function makeCloud(cloudSeed) {
  /*
  Given cloudSeed:
  { 'key': String
  , 'tsig': {'noteValue': Int, 'beats': Int}
  , 'count': Int
  , 'ranges': {'minNote', 'maxNote', 'minTimber', 'maxTimber'}
  , 'bars': Int
  , 'cloudId': Int
  }

  Generate a list of Points ({'frequency', 'timber', 'time', 'rhythm', 'velocity'})
  that satisfies the parameters of the seed.
  */
  let scaleOffsets = majorKey.map(i => i + keyMap[cloudSeed.key])
  let validNotes = [].concat.apply([], [1, 2, 3, 4, 5].map(i => {
    return scaleOffsets.map(o => o + 12 * i);
  } ) );

  return Array(cloudSeed.count).fill().map(() => {
    let maxRhythm = cloudSeed.bars * cloudSeed.tsig.beats * (16 / cloudSeed.tsig.noteValue);
    let r = randInt(0, maxRhythm);
    let n = randChoice(validNotes);
    return {
      'frequency': noteToFreq(n*10),
      'note': n,
      'timber': randInt(cloudSeed.ranges.minTimber, cloudSeed.ranges.maxTimber),
      'time': beatToTime(r, 120),
      'rhythm': r,
      'velocity': beatToVelocity(r),
    }
  });
}
