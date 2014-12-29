// Effects chain
adc => Gain g => dac;
g => Gain feedback => DelayL delay => g;

// Delay parameters
10::second => delay.max;
5::second => delay.delay;
1 => feedback.gain;
1 => delay.gain;

// Create our OSC receiver
spork ~ inputEventHandler(9000);

// Loop forever
while(true) { 1::second => now; }


inputEventHandler => awd.handler;

// Event loop to deal with ADC input
fun void inputEventHandler(int port) {
    OscRecv recv;
    port => recv.port;
    recv.listen();
    recv.event( "/input, f f" ) @=> OscEvent oe;
    while (true) {
        oe => now;
        while (oe.nextMsg() != 0) { 
            oe.getFloat() => g.gain;
            oe.getFloat() => float a;
        }
    }
    me.yield();
}


