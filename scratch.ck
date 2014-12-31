//signal chain; record a sine wave, play it back
adc => LiSa saveme => dac;
adc => dac; //monitor the input
0.5 => adc.gain;

//alloc memory; required
2::second => saveme.duration;

//start recording input
1 => saveme.loop;
0::second => saveme.playPos;
2::second => saveme.recPos;
2::second => saveme.loopEnd;

// Start recording, wait one second, then start playing
1 => saveme.record;
1 => saveme.play;
1 => saveme.feedback;

while(true)
{
    1::second => now;
}






