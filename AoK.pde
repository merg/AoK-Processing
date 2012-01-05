import processing.serial.*;
import controlP5.*;

String aok_com = "/dev/tty.usbserial-A900J3IG"; // update this to your COM port, e.g. COM4 on Windows
Serial port;
PFont font;
AoKDataParser dp = null;
AoKCommand cmd = null;
AokDebugHelper dh = null;
AoKGUI gui = null;

void setup() {
  size(800, 600);
  dp = new AoKDataParser(256);
  gui = new AoKGUI(new ControlP5(this));
  gui.init();
  font = loadFont("ArialNarrow-13.vlw");
  textFont(font, 13);  
  
  port = new Serial(this, aok_com, 38400, 'N', 8, 1.0);  
  port.buffer(dp.getBufferSize());
  
  dh = new AokDebugHelper();
  cmd = new AoKCommand(port);
}

void draw() {  
  //byte[] b = dh.createTestBuffer(dp.getBufferSize());
  //dp.parseBuffer(b);
  //dp.printDebugFrames();

  background(222);
  smooth();
  int rows = 0;
  int cols = 0;

  AoKDebugInfoFrame[] df = dp.getDebugInfoFrames();

  for (int i = 0; i < df.length; i++) {
    if (df[i].hasValue()) {      
      fill(150, 150, 250);
      text(df[i].descr, 25+(cols*200), 25+(rows*15));

      fill(50, 250, 50);
      text(df[i].value, 100+25+(cols*200), 25+(rows*15));
      rows++;
      if (rows > 30) {
        cols++;
        rows=0;
      }
    }
  }

  fill(200, 40, 200);
  text("Bytes processed: " + dp.stat_bytes_processed, 25, 535);
  text("Frames parsed: " + dp.stat_parsed, 25, 550);
  text("Invalid CRC: " + dp.stat_invalid_crc, 25, 565);
  text("Invalid debug_id: " + dp.stat_invalid_debug_id, 25, 580);
}

void serialEvent (Serial port)
{
  byte[] buffer = new byte[dp.getBufferSize()];
  for (int i=0; i < buffer.length; i++) {
    buffer[i] = 0xf;
  }  
  port.readBytes(buffer);
  dp.parseBuffer(buffer);
}

