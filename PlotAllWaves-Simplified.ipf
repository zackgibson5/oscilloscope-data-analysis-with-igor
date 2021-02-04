#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function to plot waves within PlotAllWaves function below
//searchstr must be the input used for WaveList search function
//for example if you want all waves for 0.5 ns pulse width you would use searchstr = "*0_5ns*" and YES you must include the quotes
//Then for the searchstrFFT, you simply append FFT to your search str e.g. "*0_5ns*FFT*"
//Then for the last input, PlotTitlestr is the title you would like on your plot, and PlotTitleFFTstr is the plot title to your FFT plot
Function EasyPlot(searchstr, searchstrFFT, PlotTitlestr, PlotTitleFFTstr)

	//searchstr must be the input used for WaveList search function
	//for example if you want all waves for 0.5 ns pulse width you would use searchstr = "*0_5ns*" and YES you must include the quotes
	//Then for the searchstrFFT, you simply append FFT to your search str e.g. "*0_5ns*FFT*"
	//Then for the last input, PlotTitlestr is the title you would like on your plot, and PlotTitleFFTstr is the plot title to your FFT plot
	String searchstr, searchstrFFT, PlotTitlestr, PlotTitleFFTstr	
	
	//Declare local variable(s)
	Variable i = 0
	
	//Create table of color values to be used in plots later
	//Can change the color scheme from "Rainbow" to other Igor color scheme if desired
	ColorTab2Wave Rainbow
	Wave M_colors
	Variable colorindex = 0
	//Variable N = DimSize(M_colors, 0)
	//print N
	//print M_colors
	
	//Change this to whatever folder has the data you need
	SetDataFolder root:
	
	String ListOfWaves = WaveList(searchstr,";","")
	String ListOfWaves_FFT = WaveList(searchstrFFT, ";", "")
	ListOfWaves = RemoveFromList(ListOfWaves_FFT, ListOfWaves, ";")
		
	//This sorts the list alphanumerically, that way the waves I want to plot should be next to each other in the list
	//The "16" parameter at the end indicates that the waves will be sorted to alpha-numeric list (caps insensitive)
	ListOfWaves = SortList(ListOfWaves, ";", 16)
	ListOfWaves_FFT = SortList(ListOfWaves_FFT, ";", 16)
	
	//First you have to initialize the plot with the first wave
	Display $StringFromList(0, ListOfWaves, ";") vs $StringFromList(1, ListOfWaves, ";") as PlotTitlestr
	//This loop adds all the rest of the waves
	for(i=0; i<ItemsInList(ListOfWaves); i+=2)	
		AppendToGraph  $StringFromList(i, ListOfWaves, ";") vs $StringFromList(i+1, ListOfWaves, ";")	
		//This part will (optionally, comment out if not desired) color each wave in the colors of the rainbow, equally spaced in the Igor color scheme "Rainbow"
		colorindex = i * 100 / ItemsInList(ListOfWaves)
		ModifyGraph rgb($StringFromList(i, ListOfWaves, ";")) = (	 M_colors[colorindex][0], M_colors[colorindex][1], M_colors[colorindex][2])				
	endfor		
	
	//Now we modify the plot to look pretty, even though the waves are already colored from within the above loop
	ModifyGraph margin(top)=36
	TextBox/X=39.5/Y=-7/F=0 "\\Z24" + PlotTitlestr
	ModifyGraph nticks=10,minor=1;DelayUpdate
	Label left "\\u#2 Amplitude (V 100:1)";DelayUpdate
	Label bottom "2Time (s)"
	Legend/F=0/A=RT
	
	//Now to plot the FFTs
	
	//First you have to initialize the plot with the first wave
	Display $StringFromList(0, ListOfWaves_FFT, ";") vs $StringFromList(1, ListOfWaves_FFT, ";") as PlotTitlestr
	//This loop adds all the rest of the waves
	for(i=2; i<ItemsInList(ListOfWaves_FFT); i+=2)	
		AppendToGraph  $StringFromList(i, ListOfWaves_FFT, ";") vs $StringFromList(i+1, ListOfWaves_FFT, ";")	
		//This part will (optionally, comment out if not desired) color each wave in the colors of the rainbow, equally spaced in the Igor color scheme "Rainbow"
		colorindex = i * 100 / ItemsInList(ListOfWaves_FFT)
		ModifyGraph rgb($StringFromList(i, ListOfWaves_FFT, ";")) = (M_colors[colorindex][0], M_colors[colorindex][1], M_colors[colorindex][2])				
	endfor		
	
	//Now we modify the plot to look pretty, even though the waves are already colored from within the above loop
	ModifyGraph margin(top)=36
	TextBox/X=39.5/Y=-7/F=0 "\\Z24" + PlotTitleFFTstr
	ModifyGraph nticks=10,minor=1;DelayUpdate
	Label left "\\u#2 Amplitude (arb. units)";DelayUpdate
	Label bottom "Frequency (Hz)"
	Legend/F=0/A=RT
	
end




//This function will plot all waves in the current folder (folder in IGOR, not your current folder in your computer files)
//ANY ODDLY NAMED WAVES MUST BE ADDED TO IGOR AFTER RUNNING THIS PROGRAM OR IT MAY
//PLOT NONSENSE
Function PlotAllWaves()
	
//You may plot as many functions as you want by calling the EasyPlot function that is above

//0.5 ns pulse width
EasyPlot("*0_5ns*","*0_5ns*FFT*","0.5 ns Pulse Width", "0.5 ns Pulse Width - FFT")

//1 ns pulse width
EasyPlot("*1ns*","*1ns*FFT*","1 ns Pulse Width", "1 ns Pulse Width - FFT")

//1.5 ns pulse width
EasyPlot("*1_5ns*","*1_5ns*FFT*","1.5 ns Pulse Width", "1.5 ns Pulse Width - FFT")

//2 ns pulse width
EasyPlot("*2ns*","*2ns*FFT*","2 ns Pulse Width", "2 ns Pulse Width - FFT")

//2.5 ns pulse width
EasyPlot("*2_5ns*","*2_5ns*FFT*","2.5 ns Pulse Width", "2.5 ns Pulse Width - FFT")

//3 ns pulse width
EasyPlot("*3ns*","*3ns*FFT*","3 ns Pulse Width", "3 ns Pulse Width - FFT")

//3.5 ns pulse width
EasyPlot("*3_5ns*","*3_5ns*FFT*","3.5 ns Pulse Width", "3.5 ns Pulse Width - FFT")

//4 ns pulse width
EasyPlot("*4ns*","*4ns*FFT*","4 ns Pulse Width", "4 ns Pulse Width - FFT")

//4.5 ns pulse width
EasyPlot("*4_5ns*","*4_5ns*FFT*","4.5 ns Pulse Width", "4.5 ns Pulse Width - FFT")

//5 ns pulse width
EasyPlot("X5ns*","X5ns*FFT*","5 ns Pulse Width", "5 ns Pulse Width - FFT")

//1 kV amplitude
EasyPlot("*1kV*","*1kV*FFT*","1 kV Pulse Amplitude", "1 kV Pulse Amplitude - FFT")

//1.2 kV amplitude
EasyPlot("*1_2kV*","*1_2kV*FFT*","1.2 kV Pulse Amplitude", "1.2 kV Pulse Amplitude - FFT")

//1.4 kV amplitude 
EasyPlot("*1_4kV*","*1_4kV*FFT*","1.4 kV Pulse Amplitude", "1.4 kV Pulse Amplitude - FFT")

//1.6 kV amplitude
EasyPlot("*1_6kV*","*1_6kV*FFT*","1.6 kV Pulse Amplitude", "1.6 kV Pulse Amplitude - FFT")

//1.8 kV amplitude
EasyPlot("*1_8kV*","*1_8kV*FFT*","1.8 kV Pulse Amplitude", "1.8 kV Pulse Amplitude - FFT")

//2 kV amplitude
EasyPlot("*ns2kV*","*ns2kV*FFT*","2 kV Pulse Amplitude", "2 kV Pulse Amplitude - FFT")
	
end


//In case you keep plotting way too many graphs that aren't right
//This kills all graphs
Function KillAllGraphs()
    string fulllist = WinList("*", ";","WIN:1")
    string name, cmd
    variable i
   
    for(i=0; i<itemsinlist(fulllist); i +=1)
        name= stringfromlist(i, fulllist)
        sprintf  cmd, "Dowindow/K %s", name
        execute cmd    
    endfor
end

//This is a macro that execute the above function
Menu "Macros"
	"Kill all graphs", KillAllGraphs()
end

//More macros in the GUI
Menu "Macros"
	"Plot all waves", PlotAllWaves()
end
