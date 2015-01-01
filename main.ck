// TODO: turn off adcThru when recording
// Effects chain
adc => Gain adcThru => Gain mixer => dac; // Monitor input through a mixer
SampleChan channels[4];

// Levels
//0 => adc.gain;
.5 => adcThru.gain;

// Each channel should output to the mixer
for( 0 => int i; i < channels.cap(); i++ ) { channels[i].outputTo(mixer); }

// Listen to OSC messages
OscIn oin; 9000 => oin.port; 
oin.listenAll(); 
OscMsg msg;

// Event loop
while (true) { 
    //oin => now; 
    1::second => now;
    while (oin.recv(msg)) { 
        if (msg.address=="/input") 
        {
            msg.getFloat(0) => adc.gain;
            msg.getFloat(1) => adcThru.gain;
        }
        else if(msg.address=="/delay")
        {
            msg.getFloat(0)::second => dur loopPoint;
            msg.getFloat(1) => float feedback;
            for( 0 => int i; i < channels.cap(); i++ ) { 
                channels[i].setLoopPoint(loopPoint); 
                channels[i].setFeedback(feedback);
            }
         }
        else if(msg.address=="/channel")
        {
            msg.getInt(0) => int i;
            channels[i].setGain(msg.getFloat(1));
        }
        else if(msg.address=="/arm")
        {
            msg.getInt(0) => int channel;
            for( 0 => int i; i < channels.cap(); i++ ) { channels[i].arm(i==channel); }
        }
    } 
}

public class SampleChan
{
    // Chain
    adc => LiSa sample => LPF filter;

    // Setup
    10::second => sample.duration; //This is the max duration
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

    public void outputTo(UGen ugen) { 
        1 => sample.play; 
        filter => ugen; 
    }

    public void arm(int value) {
        value => sample.record;
    }
}

