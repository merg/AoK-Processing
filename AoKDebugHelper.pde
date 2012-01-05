class AokDebugHelper {
  byte[] createTestBuffer(int buffer_size) {
    byte[] b = new byte[buffer_size];

    for (int i = 0; i < buffer_size; i+=7) {
      if ((i+6) < buffer_size) {
        b[i] = 0x1c;
        b[i+1] = (byte)random(0, 192);
        b[i+2] = (byte)random(-0, 150);
        b[i+3] = 0;
        b[i+4] = 0;
        b[i+5] = 0;
        b[i+6] = (byte) ( (b[i+1]& 0xff) ^ (b[i+2] &  0xff) ^ (b[i+3] & 0xff) ^ (b[i+4]& 0xff) ^ (b[i+5]& 0xff));
      }
    }
    return b;
  }
}

