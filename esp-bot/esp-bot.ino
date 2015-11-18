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
<canvas id="c1" height="550" width="400"></canvas>
<br/>
<input type="text" id="t1" /><button id="b1">Draw</button>
<script>
var m=[],b1=document.getElementById("b1"),t1=document.getElementById("t1");c=document.getElementById("c1").getContext("2d"),c.clearRect(0,0,c.canvas.width,c.canvas.height),c.strokeStyle="#df4b26",c.lineJoin="round",c.lineWidth=1,c.translate(275,200),c.rotate(Math.PI),c.moveTo(0,0),b1.onclick=function(){var e=t1.value.split(" "),t=Number(e[1]);switch(e[0]){case"forward":c.lineTo(0,t),c.stroke(),c.translate(0,t),c.moveTo(0,0),m.push([0,t]);break;case"backward":c.lineTo(0,t),c.stroke(),c.translate(0,-t),c.moveTo(0,0),m.push([1,t]);break;case"left":c.rotate(-t*Math.PI/180),m.push([2,t]);break;case"right":c.rotate(t*Math.PI/180),m.push([3,t]);break;case"pen":"up"==e[1]?m.push([4,0]):m.push([4,1])}};
</script>
)=====";

ESP8266WebServer server(80);

void handleRoot() {
  if (server.method() == HTTP_GET) {
    server.send(200, "text/html", index_html);
  } else {
    Serial.println("Got the post");
    server.send(200, "text/html", "<h1>That was a post</h1>");
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
  server.begin();
  Serial.println("server started");
  EEPROM.begin(2048);
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
