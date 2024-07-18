//setup
startTime = getTime();
print("\\Clear");
fs = File.separator;
run("Clear Results");
roiManager("reset");

//choosing directory
imgDir = getDirectory("Choose image directory for stitching");
fileList = getFileList(imgDir);

setBatchMode(true);
for(i=0; i<fileList.length; i++){
	if(endsWith(fileList[i], ".tif")){
		open(imgDir+fs+fileList[i]);

		filename = getTitle();
		getDimensions(width, height, channels, slices, frames);
		run("Split Channels");

		selectWindow("C"+2+"-"+filename);
		run("Flip Horizontally");
		run("Flip Vertically");

		selectWindow("C"+3+"-"+filename);
		run("Flip Horizontally");
		run("Flip Vertically");

		run("Merge Channels...", "c1=C1-"+filename+" c2=C2-"+filename+" c3=C3-"+filename+" c4=C4-"+filename+" create");

		saveAs("TIFF", imgDir+fs+filename);
		close(filename);
	}
};
setBatchMode("exit and display");
print("Done");
beep();
