import javax.sound.midi.*;
import java.io.File;
import java.io.FilenameFilter;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.Random;

Sequencer player;
String sbFile;
PFont font;
File[] midiFiles;
ArrayList<Note> activeNotes; // Store currently playing notes
ArrayList<Note> noteHistory; // Store past notes for visualization
int index = 0;


class Note {
    Random random = new Random();
    int pitch;
    int velocity;
    float speedX;
    float speedY;
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
        this.speedY = 2 + (velocity/50);
        this.speedX = 0;
        this.size = map(velocity, 0, 127, 10, 50)*1.5;
        this.col = color(map(pitch, 0, 88, pitch, 255), map(pitch, 0, 88, pitch, 255), map(pitch, 0, 88, pitch, 255));
        this.noteDuration = 1800;
    }
    
    void update() {
        y += speedY; // Move note up the screen
        x += speedX;
        bounceBall();
        noteDuration--;

        
    }
    
    float getNotePosition(){
      return x;
    }
    
    void display() {
        noStroke();
        fill(col, 200);
        ellipse(x, y, size, size);
    }
    
    void bounceBall(){
      if (y > height)
      {
        speedY =- speedY;
        boolean randomBoolean = random.nextBoolean();
        if(randomBoolean){
          speedX = speedY;
          col = color(map(pitch, 0, 88, pitch, 255), pitch, map(pitch, 0, 88, pitch, 255));
        }
          
        else
        { 
          speedX =- speedY;
          col = color(pitch, map(pitch, 0, 88, pitch, 255), map(pitch, 0, 88, pitch, 255));
        }

      }
      else if( y <= 0)
      {
        speedY =- speedY;
        col = color(map(pitch, 0, 88, pitch, 255), map(pitch, 0, 88, pitch, 255), pitch);
      }
      if( x <= 0)
      {
        speedX =- speedX;
        col = color(pitch, map(pitch, 0, 88, pitch, 255), map(pitch, 0, 88, pitch, 255));
      }
      else if ( x > width)
      {
        speedX =- speedX;
        col = color(pitch, map(pitch, 0, 88, pitch, 255), pitch);
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
    size(841*2,594*2);
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
    midiPlay(midiFiles[0]);
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
        print("trying to play" + f.getName());
        Sequence music = MidiSystem.getSequence(f);
        player.setSequence(music);
        player.start();
                println("Sequence loaded:");
        println("- Duration (microseconds): " + music.getMicrosecondLength());
        println("- Tick length: " + music.getTickLength());
        println("- Track count: " + music.getTracks().length);
    } catch (Exception e) {
        print(e.getMessage());
    }
}

public void draw() {
    background(0);
    //rect(0,0,width,height,color(255,255,255));
    text("Currently Playing:" + midiFiles[index].getName(),100,100);
    
    //update();
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
/*
public void update() {
  
      for (int i = activeNotes.size() - 1; i >= 0; i--) {
        Note note = activeNotes.get(i);
        for (int otherNote = activeNotes.size() - 1; otherNote >= 0; otherNote--)
        if (note)

        
        // Move notes to history when they reach the top
        if (note.getNoteDuration() < 0) {
            noteHistory.add(note);
            activeNotes.remove(i);
        }
    }
  
}
*/

public void keyPressed() {
  // go to next and previous song
    if (keyCode == LEFT) {// if left arrow is pressed
        index--;
        if (index < 0) {
          index = midiFiles.length -1;
        }
      println("\nTrying to play file at index: " + index);
      player.stop(); // Stop current playback
      midiPlay(midiFiles[index]);
    }
    else if (keyCode == RIGHT){// if right arrow is pressed
        index++;
        if (index > midiFiles.length -1) {
          index = 0 ;
        }
      println("\nTrying to play file at index: " + index);
      player.stop(); // Stop current playback
      midiPlay(midiFiles[index]);
    }
    // add detection from num 0 to 9 skiping through the song the amount
    
    
}


 
