/*
 * main.c
 *
 * Created: 18.11.2019 14:44:18
 * Author : Username
 */ 
#ifndef F_CPU
	#define F_CPU 20000000UL
#endif

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include "definitions.h"
#include "init.c"
#include "adc.c"
#include "led.c"
#include "dac.c"

volatile uint8_t periodic_routine = PF_IDLE;

int main(void)
{
	init();
	ledR(1);
	
	int16_t u = 0;
	while (u < uc_min || u > uc_max)
	{
		u = getCellVoltage();
	}
	ledR(0);
	
	periodic_routine = PF_REG_CC;
	while(periodic_routine == PF_REG_CC){
		toggleLedG();
		_delay_ms(500);
	}
	while(periodic_routine == PF_REG_CV){
		toggleLedG();
		_delay_ms(200);
	}
	ledG(1);
	while (u > uc_min || u < uc_max)
	{
		u = getCellVoltage();
	}
	return;
	
}

