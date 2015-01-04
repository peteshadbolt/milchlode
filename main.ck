// TODO: turn off adcThru when recording
// Effects chain
adc => Gain adcThru => dac; // Monitor input through a mixer
SampleChan channels[4];

// Levels
//0 => adc.gain;
.5 => adcThru.gain;

// Global loop time
1::second => dur loopTime;

// Each channel should output to the mixer
for( 0 => int i; i < channels.cap(); i++ ) { channels[i].outputTo(dac); }

// Listen to OSC messages
OscIn oin; 9000 => oin.port; 
oin.listenAll(); 
OscMsg msg;

// Start the metronome
0 => int metronomeLevel;
spork ~plip();

// Event loop
while (true) { 
    oin => now; 
    while (oin.recv(msg)) { 
        if (msg.address=="/input") {
            msg.getFloat(0) => adc.gain;
            msg.getFloat(1) => adcThru.gain;
        }
        else if(msg.address=="/delay") {
            msg.getFloat(0)::second => loopTime;
            msg.getFloat(1) => float feedback;
            for( 0 => int i; i < channels.cap(); i++ ) { 
                channels[i].setLoopPoint(loopTime); 
                channels[i].setFeedback(feedback);
            }
         }
        else if(msg.address=="/channel") {
            msg.getInt(0) => int i;
            channels[i].setGain(msg.getFloat(1));
            channels[i].setPan(msg.getFloat(2));
        }
        else if(msg.address=="/arm") {
            msg.getInt(0) => int channel;
            for( 0 => int i; i < channels.cap(); i++ ) { channels[i].arm(i==channel); }
        }
        else if(msg.address=="/metronome") {
            msg.getInt(0) => metronomeLevel;
        }
        else if(msg.address=="/clear") {
            msg.getInt(0) => int channel;
            channels[channel].clear();
        }
    } 
}

public class SampleChan
{
    // Chain
    adc => LiSa sample => LPF filter => Pan2 panner;

    // Setup
    10::second => sample.duration;  //This is the max duration
    0::second => sample.recPos => sample.playPos;
    1.0 => sample.feedback;
    1 => sample.loop;
    1 => filter.Q;
    setLoopPoint(1::second);
    setFilter(10000);

    public void setLoopPoint( dur length ) { length => sample.loopEnd => sample.loopEndRec; }
    public void setFeedback( float fb ) { fb => sample.feedback; }
    public void setFilter( float freq ) { freq => filter.freq; }
    public void setGain( float gain ) { gain => filter.gain; }
    public void setPan( float pan ) { pan => panner.pan; }
    public void clear() { sample.clear(); }

    public void outputTo(UGen ugen) { 
        1 => sample.play; 
        panner => ugen; 
    }

    public void arm(int value) {
        sample.playPos() => sample.recPos;
        value => sample.record;
    }
}


// TODO timing here should be done using events
fun void plip()
{
    SinOsc s => dac;
    0.01::second => dur plipTime;

    while(true){
        for( 0 => int i; i < 4; i++ ) { 
            if (i==0){2000 => s.freq;} else {1000 => s.freq;}
            .1*metronomeLevel => s.gain;
            plipTime => now;
            0 => s.gain;
            loopTime/4 - plipTime => now;
        }
    }

}
