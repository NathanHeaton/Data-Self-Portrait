import javax.sound.midi.*;
import java.io.File;
import java.io.FilenameFilter;
import java.util.Arrays;
import java.util.ArrayList;

Sequencer player;
String sbFile;
PFont font;
File[] midiFiles;
ArrayList<Note> activeNotes; // Store currently playing notes
ArrayList<Note> noteHistory; // Store past notes for visualization

class Note {
    int pitch;
    int velocity;
    float speed;
    float x;
    float y;
    float size;
    color col;
    int colourFade = 255;
    int noteDuration;
    
    Note(int pitch, int velocity) {
        this.pitch = pitch;
        this.velocity = velocity;
        this.x = map(pitch, 0, 127, 0, width);
        this.y = 0;
        this.speed = 2 + (velocity/50);
        this.size = map(velocity, 0, 127, 10, 50);
        this.col = color(map(pitch, 0, 127, pitch, 255), 200, 255);
        this.noteDuration = 1000;
    }
    
    void update() {
        y += speed; // Move note up the screen
        bounceBall();
        noteDuration--;

        
    }
    
    void display() {
        noStroke();
        fill(col, 200);
        ellipse(x, y, size, size);
    }
    
    void bounceBall(){
      if (y > height)
      {
        speed = - speed;
      }
      else if( y <= 0)
      {
        speed = - speed;
      }
    }
    
    int getNoteDuration(){
      return noteDuration;
    }
    
    void collisionDetection(){
      //for(int i=0; i <
      
    }
}

public void setup() {
    size(1000, 600);
    surface.setLocation(100, 100);
    font = createFont("pixel-art-font.ttf", 24);
    textFont(font, 24);
    sbFile = "UprightPianoKW-small-bright-20190703.sf2";
    
    activeNotes = new ArrayList<Note>();
    noteHistory = new ArrayList<Note>();
    
    File dir = new File(dataPath(""));
    midiFiles = dir.listFiles(new FilenameFilter() {
        @Override
        public boolean accept(File f, String e) {
            return e.toLowerCase().endsWith(".midi") || e.toLowerCase().endsWith(".mid");
        }
    });
    // change midi file here ==================================================
    setupMidi();
    midiPlay(midiFiles[1]);
    // ========================================================================
}

private void setupMidi() {
    try {
        File sb = new File(dataPath(sbFile));
        Soundbank soundbank = MidiSystem.getSoundbank(sb);
        Synthesizer synth = MidiSystem.getSynthesizer();
        synth.loadAllInstruments(soundbank);
        synth.open();
        
        player = MidiSystem.getSequencer();
        player.open();
        
        // Add MIDI event listener
        player.addMetaEventListener(new MetaEventListener() {
            public void meta(MetaMessage meta) {
                if (meta.getType() == 47) { // End of track
                    player.start(); // Loop playback
                }
            }
        });
        
        // Add MIDI message listener
        player.getTransmitter().setReceiver(new Receiver() {
            public void send(MidiMessage msg, long timeStamp) {
                if (msg instanceof ShortMessage) {
                    ShortMessage sm = (ShortMessage) msg;
                    if (sm.getCommand() == ShortMessage.NOTE_ON) {
                        int pitch = sm.getData1();
                        int velocity = sm.getData2();
                        if (velocity > 0) {
                            activeNotes.add(new Note(pitch, velocity));
                        }
                    }
                }
            }
            public void close() {}
        });
    } catch (Exception e) {
        print(e.getMessage());
    }
}

public void midiPlay(File f) {
    try {
        Sequence music = MidiSystem.getSequence(f);
        player.setSequence(music);
        player.start();
    } catch (Exception e) {
        print(e.getMessage());
    }
}

public void draw() {
    background(0);
    
    // Update and display active notes
    for (int i = activeNotes.size() - 1; i >= 0; i--) {
        Note note = activeNotes.get(i);
        note.update();
        note.display();
        
        // Move notes to history when they reach the top
        if (note.getNoteDuration() < 0) {
            noteHistory.add(note);
            activeNotes.remove(i);
        }
    }
    
    // Clean up note history to prevent memory issues
    if (noteHistory.size() > 1000) {
        noteHistory.remove(0);
    }
}


 
