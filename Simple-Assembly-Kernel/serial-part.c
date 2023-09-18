#include "/resources/kernel/wramp.h"


//prints characters
void printChar(char c) {
	while(!(WrampSp2->Stat & 2));
	WrampSp2->Tx = c;
}

//Counter variable
int counter = 0;
//serial main method
void serial_main(){
	char style = '1';
	
	//keeps checking while running
	while(1){
		
		//if serial port 2 has something writtent to it set local variable to it
		if(WrampSp2->Stat & 1){
			char c =  WrampSp2->Rx;
			if(c == '1' || c == '2' || c == '3' || c=='q'){
				style = c;
			}
		}
	
		printChar('\r');
		
		//‘1’ will set the format to “\rssss.ss”
		if(style == '1'){
			printChar((((counter / 100000) % 10) + 48));
			
			printChar((((counter / 10000) % 10) + 48));
			
			printChar((((counter / 1000) % 10) + 48));
			
			printChar((((counter / 100) % 10) + 48));
			
			printChar('.');
			
			printChar((((counter / 10) % 10) + 48));
			
			printChar((((counter / 1) % 10) + 48));
			
		}
		
		
		//‘2’ will set the format to “\rmm:ss”
		else if(style == '2'){
			printChar((((counter / 6000) / 10) % 10) + 48);
			
			printChar((((counter / 6000) % 10) + 48));
			
			printChar(':');
			
			printChar((((counter % 6000) / 1000) % 10) + 48);
			
			printChar((((counter % 6000) / 100) % 10) + 48);
			
			//two spaces to hide previous values
			printChar(' ');
			
			printChar(' ');
		}
		
		//‘3’ will set the format to “\rtttttt”
		else if(style == '3'){
			printChar((((counter / 100000) % 10) + 48));
			
			printChar((((counter / 10000) % 10) + 48));
			
			printChar((((counter / 1000) % 10) + 48));
			
			printChar((((counter / 100) % 10) + 48));
			
			printChar((((counter / 10) % 10) + 48));
			
			printChar((((counter / 1) % 10) + 48));
			
			//one space to hide previous value
			printChar(' ');
		}
		//quit program
		else if(style == 'q'){
			return;
		}
		
	}

}
