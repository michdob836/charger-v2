void ledR(bool turnOn){
	//inverted port state
	if(turnOn){
		PORTA.OUTCLR |= 1 << 3; 
	} else {
		PORTA.OUTSET |= 1 << 3; 
	}
}

void ledG(bool turnOn){
	//inverted port state
	if(turnOn){
		PORTA.OUTCLR |= 1 << 2;
		} else {
		PORTA.OUTSET |= 1 << 2;
	}	
}
	
