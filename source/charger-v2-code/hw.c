#include <avr/io.h>
#include <stdlib.h>

#include "hw.h"

#include <util/delay.h>

void init()
{
	// analog out:
	// PA6 as DAC_OUT
	VREF.CTRLA |= VREF_DAC0REFSEL_2V5_gc;
	VREF.CTRLB |= VREF_DAC0REFEN_bm;
	_delay_us(25);
	PORTA.PIN6CTRL &= ~PORT_ISC_gm;
	PORTA.PIN6CTRL |= PORT_ISC_INPUT_DISABLE_gc;
	PORTA.PIN6CTRL &= ~PORT_PULLUPEN_bm;
	DAC0.DATA = 0x00; //no current through MOSFET
	DAC0.CTRLA |= DAC_ENABLE_bm;
	DAC0.CTRLA |= DAC_OUTEN_bm;
	
	// digital out:
	// PA3 as LED1
	#define LED1_bp 3
	// PA2 as LED2
	#define LED2_bp 2
	// enable outputs for LEDs
	PORTA.DIR |= 1 << LED1_bp | 1 << LED2_bp;
	// turn them off: 0 -> LED turned on;
	PORTA.OUT |= 1 << LED1_bp | 1 << LED2_bp;
	
	// digital in
	// PA4 as HW_BUTTON
	PORTA.DIRCLR = PIN4_bm;
	
	// analog in:
	// PA1 as ADC_SENSE1
	// PA5 as ADC_SENSE2
	// PA7 as ADC_TEMP
	// disable input buffers of ADC pins
	PORTA.PIN1CTRL = (PORTA.PIN1CTRL & 0xf8) | 0x04;
	PORTA.PIN5CTRL = (PORTA.PIN5CTRL & 0xf8) | 0x04;
	PORTA.PIN7CTRL = (PORTA.PIN7CTRL & 0xf8) | 0x04;
	ADC0.CTRLA |= ADC_RESSEL_10BIT_gc;
	//64 samples accumulated
	ADC0.CTRLB = ADC_SAMPNUM_ACC16_gc;
	//set volt ref to internal
	ADC0.CTRLC = (ADC0.CTRLC & 0x3f) | 0x1 << 4;
	//configure VREF
	VREF.CTRLA |= VREF_ADC0REFSEL_4V34_gc;
	VREF.CTRLB |=  VREF_ADC0REFEN_bm;
	// reduced sample capacitance
	ADC0.CTRLC |= ADC_SAMPCAP_bp;
	// TODO: set pright prescaler ***********************************************
	ADC0.CTRLC |= ADC_PRESC_DIV2_gc; 
	// configure default input for ADC as PIN5 (will measure cell voltage at 0 current)
	ADC0.MUXPOS = (ADC0.MUXPOS & 0xe0) | 0x05;
	// enable ADC
	ADC0.CTRLA |= ADC_ENABLE_bm;
	
	// uart:
	PORTB.DIR &= ~PIN3_bm;
	PORTB.DIR |= PIN2_bm;
	USART0.BAUD =  USART0_BAUD_RATE;
	USART0.CTRLB = USART_TXEN_bm;
	USART0.CTRLB |= USART_RXEN_bm;
}

void LedR(uint8_t turnOn)
{
	//inverted port state
	if(turnOn){
		PORTA.OUT &= ~(1 << 3);
		} else {
		PORTA.OUT |= 1 << 3;
	}
};

void LedG(uint8_t turnOn)
{
	//inverted port state
	if(turnOn){
		PORTA.OUT &= ~(1 << 2);
		} else {
		PORTA.OUT |= 1 << 2;
	}
};

void USART0_sendChar(char c)
{
	while (!(USART0.STATUS & USART_DREIF_bm))	{
		;
	}
	USART0.TXDATAL = c;
};

void SendString(char* s){
	for (uint8_t i = 0; s[i] != '\0'; i++)
	{
		USART0_sendChar( s[i] );
	}
}

char USART0_readChar(void)
{
	while (!(USART0.STATUS & USART_RXCIF_bm))
	{
		;
	}
	return USART0.RXDATAL;
};

void SendVoltageUart(uint16_t u){
	char buff[7];
	utoa(u, buff, 10);
	for (uint8_t i = 0; buff[i] != '\0'; i++)
	{
		USART0_sendChar( buff[i] );
	}
	USART0_sendChar('\n');
}

uint16_t GetCellVoltage()
{
	/* returns cell voltage in DVs */
	uint16_t u;
	//measure higher cell potential
	ADC0.MUXPOS = (ADC0.MUXPOS & 0xe0) | 0x05;
	ADC0.COMMAND = ADC_STCONV_bm;
	while (!(ADC0.INTFLAGS & ADC_RESRDY_bm)) {
		; //waiting for conversion to be finished
	}
	ADC0.COMMAND &= ~ADC_STCONV_bm;
	u = ADC0.RES; 
	//change to another cell terminal - lower potential
	ADC0.MUXPOS = (ADC0.MUXPOS & 0xe0) | 0x01; 
	ADC0.COMMAND = ADC_STCONV_bm;
	while (!(ADC0.INTFLAGS & ADC_RESRDY_bm)) {
		; //waiting for conversion to be finished
	}
	u -= ADC0.RES ; 
	ADC0.COMMAND &= ~ADC_STCONV_bm;
	return u;	
}

void SetChargingCurrent(uint8_t dacReg)
{
		DAC0.DATA = dacReg;
return;
}

uint8_t ButtOn()
{
	return (~PORTA.IN & PIN4_bm);
}

uint16_t GetLow(uint8_t shift){
	uint16_t u;
	ADC0.MUXPOS = (ADC0.MUXPOS & 0xe0) | 0x01;
	ADC0.COMMAND = ADC_STCONV_bm;
	while (!(ADC0.INTFLAGS & ADC_RESRDY_bm)) {
		; //waiting for conversion to be finished
	}
	u = ADC0.RES >> shift; //average
	ADC0.COMMAND &= ~ADC_STCONV_bm;
	return u;
}

uint16_t GetHigh(uint8_t shift){
	uint16_t u;
	ADC0.MUXPOS = (ADC0.MUXPOS & 0xe0) | 0x05;
	ADC0.COMMAND = ADC_STCONV_bm;
	while (!(ADC0.INTFLAGS & ADC_RESRDY_bm)) {
		; //waiting for conversion to be finished
	}
	u = ADC0.RES >> shift; //average
	ADC0.COMMAND &= ~ADC_STCONV_bm;
	return  u;
}