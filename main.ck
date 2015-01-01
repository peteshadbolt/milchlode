// TODO: turn off adcThru when recording
// Effects chain
adc => Gain adcThru => Gain mixer => dac; // Monitor input through a mixer
SampleChan channel1;

// Levels
//0 => adc.gain;
.5 => adcThru.gain;

// Start recording and playing in a loop
channel1.outputTo(mixer);
channel1.recordFrom(adc);

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
    channel1.setLoopPoint(msg.getFloat(0)::second);
    channel1.setFeedback(msg.getFloat(1));
}

fun void controlChannel(OscMsg msg){
    msg.getInt(0) => int channel;
    channel1.setGain(msg.getFloat(1));
}


public class SampleChan
{
    // Chain
    LiSa sample => LPF filter;

    // Setup
    UGen @ mySource;
    10::second => sample.duration; //This is the max duration
    0::second => sample.recPos => sample.playPos;
    1.0 => sample.feedback;
    1 => sample.loop;
    1 => filter.Q;
    setLoopPoint(1::second);
    setFilter(1000);

    public void setLoopPoint( dur length ) { length => sample.loopEnd => sample.loopEndRec; }
    public void setFeedback( float fb ) { fb => sample.feedback; }
    public void setFilter( float freq ) { freq => filter.freq; }
    public void setGain( float gain ) { gain => filter.gain; }

    public void outputTo(UGen ugen) { 
        1 => sample.play; 
        filter => ugen; 
    }

    public void recordFrom(UGen ugen) {
        1 => sample.record;
        ugen => sample;
        ugen @=> mySource;
    }

    public void stopRecording() {
        0 => sample.record;
        mySource =< sample; 
    }
}

