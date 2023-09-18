#include "/resources/kernel/wramp.h"

//parallel main method
void parallel_main(){
	//intialise variables
	int style = 0;
	int switchesVal = 0;
	
	//keep chekcing while running
	while(1) {
		//get the sitches values
		switchesVal = WrampParallel->Switches;
		
		//if button 0 is pushed set style to 5
		if(WrampParallel->Buttons & 1){
			style = 5;
		}
		//if button 1 is pushed set style to 10
		else if(WrampParallel->Buttons & 2){
			style = 10;
		}
		//if button 2 was pushed return
		else if(WrampParallel->Buttons & 4){
			return;
		}
		
		//if the style is 10 display in hex
		if(style == 10){
			WrampParallel->UpperLeftSSD = (switchesVal >> 12);
			
			WrampParallel->UpperRightSSD = (switchesVal >> 8);
			
			WrampParallel->LowerLeftSSD = (switchesVal >> 4);
			
			WrampParallel->LowerRightSSD = (switchesVal);
		}
		
		//if style is 5 display in decimal
		else{
			WrampParallel->UpperLeftSSD = (switchesVal / 1000) % 10;
			
			WrampParallel->UpperRightSSD = (switchesVal/ 100) % 10;
			
			WrampParallel->LowerLeftSSD = (switchesVal / 10) % 10;
			
			WrampParallel->LowerRightSSD = (switchesVal / 1) % 10;
		}
	
	}



}
