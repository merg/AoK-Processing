/*
  Contains a single 'complete' AoKDebug info frame.
 */
class AoKDebugInfoFrame {
  private byte debug_id;
  private String descr;
  private int value;
  private boolean hasValue;
  private long position;

  AoKDebugInfoFrame(byte debug_id, int value, String descr) {
    this.debug_id = debug_id;
    this.descr = descr;
    this.value = value;
    this.position = -1;
    hasValue = false;
  }

  public void setValue(int value) {
    this.value = value;
    hasValue = true;
  }

  public void setPosition(long position) {
    this.position = position;
  }

  public String toString() {
    String s = debug_id + ": " + descr + " -> " + value;
    if (position >=0) {
      s+="  [" + position + "]";
    }

    return s;
  }

  public boolean hasValue() {
    return hasValue;
  }
}
