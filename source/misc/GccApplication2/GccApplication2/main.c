#include "hw.h"

#include <util/delay.h>

int main(void)
{
	init();
	uint16_t u;
	
	while(1){
		while( ! ButtOn() ){
			;
		}
		u = GetCellVoltage();
		SendVoltageUart(u);
		if( u > Volts(3.0) && u < Volts(4.2) ){
			_delay_ms(1000);
			LedG(1);
			SetChargingCurrent(MiliAmps(500));
			while( (u = GetCellVoltage()) < Volts(4.2) ){
				if( u < Volts(3.0) ){
					LedR(1);
					SetChargingCurrent(MiliAmps(0));
					break;
				}
				SendVoltageUart(u);
				_delay_ms(500);
		}
		SetChargingCurrent(MiliAmps(0));
		while( ! ButtOn() ){
			LedG(1);
			_delay_ms(200);
			LedG(0);
			_delay_ms(200);
		}
	}

	}
}