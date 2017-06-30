#pragma rtGlobals=1		// Use modern global access method.
#include ":AsylumResearch:Code3D:Initialization"


	StartMeUp()

function LoadUserFunc()		//this loads the user functions

	PathInfo Igor
	
	NewPath/O/Q UserProcPath S_path+"AsylumResearch:Code3D:UserProcs:"
	string procStr
	string procList = IndexedFile(UserProcPath,-1,".ipf")


	Prompt procStr, "Which user procedure do you want to load?", popup, procList
	DoPrompt "Load User Procedure", procStr
	
	if (V_flag)
		return 1
	endif
	
	procStr = procStr[0,strsearch(procStr,".ipf",0)-1]
	Execute/P "DELETEINCLUDE \":AsylumResearch:Code3D:Initialization\""		//remove this so that
	Execute/P "INSERTINCLUDE \":AsylumResearch:Code3D:UserProcs:"+procStr+"\""			//this procedure will compile first
	Execute/P "INSERTINCLUDE \":AsylumResearch:Code3D:CompileHelper\""	//this has functions that the user functions need to compile
	Execute/P "COMPILEPROCEDURES "											//compile
	Execute/P "INSERTINCLUDE \":AsylumResearch:Code3D:Initialization\""		//reload the normal software
	Execute/P "DELETEINCLUDE \":AsylumResearch:Code3D:CompileHelper\""	//we don't need this now
	Execute/P "COMPILEPROCEDURES "											//recompile
	
	Execute/P/Q "Init"+procStr+"()"			//this does any initialization that the new procedure needs

end //LoadUserFunc

function RemoveUserFunc(procStr)		//this unloads the user functions
	string procStr

	Execute/P "DELETEINCLUDE \":AsylumResearch:Code3D:UserProcs:"+procStr+"\""		//remove the MainUser procedure
	Execute/P "COMPILEPROCEDURES "										//and recompile
	
end //RemoveUserFunc

Window panelphase() : Panel
	Variable/G wavenameschecked=0
	Variable/G overwriteChecked=0
	Variable/G selectedlayer=4
	makewaves()
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1505,292,1935,618)
	DoWindow/C Layer_Extract
	ShowTools
	SetDrawLayer UserBack
	SetDrawEnv save
	Button Gobutton,pos={6,300},size={50,20},proc=GoProc,title="Go"
	ListBox waveslistbox,pos={10,5},size={375,257},proc=ListBoxProc,frame=2
	ListBox waveslistbox,listWave=listwaves
	ListBox waveslistbox,selWave=waveselect,mode= 3
	Button Cancelbutton,pos={75,300},size={50,20},proc=CancelbuttonProc,title="Cancel"
	Button Helpbutton,pos={200,300},size={50,20},proc=HelpButton,title="Help"
	Button Helpbutton,help={"Displays the help for this panel"}
	CheckBox UseWaveNameCheckBox,pos={5,275},size={134,14},proc=wavenamescheck,title="Write with wave names?"
	CheckBox UseWaveNameCheckBox,help={"If checked, will use the wave name as the name of the wave"}
	CheckBox UseWaveNameCheckBox,variable= root:Images:iVar
	CheckBox OverwriteCheckBox,pos={155,275},size={105,14},proc=OverwriteCheck,title="Overwrite images?"
	CheckBox OverwriteCheckBox,value= 0
	PopupMenu layermenu,pos={270,275},size={103,21},proc=PopMenuProc,title="Pick a layer"
	PopupMenu layermenu,help={"Selects the layer to extract and save to .TIFF"}
	PopupMenu layermenu,mode=4,popvalue="4",value= #"\"1;2;3;4;5;6\""
EndMacro

Function GoProc(ctrlName) : ButtonControl
	String ctrlName
	print ctrlName

End

Function makewaves()
	String waves = WaveList("*",";","Text:0,Dims:3")
	Variable numitems=itemsinlist(waves)
	Variable i
	print waves
	Make/T/O/N=(numitems) listwaves
	Make/T/O/N=(numitems) wavesselect
	if (numitems>=1)
		for(i=0;i<numitems;i+=1)
			listwaves[i]=StringFromList(i,waves)
		endfor
	else
		print "no opened pictures!"
		listwaves[0]="empty"
	endif
end


function savephase()
	string name
	String waves = WaveList("*",";","Text:0,Dims:3")
	prompt name, "Please enter the name of the wave", popup waves
	doprompt "wave", name
	if (Cmpstr(name,"")!=0)
		if (waveexists($name))
			Wave image=$name
			Make/O/N=(dimsize($name,0),dimsize($name,1)) new
			new = image[p][q][4]
			ImageTransform flipCols new
			ImageSave/F/I/O/D=16/T="tiff" new
		else
			print "no such wave exists"
		endif
	else
		print "Canceled"
	endif
end


Function ListBoxProc(ctrlName,row,col,event) : ListBoxControl
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
	//5=cell select with shift key, 6=begin edit, 7=end
	return 0
End

Function CancelbuttonProc(ctrlName) : ButtonControl
	String ctrlName
	Layercleanup()
End

Function OverwriteCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	NVAR overwriteChecked=checked
End

Function wavenamescheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	NVAR wavenameschecked=checked

End

Function HelpButton(ctrlName) : ButtonControl
	String ctrlName
	String text = "select the images that you want to perform the phase operation on from the list.  If you would like to overwrite existing images, check the overwrite images checkbox."
	String text2= "  If you want to use the wave names rather than individual saves, check the 'write with wave names' checkbox.  The layer popup menu allows you to select which layer"
	String text3= " of the loaded image you would like to load.  Be carefull not to select a value greater than the number of layers in the images you select."
	print text+text2+text3
End

Function PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	NVAR selectedlayer = :root:selectedlayer
	selectedlayer=(str2num(popStr))
End

Function Layercleanup()
	DoWindow/k Layer_Extract
	KillVariables selectedlayer
	KillVariables wavenameschecked
	KillVariables overwriteChecked
	KillWaves listwaves
	KillWaves wavesselect
end