#include <Arduino.h>

#define POS_BAIX 1200
#define POS_CENTRE 1000
#define POS_ALT 1400

#define MAX_SPEED 10
#define MIN_SPEED 600

#define offSetVal 1
#define bitRes 12
#define NO_OF_SAMPLES 20

static const float a_recta = 0.9783281734;
static const int b_recta = (-355);