fs = File.separator;
imgDir = getDirectory("Choose Image folder");
print("Image folder: "+ imgDir);
fileList= getFileList(imgDir);

saveDir = imgDir+fs+"2d_frames";
if(!File.exists(saveDir)){
	File.makeDirectory(saveDir);
};

setBatchMode(true);
for(i=0; i<fileList.length; i++) {
	if(endsWith(fileList[i], ".tif")){
		open(imgDir+fs+fileList[i]);

		filename = getTitle();
		nameNoExt = substring(filename, 0, indexOf(filename, ".tif"));
		//print(subtitle);
		Stack.getDimensions(width, height, channels, slices, frames);
		padlen = 7;
		count = 0;
		
		for(j = 1; j <= slices; j++){
			selectWindow(filename);
			setSlice(j);
			count += 1;
			run("Duplicate...", "title=frame_"+j);
			saveAs("TIFF", saveDir+fs+nameNoExt+"_"+IJ.pad(count, padlen)+".tif");
			close(nameNoExt+"_"+IJ.pad(count, padlen)+".tif");
		};
		close(filename);
	};
};
setBatchMode("exit and display");
print("done");
beep();