// Effects chain
Gain mixer => dac;            // Main mixer
adc => Gain adcThru => mixer; // Monitor the input
adc => LiSa sample => mixer;  // Sampler
// TODO: turn off adcThru when recording

//Times
10::second => sample.duration;
0::second => sample.recPos;
0::second => sample.playPos;
1::second => sample.loopEnd => sample.loopEndRec;

// Start recording and playing in a loop
1 => sample.loop => sample.record => sample.play; 

// Levels
//0 => adc.gain;
1 => sample.feedback;
.5 => sample.gain;
.5 => adcThru.gain;

.5::second => now;
2::second => sample.loopEnd => sample.loopEndRec;



while(true) { 1::second => now; }
