#pragma rtGlobals=3		// Use modern global access method.

Window panelphase() : Panel
	SetDataFolder "root:Images"
	String waves = WaveList("*",";","Text:0,Dims:3")
	Variable numitems=itemsinlist(waves)
	newdatafolder/O/S :phase
	Make/T/O/N=(numitems) listwave
	Make/O/N=(numitems) listwavebuddy///new
	////new
	Variable i =0
	do
		listwave[i]=StringFromList(i,waves)
		i+=1
	while (i<numitems) 	
	print listwave
	//endfor
	/////
	if (numitems>=1)
		//makewaves(listwave,waves,i) ///new
	else
		print "no opened pictures!"
		Make/T/O/N=1 listwave
		listwave[0]="Load an image into memory"
	endif
	SetDataFolder "root:Images"///new
	Variable/G wavenameschecked=0
	Variable/G overwriteChecked=0
	Variable/G selectedlayer=7///new, was 3
	String/G location ="Z:/Greg Hamilton/Summer 2014"//C:\\Research Data\\Images\\Summer Research Group" //new
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1505,292,1975,620)
	DoWindow Layer_Extract
	if (V_flag)
		DoWindow/K Layer_Extract
	endif
	DoWindow/C Layer_Extract
	ShowTools
	SetDrawLayer UserBack
	SetDrawEnv save
	Button Gobutton,pos={6,300},size={50,20},proc=GoProc,title="Go"
	ListBox waveslistbox,pos={10,5},size={265,255},proc=ListBoxProc,frame=2
	ListBox waveslistbox,listWave=listwave
	ListBox waveslistbox,selWave=listwavebuddy,mode= 3
	Button Cancelbutton,pos={75,300},size={50,20},proc=CancelbuttonProc,title="Cancel"
	Button Helpbutton,pos={200,300},size={50,20},proc=HelpButton,title="Help"
	Button Helpbutton,help={"Displays the help for this panel"}
	CheckBox UseWaveNameCheckBox,pos={290,15},size={134,14},proc=wavenamescheck,title="Write with wave names?"
	CheckBox UseWaveNameCheckBox,help={"If checked, will use the wave name as the name of the wave"}
	CheckBox UseWaveNameCheckBox,variable= root:Images:wavenameschecked, value=1
	CheckBox OverwriteCheckBox,pos={310,35},size={105,14},proc=OverwriteCheck,title="Overwrite images?"
	CheckBox OverwriteCheckBox,value= 0,variable= root:Images:overwritechecked, value=1
	PopupMenu layermenu,pos={290,150},size={103,21},proc=PopMenuProc,title="Pick a layer"
	PopupMenu layermenu,help={"Selects the layer to extract and save to .TIFF"}
	PopupMenu layermenu,mode=4,popvalue="7",value= #"\"1;2;3;4;5;6;7;8;9;10;11;12\"" //line modified by Nate June 26th, 2008 so that layer 1-12 can be selected instead of layers 1-6 //also popvalue was 7
	SetVariable Setvar1,value=location,limits={0,0,0},pos={10,275},size={426,25}
	doupdate
EndMacro

Function GoProc(ctrlName) : ButtonControl
	String ctrlName
	SetDataFolder "root:Images"///new
	Variable i
	Wave/T listwave
	print listwave
	Wave listwavebuddy
	print listwavebuddy
	Variable listsize= dimsize(listwave,0)
	Make/T/O/N=(listsize) failedlist
	NVAR wavenameschecked
	Variable size = dimsize(listwavebuddy,0)
	Variable numberfailed=0
	Variable failed
	for(i=0;i<size;i+=1)
		failed=0
		if (listwavebuddy[i]==1)
			if (wavenameschecked)
				failed=savephase(listwave[i],savename=listwave[i])
			else
				failed=savephase(listwave[i])
			endif
			if (failed==1)
				numberfailed+=1
				failedlist[numberfailed-1]=(listwave[i])
			endif
		endif
	endfor
	if (numberfailed > 0)
		print ""
		print "The waves that failed were:"
		print failedlist
		print "Please open manually"
	else
		print ""
		print "Great Success"
	endif
	Killwaves failedlist
	Layercleanup()
End

Function makewaves(listwaves,waves,number)
	Wave/t listwaves
	Variable number
	String waves
	Variable i
	SetDataFolder "root:Images"
	for(i=0;i<number;i+=1)
		listwaves[i]=StringFromList(i,waves)
	endfor
end


function savephase(name,[savename])
	String name
	String savename
	SetDataFolder "root:Images"///new
	SVAR location
	NewPath/C/O/Q path location
	NVAR selectedlayer
	NVAR wavenameschecked
	NVAR overwriteChecked
	Variable failed=0
	
	if (Cmpstr(name,"")!=0)
		if (waveexists($name))
			Wave image=$name
			Make/O/N=(dimsize($name,0),dimsize($name,1)) new
			try
				new = image[p][q][selectedlayer-1]
				ImageTransform flipCols new
				if(ParamisDefault(savename))
					ImageSave/F/D=32/T="tiff"/P=path new 
				else
					if(overwriteChecked)
						ImageSave/F/O/D=32/T="tiff"/P=path new (savename+".tif")
					else
						ImageSave/F/D=32/T="tiff"/P=path new savename
					endif
				endif
				print name, "layer", selectedlayer, " save completed"
			catch
				print name, " has too few layers for that selection.  Excluding and continuing"
				failed=1
			endtry
		else
			try
				print "Trying to load  ",name,"..."
				//SetDataFolder "root:Images"
				//LoadData/D/Q/P=Loadpath/J=(name)
				Loadwave/Q/P=Loadpath/N=name (name+".ibw")
				//SetDataFolder "root:Images:phase"
				if (waveexists($name))
					print "load successfull."
					Wave image=$name
					Make/O/N=(dimsize($name,0),dimsize($name,1)) new
					try
						new = image[p][q][selectedlayer-1]
						ImageTransform flipCols new
						if(ParamisDefault(savename))
							ImageSave/F/D=32/T="tiff"/P=path new 
						else
							if(overwriteChecked)
								ImageSave/F/O/D=32/T="tiff"/P=path new (savename+".tif")
							else
								ImageSave/F/D=32/T="tiff"/P=path new savename
							endif
						endif
						print name, "layer", selectedlayer, " save completed"
					catch
						print name, " has too few layers for that selection.  Excluding and continuing"
						failed=1
					endtry
				else
					print "Loaded, but error in file, please open into memory manually.  File: ",name
					failed=1
				endif
			catch
				print "no such wave exists"
				failed=1
			endtry
		endif
	else
		print "null string name"
		failed=1
	endif
	if (failed==1)
	else
		KillWaves new
	endif
	return failed
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
	SetDataFolder "root:Images"//new
	NVAR overwriteChecked=checked
End

Function wavenamescheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	SetDataFolder "root:Images"///new
	NVAR wavenameschecked=checked
	if (checked)
		ModifyControl Overwritecheckbox disable=0
	else
		ModifyControl Overwritecheckbox disable=1
	endif

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
	SetDataFolder "root:Images"
	NVAR selectedlayer
	selectedlayer=(str2num(popStr))
	print selectedlayer
End

Function Layercleanup()
SetDataFolder "root:Images"
	killvariables root:Images:wavenameschecked
	killvariables root:Images:overwriteChecked
	killvariables root:Images:selectedlayer
	Dowindow/K layer_extract
	killdatafolder root:Images:phase
end