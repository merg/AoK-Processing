import processing.serial.*;

class AoKCommand {
  private Serial port;

  AoKCommand(Serial port) {
    this.port = port;
  }

  public void debugOn() {
    port.write(debug_on);
  }

  public void debugOff() {
    port.write(debug_off);
  }

  public void reset() {
    port.write(reset);
  }

  // ARM-o-Kopter 'instruction' byte arrays
  byte[] reset = {
    0x63, 0x07
  };
  byte[] debug_off = {
    0x63, 0x01
  };
  byte[] debug_on = {
    0x63, 0x02
  };

  // Enable GPS debug value
  byte[] aok_debug_gps_fix = {
    0x67, 20
  };
}

