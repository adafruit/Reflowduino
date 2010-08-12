#include <LiquidCrystal.h>
#include <max6675.h>

// The pin we use to control the relay
#define RELAYPIN 4

// The SPI pins we use for the thermocouple sensor
#define MAX_CLK 5
#define MAX_CS 6
#define MAX_DATA 7

MAX6675 thermocouple(MAX_CLK, MAX_CS, MAX_DATA);

// Classic 16x2 LCD used
LiquidCrystal lcd(8,9,10,11,12,13);

// volatile means it is going to be messed with inside an interrupt 
// otherwise the optimization code will ignore the interrupt

volatile long seconds_time = 0;  // this will get incremented once a second
volatile float the_temperature;  // in celsius

int relay_state;       // whether the relay pin is high (on) or low (off)

void setup() {  
  Serial.begin(9600); 
  Serial.println("Reflowduino!");

  // the relay pin controls the plate
  pinMode(RELAYPIN, OUTPUT);
  // ...and turn it off to start!
  pinMode(RELAYPIN, LOW);

  // Set up 16x2 standard LCD  
  lcd.begin(16,2);

  // clear the screen and print out the current version
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("Reflowduino!");
  lcd.setCursor(0,1);
  // compile date
  lcd.print(__DATE__);
  
  // pause for dramatic effect!
  delay(2000);
  lcd.clear();
  
  // Setup 1 Hz timer to refresh display using 16 Timer 1
  TCCR1A = 0;                           // CTC mode (interrupt after timer reaches OCR1A)
  TCCR1B = _BV(WGM12) | _BV(CS10) | _BV(CS12);    // CTC & clock div 1024
  OCR1A = 15609;                                 // 16mhz / 1024 / 15609 = 1 Hz
  TIMSK1 = _BV(OCIE1A);                          // turn on interrupt
}

void loop() { 
  // we moved the LCD code into the interrupt so we don't have to worry about updating the LCD 
  // or reading from the thermocouple in the main loop


  // do the most stupid thing - turn on the relay if the temperature is too low 
  // and turn it off when its too high!
  
  if (the_temperature < 100) {
    relay_state = HIGH;
    digitalWrite(RELAYPIN, HIGH);
  } else {
    relay_state = LOW;
    digitalWrite(RELAYPIN, LOW);
  }
}


// This is the Timer 1 CTC interrupt, it goes off once a second
SIGNAL(TIMER1_COMPA_vect) { 
  // time moves forward!
  seconds_time++;

  // we will want to know the temperauter in the main loop()
  // instead of constantly reading it, we'll just use this interrupt
  // to track it and save it once a second to 'the_temperature'
  the_temperature = thermocouple.readCelsius();
  
  // display current time and temperature
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Time: ");
  lcd.print(seconds_time);
  lcd.print(" s");
  
  // go to line #1
  lcd.setCursor(0,1);
  lcd.print(the_temperature);
  lcd.print(0xDF, BYTE);
  lcd.print("C ");
  
  // print out a log so we can see whats up
  Serial.print(seconds_time);
  Serial.print("\t");
  Serial.print(the_temperature);
  Serial.print("\t");
  Serial.println(relay_state);
} 
