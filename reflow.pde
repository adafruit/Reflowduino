#include <LiquidCrystal.h>
#include <max6675.h>

#define MAX_DATA 7
#define MAX_CS 6
#define MAX_CLK 5

MAX6675 thermocouple(MAX_CLK, MAX_CS, MAX_DATA);

LiquidCrystal lcd(8,9,10,11,12,13);

void setup() { 
  pinMode(13, OUTPUT);  //we'll use the debug LED to output a heartbeat
  
  Serial.begin(9600); 
  Serial.println("Reflowduino!");

  // Set up 16x2 standard LCD  
  lcd.begin(16,2);

  // clear the screen and print out the current version
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("Reflowduino!");
  lcd.setCursor(0,1);
  // compile date
  lcd.print(__DATE__);
  
  // Setup 1 Hz timer to refresh display using 16 Timer 1
  TCCR1A = 0;                           // CTC mode (interrupt after timer reaches OCR1A)
  TCCR1B = _BV(WGM12) | _BV(CS10) | _BV(CS12);    // CTC & clock div 1024
  OCR1A = 15609;                                 // 16mhz / 1024 / 15609 = 1 Hz
  TIMSK1 = _BV(OCIE1A);                          // turn on interrupt
  
  // pause for dramatic effect!
  delay(2000);
  lcd.clear();
}

void loop() { 
// basic readout test, just print the current temp
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("MAX6675 test");
  
  // go to line #1
  lcd.setCursor(0,1);
  lcd.print(thermocouple.readCelsius());
  lcd.print(0xDF, BYTE);
  lcd.print("C ");
  lcd.print(thermocouple.readFarenheit());
  lcd.print(0xDF, BYTE);
  lcd.print('F');
  
  delay(1000);
}

// This is the Timer 1 CTC interrupt, it goes off once a second
SIGNAL(TIMER1_COMPA_vect) { 
   Serial.print(".");
} 
