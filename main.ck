// Effects chain
Gain mixer => dac;            // Main mixer
adc => Gain adcThru => mixer; // Monitor the input
adc => LiSa sample => mixer;  // Sampler
// TODO: turn off adcThru when recording

//Times
10::second => sample.duration;
0::second => sample.recPos => sample.playPos;
1::second => sample.loopEnd => sample.loopEndRec;

// Levels
//0 => adc.gain;
1 => sample.feedback;
.5 => sample.gain;
.5 => adcThru.gain;

// Start recording and playing in a loop
1 => sample.loop => sample.record => sample.play; 

// Listen to OSC messages
OscIn oin; 9000 => oin.port; 
oin.listenAll(); 
OscMsg msg;

// Event loop
while (true) { 
    oin => now; 
    while (oin.recv(msg)) { 
        <<<msg.address>>>;
        if (msg.address=="/input")
            controlInput(msg);
        else if(msg.address=="/delay")
            controlDelay(msg);
        else if(msg.address=="/channel")
            controlChannel(msg);
    } 
}

fun void controlInput(OscMsg msg){
    msg.getFloat(0) => adc.gain;
    msg.getFloat(1) => adcThru.gain;
}

fun void controlDelay(OscMsg msg){
    msg.getFloat(0)::second => sample.loopEnd => sample.loopEndRec;
    msg.getFloat(1) => sample.feedback;
}

fun void controlChannel(OscMsg msg){
    msg.getInt(0) => int channel;
    msg.getFloat(1) => sample.gain;
}
