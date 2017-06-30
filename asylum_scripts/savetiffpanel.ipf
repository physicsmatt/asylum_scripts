//function ExtractTiffPhase()
//	//String path
//	//String name
//	Wave image
//	//Wave image2
//	//prompt path,"Please, enter the path for the picture"
//	//prompt name,"Please, enter the name of the picture"
//	//Doprompt "Picture",path,name
//	//NewPath Path1,path
//	ImageLoad/O/T=tiff/S=3 /C=1 /N=image /G
//	doupdate
//	print S_filename
//	print S_waveNames
//	print S_path
//	print V_flag
//	if(V_flag)
//		if (cmpstr(S_waveNames,"")!=0)
//			ImageTransform flipCols image3
//			ImageSave/F/I/O/T="tiff" image3
//		else
//			print "Extraction failed, layers incorrect"
//		endif
//	endif
//	
//end

function SaveTiff()
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