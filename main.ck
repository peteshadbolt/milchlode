//TODO: turn off adcThru when recording, and turn it back on afterwards
//TODO: Effects break panning for some unknown reason
//TODO varying number of bars
NRev reverb => LPF lpf => HPF hpf => Dyno fxLimiter => dac;
Dyno outputDryLeft => dac.left;
Dyno outputDryRight => dac.right;
fxLimiter.limit();
outputDryLeft.limit();
outputDryRight.limit();
reverb @=> UGen @ outputWet; // Reference to wet output

// Capture mic/line in and monitor through DAC. Limit
adc => Dyno inputLimiter => Gain adcThru => fxLimiter; // Monitor input 
inputLimiter.limit(); 
inputLimiter @=> UGen @ mainInput;

// Default parameters
0 => float adcThruLevel;
1 => int adcThruMute;
adcThruLevel * adcThruMute => adcThru.gain;
10000 => lpf.freq;
10 => hpf.freq;
2::second => dur globalLoopTime;

// Plug in the pedals
LoopPedal pedals[4];
for( 0 => int i; i < pedals.cap(); i++ ) { 
    pedals[i].recordFrom(mainInput);  
    pedals[i].outputTo(outputWet, outputDryLeft, outputDryRight); 
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
            msg.getFloat(1) => adcThruLevel;
            adcThruLevel * adcThruMute => adcThru.gain;
        }
        else if(msg.address=="/delay") {
            msg.getFloat(0)::second => globalLoopTime;
            msg.getFloat(1) => float feedback;
            for( 0 => int i; i < pedals.cap(); i++ ) { 
                pedals[i].setLoopPoint(globalLoopTime); 
                pedals[i].setFeedback(feedback);
            }
         }
        else if(msg.address=="/channel") {
            msg.getInt(0) => int i;
            pedals[i].setGain(msg.getFloat(1));
            pedals[i].setPan(msg.getFloat(2));
            pedals[i].setWet(msg.getFloat(3));
        }
        else if(msg.address=="/multiplier"){
            msg.getInt(0) => int i;
            pedals[i].setLoopPoint(globalLoopTime * msg.getFloat(1));
        }
        else if(msg.address=="/direction"){
            msg.getInt(0) => int i;
            pedals[i].setDirection(msg.getFloat(1));
        }
        else if(msg.address=="/arm") {
            msg.getInt(0) => int channel;
            (channel<0) => adcThruMute;
            adcThruLevel * adcThruMute => adcThru.gain;
            for( 0 => int i; i < pedals.cap(); i++ ) { pedals[i].arm(i==channel); }
        }
        else if(msg.address=="/metronome") {
            metronome.mute(msg.getInt(0));
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
            msg.getFloat(0) => float masterGain;
            masterGain => outputDryLeft.gain;
            masterGain => outputDryRight.gain;
            masterGain => fxLimiter.gain;
        }
    } 
}

class LoopPedal
{
    // We are wrapping a live sampler, LiSa
    LiSa sample;
    sample => Gain wet;
    sample => Pan2 dry;

    // Setup
    10::second => sample.duration;  // Allocate max 10 secs of memory
    0::second => sample.recPos => sample.playPos;
    1.0 => sample.feedback;
    1 => sample.loop;
    dur loopTime;
    setLoopPoint(2::second);
    setWet(0.5);

    public void setLoopPoint( dur length ) { 
        length => loopTime => sample.loopEnd => sample.loopEndRec; 
    }
    public void setDirection( float direction ) { 
        direction => sample.rate;
    }
    public void setFeedback( float fb ) { fb => sample.feedback; }
    public void setGain( float gain ) { gain => sample.gain; }
    public void setPan( float pan ) { pan => dry.pan; }
    public void setWet( float ratio ) { ratio => wet.gain; 1-ratio => dry.gain;} 
    public void clear() { sample.clear(); }
    public void recordFrom(UGen ugen) { ugen => sample; }
    // TODO: maybe this should be % looptime/multiplier?
    public dur remaining() { return loopTime - sample.playPos(); }

    public void outputTo(UGen wetSink, UGen drySinkLeft, UGen drySinkRight) { 
        1 => sample.play; 
        wet => wetSink; 
        dry.left => drySinkLeft; 
        dry.right => drySinkRight; 
    }

    public void arm(int value) {
        sample.playPos() => sample.recPos;
        value => sample.record;
    }
}


class Metronome
{
    // A simple metronome
    SinOsc s => ADSR a;
    60 => s.freq;
    0.6 => s.gain;
    a.set(0.001, .1, .5, .13);
    10::ms => dur plipTime;

    fun void mute(int value) {
        if (value){ a => dac; } else { a =< dac; }
    }

    fun void run() {
        while(true) {
            // Compute the beat time
            globalLoopTime/4. - plipTime => dur beatTime;

            // Beep four times
            0.15::second => a.releaseTime;
            a.keyOn(); plipTime => now; a.keyOff();
            beatTime => now;
            0.1::second => a.releaseTime;
            a.keyOn(); plipTime => now; a.keyOff();
            beatTime => now;
            a.keyOn(); plipTime => now; a.keyOff();
            beatTime => now;
            a.keyOn(); plipTime => now; a.keyOff();
            pedals[0].remaining() => now; // Sync
        }
    }
}
