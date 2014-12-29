// Effects chain
adc => Gain monitor => Gain mixer => dac; //Monitor
.5 => monitor.gain;

monitor => Gain feed => Gain feedback => DelayL delay => feedback;
delay => Gain attenuate => mixer;

// Delay parameters
2::second => delay.max;
1::second => delay.delay;
.98 => feedback.gain;
1 => delay.gain;
.5 => attenuate.gain;

while (true){
        1::second => now;
}
