// the event
Dyno d;
SinOsc s => Pan2 p;
p.left => JCRev revr => dac.left;
p.right => JCRev revl => dac.right;
100 => s.freq;
.2 => s.gain;
.1 => p.gain;

-1 => p.pan;
1::second => now;

0 => p.pan;
1::second => now;

1 => p.pan;
1::second => now;

