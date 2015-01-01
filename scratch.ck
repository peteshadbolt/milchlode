SinOsc s => Pan2 p => dac;
1 => p.pan;

while(1::second => now){
    // this will flip the pan from left to right
    p.pan() * -1. => p.pan;
}
