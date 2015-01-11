// TODO: turn off adcThru when recording
// TODO: Effects break panning for some unknown reason
// TODO: currently I don't turn ADC thru back on after recording
// Effects chain with limiters, reverb, filters
NRev reverb => LPF lpf => HPF hpf => Dyno outputLimiter => dac;
outputLimiter.limit();
reverb @=> UGen @ outputWet; // Reference to wet output
outputLimiter @=> UGen @ outputDry; // Reference to dry output
outputLimiter @=> UGen @ mainOutput; // Reference to main output

// Capture mic/line in and monitor through DAC. Limit
adc => Dyno inputLimiter => Gain adcThru => mainOutput; // Monitor input 
inputLimiter.limit(); 
inputLimiter @=> UGen @ mainInput;


// Default parameters
.5 => adcThru.gain;
10000 => lpf.freq;
10 => hpf.freq;
//1::second => dur loopTime;

// Plug in the pedals
LoopPedal pedals[4];
for( 0 => int i; i < pedals.cap(); i++ ) { 
    pedals[i].recordFrom(mainInput);  
    pedals[i].outputTo(outputWet, outputDry); 
}

// Create the metronome
Metronome metronome;
spork ~metronome.run();

// Start listening to OSC messages
OscIn oin; 9000 => oin.port; 
oin.listenAll(); 
OscMsg msg;

// Event loop
while (true) { 
    oin => now; 
    while (oin.recv(msg)) { 
        if (msg.address=="/input") {
            msg.getFloat(0) => adc.gain;
            msg.getFloat(1) => adcThru.gain;
        }
        else if(msg.address=="/delay") {
            msg.getFloat(0)::second => dur loopTime;
            msg.getFloat(1) => float feedback;
            for( 0 => int i; i < pedals.cap(); i++ ) { 
                pedals[i].setLoopPoint(loopTime); 
                pedals[i].setFeedback(feedback);
            }
         }
        else if(msg.address=="/channel") {
            msg.getInt(0) => int i;
            pedals[i].setGain(msg.getFloat(1));
            pedals[i].setPan(msg.getFloat(2));
            pedals[i].setWet(msg.getFloat(3));
        }
        else if(msg.address=="/arm") {
            msg.getInt(0) => int channel;
            for( 0 => int i; i < pedals.cap(); i++ ) { pedals[i].arm(i==channel); }
        }
        else if(msg.address=="/metronome") {
            //msg.getInt(0) => metronomeLevel;
        }
        else if(msg.address=="/clear") {
            msg.getInt(0) => int channel;
            pedals[channel].clear();
        }
        else if(msg.address=="/fx") {
            (100+msg.getFloat(0)*10000) => lpf.freq;
            (100+msg.getFloat(1)*10000) => hpf.freq;
            msg.getFloat(2) => reverb.mix;
        }
        else if(msg.address=="/master") {
            msg.getFloat(0) => mainOutput.gain;
        }
    } 
}

class LoopPedal
{
    // We are wrapping a live sampler, LiSa
    LiSa sample;
    sample => Gain wet;
    sample => Gain dry;

    // Setup
    10::second => sample.duration;  // Allocate max 10 secs of memory
    0::second => sample.recPos => sample.playPos;
    1.0 => sample.feedback;
    1 => sample.loop;
    setLoopPoint(1::second);
    setWet(0.5);

    public void setLoopPoint( dur length ) { length => sample.loopEnd => sample.loopEndRec; }
    public void setFeedback( float fb ) { fb => sample.feedback; }
    public void setGain( float gain ) { gain => sample.gain; }
    public void setPan( float pan ) { } //pan => panner.pan; }
    public void setWet( float ratio ) { ratio => wet.gain; 1-ratio => dry.gain;} 
    public void clear() { sample.clear(); }
    public void recordFrom(UGen ugen) { ugen => sample; }
    public dur remaining() { return sample.loopEnd() - sample.playPos(); }

    public void outputTo(UGen wetSink, UGen drySink) { 
        1 => sample.play; 
        wet => wetSink; 
        dry => drySink; 
    }

    public void arm(int value) {
        0 => adcThru.gain;
        sample.playPos() => sample.recPos;
        value => sample.record;
    }
}


class Metronome
{
    // A simple metronome
    SinOsc s => ADSR a => dac;
    0.5 => s.gain;
    a.set(0.01, .1, .5, .2);
    0.01::second => dur plipTime;

    fun void run()
    {
        while(true){
            pedals[0].remaining() => now;
            a.keyOn();
            plipTime => now;
            a.keyOff();
        }
    }
}











/*

// Start the metronome and the vu meter (optional)
//0 => int metronomeLevel;
//spork ~plip();
//spork ~vu_meter();

// TODO timing here should be done using events
fun void metronome()
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
*/
