// the event
KBHit kb;

class MetronomeEvent extends Event{ int value; }

class Metronome {
    MetronomeEvent metronomeEvent;
    spork ~pulse();

    fun void listen(){
        while (true){
            metronomeEvent => now;
            <<<"Metronome got event " + metronomeEvent.value>>>;
            if (metronomeEvent.value==0){
                spork ~pulse();
            }
        }
    }

    fun void pulse(){
       1::second => now; 
       0=>metronomeEvent.value;
       metronomeEvent.signal();
    }

    fun void signal(){
        1=>metronomeEvent.value;
        metronomeEvent.signal();
    }
}

Metronome m;
spork ~m.listen();

// time-loop
while( true )
{
    kb => now;
    while( kb.more() )
    {
        <<< "ascii: ", kb.getchar() >>>;
        m.signal();
    }
}
