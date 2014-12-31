//signal chain; record a sine wave, play it back
adc => LiSa saveme => dac;
adc => dac; //monitor the input
0.5 => adc.gain;

//alloc memory; required
2::second => saveme.duration;

//start recording input
1 => saveme.loop;
0::second => saveme.playPos;
1::second => saveme.loopEnd;

// Start recording, wait one second, then start playing
saveme.record(1);
1::second => now;
1 => saveme.play;

while(true)
{
    1::second => now;
}







/*
// Effects chain
adc => LiSa s => dac;  
1::second => s.duration;
0::second => s.recPos;
1::second => s.playPos;
s.loop(1);
s.loopRec(1);
s.play(1);


while (true){
        1::second => now;
}
*/
