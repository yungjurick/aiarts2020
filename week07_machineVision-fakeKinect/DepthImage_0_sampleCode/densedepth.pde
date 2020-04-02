// import Runway library
import com.runwayml.*;
// reference to runway instance
RunwayHTTP runway;


// periocally to be updated using millis()
int lastMillis;
// how often should the above be updated and a time action take place ?
int waitTime = 1000;
// status
String status = "waiting ~"+(waitTime/1000)+"s";

PImage depthImage;

void setup_fakeKinect() {
  // setup Runway
  runway = new RunwayHTTP(this);
  // update manually
  runway.setAutoUpdate(false);
  // setup camera
  camera = new Capture(this, 600, 400, Capture.list()[0]);
  camera.start();
  // setup timer
  lastMillis = millis();
}



void update_fakeKinect() {
  // update timer
  int currentMillis = millis();
  // if the difference between current millis and last time we checked past the wait time
  if (currentMillis - lastMillis >= waitTime) {
    status = "sending image to Runway";
    // call the timed function
    sendFrameToRunway();
    // update lastMillis, preparing for another wait
    lastMillis = currentMillis;
  }
}


void sendFrameToRunway() {
  // nothing to send if there's no new camera data available
  if (camera.available() == false) {
    return;
  }
  // read a new frame
  camera.read();
  // crop image to Runway input format (600x400)
  PImage image = camera.get(0, 0, 600, 400);
  // query Runway
  runway.query(image);
}

// this is called when new Runway data is available
void runwayDataEvent(JSONObject runwayData) {
  // point the sketch data to the Runway incoming data 
  String base64ImageString = runwayData.getString("depth_image");
  // try to decode the image from
  try {
    depthImage = ModelUtils.fromBase64(base64ImageString);
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  status = "received runway result";
}

// this is called each time Processing connects to Runway
// Runway sends information about the current model
public void runwayInfoEvent(JSONObject info) {
  println(info);
}
// if anything goes wrong
public void runwayErrorEvent(String message) {
  println(message);
}
