
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


let testNotes = [
    {velocity: 100, timber: 4000, time: 0, frequency: 440},
    {velocity: 80, timber: 2000, time: 3000, frequency: 640},
];
let testRegister = {voices:[{waveform: 'Sine', adsr: {attack: 100, decay: 100, sustain: 0.5, release: 500}}]}


function playNote(frequency, waveform, velocity, adsr, duration) {
  let o = ctx.createOscillator();
  o.type = waveform;
  o.frequency.value = frequency;
  let a = ctx.createGain();
  let n = ctx.currentTime;
  let v = velocity / 100;

  a.gain.setValueAtTime(0, n);

  let peak = n + adsr.attack/1000;
  let dip = n + (adsr.attack+adsr.decay)/1000;
  let drop = n + (adsr.attack+adsr.decay+duration)/1000;
  let end = n + (adsr.attack+adsr.decay+duration+adsr.release)/1000;

  a.gain.linearRampToValueAtTime(v, peak);
  a.gain.linearRampToValueAtTime(v * adsr.sustain, dip);
  a.gain.setValueAtTime(v * adsr.sustain, drop);
  a.gain.linearRampToValueAtTime(0, end);

  o.start();
  o.connect(a);
  a.connect(ctx.destination);
}


function playNotesInRegister( register, notes ) {

  for ( var i = 0; i < notes.length; i++ ) {
    let note = notes[i];
    setTimeout( function() {

      let n = ctx.currentTime;

      let voices = register.voices.map( function( v ) {
        playNote(note.frequency, v.waveform, note.velocity, v.adsr, note.timber)
      } );

    }, note.time)
  }

}
