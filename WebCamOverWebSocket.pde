// WebSocketライブラリ
import muthesius.net.*;
import org.webbitserver.*;


// 画像圧縮とデータ出力
import javax.imageio.*;
import java.awt.image.*; 
import java.io.*;

// Base64エンコーダー
import org.apache.commons.codec.binary.*;

// Webカメラ
import processing.video.*;

// WebSocket
WebSocketP5 ws;

// 描画
ArrayList<PVector> lines;

// フォント
PFont font;

// Webカメラ
Capture camera;


void setup() {
  size(320, 240);
  smooth();
  font = createFont("Monaco", 20);
  textFont(font);
  lines = new ArrayList<PVector>();
  ws = new WebSocketP5(this, 8080);
  camera = new Capture(this,width,height,30);
  camera.start();
}

void draw() {
  
  if(camera.available() == true){
    camera.read();
  }
  
  /*
  if( !mousePressed && lines.size() > 0){
    lines.remove(0);
  }
  */
  
  background(127);
  noStroke();
  fill(255);

  image(camera,0,0);

  text("FPS: "+frameRate, 10, 35);
  
  // 落書き
  noFill();
  stroke(255);
  strokeWeight(3);
  beginShape();
  for(int i = 0; i < lines.size(); i++){
    curveVertex(lines.get(i).x, lines.get(i).y);
  }
  endShape();
  
  // 画面を送信
  broadcastOutput();
}

void mouseDragged(){
  
  lines.add( new PVector(mouseX, mouseY) );
  
}

void broadcastOutput() {
  // We need a buffered image to do the JPG encoding
  int w = width;
  int h = height;
  BufferedImage b = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);

  // Transfer pixels from localFrame to the BufferedImage
  loadPixels();
  b.setRGB( 0, 0, w, h, pixels, 0, w);

  // Need these output streams to get image as bytes for UDP
  ByteArrayOutputStream baStream = new ByteArrayOutputStream();
  BufferedOutputStream bos = new BufferedOutputStream(baStream);

  // JPG compression into BufferedOutputStream
  // Requires try/catch

  try {
    ImageIO.write(b, "jpg", bos);
  } 
  catch (IOException e) {
    println("could not encode image");
    return;
  }

  // Get the byte array, which we will send out via UDP!
  try {
    String out = new String(Base64.encodeBase64(baStream.toByteArray(), false));
    ws.broadcast("data:image/*;base64,"+out);
  } 
  catch(Exception e) {
    e.printStackTrace();
  }
}

