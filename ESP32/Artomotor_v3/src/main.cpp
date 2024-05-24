#include <Arduino.h>
#include <ESP32Servo.h>
#include <BluetoothSerial.h>
#include <string.h>
#include <PCF8574_library.h>
#include "esp_system.h"
#include "esp_adc_cal.h"
#include <driver/dac.h>
#include <driver/adc.h>
#include <stdlib.h>
#include <esp32-hal-timer.h>

// Definicion de posiciones para el servo
#define POS_BAIX 1400
#define POS_CENTRE 1000
#define POS_ALT 600

/* Conexiones
	=========================
	 Servo | ESP32 |
   --------------------------
	 S1    |  IO2  |  D9
	=========================

	==========================
	MOSFET | ESP32  |
	--------------------------
	MF     |  IO27  |  D4
	==========================
*/

// Definicion de pines
uint8_t servoPin = IO14; // Pin del servo D9
uint8_t mosfetPin = IO27; // Pin del MOSFET D4
uint8_t mosfetState = 0; // Estado del MOSFET

uint8_t step = 1; // Paso para el movimiento del servo

const byte numByte = 5; // Número de bytes para recibir
byte receivedChars[numByte]; // Almacenamiento de caracteres recibidos
boolean newData = false; // Indicador de datos nuevos

const byte STX = 0x40; // Inicio de texto '@'
const byte ETX = 0x23; // Fin de texto '#'

// Variables para datos recibidos
byte DIR = 0x00;
byte REP = 0x01;
byte T = 0x01;

// Posiciones de datos en el array recibido
const byte dirData = 1;
const byte repData = 2;
const byte timeData = 3;

#define posDir 0x2B // Direccion positiva '+'
#define negDir 0x2D // Direccion negativa '-'
#define cntrDir 0x00 // Direccion central '0'

bool init_cycle_flag = false; // Indicador de ciclo de inicializacion

// Secuencias de inicializacion
const byte initSeq[numByte] = {'@', '0', '0', '0', '#'};
const byte startPosSeq[numByte] = {(byte)64, (byte)43, (byte)49, (byte)97, (byte)35};
const byte startNegSeq[numByte] = {(byte)64, (byte)45, (byte)49, (byte)97, (byte)35};
const byte centerSeq[numByte] = {(byte)64, (byte)48, (byte)49, (byte)97, (byte)35};

const uint8_t speedT[25] = {1, 2, 3, 4, 5,
							6, 7, 8, 9, 10,
							11, 12, 13, 14, 15,
							16, 17, 18, 19, 20,
							21, 22, 23, 24, 25};
/*******************************
 ***** DEFINICIoN DE OBJETOS *****
 ********************************/
hw_timer_t *My_Timer = NULL; // Temporizador de hardware
portMUX_TYPE synch = portMUX_INITIALIZER_UNLOCKED; // Sincronizacion de puertos
Servo myServo; // Objeto Servo
BluetoothSerial SerialBT; // Objeto Bluetooth
/***********************************************/
/***********************************************/

/********************************
 ******* VARIABLES GLOBALES *******
 ********************************/

uint32_t pwmSig = POS_CENTRE; // Señal PWM para el servo

/***********************************************/
/***********************************************/

/***********************************************/
/*********** VARIABLES DE INTERRUPCIoN ************/
/***********************************************/

volatile uint16_t timer_interrupt_count = 0;

volatile bool timer_interrupt_1ms = false;
volatile bool timer_interrupt_10ms = false;
volatile bool timer_interrupt_25ms = false;

/***********************************************/
/***********************************************/

// Funcion para recibir datos con un marcador final
void recvWithEndMarker()
{
	static byte ndx = 0;
	char rc;

	if (Serial.available() > 0)
	{
		while (Serial.available() > 0 && newData == false)
		{
			rc = Serial.read();
			if (rc == STX)
			{
				ndx = 0;
			}
			if (rc != ETX)
			{
				receivedChars[ndx] = rc;
				ndx++;
				if (ndx >= numByte)
				{
					ndx = numByte - 1;
				}
			}
			else
			{
				receivedChars[ndx] = '\0'; // Terminar la cadena
				ndx = 0;
				newData = true;
			}
		}
	}
}

// Leer línea desde Bluetooth
String bluetoothReadLine()
{
	String text_received = "";
	while (SerialBT.available())
	{
		byte r = SerialBT.read();
		if (r != 13 && r != 10 && char(r) != '\0')
			text_received = text_received + char(r);
	}
	return text_received;
}

// Interrupcion de Bluetooth
void callback(esp_spp_cb_event_t event, esp_spp_cb_param_t *param)
{
	portENTER_CRITICAL_ISR(&synch);
	// Evento de desconexion
	if (event == ESP_SPP_CLOSE_EVT)
	{
		mosfetState = 0; // Desconexion de la alimentacion
	}
	else if (event == ESP_SPP_SRV_OPEN_EVT)
	{
		if (init_cycle_flag)
		{
			mosfetState = 1;
		}
		
		Serial.println("Client Connected!");
	}
	else if (event == ESP_SPP_DATA_IND_EVT)
	{
		String received = bluetoothReadLine();
	}
	portEXIT_CRITICAL_ISR(&synch);
}

// Inicializar Bluetooth
void initBT()
{
	if (!SerialBT.begin("ARTROMOTOR"))
	{
		Serial.println("An error occurred initializing Bluetooth");
		ESP.restart();
	}
	else
	{
		Serial.println("Bluetooth initialized");
	}

	SerialBT.register_callback(callback);
	Serial.println("The device started, now you can pair it with bluetooth");
}

// Configurar el temporizador para un período de 1ms
void IRAM_ATTR onTimer()
{
	portENTER_CRITICAL_ISR(&synch);
	timer_interrupt_count++;
	if (timer_interrupt_1ms == false)
	{
		if (timer_interrupt_1ms == false)
		{
			timer_interrupt_1ms = true;
		}
	}
	if (timer_interrupt_count % 10 == 0) // 10 ms
	{
		if (timer_interrupt_10ms == false)
		{
			timer_interrupt_10ms = true;
		}
	}
	if (timer_interrupt_count == 25) // 25 ms
	{
		if (timer_interrupt_25ms == false)
		{
			timer_interrupt_25ms = true;
		}
		timer_interrupt_count = 0;
	}

	portEXIT_CRITICAL_ISR(&synch);
}

// Mover el servo en la direccion especificada
void servoMove(byte dir)
{
	if (dir == posDir)
	{
		myServo.write(pwmSig);
		pwmSig -= step;
		Serial.println(pwmSig);
	}
	else if (dir == negDir)
	{
		myServo.write(pwmSig);
		pwmSig += step;
		Serial.println(pwmSig);
	}
}

void setup()
{
	Wire.begin(); // Iniciar I2C

	// Permitir la asignacion de todos los temporizadores
	ESP32PWM::allocateTimer(0);
	ESP32PWM::allocateTimer(1);

	myServo.setPeriodHertz(330); // Configurar frecuencia del servo

	myServo.attach(servoPin, 500, 2500); // Adjuntar el servo al pin especificado

	delay(100); // Esperar 100 ms

	Serial.begin(115200); // Iniciar la comunicacion serie

	initBT(); // Inicializar Bluetooth

	pinMode(mosfetPin, OUTPUT); // Configurar el pin del MOSFET como salida
	digitalWrite(mosfetPin, LOW); // Establecer el estado inicial del MOSFET en bajo

	myServo.write(POS_CENTRE); // Mover el servo a la posicion central

	My_Timer = timerBegin(2, 80, true); // Iniciar el temporizador
	timerAttachInterrupt(My_Timer, &onTimer, true); // Adjuntar la interrupcion del temporizador
	timerAlarmWrite(My_Timer, 1000, true); // Configurar alarma del temporizador
	timerAlarmEnable(My_Timer); // Habilitar alarma del temporizador
}

void loop()
{
	static byte ndx = 0;
	char rc;

	bool pos_cycle_flag = false;
	bool neg_cycle_flag = false;
	bool center_cycle_flag = false;

	uint8_t tCount = 0;

	while (1)
	{
		digitalWrite(mosfetPin, mosfetState); // Escribir estado del MOSFET

		recvWithEndMarker(); // Recibir datos con marcador final

		if (newData)
		{
			// Decodificar datos recibidos
			DIR = receivedChars[dirData];
			REP = receivedChars[repData];
			T = receivedChars[timeData];
			SerialBT.println((char)DIR);
			SerialBT.println((char)REP);
			SerialBT.println((char)T);
			
			/******* DECODIFICACIoN DE MENSAJES ********/
			if (DIR == '0' && REP == '0' && T == '0')
			{
				init_cycle_flag = true;
				mosfetState = true;
				SerialBT.println("INIT CYCLE");
			}
			else if (DIR == '+' && REP == '1')
			{
				T = speedT[T - 96];
				pos_cycle_flag = true;
				SerialBT.println("POSITIVE CYCLE");
			}
			else if (DIR == '-' && REP == '1')
			{
				T = speedT[T - 96];
				neg_cycle_flag = true;
				SerialBT.println("NEGATIVE CYCLE");
			}
			else if (DIR == '0' && REP == '1')
			{
				T = speedT[T - 96];
				center_cycle_flag = true;
				SerialBT.println("NEGATIVE CYCLE");
			}
			newData = false; // Restablecer indicador de datos nuevos
		}

		/******* FLAGS DEL TEMPORIZADOR ********/

		if (timer_interrupt_1ms)
		{
			tCount++;
			timer_interrupt_1ms = false;
		}
		if (timer_interrupt_10ms)
		{
			timer_interrupt_10ms = false;
		}
		if (timer_interrupt_25ms)
		{
			timer_interrupt_25ms = false;
		}

		if (tCount >= T)
		{
			if (pos_cycle_flag)
			{
				servoMove(DIR); // Mover el servo en direccion positiva
				if (pwmSig <= POS_ALT)
				{
					pos_cycle_flag = false; // Finalizar ciclo positivo
				}
			}
			else if (neg_cycle_flag)
			{
				servoMove(DIR); // Mover el servo en direccion negativa
				if (pwmSig >= POS_BAIX)
				{
					neg_cycle_flag = false; // Finalizar ciclo negativo
				}
			}
			else if (center_cycle_flag)
			{
				servoMove(DIR); // Mover el servo hacia la posicion central
				
				if (pwmSig == POS_CENTRE)
				{
					pos_cycle_flag = false;
					break;
				}else if (pwmSig < POS_CENTRE )
				{
					DIR = negDir;
				}
				else if (pwmSig > POS_CENTRE )
				{
					DIR = posDir;
				}
			}
			tCount = 0;
		}
	}
}
