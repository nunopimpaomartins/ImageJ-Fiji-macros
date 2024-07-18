imgDir = getDirectory("Choose a Directory to save");
print("Image directory: "+imgDir);
fileList = getFileList(imgDir);
print("File number in directory: "+fileList.length);
fs = File.separator;

setBatchMode(true);
for (i=0; i<fileList.length; i++){
	if(endsWith(fileList[i], ".tif")){
		open(imgDir+fs+fileList[i]);
		title = getTitle();
		titleNoExt = substring(title, 0, indexOf(title, ".tif"));
		setSlice(200);
	
		setMinAndMax(0, 65535);
		run("16-bit");
		run("Bleach Correction", "correction=[Histogram Matching]");
		selectWindow("DUP_"+title);
		saveAs("TIFF", imgDir+fs+titleNoExt+"_Znormalized.tif");
		run("Close All");
	};
};
setBatchMode("exit and display");
print("Done");
beep();