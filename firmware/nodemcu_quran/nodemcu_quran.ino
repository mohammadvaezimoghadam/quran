/*
  =============================================================================
  Smart Quran Controller - NodeMCU Firmware
  Dramatic Full-Range OLED Brightness (Contrast + Pre-charge + VCOMH Control)
  =============================================================================
  Access Point Info:
    - SSID: Quran_Smart_NodeMCU
    - Password: 1234
    - Default IP: 192.168.4.1
  =============================================================================
  Available API Routes:
    - GET /                     -> Device JSON Status
    - GET /set_page?page=150    -> Set active Quran page (1..604)
    - GET /brightness?value=20  -> Set hardware brightness (1..100 or 1..255)
    - GET /set_brightness?level=20
    - GET /power?state=1        -> Turn OLED screen ON (1) or OFF (0)
    - GET /mode?mode=0          -> 0: Left QR+Text, 1: Big Text, 2: Dual QR
    - GET /reboot               -> Soft restart ESP8266 board
  =============================================================================
*/

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <qrcode.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET    -1
#define SCREEN_ADDRESS 0x3C

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
ESP8266WebServer server(80);

int currentPage = 1;
int lastDrawnPage = -1; // Frame lock tracker to prevent unnecessary OLED rebuilds
bool oledAvailable = false;
bool isDisplayPoweredOn = true;
int currentBrightness = 30; // Default ~30% for clear camera focus + comfortable viewing
int currentDisplayMode = 0; // 0: Left QR + Right Text, 1: Full-Screen Page Text, 2: Dual QR Mode

// Full-Range Hardware Brightness control (Modifies Contrast 0x81, Pre-charge 0xD9, VCOMH 0xDB)
void setOledBrightness(int level) {
  if (!oledAvailable) return;

  // Handle inputs from both 1..100 (percentage) and 1..255
  level = constrain(level, 1, 255);
  currentBrightness = level;

  int pct = (level <= 100) ? level : map(level, 1, 255, 1, 100);

  // 1. Contrast Control (0x81): 0x01 (Ultra Dim) to 0xFF (Max Current)
  uint8_t contrastVal = map(pct, 1, 100, 0x01, 0xFF);
  display.ssd1306_command(SSD1306_SETCONTRAST);
  display.ssd1306_command(contrastVal);

  // 2. Pre-charge Period (0xD9): Phase 1 (1..15) & Phase 2 (1..15)
  // Low pre-charge reduces pixel glow dramatically; High pre-charge maximizes pixel output!
  uint8_t phase1 = map(pct, 1, 100, 1, 15);
  uint8_t phase2 = map(pct, 1, 100, 1, 15);
  uint8_t prechargeVal = (phase2 << 4) | phase1;
  display.ssd1306_command(SSD1306_SETPRECHARGE);
  display.ssd1306_command(prechargeVal);

  // 3. VCOMH Deselect Level (0xDB): 0x00 (~0.65xVcc Dim) to 0x40 (~0.83xVcc Bright)
  uint8_t vcomhVal = map(pct, 1, 100, 0x00, 0x40);
  display.ssd1306_command(SSD1306_SETVCOMDETECT);
  display.ssd1306_command(vcomhVal);

  Serial.print("[OLED] Full-Range Hardware Brightness set to: ");
  Serial.print(pct);
  Serial.println("%");
}

// Turn OLED display ON or OFF
void setOledPower(bool on) {
  if (!oledAvailable) return;
  isDisplayPoweredOn = on;
  if (on) {
    display.ssd1306_command(SSD1306_DISPLAYON);
    Serial.println("[OLED] Display ON");
  } else {
    display.ssd1306_command(SSD1306_DISPLAYOFF);
    Serial.println("[OLED] Display OFF");
  }
}

// Render QR & Page Info according to currentDisplayMode
void drawPageQRCode(int pageNum, bool force = false) {
  if (!oledAvailable || !isDisplayPoweredOn) return;

  // HARDWARE FRAME LOCK: Skip rebuild if page didn't change and not forced
  if (!force && pageNum == lastDrawnPage) {
    Serial.print("[OLED] Page ");
    Serial.print(pageNum);
    Serial.println(" already locked in RAM. Skipping rebuild!");
    return;
  }

  lastDrawnPage = pageNum;

  char qrPayload[16];
  snprintf(qrPayload, sizeof(qrPayload), "%d", pageNum);

  Serial.print("[NodeMCU] Drawing Frame for Payload: ");
  Serial.println(qrPayload);

  // Version 1 QR Code (21x21 modules)
  QRCode qrcode;
  uint8_t qrcodeData[qrcode_getBufferSize(1)];
  qrcode_initText(&qrcode, qrcodeData, 1, ECC_LOW, qrPayload);

  display.clearDisplay();

  if (currentDisplayMode == 1) {
    // Mode 1: Text-only Big Page Number
    display.setTextSize(1);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(22, 10);
    display.print("HOLY QURAN");

    display.setCursor(42, 24);
    display.print("PAGE");

    display.setTextSize(3);
    display.setCursor(36, 38);
    display.print(pageNum);
  } else if (currentDisplayMode == 2) {
    // Mode 2: Dual QR Codes
    int scale = 2;
    int qrSize = qrcode.size * scale; // 42 px
    int quietPadding = 4;

    int offsetXs[2] = {11, 75};
    int startY = (SCREEN_HEIGHT - (qrSize + (quietPadding * 2))) / 2;

    for (int i = 0; i < 2; i++) {
      int startX = offsetXs[i];
      display.fillRect(startX, startY, qrSize + (quietPadding * 2), qrSize + (quietPadding * 2), SSD1306_WHITE);
      for (uint8_t y = 0; y < qrcode.size; y++) {
        for (uint8_t x = 0; x < qrcode.size; x++) {
          if (qrcode_getModule(&qrcode, x, y)) {
            display.fillRect(startX + quietPadding + (x * scale), startY + quietPadding + (y * scale), scale, scale, SSD1306_BLACK);
          }
        }
      }
    }
  } else {
    // Mode 0 (Default): LARGER 54x54 px High-Contrast QR Code (Left) + Page Text (Right)
    int scale = 2; // 2x2 pixels per module -> 42x42 px
    int qrSize = qrcode.size * scale; // 42 px
    int quietPadding = 6; // LARGER 54x54 px Quiet Zone Box -> Covers height Y: 5 to 59 px

    int startX = 4;
    int startY = (SCREEN_HEIGHT - (qrSize + (quietPadding * 2))) / 2; // 5 px

    // 1. Solid White Quiet Zone Box
    display.fillRect(startX, startY, qrSize + (quietPadding * 2), qrSize + (quietPadding * 2), SSD1306_WHITE);

    // 2. Black QR Modules over White Quiet Zone
    for (uint8_t y = 0; y < qrcode.size; y++) {
      for (uint8_t x = 0; x < qrcode.size; x++) {
        if (qrcode_getModule(&qrcode, x, y)) {
          display.fillRect(startX + quietPadding + (x * scale), startY + quietPadding + (y * scale), scale, scale, SSD1306_BLACK);
        }
      }
    }

    // 3. Right Side: Clean Typography & Large Page Number
    display.setTextSize(1);
    display.setTextColor(SSD1306_WHITE);

    display.setCursor(64, 10);
    display.print("QURAN");

    display.setCursor(64, 22);
    display.print("PAGE:");

    display.setTextSize(2);
    display.setCursor(64, 38);
    display.print(pageNum);
  }

  display.display();
}

// Add CORS headers to allow cross-origin requests
void sendCORSResponse(int code, const String& contentType, const String& content) {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.sendHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  server.sendHeader("Access-Control-Allow-Headers", "*");
  server.send(code, contentType, content);
}

// Endpoint: GET / (Health Check & Full Status)
void handleRoot() {
  String json = "{\"status\":\"online\",\"device\":\"Quran_Smart_NodeMCU\",\"page\":" + String(currentPage) + ",\"brightness\":" + String(currentBrightness) + ",\"mode\":" + String(currentDisplayMode) + ",\"power\":" + (isDisplayPoweredOn ? "true" : "false") + "}";
  sendCORSResponse(200, "application/json", json);
  Serial.println("[HTTP 200] Full status requested on /");
}

// Endpoint: GET /set_page?page=150
void handleSetPage() {
  if (server.hasArg("page")) {
    int p = server.arg("page").toInt();
    if (p >= 1 && p <= 604) {
      currentPage = p;
      drawPageQRCode(currentPage, false);
      sendCORSResponse(200, "text/plain", "OK");
      Serial.print("[HTTP 200] Page set to: ");
      Serial.println(currentPage);
      return;
    }
  }
  sendCORSResponse(400, "text/plain", "Invalid Page Parameter");
}

// Endpoint: GET /brightness?value=20 or /set_brightness?level=20
void handleSetBrightness() {
  int lvl = -1;
  if (server.hasArg("level")) lvl = server.arg("level").toInt();
  else if (server.hasArg("value")) lvl = server.arg("value").toInt();

  if (lvl >= 1 && lvl <= 255) {
    setOledBrightness(lvl);
    sendCORSResponse(200, "text/plain", "OK");
    return;
  }
  sendCORSResponse(400, "text/plain", "Invalid Brightness Parameter");
}

// Endpoint: GET /power?state=1 or /power?state=0
void handleSetPower() {
  if (server.hasArg("state")) {
    int st = server.arg("state").toInt();
    setOledPower(st == 1);
    if (isDisplayPoweredOn) {
      drawPageQRCode(currentPage, true);
    }
    sendCORSResponse(200, "text/plain", "OK");
    return;
  }
  sendCORSResponse(400, "text/plain", "Invalid Power Parameter");
}

// Endpoint: GET /mode?mode=0 (0: Left QR+Text, 1: Big Text, 2: Dual QR)
void handleSetMode() {
  if (server.hasArg("mode")) {
    int m = server.arg("mode").toInt();
    if (m >= 0 && m <= 2) {
      currentDisplayMode = m;
      drawPageQRCode(currentPage, true);
      sendCORSResponse(200, "text/plain", "OK");
      return;
    }
  }
  sendCORSResponse(400, "text/plain", "Invalid Mode Parameter");
}

// Endpoint: GET /reboot
void handleReboot() {
  sendCORSResponse(200, "text/plain", "Rebooting NodeMCU...");
  Serial.println("[HTTP 200] Board reboot requested...");
  delay(500);
  ESP.restart();
}

// Endpoint: NotFound & OPTIONS preflight
void handleNotFound() {
  if (server.method() == HTTP_OPTIONS) {
    sendCORSResponse(200, "text/plain", "OK");
    return;
  }
  sendCORSResponse(404, "text/plain", "Endpoint Not Found");
}

void setup() {
  Serial.begin(115200);
  delay(300);

  Serial.println("\n----------------------------------------");
  Serial.println("  Smart Quran NodeMCU Server Initializing");
  Serial.println("----------------------------------------");

  // Initialize I2C Bus
  Wire.begin(D2, D1);
  Wire.setClock(100000);

  if (display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    oledAvailable = true;

    // HARDWARE FIX 1: Boost internal OLED refresh rate to MAX (~200Hz) to eliminate scanlines
    display.ssd1306_command(SSD1306_SETDISPLAYCLOCKDIV);
    display.ssd1306_command(0xF0);

    // HARDWARE FIX 2: Set Full-Range Initial Brightness (30%)
    setOledBrightness(30);

    Serial.println("[OLED] Display initialized with Full-Range Brightness & 200Hz Refresh Rate!");
  } else {
    oledAvailable = false;
    Serial.println("[OLED] Warning: Display not detected at 0x3C.");
  }

  // Start Access Point (SoftAP)
  WiFi.mode(WIFI_AP);
  IPAddress local_IP(192, 168, 4, 1);
  IPAddress gateway(192, 168, 4, 1);
  IPAddress subnet(255, 255, 255, 0);

  WiFi.softAPConfig(local_IP, gateway, subnet);
  if (WiFi.softAP("Quran_Smart_NodeMCU", "1234")) {
    Serial.println("[AP] Access Point Started!");
    Serial.println("[AP] SSID: Quran_Smart_NodeMCU");
    Serial.print("[AP] IP: ");
    Serial.println(WiFi.softAPIP());
  } else {
    Serial.println("[AP] Error: Failed to start Access Point.");
  }

  // Bind Web Server Routes
  server.on("/", handleRoot);
  server.on("/set_page", handleSetPage);
  server.on("/set_brightness", handleSetBrightness);
  server.on("/brightness", handleSetBrightness);
  server.on("/power", handleSetPower);
  server.on("/mode", handleSetMode);
  server.on("/reboot", handleReboot);
  server.onNotFound(handleNotFound);

  server.begin();
  Serial.println("[HTTP] Web Server listening on port 80");
  Serial.println("----------------------------------------\n");

  // Draw initial Page 1 QR Code once (forced initial draw)
  drawPageQRCode(1, true);
}

void loop() {
  server.handleClient();
}
