// Adafruit GFX Library
#include <Adafruit_GFX.h>
#include <Adafruit_GrayOLED.h>
#include <Adafruit_SPITFT.h>
#include <Adafruit_SPITFT_Macros.h>
#include <SPI.h>
#include <gfxfont.h>

#include <Adafruit_SSD1351.h>  // Adafruit SSD1351 Library

#include "PCF8575.h"  // PCF8575 Library by Rob Tillaart

#define ENCODER_OPTIMIZE_INTERRUPTS
#include <Encoder.h>  // Encoder Library by Paul Stoffregen

//#define DEBUG

// Screen dimensions
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 128

// Used pins
#define DC_PIN 4
#define CS_PIN 5

#define COL0_PIN 18
#define COL1_PIN 19
#define COL2_PIN 20
#define COL3_PIN 21

// Encoder A pins must be connected to a interrupt pin:
// pin 0 is interrupt 2 (INT2)
// pin 1 is interrupt 3 (INT3)
// pin 2 is interrupt 1 (INT1) // do not use, used by I2C
// pin 3 to interrupt 0 (INT0) // do not use, used by I2C
// pin 7 is interrupt 4 (INT6)
#define ENCODER_A 7
#define ENCODER_B 6

// The two other encoder are not connected to a interrupt pin
#define ENCODER_LA 9
#define ENCODER_LB 8
#define ENCODER_RA 10
#define ENCODER_RB 14

// Color definitions
#define BLACK 0x0000
#define BLUE 0x001F
#define RED 0xF800
#define GREEN 0x07E0
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define YELLOW 0xFFE0
#define WHITE 0xFFFF

Adafruit_SSD1351 tft = Adafruit_SSD1351(SCREEN_WIDTH, SCREEN_HEIGHT, &SPI, CS_PIN, DC_PIN, -1);
PCF8575 pcf = PCF8575(0x20);
Encoder knob(ENCODER_A, ENCODER_B);
Encoder knobLeft(ENCODER_LA, ENCODER_LB);
Encoder knobRight(ENCODER_RA, ENCODER_RB);

uint8_t row = 0;
uint8_t buttons[] = { 0, 0, 0, 0, 0, 0 };
#ifdef DEBUG
uint8_t debug_delay = 0;
#endif

void setup(void) {
  Serial.begin(9600);

  tft.begin();
  tft.fillScreen(RED);

  Wire.begin();

  pcf.begin();
  pcf.write16(0xFFFF);

  pinMode(COL0_PIN, INPUT_PULLUP);
  pinMode(COL1_PIN, INPUT_PULLUP);
  pinMode(COL2_PIN, INPUT_PULLUP);
  pinMode(COL3_PIN, INPUT_PULLUP);

  while(!Serial);
  delay(1000);
  Serial.println("init done");
}


void loop() {

  // readbuttons and rotary switches
  if (row > sizeof(buttons) - 1) row = 0;
  pcf.write16((uint16_t)~(1 << row));
  buttons[row] |= (1 ^ digitalRead(COL0_PIN))
               |  (1 ^ digitalRead(COL1_PIN)) << 1
               |  (1 ^ digitalRead(COL2_PIN)) << 2
               |  (1 ^ digitalRead(COL3_PIN)) << 3;
  row++;

  knob.read();
  knobLeft.read();
  knobRight.read();

  char buffer[256];
#ifdef DEBUG
  if (row == 1) {
    debug_delay++;
    if (debug_delay == 0) {
      buffer[0] = 'i';
#else
  if (Serial.available()) {
    if (Serial.readBytes(buffer, 1) > 0) {
#endif
      switch (buffer[0]) {
        case 'r':
          {
            Serial.readBytes(buffer, 10);
            int16_t x = (int16_t)buffer[0];
            int16_t y = (int16_t)buffer[2];
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
            int16_t x = (int16_t)buffer[0];
            int16_t y = (int16_t)buffer[2];
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
        case 'x':
          {
            knobLeft.readAndReset();
            knob.readAndReset();
            knobRight.readAndReset();
            memset(&buttons[0], 0, sizeof(buttons));
          }
          break;
        case 'i':
          {
            #ifdef DEBUG
              for (uint8_t i = 0; i < sizeof(buttons); i++) {
                Serial.print(buttons[i]);
                buttons[i] = 0;
              }

              Serial.print(' ');
              Serial.print(knobLeft.readAndReset() >> 1);
              Serial.print(' ');
              Serial.print(-knob.readAndReset() >> 2);
              Serial.print(' ');
              Serial.print(knobRight.readAndReset() >> 1);

              Serial.println();
            #else
              Serial.write(&buttons[0], sizeof(buttons));
              
              int32_t value = knobLeft.readAndReset() >> 1; 
              Serial.write((char*)&value, sizeof(value));
              
              value = -knob.readAndReset() >> 2;  
              Serial.write((char*)&value, sizeof(value));

              value = knobRight.readAndReset() >> 1;  
              Serial.write((char*)&value, sizeof(value));

              memset(&buttons[0], 0, sizeof(buttons));
            #endif
          }
          break;
      }
    }
  }
}
