
/*
 Responsible for parsing the data-stream, wether it comes via the serial port or a file.
 Data is read into a buffer, a check is done on the 0x1c of a AoK debug frame:
 0x1c NUM B1 B2 B3 B4 CRC
 */
class AoKDataParser {
  byte[] buffer = null;
  int buffer_size = 0;
  byte[] frame = new byte[7];
  int fi = 0;
  long last_frame_pos = -1;
  AoKDebugInfoFrame[] debug_frames = null;  
  long stat_parsed = 0;
  long stat_invalid_crc = 0;
  long stat_invalid_debug_id = 0;
  long stat_bytes_processed = 0;
  boolean recordToFile = false;
  byte[] fileBuffer;
  int fileBufferIndex;

  AoKDataParser(int buffer_size) {
    this.buffer_size = buffer_size;
    resetStats();
    loadDebugDescr();
  }

  AoKDebugInfoFrame[] getDebugInfoFrames() {
    return debug_frames;
  }

  void startRecording() {
    println("---> startRecording()");    
    fileBuffer = new byte[1024*1024*1];
    fileBufferIndex = 0;
    recordToFile=true;
  }

  void stopRecording() {
    println("---> stopRecording(): " + fileBufferIndex);    
    recordToFile=false;
  }

  synchronized void writeRecording() {
    println("---> writeRecording()");
    if ((fileBufferIndex > 0) ) {
      String filename = "./logged/AoK-" + year() + "" + month() + "" + day() + "-" + hour() + "" + minute() + "" + second() + ".AoK-bin";
      println(fileBufferIndex + "bytes -> " + filename);

      byte[] ad = new byte[fileBufferIndex];
      for (int i =0; i < fileBufferIndex; i++) {      
        ad[i] = fileBuffer[i];
      }
      saveBytes(filename, ad);
    }
  }

  void loadDebugDescr() {
    // Dirty, quickly read all the strings (max 256) in a temp array
    String[] temp_strings = new String[256];
    int i = 0;
    BufferedReader reader = createReader("legend_debug.txt");
    String s = "";
    while ( (s != null) ) {
      try {
        s = reader.readLine();        
        temp_strings[i] = s;         
        i++;
      } 
      catch (IOException e) {    
        s=null;
      }
    }
    int debug_descr_size=i-1;

    // Then create and initialize the debug frames
    debug_frames = new AoKDebugInfoFrame[debug_descr_size];
    for (i = 0; i < debug_frames.length; i++) {
      debug_frames[i] = new AoKDebugInfoFrame((byte)i, 0xff, temp_strings[i]);
    }

    println("# debug items: " + debug_descr_size);
  }

  public void printDebugFrames() {
    for (int i = 0; i < debug_frames.length; i++) {
      if (debug_frames[i].value != 0xff) {
        println(debug_frames[i].toString());
      }
    }
  }

  public void resetStats() {
    println("Reset stats");
    stat_parsed = 0;
    stat_invalid_crc = 0;
    stat_invalid_debug_id = 0;
    stat_bytes_processed = 0;
  }

  public void printStats() {
    println("Bytes processed: " + stat_bytes_processed);
    println("Frames parsed: " + stat_parsed);
    println("Invalid CRC: " + stat_invalid_crc);
    println("Invalid debug_id: " + stat_invalid_debug_id);
  }


  int getBufferSize() {
    return buffer_size;
  }

  void printDebugFrame() {
    for (int i = 0; i < 7; i++) {
      print(binary(frame[i]) + " ");
    }
    println("");
  }

  void printBuffer() {
    for (int i = 0; i < buffer_size; i++) {
      print(hex(buffer[i]) + " ");
      if (((i % 20) == 0) ) {
        println("");
      }
    }
    println("");
  }

  void parseDebugFrame() {
    stat_parsed++;

    int xor = frame[1] ^ frame[2] ^ frame[3] ^ frame[4] ^ frame[5];

    if (xor == frame[6]) {
      int val = 0;
      val = (val << 8)+ (int)(frame[5] & 0xff);
      val = (val << 8)+ (int)(frame[4] & 0xff );
      val = (val << 8)+ (int)(frame[3] & 0xff );
      val = (val << 8)+ (int)(frame[2] & 0xff );

      if ((frame[1] >= 0) && (frame[1] < debug_frames.length)) {
        // Set the actual value
        debug_frames[frame[1]].setValue(val);
        debug_frames[frame[1]].setPosition(last_frame_pos);
        print(frame[1] + " ["  + val + "] ");
        printDebugFrame();
      } 
      else {
        stat_invalid_debug_id++;
        print("Invalid debug id: " + frame[1] + " frame: ");
        printDebugFrame();
      }
    } 
    else {
      stat_invalid_crc++;
      print("CRC check failed, frame: ");
      printDebugFrame();
    }

    fi=0;
  }

  void parseBuffer(byte[] buffer) {    
    this.buffer = buffer;    

    //println("recordToFile: "+recordToFile);
    //println("fileBuffer: "+fileBuffer); 
    //println("fileBufferIndex: "+fileBufferIndex);

    if (recordToFile &&  ((fileBufferIndex + buffer.length) < fileBuffer.length )) {
      for (int i = 0; (i < buffer.length) ; i++) {
        fileBuffer[fileBufferIndex++]=buffer[i];
      }
    }

    int i = 0;
    // Check if there was a frame being read which rolled over to this buffer.
    if ((fi != 0)) {
      for (; fi < 7; fi++) {
        frame[fi] = buffer[i++];
      }
      parseDebugFrame();
    } 
    else {
      i = 0;
    }

    while (i < buffer_size) {
      if (buffer[i] == 0x1c) {
        // Potential header frame read, assume next 6 bytes are from a debug frame
        last_frame_pos = i + stat_bytes_processed;

        fi = 0;
        for (; (fi < 7) && (i < buffer_size); fi++, i++) {
          frame[fi] = buffer[i];
        }
        if (fi == 7) {
          parseDebugFrame();
          fi = 0;
        }
      } 
      else {
        i++;
      }
    }
    stat_bytes_processed+=buffer.length;
  }
}

