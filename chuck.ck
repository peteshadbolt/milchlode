// feedforward
adc => Gain g => dac;
// feedback
g => Gain feedback => DelayL delay => g;

// set delay parameters
5::second => delay.max => delay.delay;
// set feedback
.5 => feedback.gain;
// set effects mix
.75 => delay.gain;

// infinite time loop
<<< "hello from chuck (waiting for OSC)" >>>;

// create our OSC receiver
OscRecv recv;

// use port 9000
9000 => recv.port;
// start listening (launch thread)
recv.listen();

// create an address in the receiver, store in new variable
recv.event( "/test, f" ) @=> OscEvent oe;

// infinite event loop
while ( true )
{
    // wait for event to arrive
    oe => now;

    // grab the next message from the queue. 
    while ( oe.nextMsg() != 0 )
    { 
      <<< oe.getFloat() >>>;
    }
}

