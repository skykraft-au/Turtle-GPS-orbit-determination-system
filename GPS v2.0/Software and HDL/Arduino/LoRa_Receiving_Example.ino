#include <SPI.h>
#include <RadioLib.h>

#define MOSI_PIN   11   //MOSI Pin
#define MISO_PIN   12   //MISO Pin
#define SCLK_PIN   13   //Clock Pin
#define CS_PIN     10   //Chip Select or Slave Select Pin
#define RESET      14
#define DIO0_PIN   15
#define DIO1_PIN   16

// Debug parameter - change this to true if you wish to see each packet and additonal information
const bool DEBUG_OUTPUT = true;


SX1278 radio = new Module(CS_PIN, DIO0_PIN, RESET, DIO1_PIN);

// DIO2 Pin: 5
const int pin = 5;

int counter = 0;

String fifo_data = "";

//Flag for packet receiving
volatile bool receivedFlag = false;

//This function is called when packet is received
void setFlag(void) {
  //Trigger Flag
  receivedFlag = true;
}

void readBit(void) {
  //Read the data bit
  radio.readBit(pin);
}

String reverseString(String s) { String out = ""; for (int i = s.length() - 1; i >= 0; i--) { out += s[i]; } return out; }  //Reverse String function

void setup() {
  Serial.begin(9600);

  // initialize SX1278 with default settings
  Serial.println("LoRa initialsing");
  int state = radio.begin(433.000000, 500, 10, 7, 18, 20, 16, 0);
  if (state == RADIOLIB_ERR_NONE) {
    Serial.println(F("success!"));
  } else {
    Serial.print(F("failed, code "));
    Serial.println(state);
    while (true) { delay(10); }
  }

  radio.setPacketReceivedAction(setFlag);

  Serial.print(F("[SX1278] Starting to listen ..."));
  state = radio.startReceive();
  if (state == RADIOLIB_ERR_NONE) {
    Serial.println(F("success!"));
  } else {
    Serial.print(F("failed, code "));
    Serial.println(state);
    while (true) { delay(10); }
  }
}

void loop() {
  // check if the flag is set
  if (receivedFlag) {
    receivedFlag = false;

    // First, ask RadioLib how many bytes are in the just-received packet.
    // In explicit header mode (RadioLib default), the modem provides this.
    int16_t len = radio.getPacketLength();   // after a successful Rx

    if (len <= 0) {
      // Fallback: choose a safe max or just bail out
      len = 255;
    }

    // Allocate a buffer on the stack (or use a static/global)
    uint8_t buf[255];
    int state = radio.readData(buf, len);

    if (state == RADIOLIB_ERR_NONE) {
      if (DEBUG_OUTPUT) {
        Serial.println(F("[SX1278] Received packet!"));
      }

      // Convert bytes to bits safely
      String data_packet;
      data_packet.reserve(len * 8);  // optional: reduce reallocs

      int bit_index = 0;

      if (DEBUG_OUTPUT) {
        Serial.print(F("[SX1278] Data:\t\t"));
      }
      for (int i = 0; i < len; i++) {
        uint8_t c = buf[i];            // ensure unsigned
        for (int j = 7; j >= 0; j--) {
          uint8_t bit = (c >> j) & 0x01;
          bit_index++;
          if (DEBUG_OUTPUT) {
            Serial.print(bit);
          }

          if (bit_index > 64) {
            data_packet += (bit ? '1' : '0');
          }
        }
      }

      // Padding logic (if you still want to pad to 512 bits)
      if (bit_index < 512) {
        int pad = 512 - bit_index;
        for (int k = 0; k < pad; k++) {
          if (DEBUG_OUTPUT) {
            Serial.print('x');
          }
        }
        data_packet += String('x', pad);  // requires modern Arduino cores; otherwise loop-append
      }

      if (DEBUG_OUTPUT) {
        Serial.println();
      }

      fifo_data += data_packet;

      // Diagnostics
      if (DEBUG_OUTPUT) {
        Serial.print(F("[SX1278] RSSI:\t\t"));
        Serial.print(radio.getRSSI());
        Serial.println(F(" dBm"));

        Serial.print(F("[SX1278] SNR:\t\t"));
        Serial.print(radio.getSNR());
        Serial.println(F(" dB"));

        Serial.print(F("[SX1278] Frequency error:\t"));
        Serial.print(radio.getFrequencyError());
        Serial.println(F(" Hz"));

        Serial.print(F("[SX1278] Packet Index:"));
        Serial.println(counter++);
      }

      // Append to your FIFO string
      if (fifo_data.length() > 30000) {
        Serial.println();
        Serial.println(F("[SX1278] Data - 30000 bits:"));
        Serial.println(fifo_data);
        fifo_data = "";
      }

    } else if (state == RADIOLIB_ERR_CRC_MISMATCH) {
      Serial.println(F("[SX1278] CRC error!"));
    } else {
      Serial.print(F("[SX1278] Failed, code "));
      Serial.println(state);
    }
  }
}
