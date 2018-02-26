const scaleMap = { 'major': [ 0, 2, 4, 5, 7, 9, 11 ]
                 , 'minor': [ 0, 2, 3, 5, 7, 8, 10 ]
                 , 'jazz minor': [ 0, 2, 3, 5, 7, 9, 11 ]
                 }
const keyMap = { 'Ab':20
               , 'A': 21
               , 'A#':22
               , 'Bb':22
               , 'B': 23
               , 'C': 24
               , 'C#':25
               , 'Db':25
               , 'D': 26
               , 'D#':27
               , 'Eb':27
               , 'E': 28
               , 'F': 29
               , 'F#':30
               , 'Gb':30
               , 'G': 31
               , 'G#':32
               }


function randInt( min, max ) {
  return Math.floor( Math.random() * ( max - min ) ) + min;
}


function randChoice( list ) {
  let r = Math.floor( Math.random() * list.length )
  return list[ r ];
}


function noteToFreq( note ) {
  /*
  Accepts MIDI note values * 10, to allow for some inter-note frequencies.

  EG. MIDI 52 would be 520.

  Assumes 440 tuning for MVP.
  */
  return Math.round( Math.pow( 2, ( note - 690 ) / 120 ) * 440 );
}


function beatToTime( beat, tempo ) {
  // we're going to assume beats are expressed as 16th notes
  // by convension

  // the magic '4' is to map from quarter note beats to sixteenth notes

  return Math.round( beat / ( tempo / 60 / 1000 * 4 ) )
}


function beatToVelocity( beat ) {
  /*
  -- assume a 4/4, 120bpm
  -- 100 at each note, ie when beatVal modulo 16 == 0
  -- 80 at each beat, ie when beatVal modulo 4 == 0
  -- 50 at each demi, ie when beatVal modulo 2 == 0
  -- 30 else

  A bar is assumed to be 16 beats long here... for MVP simplicity (IE each
  beat is a 16th note value, and we're trying to bias the velocity to the bar).
  */
  switch ( true ) {
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


function randomNote( scale, key ) {
    // scale - an array of steps indicating the scale, starting at 0, usually ending at 12
    // key - a base midi note (A = 21)
    // returns an integers MIDI note value
    if ( !scale || !key ) {
      return 20
    }

    var scaleOffsets = scale.map( i => i + key );

    /*
    In truth, notes selected are biased. The root note is favoured, followed
    next by the fifth. The third and eigth are next favoured.

    For now, we'll simply double the occurances of root and fifths. This may be
    a parameter in the future.
    */
    let fourth = scaleOffsets[ 3 ];
    let fifth = scaleOffsets[ 4 ];
    let tonic = scaleOffsets[ 0 ];
    scaleOffsets = scaleOffsets.concat( [ tonic, tonic, fourth, fifth, fifth ] );

    let validNotes = [].concat.apply( [], [ 1, 2, 3, 4, 5 ].map( i => {
      return scaleOffsets.map( o => o + 12 * i );
    } ) );

    return randChoice( validNotes );
}


function randomRhytm( bars, beats, noteValue ) {
  /*
  bars - how many bars of music the choice covers
  beats - the top value of a time signature; how many beats per bar
  noteValue - the bottom value of a time signature; the note value of a beat

  NB: The rhythm "grid" is a 16th note quantized grid for now, to simplify some
  of the abstractions.

  Rhythm is actually not entirely random (much as notes are not).

  Statistically (and stylistically) the first beat of the bar is much more
  likely, followed by one of the intervals of the noteValue (eg on a round
  quarter note in 4/4 time), followed by a complex set of recursive
  probabilities which we will for now wave away as "everything else".
  */
  const sixteenth_note_base = 16
  let maxRhythm = bars * beats * ( sixteenth_note_base / noteValue );
  let baseRhythmGrid = Array( maxRhythm ).fill().map( ( _, i ) => {
    return i
  } )
  let barRhythmGrid = Array( bars ).fill().map( ( _, i ) => {
    return i * beats * ( sixteenth_note_base / noteValue );
  } )
  let beatBaseRhythmGrid = Array( bars * beats ).fill().map( ( _, i ) => {
    return i * ( sixteenth_note_base / noteValue );
  } )
  return randChoice(
      baseRhythmGrid.concat( barRhythmGrid ).concat( beatBaseRhythmGrid )
  );
}


function makeMetronome ( cloudSeed ) {
  let n = keyMap[ cloudSeed.key ]
  var barTemplate = Array( cloudSeed.tsig.beats ).fill().map( () => {
    return { 'frequency': noteToFreq( n * 10 ) * 16
           , 'note': n
           , 'timber': 100
           , 'time': null
           , 'rhythm': null
           , 'velocity': 50
           }
  } )
  barTemplate[ 0 ].frequency = noteToFreq( n * 10 ) * 32;
  var bars = [];
  for ( var i = 0; i < cloudSeed.bars; i++ ) {
    bars = bars.concat( barTemplate );
  }
  let beatInterval = 16 / cloudSeed.tsig.noteValue;
  let timedBars = bars.map( ( b, i ) => {
    let r = Math.floor(beatInterval * i);
    let t = Object.assign( {}
                         , b
                         , { rhythm: r
                           , time: Math.floor( beatToTime( r, cloudSeed.tempo ) )
                           }
                         );
    return t
  })
  return timedBars
}


function makeCloud ( cloudSeed ) {
  /*
  Given cloudSeed:
  { 'key': String
  , 'tsig': {'noteValue': Int, 'beats': Int}
  , 'count': Int
  , 'ranges': {'minNote', 'maxNote', 'minTimber', 'maxTimber'}
  , 'bars': Int
  , 'cloudId': Int
  , 'tempo': Int
  , 'scale': String
  }

  Generate a list of Points ({'frequency', 'timber', 'time', 'rhythm', 'velocity'})
  that satisfies the parameters of the seed.
  */
  let scale = scaleMap[ cloudSeed.scale ];
  let key = keyMap[ cloudSeed.key ];


  return Array( cloudSeed.count ).fill().map( () => {
    let r = randomRhytm( cloudSeed.bars, cloudSeed.tsig.beats,
                         cloudSeed.tsig.noteValue );
    let n = randomNote( scale, key );
    return { 'frequency': noteToFreq( n * 10 )
           , 'note': n
           , 'timber': randInt( cloudSeed.ranges.minTimber
                              , cloudSeed.ranges.maxTimber )
           , 'time': beatToTime( r, cloudSeed.tempo )
           , 'rhythm': r
           , 'velocity': beatToVelocity( r )
    }
  });
}
