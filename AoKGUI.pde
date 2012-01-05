import controlP5.*;


class AoKGUI {
  ControlP5 controlP5;
  ControlWindow cW;
  ControlWindowCanvas cc;
  Tab tD;
  Tab tP;

  AoKGUI(ControlP5 controlP5) {
    this.controlP5 = controlP5;
  }

  void init() {
    cW = controlP5.addControlWindow("AoK Control Panel", 800, 40, 400, 400, 30);

    cW.setUpdateMode(ControlWindow.NORMAL);

    cW.tab("default").setLabel("Debug");
    cW.tab("default").setId(1);
    cW.tab("default").activateEvent(true);
    tD = cW.tab("default");
    createDebug();


    cW.tab("Parameters").setId(2);
    cW.tab("Parameters").activateEvent(true);


    createParameters();
  }

  void createDebug() {   
    Button b =controlP5.addButton("Save", 0, 155, 25, 100, 19);
    b.setId(102);   
    b.setGroup(tD);

    Toggle t = controlP5.addToggle("Debug On?", 5, 25, 20, 20);
    t.setId(100);
    t.setGroup(tD);

    t = controlP5.addToggle("Recording On?", 65, 25, 20, 20);
    t.setId(101);
    t.setGroup(tD);
  }

  void createParameters() {
  }
}


public void controlEvent(ControlEvent theEvent) {
  println(theEvent.controller().id()+"  /  "+
    //theEvent.controller()+"  /  "+
  theEvent.controller().value()
    );

  switch(theEvent.controller().id()) {
    case(100) : 
    if (1 == (int)theEvent.controller().value()) {
      cmd.debugOn();
    } 
    else {
      cmd.debugOff();
    }
    break;
    case(101) : 

    if (1 == (int)theEvent.controller().value()) {
      dp.startRecording();
    } 
    else {
      dp.stopRecording();
    }
    break;
    
    case(102) :    
    dp.writeRecording();
    break;
  }
}

