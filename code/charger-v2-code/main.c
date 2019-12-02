/*
 * charger-v2-code.c
 *
 * Created: 18.11.2019 14:44:18
 * Author : Username
 */ 

#include <avr/io.h>
#include <util/delay.h>


int main(void)
{
    DDRA = 0xFF;
    while (1) 
    {
		PORTA = 0xFF;
		_delay_ms(1000);
		PORTA = 0x00;
		_delay_ms(1000);	
    }
}

