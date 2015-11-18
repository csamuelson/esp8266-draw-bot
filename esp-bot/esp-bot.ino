#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <EEPROM.h>


// const char *ssid = "robot";
// const char *password = "password";
const char *ssid = "rewscorner";
const char *password = "samuelson123";
int address = 0;
byte value;

const char index_html[] PROGMEM = R"=====(
<h1>robot</h1>
<button id='b3'>Start</button><button id='b4'>Stop</button><br/>  
<canvas id="c1" height="550" width="400"></canvas>
<br/>
  <input type="text" id="t1" /><button id="b1">Draw</button>
  <br/>
  <button id="b2">Send</button>
<script>
var m = [];
var b1=document.getElementById('b1');
var b2=document.getElementById('b2');
var b3=document.getElementById('b3');
var b4=document.getElementById('b4');
var t1=document.getElementById('t1');
document.onkeydown = function (e) {
  var kc = e ? (e.which ? e.which : e.keyCode) : event.keyCode;
  if (kc == 13) {
    dw();
  }
}
c = document.getElementById('c1').getContext('2d');
c.clearRect(0, 0, c.canvas.width, c.canvas.height);
c.strokeStyle = "#df4b26";
c.lineJoin = "round";
c.lineWidth = 1;
c.translate(275,200);
c.rotate(Math.PI);
c.moveTo(0,0);
b2.onclick=function(){
  var x = new XMLHttpRequest();
  x.open('POST', '/');
  x.send(JSON.stringify(m));
};

var dw =function(){
  var r=t1.value.split(" ");
  var d=Number(r[1]);
  switch(r[0]) {
  case "forward":
    c.lineTo(0,d);
    c.stroke();
    c.translate(0,d);
    c.moveTo(0,0);
    m.push([0,d]);
    break;
  case "backward":
    c.lineTo(0,-d);
    c.stroke();
    c.translate(0,-d);
    c.moveTo(0,0);
    m.push([1,d]);
    break;
  case "left":
    c.rotate(-d*Math.PI/180);
    m.push([2,d]);
    break;
  case "right":
    c.rotate(d*Math.PI/180);
    m.push([3,d]);
    break;
  case "pen":
    if(r[1]=="up"){
      m.push([4,0]);
    }else{
      m.push([4,1]);
    }
  }
  t1.value="";
};
b1.onclick=dw;
b3.onclick=function() {
  var x = new XMLHttpRequest();
  x.open('POST', '/start');
  x.send(null);
}
b4.onclick=function() {
  var x = new XMLHttpRequest();
  x.open('POST', '/stop');
  x.send(null);
}

</script>
)=====";

ESP8266WebServer server(80);

void handleRoot() {
  if (server.method() == HTTP_GET) {
    server.send(200, "text/html", index_html);
  } else {
    Serial.println(server.arg(0));
    // Parse the response
    parseTheData(server.arg(0));
    server.send(200, "text/json", "{'result':'ok'}");
  }
}

void setup() {
  // put your setup code here, to run once:
  delay(1000);
  Serial.begin(115200);
  Serial.println();
  /* You can remove the password parameter if you want the AP to be open. */
  // WiFi.softAP(ssid, password);
  // IPAddress myIP = WiFi.softAPIP();

  WiFi.begin(ssid, password);
  // Wait for connection
  while ( WiFi.status() != WL_CONNECTED ) {
    delay ( 500 );
    Serial.print ( "." );
  }
  IPAddress myIP = WiFi.localIP();
  
  Serial.print("IP: ");
  Serial.println(myIP);
  server.on("/", handleRoot);
  server.on("/start", []() {
    if (server.method() == HTTP_POST) {
       Serial.println("starting");
    }
  });

  server.on("/stop", []() {
    if (server.method() == HTTP_POST) {
      Serial.println("stopping");
    }
  });
  
  server.begin();
  Serial.println("server started");
  
  EEPROM.begin(2048);
}

void parseTheData(String data){
  int curPos = 0;
  int lastPos = 0;
  char mydata[data.length()+1];
  char *mydataPtr;
  mydataPtr = mydata;
  data.toCharArray(mydata, data.length()+1);
  Serial.println(++mydataPtr);
  char *token;
  char tokenChars[] = "[,]";
  token=strtok(mydata,tokenChars);
  while (token != NULL) {
    Serial.println(token);
    token = strtok(NULL,tokenChars);
    if (token != NULL) {
    int n = atoi(token);
    Serial.println(n);
    }
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  server.handleClient();
  // read a byte from the current address of the EEPROM
//  value = EEPROM.read(address);
//
//  Serial.print(address);
//  Serial.print("\t");
//  Serial.print(value, DEC);
//  Serial.println();
//
//  // advance to the next address of the EEPROM
//  address = address + 1;
//
//  // there are only 512 bytes of EEPROM, from 0 to 511, so if we're
//  // on address 512, wrap around to address 0
//  if (address == 2048)
//    address = 0;
//
//  delay(500);
}
