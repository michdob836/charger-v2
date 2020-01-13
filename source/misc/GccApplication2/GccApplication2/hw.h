#include <stdint.h>

#define F_CPU 3333333
#define BAUD_RATE 19200
#define USART0_BAUD_RATE ((uint16_t)(F_CPU * 64.0 / (16.0 * BAUD_RATE)) + 0.5)

#define SHUNT_RES_OHM 0.08
#define U_DAC_VSOURCE 0.55
#define MiliAmps(MAMPS) ((uint8_t)(MAMPS / 1000.0 * SHUNT_RES_OHM * 256.0/U_DAC_VSOURCE + 0.5))

#define U_ADC_VREF 4.3
#define DV (U_ADC_VREF / 1024.0)
#define Volts(VOLTS) ( (uint16_t)(VOLTS / DV + 0.5) )

void init();

void LedR(uint8_t turnOn);

void LedG(uint8_t turnOn);

void SendVoltageUart(uint16_t u);

char USART0_readChar(void);

void USART0_sendChar(char c);

void SendString(char* s);

uint16_t GetCellVoltage();

uint16_t GetLow(uint8_t shift);

uint16_t GetHigh(uint8_t shift);

void SetChargingCurrent(uint8_t dacReg);

uint8_t ButtOn();
