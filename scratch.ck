// Effects chain
Gain mixer => dac;  // Main mixer
adc => Gain adcThru => mixer;       // Monitor the input 
adc => Gain feedback => DelayL delay => feedback; // Delay line
delay => Gain delaySend => mixer; // Connect delay to mixer

// Delay parameters
2::second => delay.max;
1::second => delay.delay;
.98 => feedback.gain;
1 => delay.gain;
.5 => delaySend.gain;
.5 => adcThru.gain;

while (true){
        1::second => now;
}
