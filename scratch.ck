1::second => dur loopTime;

fun void plip()
{
    SinOsc s => dac;
    0.05::second => dur plipTime;
    2000 => s.freq;

    while(true){
        .1 => s.gain;
        plipTime => now;
        0 => s.gain;
        loopTime - plipTime => now;
    }

}

spork ~plip();

while(true){
    1::second => now;
    loopTime - 0.1::second => loopTime;
}



