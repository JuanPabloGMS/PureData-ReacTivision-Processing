import oscP5.*;
import netP5.*;
import java.util.concurrent.ThreadLocalRandom;

int x_i, r, max_r, max_x, p;
float volume;
String ip;
int port_send, port_receive;
boolean dir, w_r, random;
int x_spacing;

OscP5 oscP5_send, oscP5_receive;
NetAddress direccion_send, direccion_receive;

void setup(){
  size(800,800);
  background(0);
  x_i = 0;
  r = 0;
  p = 1;
  max_r = 0;
  x_spacing = 0;
  max_x = 200;
  volume = 0.0;
  dir = true;
  w_r = true;
  random = false;
  
  ip = "127.0.0.1";
  port_send = 5050;
  port_receive = 5051;
  
  oscP5_send = new OscP5(this, port_send);
  oscP5_receive = new OscP5(this, port_receive);
  direccion_send = new NetAddress(ip,port_send);
  direccion_receive = new NetAddress(ip,port_receive);
  
}


void draw(){
  background(0);
  strokeCap(ROUND);
  int R = 255, G = 0, B = 0;
  if(random){
    R = ThreadLocalRandom.current().nextInt(0, 255 + 1);
    G = ThreadLocalRandom.current().nextInt(0, 255 + 1);
    B = ThreadLocalRandom.current().nextInt(0, 255 + 1);
  }
  stroke(R,G,B);
  strokeWeight(3);
  switch(p){
    case 1:
    for(int i = 0; i < 300; i++){
      point(x_i+300+x_spacing*r,sin(radians(x_i))*r+300);

      if (dir){
       x_i+=PI;
      }else{
        x_i-=PI;
      }
     if(x_i >= max_x*PI){
       dir = false;
     }else if(x_i <= -max_x*PI){
       dir = true;
     }
    }
    break;
    case -1:
    for(int i = 0; i < 300; i++){
      point(x_i+300+x_spacing*r,cos(radians(x_i))*r+300);

      if (dir){
       x_i+=PI;
      }else{
        x_i-=PI;
      }
     if(x_i >= max_x*PI){
       dir = false;
     }else if(x_i <= -max_x*PI){
       dir = true;
     }
    }
    break;
 }
 p*=-1;
 if (max_x < 200*PI){
   max_x += PI/6;
 }else if(max_x > -200*PI){
   max_x -= PI/6;
 }
 if(w_r){
   r-=10;
 }else{
   r+=10;
 }
 if(r <1){
   w_r = false;
 }else if(r >= max_r){
   w_r = true;
 }
 //println(max_r);
}

void oscEvent(OscMessage m){
 
  if(m.checkAddrPattern("/r")){
    if(m.checkTypetag("f")){
      max_r = (int)m.get(0).floatValue();
      return;
    }
  }else if(m.checkAddrPattern("/p")){
    if(m.checkTypetag("i")){
      max_r = m.get(0).intValue();
      r = m.get(0).intValue();
    }
  }else if(m.checkAddrPattern("/c")){
    random = true;
  }else if(m.checkAddrPattern("/c1")){
    random = false;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  OscMessage m = new OscMessage("/processing");
  volume+=e/10;
  max_r = (int)(400*volume);
  m.add(volume);
  oscP5_send.send(m,direccion_send);
  println(e);
}

void mousePressed(){
  if(mouseButton == LEFT && random){
    random = false;
    OscMessage m = new OscMessage("/next_track");
    m.add(1);
    oscP5_send.send(m,direccion_send);
  }else if (mouseButton == LEFT){
    random = true;
    OscMessage m = new OscMessage("/next_track");
    m.add(3);
    oscP5_send.send(m,direccion_send);
  }
  if(mouseButton == RIGHT){
    OscMessage m = new OscMessage("/stop");
    m.add(2);
    oscP5_send.send(m,direccion_send);
  }
}
