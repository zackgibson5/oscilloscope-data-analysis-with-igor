#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//This utilizes built-in functions from PulseStats to find pulse widths, maxima, etc. and puts all of that
//data into waves for comparison
Function ComputePulseStatistics()

	//Set the timestep for accurate results (look at the time data!)
	Variable timestep = 8e-12
	
	//Create a list of waves to cycle through
	//Arbitrarily chose "kV" to be sure I don't pick up other weird waves like M_colors
	String ListOfWaves = WaveList("*kV*", ";", "")
	
	//Also remove any FFTs from list, because these are not being analyzed here
	String ListOfWaves_FFT = WaveList("*FFT*", ";", "")
	ListOfWaves = RemoveFromList(ListOfWaves_FFT, ListOfWaves, ";")
	//Also remove any of the time waves, those are not needed here
	String ListOfWaves_time = WaveList("*ti*",";","")
	ListOfWaves = RemoveFromList(ListOfWaves_time, ListOfWaves, ";")
	
	//This sorts the list alphanumerically, that way the waves I want to plot should be next to each other in the list
	//The "16" parameter at the end indicates that the waves will be sorted to alpha-numeric list (caps insensitive)
	ListOfWaves = SortList(ListOfWaves, ";", 16)
	
	//Create wave to hold FWHM values
	Make/N=(ItemsInList(ListOfWaves)) FWHM_measured
	//Create wave to hold pulse width value, that is the value from the setting on the high voltage pulse generator
	//This will be unnecessary in analysis of PEA data, only FWHM will be calculated/needed
	Make/N=(ItemsInList(ListOfWaves)) FWHM_settings
	//Create wave to hold pulse amplitude data
	Make/N=(ItemsInList(ListOfWaves)) Amplitude_measured
	//Create wave to hold pulse amplitude data from settings
	Make/N=(ItemsInList(ListOfWaves)) Amplitude_settings
	
	variable i = 0
	for(i=0; i<ItemsInList(ListOfWaves); i+=1)	
		
		//Get the max of the current pulse (stored in V_max)
		WaveStats/Q $StringFromList(i, ListOfWaves, ";")
		
		//Use V_max and 0 as the height and base level of the pulse
		PulseStats/Q/L=(V_max, 0) $StringFromList(i, ListOfWaves, ";")
		
		//Now compute and save the values for FWHM and Amplitude
		//FWHM must use the timestep to get the proper width in time and not just data points
		FWHM_measured[i] = V_PulseWidth2_1*timestep
		//To get the proper amplitude, you must multiply by 100 as the measurements are using a 100:1 tapoff
		//Note that the fraction is slightly higher than 100, refer to lab notebook for exact number
		//this may also drift with time due to the resitance of the tapoff...
		Amplitude_measured[i] = V_max*100
		
		//This appends the pulse width setting from the pulse generator into the wave PulseWidth
		//Each if (or elseif) statement looks to see if there is the search string in the wave name 
		//The search goes from 0.5 to 5 ns
		//StringMatch returns 1 if true or 0 if false
		if (StringMatch(StringFromList(i, ListOfWaves, ";"), "*0_5ns*") == 1)
			FWHM_settings[i] = 5e-10
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*1ns*") == 1)
			FWHM_settings[i] = 1e-9
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*1_5ns*") == 1)
			FWHM_settings[i] = 1.5e-9
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*2ns*") == 1)
			FWHM_settings[i] = 2e-9
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*2_5ns*") == 1)
			FWHM_settings[i] = 2.5e-9
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*3ns*") == 1)
			FWHM_settings[i] = 3e-9
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*3_5ns*") == 1)
			FWHM_settings[i] = 3.5e-9
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*4ns*") == 1)
			FWHM_settings[i] = 4e-9
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*4_5ns*") == 1)
			FWHM_settings[i] = 4.5e-9	
		elseif(StringMatch(StringFromList(i, ListOfWaves, ";"), "X5ns*") == 1)
			FWHM_settings[i] = 5e-9
		endif
		
		//Now we have to append data to the amplitude waveform settings
		if (StringMatch(StringFromList(i, ListOfWaves, ";"), "*1kV*") == 1)
			Amplitude_settings[i] = 1000
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*1_2kV*") == 1)
			Amplitude_settings[i] = 1200
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*1_4kV*") == 1)
			Amplitude_settings[i] = 1400
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*1_6kV*") == 1)
			Amplitude_settings[i] = 1600
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*1_8kV*") == 1)
			Amplitude_settings[i] = 1800
		elseif (StringMatch(StringFromList(i, ListOfWaves, ";"), "*ns2kV*") == 1)
			Amplitude_settings[i] = 2000
		endif
			
	endfor												
	
	//Now plot the results
	Display FWHM_measured vs FWHM_settings as "FWHM Accuracy"
	Display Amplitude_measured vs Amplitude_settings as "Amplitude Accuracy"
	Display FWHM_measured vs Amplitude_measured as "Measured FWHM and Amplitude Correlation"
	
	
end	

//Add menu item
Menu "Macros"
	"Get pulse statistics", ComputePulseStatistics()
end