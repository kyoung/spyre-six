
var ctx = new AudioContext();
var voices = 32;
var playLoop = true;

var testBeat = [ {'time': 250, 'timber': 100, 'frequency': 400}
               , {'time': 500, 'timber': 100, 'frequency': 200}
               , {'time': 750, 'timber': 100, 'frequency': 200}
               , {'time': 1000, 'timber': 100, 'frequency': 200}
               , {'time': 1250, 'timber': 100, 'frequency': 400}
               , {'time': 1500, 'timber': 100, 'frequency': 200}
               , {'time': 1750, 'timber': 100, 'frequency': 200}
               , {'time': 2000, 'timber': 100, 'frequency': 200}
               ]

var vcos = Array.from(Array(voices)).map(function(_, i) {
    var c = ctx.createOscillator();
    switch (true) {
      case i < 4:
        c.type = 'square';
        break;
      case i < 8:
        c.type = 'triangle';
        break;
      default:
        c.type = 'sine'
    }
    c.start();
    return c;
})

var vcas = Array.from(Array(voices)).map(function() {
    var a = ctx.createGain();
    a.gain.value = 0;
    return a;
})

vcos.map(function(vco, i) {
    vco.connect(vcas[i]);
    vcas[i].connect(ctx.destination);
})


async function playCloud( state ) {

  var start = Date.now();
  var notes = state.cloud.sort( function (a, b) { return a.time - b.time  } )

  var percusiveNotes = notes.filter( function(note) { return note.timber < 62; } )
  var melodicNotes = notes.filter( function(note) { return note.timber >= 62 && note.timber < 500; } )
  var padNotes = notes.filter( function(note) { return note.timber >= 500; } )

  playPercusion(percusiveNotes);
  playMelodic(melodicNotes);
  playPads(padNotes);

  if ( playLoop ) {
    setTimeout( function() {
      playCloud( state );
    }, notes[notes.length -1 ].time )
  }

}

function playNotes(voicePool, notes) {
  var voiceMux = voicePool.map( () => false )
  for ( var i = 0; i < notes.length; i++ ) {
    let note = notes[i];
    setTimeout( function() {
      var freeVoice = voiceMux.indexOf(false);
      if ( freeVoice == -1 ) {
        return
      }
      var voice = voicePool[ freeVoice ]
      voiceMux[ freeVoice ] = true;
      vcos[voice].frequency.value = note.frequency;
      vcas[voice].gain.value = note.velocity / 100;
      setTimeout( function() {
        vcas[voice].gain.value = 0;
        voiceMux[ freeVoice ] = false;
      }, note.timber);
    }, note.time)
  }
}

async function playPercusion( notes ) {
  playNotes([0, 1, 2, 3], notes);
}

async function playMelodic( notes ) {
  playNotes([4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], notes)
}

async function playPads( notes ) {
  playNotes([16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31], notes)
}

function sleep (ms) {
  return new Promise( resolve => setTimeout(resolve, ms));
}
