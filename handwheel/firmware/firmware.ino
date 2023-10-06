#include <Adafruit_GFX.h>
#include <Adafruit_GrayOLED.h>
#include <Adafruit_SPITFT.h>
#include <Adafruit_SPITFT_Macros.h>
#include <Adafruit_SSD1351.h>
#include <SPI.h>
#include <gfxfont.h>

// Screen dimensions
#define SCREEN_WIDTH  128
#define SCREEN_HEIGHT 128

// Used pins
#define POT1_PIN A0
#define POT2_PIN A1
#define DC_PIN   4
#define CS_PIN   5

// Color definitions
#define	BLACK           0x0000
#define	BLUE            0x001F
#define	RED             0xF800
#define	GREEN           0x07E0
#define CYAN            0x07FF
#define MAGENTA         0xF81F
#define YELLOW          0xFFE0
#define WHITE           0xFFFF

Adafruit_SSD1351 tft = Adafruit_SSD1351(SCREEN_WIDTH, SCREEN_HEIGHT, &SPI, CS_PIN, DC_PIN, -1);

const char* AXIS[5] = {"X", "Y", "Z", "A", " "};
const uint16_t* STEP[5] = {1, 10, 100, 1000, 0};

char* axis[2]       = {"", "X"};
uint16_t step[2]    = {0, 100};
uint16_t spindle[2] = {0, 5000};
uint16_t speed[2]   = {0, 100};
char* workspace[2]  = {"", "G53"};

void clearText(int16_t x, int16_t y, uint16_t w, uint16_t h, uint16_t color) {
  tft.fillRect(x, y, w, h, color);
  tft.setCursor(x+2, y+3);
}

bool updateText(int16_t x, int16_t y, uint16_t color, uint16_t* value, uint16_t w = 128, uint16_t h = 20) {
  if (value[0] != value[1]) {
    clearText(x, y, w, h, color);
    value[0] = value[1];
    return true;
  }
  return false;
}

bool updateText(int16_t x, int16_t y, uint16_t color, char** value, uint16_t w = 128, uint16_t h = 20) {
  if (strcmp(value[0], value[1]) != 0) {
    clearText(x, y, w, h, color);
    value[0] = value[1];
    return true;
  }
  return false;
}

void PrintScreen(bool initial) {
  tft.setTextSize(6);

  if (updateText(0, 0, BLACK, axis, 64, 45)) {
    tft.print(axis[1]);
  }

  tft.setTextColor(BLACK);
  tft.setTextSize(2);
  if (updateText(90, 0, WHITE, workspace)) {
    tft.print(workspace[1]);
  }

  tft.setTextColor(WHITE);
  tft.setTextSize(2);

  if (updateText(20, 60, BLACK, step)) {
    tft.print(step[1] / 10.0, 1);
    if (initial) {
      tft.fillTriangle(2, (60+16), 12, (60+16), 7, (60+8), WHITE);
      tft.fillTriangle(2+3, (60+16)-2, 12-3, (60+16)-2, 7, (60+8)+3, BLACK);
    }
  }
  if (updateText(20, 80, BLACK, speed)) {
    tft.print(speed[1]);
    if (initial) {
      tft.setCursor(0, tft.getCursorY());
      tft.print("S");
    }
  }
  if (updateText(20, 100, BLACK, spindle)) {
    tft.print(spindle[1]);
    if (initial) {
      tft.setCursor(0, tft.getCursorY());
      tft.print("M");
    }
  }
}

void setup(void) {
  Serial.begin(9600);

  tft.begin();
  tft.fillScreen(BLACK);
  PrintScreen(true);

  Serial.println("init done");
}

void loop() {
  axis[1] = AXIS[(int)(analogRead(POT1_PIN) / 150) - 1];
  step[1] = STEP[(int)(analogRead(POT2_PIN) / 150) - 1];

  PrintScreen(false);
  //delay(100);
}
