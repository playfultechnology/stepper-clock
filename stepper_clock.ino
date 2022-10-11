// DEFINES
// Some discrepancy as to whether 4076 or 4096
// See https://www.makerguides.com/28byj-48-stepper-motor-arduino-tutorial/
#define NUM_STEPS 4096.0  
#define DEBUG

// INCLUDES
// https://www.airspayce.com/mikem/arduino/AccelStepper/
#include <AccelStepper.h>

// GLOBALS
// The 28BYJ-48 coils need to be energised in the pin sequence 1,3,2,4, rather than the standard 1,2,3,4 sequence
// In1, In3, In2, In4
AccelStepper hourStepper(AccelStepper::HALF4WIRE, 11, 9, 10, 8);
// Note the pin order for one pair is swapped for this motor as its direction is reversed through the gear train.
// In3, In1, In2, In4
AccelStepper minuteStepper(AccelStepper::HALF4WIRE, 5, 7, 6, 4);

void setup() {

  Serial.begin(115200);
  Serial.println(__FILE__ __DATE__);

  Serial.println(F("Send time in hh:mm format to set time"));
  Serial.println(F("Send H/h to +/-1 hour"));
  Serial.println(F("Send M/m to +/-1 minute"));
  Serial.println(F("Send - to set zero position"));
    

  // Configure each stepper
  hourStepper.setMaxSpeed(1000);
  minuteStepper.setMaxSpeed(1000);
  hourStepper.setAcceleration(500);
  minuteStepper.setAcceleration(500);
}

/**
 * Sets the target position of each hand based on supplied hours and minutes values
 * Note that this only sets the desired target - the actual movement is handled
 * in the main loop()
 */
void SetTime(long hours, long minutes){
  
    Serial.print("Setting time to ");
    Serial.print(hours);
    Serial.print(":");
    Serial.println(minutes);

  // There are 12 hours on one revolution of the clock face, so each hour requires NUM_STEPS / 12 steps
  hourStepper.moveTo(hours * (NUM_STEPS/12.0));
  // There are 60 minutes, so advancing one minute requires NUM_STEPS / 60 steps
  minuteStepper.moveTo(minutes * (NUM_STEPS/60.0));
}

/**
 * Checks and acts upon any input received on the serial connection
 */
void CheckSerialInput() {
    // Has any input has been received on the serial connection?
  if(Serial.available() > 0){
    // Define a character array to hold the received time data
    char data[6];
    // Count the number of bytes received
    int number_of_bytes_received;
    // Read data from the serial buffer into the timeData variable, until carriage return (or 5 bytes) is reached
    number_of_bytes_received = Serial.readBytesUntil('\r', data, 5);
    // Add a terminator to the end of the char array
    data[number_of_bytes_received] = 0;
    // If the character of data received was "-"
    if(memcmp(data, "-", 1) == 0){
      Serial.println("Setting zero position");
      hourStepper.setCurrentPosition(0);
      minuteStepper.setCurrentPosition(0);
    }
    // If the data character was "H", "h", "M", or "m", move the corresponding hand
    else if(memcmp(data, "h", 1) == 0) { hourStepper.move(-NUM_STEPS/12.0); }
    else if(memcmp(data, "H", 1) == 0) { hourStepper.move(NUM_STEPS/12.0); }
    else if(memcmp(data, "m", 1) == 0) { minuteStepper.move(-NUM_STEPS/60.0); }
    else if(memcmp(data, "M", 1) == 0) { minuteStepper.move(NUM_STEPS/60.0); }
    // Otherwise, set the hands based on the time assuming "hh:mm" format
    else {
      char *p = data;
      char *str;
      // Take the part of the time data up to the ":" token
      str = strtok_r(p, ":", &p);
      // Convert the tokenised string to a decimal number and save as "hours"
      long hours = strtol(str, NULL, 10);
      // Take the remaining part of the tokenised string
      str = strtok_r(NULL,":",&p);
      // Convert to a number and store as "minutes"
      long minutes = strtol(str, NULL, 10);
     
      // Set the hands' positions based on values received
      SetTime(hours,minutes);
    }
  }
}

void loop() {
    // Check for input via USB serial connection in format hh:mm
  CheckSerialInput();
  
  // We call the run() function on both steppers every frame, which processes any movement
  // required to reach their target position
  hourStepper.run();
  minuteStepper.run();
}
