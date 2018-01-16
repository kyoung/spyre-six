function randInt(min, max) {
  return Math.floor( Math.random() * ( max - min ) ) + min;
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
  { 'key': Int
  , 'tsig': {'noteValue': Int, 'beats': Int}
  , 'count': Int
  , 'ranges': {'minNote', 'maxNote', 'minTimber', 'maxTimber'}
  , 'bars': Int
  , 'cloudId': Int
  }

  Generate a list of Points ({'frequency', 'timber', 'time', 'rhythm', 'velocity'})
  that satisfies the parameters of the seed.
  */
  return Array(cloudSeed.count).fill().map(() => {
    let maxRhythm = cloudSeed.bars * cloudSeed.tsig.beats * (16 / cloudSeed.tsig.noteValue);
    let r = randInt(0, maxRhythm);
    let n = randInt(cloudSeed.ranges.minNote, cloudSeed.ranges.maxNote);
    return {
      'frequency': noteToFreq(n),
      'timber': randInt(cloudSeed.ranges.minTimber, cloudSeed.ranges.maxTimber),
      'time': beatToTime(r, 120),
      'rhythm': r,
      'velocity': beatToVelocity(r),
    }
  });
}
