/*
 * main.c
 *
 * Created: 18.11.2019 14:44:18
 * Author : Username
 */ 
#ifndef F_CPU
	#define F_CPU 20000000L
#endif

#include <avr/io.h>
#include <util/delay.h>
#include "init.c"
#include "adc.c"
#include "led.c"



int main(void)
{
	init();
	ledR(1);
	
	uint16_t u = 0;
	while (u < 2 || u > 4.2) //change to int
	{
		u = getCellVoltage();
	}
}

