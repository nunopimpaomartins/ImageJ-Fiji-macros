fs = File.separator;
imgDir = getDirectory("choose image Dir");
fileList = getFileList(imgDir);
print("image directory: "+imgDir);
print("Number of files in Dir: "+fileList.length);

saveDir = imgDir+fs+"cropped";
if(!File.exists(saveDir)){
	File.makeDirectory(saveDir);
};

setBatchMode(true);
for(i=0; i<fileList.length; i++) {
	if(endsWith(fileList[0], ".tif")){
		open(imgDir+fs+fileList[i]);
		filename = getTitle();
		roiManager("Select", 0);
		run("Crop");
		saveAs("TIFF", saveDir+fs+filename);
		run("Close All");
	}
}
setBatchMode("exit and display");
beep();
print("Done");