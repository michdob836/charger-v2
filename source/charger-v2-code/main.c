#define F_CPU 3333333

#include <util/delay.h>

#include "hw.h"


int main(void)
{
	init();

	uint8_t Is = 0;
	uint16_t u;	

	while(1)
	{
		char c  = USART0_readChar();
		
		if( c > 0 )
		{
			switch(c)
			{
				case 'K':
					Is = USART0_readChar();
					u = GetHigh(0) - GetLow(0);
					SetChargingCurrent(Is);
					SendVoltageUart(u);
					break;
				case 'I':
					SetChargingCurrent(USART0_readChar());
					break;
				case 'H':
					SendVoltageUart(GetHigh(0));
					break;
				case 'L':
					SendVoltageUart(GetLow(0));
					break;
				case 'T':
					break;
				case 'G':
					if(USART0_readChar() > 0)
						LedG(1);
					else
						LedG(0);
					break;
				case 'R':
					if(USART0_readChar() > 0)
						LedR(1);
					else
						LedR(0);
					break;
				default:
					USART0_sendChar('E');
					USART0_sendChar(c);
					SetChargingCurrent(0);
			}
		}
		else
		{
			SetChargingCurrent(0);
		}
	}
}