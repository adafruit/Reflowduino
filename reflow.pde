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
