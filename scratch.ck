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
    setLoopPoint(1::second);
    filter.set(10000, 1);

    public void setLoopPoint( dur length ) {
        length => sample.loopEnd => sample.loopEndRec;
    }

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

// Effects chain
Gain mixer => dac;              // Main mixer
//adc => Gain adcThru => mixer; // Monitor the input
SampleChan sample;              // Sampler

sample.outputTo(mixer);
sample.recordFrom(adc);

2::second => now;
sample.stopRecording();
5::second=>now;

/*while(true) { 1::second => now; }*/
