// Effects chain
Gain mixer => dac;  // Main mixer
adc => Gain adcThru => mixer;       // Monitor the input 
adc => Gain feedback => DelayL delay => feedback; // Delay line
delay => Gain delaySend => mixer; // Connect delay to mixer

// Delay parameters
10::second => delay.max;
5::second => delay.delay;
1 => feedback.gain;
.5 => delaySend.gain;
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
        oe.getFloat()::second => delay.delay;
        oe.getFloat() => feedback.gain;
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



