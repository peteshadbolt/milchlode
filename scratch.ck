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
