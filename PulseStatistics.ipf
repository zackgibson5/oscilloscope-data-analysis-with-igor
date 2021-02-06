#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//This utilizes built-in functions from PulseStats to find pulse widths, maxima, etc. and puts all of that
//data into waves for comparison
//Currently built in is: Double checking measured amplitude vs input settings, double check FWHM against input pulse width
//looks for correlation between FWHM and measured amplitude, computes aspect ratio and plots it vs amplitde and FWHM,
//and also finds the FFT 3 dB frequency (the bandwidth of the pulse) and plots that agains FWHM and amplitude
Function ComputePulseStatistics()

	//Set the timestep for accurate results (look at the time data!)
	Variable timestep = 8e-12
	//These variables are used in determining the bandwidth of the pulse
	variable level
	variable Freq3dB
	//Remember to change this to the proper frequency for the FFT
	//It is the interval between points in the FFT
	variable FreqInterval = 100e6
	
	//Create a list of waves to cycle through
	//Arbitrarily chose "kV" to be sure I don't pick up other weird waves like M_colors
	String ListOfWaves = WaveList("*kV*", ";", "")
	
	//Also remove any FFTs from the main list
	String ListOfWaves_FFT = WaveList("*FFT*", ";", "")
	ListOfWaves = RemoveFromList(ListOfWaves_FFT, ListOfWaves, ";")
	//Also remove any of the time waves, those are not needed here
	String ListOfWaves_time = WaveList("*ti*",";","")
	ListOfWaves = RemoveFromList(ListOfWaves_time, ListOfWaves, ";")
	ListOfWaves_FFT = RemoveFromList(ListOfWaves_time, ListOfWaves_FFT, ";")
	//Also remove any of the waves that were attenuated since the amplitude won't be correct
	//String ListOfWaves_A = WaveList("*_A_*", ";", "")
	//ListOfWaves = RemoveFromList(ListOfWaves_A, ListOfWaves, ";")
	
	//Also want to remove any of the normalized plots from messing up the way the data is plotted
	//Normalized waves are re-saved with an append "_n"
	String ListOfWaves_normalized = WaveList("*_n", ";", "")
	ListOfWaves = RemoveFromList(ListOfWaves_normalized, ListOfWaves, ";")
	ListOfWaves_FFT = RemoveFromList(ListOfWaves_normalized, ListOfWaves_FFT, ";")
	
	//This sorts the list alphanumerically, that way the waves I want to plot should be next to each other in the list
	//The "16" parameter at the end indicates that the waves will be sorted to alpha-numeric list (caps insensitive)
	ListOfWaves = SortList(ListOfWaves, ";", 16)
	ListOfWaves_FFT = SortList(ListOfWaves_FFT, ";", 16)
	
	//Create wave to hold FWHM values
	Make/N=(ItemsInList(ListOfWaves)) FWHM_measured
	//Create wave to hold pulse width value, that is the value from the setting on the high voltage pulse generator
	//This will be unnecessary in analysis of PEA data, only FWHM will be calculated/needed
	Make/N=(ItemsInList(ListOfWaves)) FWHM_settings
	//Create wave to hold pulse amplitude data
	Make/N=(ItemsInList(ListOfWaves)) Amplitude_measured
	//Create wave to hold pulse amplitude data from settings
	Make/N=(ItemsInList(ListOfWaves)) Amplitude_settings
	//Create wave to hold aspect ratio data
	Make/N=(ItemsInList(ListOfWaves)) AspectRatio
	
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
	
	//Create Aspect Ratio Wave
	AspectRatio = FWHM_measured / Amplitude_measured
	
	//Now plot the results
	Display FWHM_measured vs FWHM_settings as "FWHM Accuracy"
	ModifyGraph mode=3; DelayUpdate
	ModifyGraph mrkThick=2
	ModifyGraph margin(top)=36; DelayUpdate
	TextBox/X=39.5/Y=-7/F=0 "\\Z24 FWHM Accuracy"; DelayUpdate
	ModifyGraph nticks=10,minor=1;DelayUpdate
	Label left "\\u#2 FWHM Measured (ns)";DelayUpdate
	Label bottom "\\u#2 Pulse Width Setting (ns)"
	
	Display Amplitude_measured vs Amplitude_settings as "Amplitude Accuracy"
	ModifyGraph mode=3; DelayUpdate
	ModifyGraph mrkThick=2
	ModifyGraph margin(top)=36; DelayUpdate
	TextBox/X=39.5/Y=-7/F=0 "\\Z24Amplitude Accuracy"; DelayUpdate
	ModifyGraph nticks=10,minor=1;DelayUpdate
	Label left "\\u#2 Amplitude Measured (V)";DelayUpdate
	Label bottom "\\u#2 Amplitude Setting (V)"
	
	Display FWHM_measured vs Amplitude_measured as "Measured FWHM and Amplitude Correlation"
	ModifyGraph mode=3; DelayUpdate
	ModifyGraph mrkThick=2
	ModifyGraph margin(top)=36; DelayUpdate
	TextBox/X=39.5/Y=-7/F=0 "\\Z24 Measured FWHM and Amplitude Correlation"; DelayUpdate
	ModifyGraph nticks=10,minor=1;DelayUpdate
	Label left "\\u#2 FWHM Measured (ns)";DelayUpdate
	Label bottom "\\u#2 Amplitude Measured (V)"
	
	Display AspectRatio vs Amplitude_measured as "Aspect Ratio vs Amplitude"
	ModifyGraph mode=3; DelayUpdate
	ModifyGraph margin(top)=36; DelayUpdate
	TextBox/X=39.5/Y=-7/F=0 "\\Z24 Aspect Ratio vs Amplitude"; DelayUpdate
	ModifyGraph nticks=10,minor=1;DelayUpdate
	Label left "\\u#2 Aspect Ratio (ns/kV)";DelayUpdate
	Label bottom "\\u#2 Amplitude Measured (V)"
	//Add color to the markers as a 3rd dimension
	ModifyGraph zColor(AspectRatio)={FWHM_measured,*,*,Rainbow,0}
	ColorScale/C/N=text1/F=0/A=MC trace=AspectRatio
	ModifyGraph mrkThick=2
	ColorScale/C/N=text1/F=0/x=56.5 "\\u#2 Measured FWHM (ns)"
	ModifyGraph margin(right)=108
	
	Display AspectRatio vs FWHM_measured as "Aspect Ratio vs FWHM"
	ModifyGraph mode=3; DelayUpdate
	ModifyGraph margin(top)=36; DelayUpdate
	TextBox/X=39.5/Y=-7/F=0 "\\Z24 Aspect Ratio vs FWHM"; DelayUpdate
	ModifyGraph nticks=10,minor=1;DelayUpdate
	Label left "\\u#2 Aspect Ratio (ns/kV)";DelayUpdate
	Label bottom "\\u#2 FWHM Measured (ns)"
	//Add color to the markers as a 3rd dimension
	ModifyGraph zColor(AspectRatio)={Amplitude_measured,*,*,Rainbow,0}
	ColorScale/C/N=text1/F=0/A=MC trace=AspectRatio
	ModifyGraph mrkThick=2
	ColorScale/C/N=text1/F=0/x=56.5 "Measured Amplitude (V)"
	ModifyGraph margin(right)=108
	
	///////////////////This section is for finding the pulse bandwidth by finding the -3 dB frequency from the FFTs/////////
	
	//Create wave to hold bandwidth data
	Make/N=(ItemsInList(ListOfWaves_FFT)) Bandwidth3dB
		
	//Fill the Bandwidth3dB wave with the -3 dB frequencies for each pulse	
	for(i=0; i<ItemsInList(ListOfWaves_FFT); i +=1)
		
		//Get V_max for use in finding the correct level to search for
		WaveStats/Q $StringFromList(i, ListOfWaves_FFT, ";")
		
		//Find the -3 dB level to search for
		level = V_max / 2
		
		//Find the -3 dB level
		FindLevel/Q/EDGE=2 $StringFromList(i, ListOfWaves_FFT, ";") level
		
		//This uses the level found (interpolated between points) from the FindLevel function
		//So finds the x value at -3 dB level, but here we turn that into the true frequency by 
		//multiplying by the frequency step interval, in this case 100 MHz
		Freq3dB = V_LevelX * FreqInterval
		
		//Fill in the wave with the 3 dB level that was just found
		Bandwidth3dB[i] = Freq3dB
		Print(StringFromList(i, ListOfWaves_FFT, ";"))
		
	endfor
	
	//Plotting the Bandwidth data
	Display Bandwidth3dB vs FWHM_measured as "Bandwidth vs Measured FWHM"
	ModifyGraph mode=3; DelayUpdate
	ModifyGraph margin(top)=36; DelayUpdate
	TextBox/X=39.5/Y=-7/F=0 "\\Z24 Bandwidth (-3 dB) vs Measured FWHM"; DelayUpdate
	ModifyGraph nticks=10,minor=1;DelayUpdate
	Label left "\\u#2 Bandwidth (MHz)";DelayUpdate
	Label bottom "\\u#2 FWHM Measured (ns)"
	//Add color to the markers as a 3rd dimension
	ModifyGraph zColor(Bandwidth3dB)={Amplitude_measured,*,*,Rainbow,0}
	ColorScale/C/N=text1/F=0/A=MC trace=Bandwidth3dB
	ModifyGraph mrkThick=2
	ColorScale/C/N=text1/F=0/x=56.5 "Measured Amplitude (V)"
	ModifyGraph margin(right)=108
	
	Display Bandwidth3dB vs FWHM_measured as "Bandwidth vs Measured Amplitude"
	ModifyGraph mode=3; DelayUpdate
	ModifyGraph margin(top)=36; DelayUpdate
	TextBox/X=39.5/Y=-7/F=0 "\\Z24 Bandwidth (-3 dB) vs Measured Amplitude"; DelayUpdate
	ModifyGraph nticks=10,minor=1;DelayUpdate
	Label left "\\u#2 Bandwidth (MHz)";DelayUpdate
	Label bottom "Measured Amplitdue (V)"
	//Add color to the markers as a 3rd dimension
	ModifyGraph zColor(Bandwidth3dB)={FWHM_measured,*,*,Rainbow,0}
	ColorScale/C/N=text1/F=0/A=MC trace=Bandwidth3dB
	ModifyGraph mrkThick=2
	ColorScale/C/N=text1/F=0/x=56.5 "\\u#2 Measured FWHM (ns)"
	ModifyGraph margin(right)=108
		
	
end	

//Re do the pulse statistics
Function RedoComputePulseStatistics()
	
	//Kill the stat waves
	Wave FWHM_settings, FWHM_measured, Amplitude_settings, Amplitude_measured, AspectRatio, Bandwidth3dB
	KillWaves FWHM_settings, FWHM_measured, Amplitude_settings, Amplitude_measured, AspectRatio, Bandwidth3dB
	
	//Re do stats
	ComputePulseStatistics()
	
end


//Add menu item
Menu "Macros"
	"Get pulse statistics", ComputePulseStatistics()
end

//Re-Do Pulse Statistics
Menu "Macros"
	"Re-do Pulse Statistics", RedoComputePulseStatistics()
end