//#include "E:\inz\GccApplication2\GccApplication2\hw.h"


#define F_CPU 3333333
#define BAUD_RATE 9600
#define USART0_BAUD_RATE ((uint16_t)(F_CPU * 64.0 / (16.0 * BAUD_RATE)) + 0.5)

#define SHUNT_RES_OHM 0.08
#define U_DAC_VSOURCE 0.55
#define MiliAmps(MAMPS) ((uint8_t)(MAMPS / 1000.0 * SHUNT_RES_OHM * 256.0/U_DAC_VSOURCE + 0.5))

#define U_ADC_VREF 4.3
#define DV (U_ADC_VREF / 1024.0)
#define Volts(VOLTS) ( (uint16_t)(VOLTS / DV + 0.5) )


#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>

void init(){
	// analog out:
	// PA6 as DAC_OUT
	VREF.CTRLA |= VREF_DAC0REFSEL_0V55_gc;
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
	//no samples accumulated
	ADC0.CTRLB = ADC_SAMPNUM_ACC1_gc;
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
}

uint8_t ButtOn(){
	return (~PORTA.IN & PIN4_bm);
}

void SetChargingCurrent(uint8_t dacReg){
	DAC0.DATA = dacReg;
	return;
}

void LedG(uint8_t turnOn){
	//inverted port state
	if(turnOn){
		PORTA.OUT &= ~(1 << 2);
		} else {
		PORTA.OUT |= 1 << 2;
	}
};

void USART0_sendChar(char c){
	while (!(USART0.STATUS & USART_DREIF_bm))	{
		;
	}
	USART0.TXDATAL = c;
};

void Send(char* s){
	for (uint8_t i = 0; s[i] != '\0'; i++)
	{
		USART0_sendChar( s[i] );
	}
}

uint16_t GetLow(uint8_t div){
	uint16_t u;
	ADC0.MUXPOS = (ADC0.MUXPOS & 0xe0) | 0x01;
	ADC0.COMMAND = ADC_STCONV_bm;
	while (!(ADC0.INTFLAGS & ADC_RESRDY_bm)) {
		; //waiting for conversion to be finished
	}
	u = ADC0.RES ; //average 64 samples
	ADC0.COMMAND &= ~ADC_STCONV_bm;
	return (uint16_t) (((u >> div) + 6)  * 1152.0 *DV + 0.5);
}

uint16_t GetHigh(uint8_t div){
	uint16_t u;
	ADC0.MUXPOS = (ADC0.MUXPOS & 0xe0) | 0x05;
	ADC0.COMMAND = ADC_STCONV_bm;
	while (!(ADC0.INTFLAGS & ADC_RESRDY_bm)) {
		; //waiting for conversion to be finished
	}
	u = ADC0.RES ; //average 64 samples
	ADC0.COMMAND &= ~ADC_STCONV_bm;
	return  (uint16_t) (((u >> div) + 6)  * 1152.0 *DV + 0.5);
}


int main(void)
{
	init();
	uint8_t sL = 64;
	char s[sL];
	
	
	uint8_t i = 0;
	
	while(1)
	{
		while( ! ButtOn() )
		{
			;
		}
		
	SetChargingCurrent(MiliAmps(i * 100));
	i++;
	LedG(1);
	
	ADC0.CTRLB = ADC_SAMPNUM_ACC1_gc;
	ADC0.CTRLC |= ADC_SAMPCAP_bp; //reduced capac
	ADC0.CTRLC |= ADC_PRESC_DIV2_gc;
	sprintf(s  , "S:1 \tC:R \tP:2 \t L: %u\t H: %u\t I: %u\n",  GetLow(0) , 
															    GetHigh(0)  ,
															    (uint16_t)(GetLow(0) / SHUNT_RES_OHM / 1000.0 * DV + 0.5) );
	Send(s);
	_delay_ms(10);
		
	ADC0.CTRLB = ADC_SAMPNUM_ACC64_gc;
	ADC0.CTRLC &= ~ADC_SAMPCAP_bm; //full capac
	ADC0.CTRLC |= ADC_PRESC_DIV256_gc;
	sprintf(s , "S:64 \tC:F \tP:256 \t L: %u\t H: %u\t I: %u\n",  GetLow(6)  ,
																  GetHigh(6)  , 
																    (uint16_t)(GetLow(6) / SHUNT_RES_OHM / 1000.0 * DV + 0.5) );
	Send(s);
	_delay_ms(10);
		
	snprintf(s, sL, "\n\n");
	Send(s);
	_delay_ms(100);
	LedG(0);
	}
}