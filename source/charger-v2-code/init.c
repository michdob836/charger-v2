
void init(){
	// analog out:
	// PA6 as DAC_OUT
	VREF.CTRLA |= VREF_DAC0REFSEL_2V5_gc;
	VREF.CTRLA |= VREF_DAC0REFEN_bm;
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
	
	// digital in:
	// PA4 as HW_BUTTON
	#define HW_BUTTON_bp 4
	PORTA.DIRCLR = 1 << HW_BUTTON_bp;
	// enable inverted input (0 shows as 1 in PORTA.IN)
	PORTA.PIN4CTRL |= PORT_INVEN_bm; 
	
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
	ADC0.CTRLB  = (ADC0.CTRLB & 0xf8) | 0x00;
	//set volt ref to internal
	ADC0.CTRLC = (ADC0.CTRLC & 0x3f) | 0x1 << 4;
	//configure VREF 
	VREF.CTRLA |= VREF_ADC0REFSEL_4V34_gc;
	VREF.CTRLA |=  VREF_ADC0REFEN_bm;
	//set Sample Capacitance to reduced (recommended for >1V)
	ADC0.CTRLC |= ADC_SAMPCAP_bm;
	// TODO: set pright prescaler ***********************************************
	ADC0.CTRLC = (ADC0.CTRLC & 0xf8) | 0x0 << 0; //temporary to DIV2
	// configure default input for ADC as PIN5 (will measure cell voltage at 0 current)
	ADC0.MUXPOS = (ADC0.MUXPOS & 0xe0) | 0x05;
	// enable ADC
	ADC0.CTRLA |= ADC_ENABLE_bm;
	

		
	// periodic interrupt timer
	RTC.CLKSEL = RTC_CLKSEL_INT1K_gc;
	RTC.DBGCTRL |= RTC_DBGRUN_bm;
	RTC.PITINTCTRL |= RTC_PI_bm; //enable interrupt
	RTC.PITCTRLA |= RTC_PERIOD_CYC128_gc //8Hz @ 1khz int clk
	RTC.PITCTRLA |= RTC_PITEN_bm;
	
		
	return;
}