import javax.sound.midi.MidiSystem;
import javax.sound.midi.Sequence;
import javax.sound.midi.Sequencer;
import javax.sound.midi.Soundbank;
import javax.sound.midi.Synthesizer;
import java.io.File;
import java.io.FilenameFilter;
import java.util.Arrays;

Sequencer player;
String sbFile; // sound bank file stores sound that will be used
PFont font;
File [] midiFiles;// store all of the midi files

public void setup(){
  size(1000,600);
  surface.setLocation(100,100);
  font = createFont("pixel-art-font.ttf", 24); // font
  textFont(font, 24);
  sbFile = "UprightPianoKW-small-bright-20190703.sf2"; // piano sound
  File dir = new File(dataPath(""));
  midiFiles = dir.listFiles(new FilenameFilter(){
    @Override
    public boolean accept(File f,String e){
      return e.endsWith(".midi");
     }
  });
  setupMidi();
  midiPlay(midiFiles[0]);//just play first one it finds for now

  
}

private void setupMidi(){
  try{
    File sb = new File(dataPath(sbFile));
    Soundbank soundbank = MidiSystem.getSoundbank(sb);
    Synthesizer synth = MidiSystem.getSynthesizer();
    synth.loadAllInstruments(soundbank);
    synth.open();
    //adds the synth to the player
    player = MidiSystem.getSequencer();
    player.open();
  }
  catch (Exception e)
  {
     print(e.getMessage());
  }
 
}


public void midiPlay(File f)
{
  try {
    Sequence music = MidiSystem.getSequence(f);
    player.setSequence(music);
    player.start();
  }
  catch (Exception e){
    print(e.getMessage());
  }
  
  
  
}

public void draw(){
  background(0);
  text(midiFiles[0].getName(),100,100);
  
}
  
  
  


  
