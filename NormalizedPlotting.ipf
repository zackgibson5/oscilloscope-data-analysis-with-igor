#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//I found these functions on the internet, and as such I do not have comments for the code

Menu "TracePopup"
    "Normalize By Wave Max", /Q, NormaliseTraceByMax("")
end

Menu "AllTracesPopup"
    "Normalize All By Maxima", /Q, NormaliseAllTracesByMax()
end

function NormaliseAllTracesByMax()
   
    string tracelist=TraceNameList("",";",1+4)
    string s_trace
    variable i=0, numTraces=ItemsInList(tracelist)
    for(i=0;i<numTraces;i+=1)
        s_trace=StringFromList(i,tracelist)
        NormaliseTraceByMax(s_trace)
    endfor
end

function NormaliseTraceByMax(s_trace, [x1, x2])
    string s_trace
    variable x1, x2
   
    if (strlen(s_trace)==0)
        GetLastUserMenuInfo
        string tracesList=S_traceName
    endif
       
    wave w=traceNameToWaveRef("",s_trace)
    if (waveexists(w)==0)
        return 0
    endif
   
    variable maxVal=nan
    if(ParamIsDefault(x1)||ParamIsDefault(x2))
        maxVal=wavemax(w)
    else
        maxVal=wavemax(w, x1, x2)
    endif
    duplicate /o w $nameofwave(w)+"_n" /wave=w_norm
    w_norm=w/maxVal
    printf "duplicate /o %s %s_n\r" nameofwave(w), nameofwave(w)
    printf "%s_n = %s/%g\r" nameofwave(w), nameofwave(w), maxVal
    ReplaceWave trace=$s_trace, $nameofwave(w)+"_n"
end

Menu "Macros"
    "Normalize all waves in top graph", NormaliseAllTracesByMax()
end