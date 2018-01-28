
var ctx = new AudioContext();
var voices = 32;


function playClouds( state ) {
  var lastEnd = 0
  state.sequence.forEach(function(cloudID) {
    // assumes the clouds are in order
    let cloud = state.clouds[cloudID];
    let thisEnd = lastEnd;
    setTimeout( function() {
      playCloud(cloud)
    }, thisEnd );
    let maxTime = Math.max(...cloud.points.map( p => p.time))
    lastEnd = thisEnd + maxTime
  })
  if (playLoop) {
    setTimeout( function () {
      playClouds(fullState)
    }, lastEnd)
  }
}


function playCloud( cloud ) {
  console.log("playing cloud " + cloud.id)

  var notes = cloud.points.sort( function (a, b) { return a.time - b.time  } )


  for (var i = 0; i< cloud.registers.length; i++) {

    let register = cloud.registers[i]

    let regNotes = notes.filter(
      function( n ) {
        return n.timber > register.lowerTimber && n.timber < register.upperTimber
      }
    )

    playNotesInRegister( register, regNotes )

  }

}


function playNotesInRegister( register, notes ) {

  debugger;

  for ( var i = 0; i < notes.length; i++ ) {
    let note = notes[i];
    setTimeout( function() {

      let n = Date.now();

      let voices = register.voices.map( function( v ) {
        let o = ctx.createOscillator();
        o.type = v.waveform;
        o.frequency.value = note.frequency;

        let a = ctx.createGain();
        a.gain.value = 0;
        a.gain.linearRampToValueAtTime(note.velocity / 100, n+v.adsr.attack);
        a.gain.linearRampToValueAtTime(note.velocity / 100 * v.sustain, n+v.adsr.attack+v.adsr.decay);
        a.gain.setValueAtTime(note.velocity / 100 * v.sustain, n+note.timber);
        a.gain.linearRampToValueAtTime(0, n+note.timer+v.adsr.release);

        o.connect(a);
        a.connect(ctx.destination);

      } );

    }, note.time)
  }

}
