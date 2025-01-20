// Adafruit GFX Library
#include <Adafruit_GFX.h>
#include <Adafruit_GrayOLED.h>
#include <Adafruit_SPITFT.h>
#include <Adafruit_SPITFT_Macros.h>
#include <SPI.h>
#include <gfxfont.h>

// Adafruit SSD1351 Library
#include <Adafruit_SSD1351.h>

// RotaryEncoder by Matthias Hertel
#include <RotaryEncoder.h>

// Used pins
#define LED_BUILTIN PC13

#define SCLK_PIN PB3
#define MOSI_PIN PB5
#define DC_PIN PB6
#define CS_PIN PB4

#define RX_PIN PA10
#define TX_PIN PA9

#define ROW0_PIN PA4
#define ROW1_PIN PB0
#define ROW2_PIN PB1
#define ROW3_PIN PB10
#define ROW4_PIN PB11
#define ROW5_PIN PB14

#define COL0_PIN PA5
#define COL1_PIN PA6
#define COL2_PIN PA11
#define COL3_PIN PA8

#define ENCODER_A PA0
#define ENCODER_B PA1
#define ENCODER_LA PB8
#define ENCODER_LB PB9
#define ENCODER_RA PA15
#define ENCODER_RB PB7

// Color definitions
#define BLACK 0x0000
#define BLUE 0x001F
#define RED 0xF800
#define GREEN 0x07E0
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define YELLOW 0xFFE0
#define WHITE 0xFFFF

class Encoder {
public:
  uint32_t pinA;
  uint32_t pinB;
  uint8_t state;
  int32_t position;

  Encoder(uint32_t _pinA, uint32_t _pinB) {
    pinA = _pinA;
    pinB = _pinB;
    state = 0;
    position = 0;
  }
};

// Global vars
Adafruit_SSD1351 tft = Adafruit_SSD1351(128, 128, &SPI, CS_PIN, DC_PIN, -1);
RotaryEncoder *encoder = nullptr;
RotaryEncoder *encoderL = nullptr;
RotaryEncoder *encoderR = nullptr;

int row = 0;
uint32_t rows[] = { ROW0_PIN, ROW1_PIN, ROW2_PIN, ROW3_PIN, ROW4_PIN, ROW5_PIN };
uint8_t buttons[] = { 0, 0, 0, 0, 0, 0 };

// #define DEBUG


void encoder_ISR(void) {
  encoder->tick();
}
void encoderL_ISR(void) {
  encoderL->tick();
}
void encoderR_ISR(void) {
  encoderR->tick();
}

uint16_t convert2Uint16(char *buffer) { 
  uint16_t value;
  memcpy(&value, buffer, sizeof(uint16_t));
  return value;
}
int16_t convert2Int16(char *buffer) { 
  int16_t value;
  memcpy(&value, buffer, sizeof(int16_t));
  return value;
}

void setup() {
  Serial.setRx(RX_PIN);
  Serial.setTx(TX_PIN);
  Serial.begin(115200);

  SPI.setSCLK(SCLK_PIN);
  SPI.setMOSI(MOSI_PIN);
  tft.begin();
  tft.fillScreen(BLACK);
#ifdef DEBUG
  tft.setTextColor(BLUE);
  tft.print("DEBUG MODE");
#else
  tft.setTextColor(RED);
  tft.print("Waiting for connection.");
#endif
  tft.setTextColor(WHITE);

  pinMode(ENCODER_A, INPUT_PULLUP);
  pinMode(ENCODER_B, INPUT_PULLUP);
  pinMode(ENCODER_LA, INPUT_PULLUP);
  pinMode(ENCODER_LB, INPUT_PULLUP);
  pinMode(ENCODER_RA, INPUT_PULLUP);
  pinMode(ENCODER_RB, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(ENCODER_A), encoder_ISR, CHANGE);
  attachInterrupt(digitalPinToInterrupt(ENCODER_B), encoder_ISR, CHANGE);
  attachInterrupt(digitalPinToInterrupt(ENCODER_LA), encoderL_ISR, CHANGE);
  attachInterrupt(digitalPinToInterrupt(ENCODER_LB), encoderL_ISR, CHANGE);
  attachInterrupt(digitalPinToInterrupt(ENCODER_RA), encoderR_ISR, CHANGE);
  attachInterrupt(digitalPinToInterrupt(ENCODER_RB), encoderR_ISR, CHANGE);

  pinMode(COL0_PIN, INPUT_PULLUP);
  pinMode(COL1_PIN, INPUT_PULLUP);
  pinMode(COL2_PIN, INPUT_PULLUP);
  pinMode(COL3_PIN, INPUT_PULLUP);

  pinMode(ROW0_PIN, OUTPUT);
  pinMode(ROW1_PIN, OUTPUT);
  pinMode(ROW2_PIN, OUTPUT);
  pinMode(ROW3_PIN, OUTPUT);
  pinMode(ROW4_PIN, OUTPUT);
  pinMode(ROW5_PIN, OUTPUT);

  pinMode(LED_BUILTIN, OUTPUT);

  digitalWrite(LED_BUILTIN, LOW);
  digitalWrite(ROW0_PIN, HIGH);
  digitalWrite(ROW1_PIN, HIGH);
  digitalWrite(ROW2_PIN, HIGH);
  digitalWrite(ROW3_PIN, HIGH);
  digitalWrite(ROW4_PIN, HIGH);

  encoder  = new RotaryEncoder(ENCODER_A, ENCODER_B, RotaryEncoder::LatchMode::TWO03);
  encoderL = new RotaryEncoder(ENCODER_LA, ENCODER_LB, RotaryEncoder::LatchMode::TWO03);
  encoderR = new RotaryEncoder(ENCODER_RA, ENCODER_RB, RotaryEncoder::LatchMode::TWO03);

  while (!Serial);
  Serial.println("init done");
}


void loop() {
  row++;
  if (row > sizeof(buttons)) row = 0;
  
  digitalWrite(rows[row], LOW);
  buttons[row] |= (1 ^ digitalRead(COL0_PIN))
                  | (1 ^ digitalRead(COL1_PIN)) << 1
                  | (1 ^ digitalRead(COL2_PIN)) << 2
                  | (1 ^ digitalRead(COL3_PIN)) << 3;
  digitalWrite(rows[row], HIGH);

#ifdef DEBUG
  Serial.print(encoderL->getPosition());
  Serial.print(',');
  Serial.print(encoder->getPosition());
  Serial.print(',');
  Serial.print(encoderR->getPosition());
  Serial.print(',');
  Serial.println();
#else
  if (Serial.available()) {
    char buffer[256];

    if (Serial.readBytes(buffer, 1) > 0) {
      switch (buffer[0]) {
        case 'r':
          {
            Serial.readBytes(buffer, 10);
            int16_t x  = convert2Int16(&buffer[0]);
            int16_t y  = convert2Int16(&buffer[2]);
            uint16_t w = convert2Uint16(&buffer[4]);
            uint16_t h = convert2Uint16(&buffer[6]);
            uint16_t c = convert2Uint16(&buffer[8]);
            tft.fillRect(x, y, w, h, c);
            Serial.write('\0');
          }
          break;
        case 'f':
          {
            Serial.readBytes(buffer, 2);
            uint16_t c = convert2Uint16(&buffer[0]);
            tft.fillScreen(c);
            Serial.write('\0');
          }
          break;
        case 's':
          {
            Serial.readBytes(buffer, 1);
            uint8_t s = (uint8_t)buffer[0];
            tft.setTextSize(s);
            Serial.write('\0');
          }
          break;
        case 'c':
          {
            Serial.readBytes(buffer, 2);
            uint16_t c = convert2Uint16(&buffer[0]);
            tft.setTextColor(c);
            Serial.write('\0');
          }
          break;
        case '_':
          {
            Serial.readBytes(buffer, 4);
            int16_t x = convert2Int16(&buffer[0]);
            int16_t y = convert2Int16(&buffer[2]);
            tft.setCursor(x, y);
            Serial.write('\0');
          }
          break;
        case 't':
          {
            Serial.readBytes(buffer, 2);
            uint16_t s = convert2Uint16(&buffer[0]);

            Serial.readBytes(buffer, s);
            buffer[s] = '\0';
            tft.print(buffer);
            Serial.write('\0');
          }
          break;
        case 'x':
          {
            encoderL->setPosition(0);
            encoder->setPosition(0);
            encoderR->setPosition(0);
            memset(&buttons[0], 0, sizeof(buttons));
            Serial.write('\0');
          }
          break;
        case 'i':
          {
            int32_t valueL = encoderL->getPosition();
            int32_t value = encoder->getPosition();
            int32_t valueR = encoderR->getPosition();
            
            memset(&buffer[0], 0, sizeof(buffer));
            memcpy(&buffer[0], &button[0], sizeof(button))

            // Serial.write((byte*)&data, sizeof(data));
            memcpy(&buffer[7], &valueL, sizeof(valueL))
            memcpy(&buffer[11], &value, sizeof(value))
            memcpy(&buffer[15], &valueR, sizeof(valueR))

            // buffer[7] = valueL & 255;
            // buffer[8] = (valueL >> 8)  & 255;
            // buffer[9] = (valueL >> 16) & 255;
            // buffer[10] = (valueL >> 24) & 255;

            // buffer[11] = value & 255;
            // buffer[12] = (value >> 8)  & 255;
            // buffer[13] = (value >> 16) & 255;
            // buffer[14] = (value >> 24) & 255;
            
            // buffer[15] = valueR & 255;
            // buffer[16] = (valueR >> 8)  & 255;
            // buffer[17] = (valueR >> 16) & 255;
            // buffer[18] = (valueR >> 24) & 255;

            encoderL->setPosition(0);
            encoder->setPosition(0);
            encoderR->setPosition(0);
            memset(&buttons[0], 0, sizeof(buttons));
          
            Serial.write(&buffer[0], 18);
          }
          break;
      }
    }
  }
#endif
}