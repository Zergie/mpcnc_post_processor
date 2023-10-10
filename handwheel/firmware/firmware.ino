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

void setup(void) {
  Serial.begin(9600);

  tft.begin();
  tft.fillScreen(RED);

  Serial.println("init done");
}

void loop() {
  // axis[1] = AXIS[(int)(analogRead(POT1_PIN) / 150) - 1];
  // step[1] = STEP[(int)(analogRead(POT2_PIN) / 150) - 1];

  char buffer[256];
  if (Serial.readBytes(buffer, 1) > 0) {
    switch (buffer[0]) {
      case 'r':
	{
	  Serial.readBytes(buffer, 10);
	  int16_t x  = (int16_t)buffer[0];
	  int16_t y  = (int16_t)buffer[2];
	  uint16_t w = (uint16_t)buffer[4];
	  uint16_t h = (uint16_t)buffer[6];
	  uint16_t c = (uint16_t)buffer[8];
	  tft.fillRect(x, y, w, h, c);
	}
	break;
      case 'f':
	{
	  Serial.readBytes(buffer, 2);
	  uint16_t c = (uint16_t)buffer[0];
	  tft.fillScreen(c);
	}
	break;
      case 's':
	{
	  Serial.readBytes(buffer, 1);
	  uint8_t s = (uint8_t)buffer[0];
	  tft.setTextSize(s);
	}
	break;
      case 'c':
	{
	  Serial.readBytes(buffer, 2);
	  uint16_t c = (uint16_t)buffer[0];
	  tft.setTextColor(c);
	}
	break;
      case '_':
	{
	  Serial.readBytes(buffer, 4);
	  int16_t x  = (int16_t)buffer[0];
	  int16_t y  = (int16_t)buffer[2];
	  tft.setCursor(x, y);
	}
	break;
      case 't':
	{
	  Serial.readBytes(buffer, 2);
	  uint16_t s = (uint16_t)buffer[0];

	  Serial.readBytes(buffer, s);
	  buffer[s] = '\0';
	  tft.print(buffer);
	}
	break;
    }
  }
}
