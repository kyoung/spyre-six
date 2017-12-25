
var ctx = new AudioContext();

var vco = ctx.createOscillator();
vco.type = vco.SINE;
vco.start();

var vca = ctx.createGain();
vca.gain.value = 0;

vco.connect(vca);
vca.connect(ctx.destination);


async function playCloud( state ) {

  var start = Date.now();
  var notes = state.cloud.sort( function (a, b) { return a.time - b.time  } )

  vca.gain.value = 1;
  for (var i = 0; i < notes.length; i++ ) {
    vco.frequency.value = notes[i].frequency;
    if ( i < notes.length - 1 ) {
      await sleep(notes[i+1]-notes[i]);
    }
  }

  vca.gain.value = 0;
}

function sleep (ms) {
  return new Promise( resolve => setTimeout(resolve, ms));
}
