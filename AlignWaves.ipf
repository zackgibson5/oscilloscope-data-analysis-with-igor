#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <Append Calibrator>

//This function will make plots of waveforms where the rising edge is matched up for each of the waves
//A lot will be stolen from the procedure "PlotAllWaves-Simplified"
//THIS WILL IRREVERSIBLY CHANGE ALL OF THE TIME WAVES!!!!
Function AlignWaves()
	
	//Be sure to change this to match your data set!!
	Variable Timestep = 8e-12
	Variable i 
	Variable EdgeLocMin
	Variable EdgeTime

	
	//First we must find the minimum value for V_PulseLoc1 from the PulseStats function
	//That is, we must find the wave to align all other waves to
	
	//Create a list of waves to cycle through
	//Arbitrarily chose "kV" to be sure I don't pick up other weird waves like M_colors
	String ListOfWaves = WaveList("*kV*", ";", "")
	
	//Also remove any FFTs from list, because these are not being analyzed here
	String ListOfWaves_FFT = WaveList("*FFT*", ";", "")
	ListOfWaves = RemoveFromList(ListOfWaves_FFT, ListOfWaves, ";")
	//Also remove any of the time waves, those are not needed here
	String ListOfWaves_time = WaveList("*time*",";","")
	ListOfWaves = RemoveFromList(ListOfWaves_time, ListOfWaves, ";")
	
	//But we also will need the time data separately, so lets remove the FFT's
	ListOfWaves = RemoveFromList(ListOfWaves_FFT, ListOfWaves, ";")
	ListOfWaves_time = RemoveFromList(ListOfWaves_FFT, ListOfWaves_time, ";")
	
	//Let's be sure all our waves are in the correct order for manipulation
	//This sorts the list alphanumerically, that way the waves I want to plot should be next to each other in the list
	//The "16" parameter at the end indicates that the waves will be sorted to alpha-numeric list (caps insensitive)
	ListOfWaves = SortList(ListOfWaves, ";", 16)
	ListOfWaves_time = SortList(ListOfWaves_time, ";", 16)
	
	//Print(ItemsInList(ListOfWaves))
	//Print(ItemsInList(ListOfWaves_time))
	
	//Make a wave to hold all of the rising edge positions
	Make/N=(ItemsInList(ListOfWaves)) RisingEdgeLoc
	
	for(i=0; i<ItemsInList(ListOfWaves); i+=1)
	
		//Get the rising edge location
		WaveStats/Q $StringFromList(i, ListOfWaves, ";")
		//F determines the fraction of the height up the pulse of where the rising edge location is given
		//some adjusting may be necessary to find a trade off between a value high enough to work and a 
		//value low enough that the pulses are actually lined up
		PulseStats/Q/F=0.05/L=(V_max, 0) $StringFromList(i, ListOfWaves, ";")
		
		//Save the rising edge location for that wave
		RisingEdgeLoc[i] = V_PulseLoc1
	endfor
	
	//Assign the minimum rising edge position to EdgeLocMin
	EdgeLocMin = WaveMin(RisingEdgeLoc)
	EdgeTime = Round(EdgeLocMin)*timestep
		
	Variable Offset
	//Now every time wave will be offset to match the minimum rising edge wave
	for(i=0; i<ItemsInList(ListOfWaves_time); i+=1)
		
		//Find how much to subtract
		Wave TempWave = root:$StringFromList(i, ListOfWaves_time, ";")
		Offset = TempWave[RisingEdgeLoc[i]] - EdgeTime
		
		//Create new time waves for alignment
		//TempWave = root:$StringFromList(i, ListOfWaves_time, ";")
		//Duplicate TempWave $StringFromList(i, ListOfWaves_time, ";")+"_a"
		//Didn't finish this code, but could use this if you don't want to edit the original time waves
		
		//Subtract the time from each time wave to align with the original minimum time rising edge
		TempWave -= Offset
		//Print(StringFromList(i, Listofwaves_time, ";"))
		//Print(TempWave[250])
		
	endfor
	
	//A little clean-up
	KillWaves RisingEdgeLoc
	
end

//Add to menu
Menu "Macros"
	"Align pulses in all waves", AlignWaves()
end