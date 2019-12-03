void ledR(uint8_t turnOn){
	//inverted port state
	if(turnOn){
		PORTA.OUTCLR |= 1 << 3; 
	} else {
		PORTA.OUTSET |= 1 << 3; 
	}
};

void ledG(uint8_t turnOn){
	//inverted port state
	if(turnOn){
		PORTA.OUTCLR |= 1 << 2;
		} else {
		PORTA.OUTSET |= 1 << 2;
	}	
};
	
inline void toggleLedG(){
	PORTA.OUTTGL = 1 << 2;
};

inline void toggleLedR(){
	PORTA.OUTTGL = 1 << 3;
};