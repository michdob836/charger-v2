int16_t getCellVoltage(){
	
	int16_t du;
	
	//measure higher cell potential
	ADC0.MUXPOS = (ADC0.MUXPOS & 0xe0) | 0x05;
	ADC0.COMMAND = ADC_STCONV_bm;
	while (!(ADC0.INTFLAGS & ADC_RESRDY_bm)) {
		; //waiting for conversion to be finished
	}
	ADC0.MUXPOS = (ADC0.MUXPOS & 0xe0) | 0x01; //change to another cell terminal //may cause troubles *******8
	du = ADC0.RES; //type mismatch!
	while (!(ADC0.INTFLAGS & ADC_RESRDY_bm)) {
		; //waiting for conversion to be finished
	}
	du -= ADC0.RES;
	ADC0.COMMAND &= ~ADC_STCONV_bm; //don't let another conversion take time
	
	return du;
};

uint16_t getTempVoltage(){
	return 0;
	};