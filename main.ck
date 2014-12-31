// Effects chain
Gain mixer => dac;            // Main mixer
adc => Gain adcThru => mixer; // Monitor the input
adc => LiSa sample => mixer;  // Sampler
// TODO: turn off adcThru when recording

//Times
10::second => sample.duration;
0::second => sample.recPos;
1::second => sample.playPos => sample.loopEnd => sample.loopEndRec;

// Start recording and playing in a loop
1 => sample.loop => sample.record => sample.play; 

// Levels
//0 => adc.gain;
1 => sample.feedback;
.5 => sample.gain;
.5 => adcThru.gain;

// OSC listener class
class OSCListener {
    fun void run(int port, string address) {
        OscRecv recv; port => recv.port; recv.listen(); 
        recv.event(address) @=> OscEvent oe;
        while (true) { oe => now; while (oe.nextMsg() != 0) { this.handle(oe); } }
        me.yield();
    }
    fun void handle(OscEvent oe){};
}

// define child class Y
class InputListener extends OSCListener {
    fun void handle(OscEvent oe){
        oe.getFloat() => adc.gain;
        oe.getFloat() => adcThru.gain;
        <<< "Edit input" >>>;
    }
}

// define child class Y
class DelayListener extends OSCListener
{
    fun void handle(OscEvent oe){
        //TODO: this doesn't work
        // oe.getFloat()::second => sample.recPos => sample.loopEnd => sample.loopEndRec;
        //oe.getFloat()::second => sample.playPos => sample.loopEnd => sample.loopEndRec;
        oe.getFloat();
        oe.getFloat() => sample.feedback;
        <<< "Edit delay" >>>;
    }
}

// define child class Y
class ChannelListener extends OSCListener
{
    fun void handle(OscEvent oe){
        oe.getInt() => int channel;
        oe.getFloat();
        oe.getFloat();
        <<< "Edit channel"  >>>;
    }
}


InputListener il;
DelayListener dl;
ChannelListener cl;
spork ~ il.run(9000, "/input, f, f");
spork ~ dl.run(9000, "/delay, f, f");
spork ~ cl.run(9000, "/channel, i, f, f");

// Loop forever
while(true) { 1::second => now; }



