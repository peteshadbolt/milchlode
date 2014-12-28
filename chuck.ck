// Effects chain
adc => Gain g => dac;
g => Gain feedback => DelayL delay => g;

// Delay parameters
10::second => delay.max;
5::second => delay.delay;
1 => feedback.gain;
1 => delay.gain;

// Create our OSC receiver
OscRecv recv;
9000 => recv.port;
recv.listen();
recv.event( "/test, f" ) @=> OscEvent oe;

// Event loop
while (true) {
    // Wait for event to arrive
    oe => now;

    // Grab the next message from the queue. 
    while ( oe.nextMsg() != 0 ) { 
        float val;
        <<<val>>>;
        oe.getFloat() => val;
        val::second => delay.delay;
    }
}


/*
// Listen for messages regarding ADC input
fun void oscListener( int port, string osctype ) {
// create our OSC receiver
OscRecv recv;
port => recv.port;
recv.listen();

int val;
string type;

// create an address in the receiver, store in new variable
recv.event( osctype ) @=> OscEvent oe;

while( true ) {
// wait for osc event to arrive
oe => now;

while( oe.nextMsg() ) {
oe.getInt() => val;
osctype => type;

if( type == leftraw ) {
val => raw.freq;
}
else if( type == leftavg ) {
val => avg.freq;
}

me.yield();
}
}
} 
*/
