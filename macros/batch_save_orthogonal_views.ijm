fs = File.separator;
imgDir = getDirectory("choose image Dir");
fileList = getFileList(imgDir);
print("image directory: "+imgDir);
print("Number of files in Dir: "+fileList.length);

saveDir = imgDir+fs+"orthos";
if(!File.exists(saveDir)){
	File.makeDirectory(saveDir);
};

saveDirTrain = saveDir+fs+"images";
if(!File.exists(saveDirTrain)) {
	File.makeDirectory(saveDirTrain);
};

saveDirLabel = saveDir+fs+"labels";
if(!File.exists(saveDirLabel)) {
	File.makeDirectory(saveDirLabel);
};

for(i=0; i<fileList.length; i++) {
	if(endsWith(fileList[0], ".tif")){
		open(imgDir+fs+fileList[i]);
		Stack.getDimensions(width, height, channels, slices, frames);
		if(channels < 3){
			print("Has less than 3 channels, should have 5. Skipping");
			continue;
		};
		nameFull = getTitle();
		nameNoExt = substring(nameFull, 0, indexOf(nameFull, ".tif"));

		//orthogonal for phalloidin
		run("Split Channels");
		selectWindow("C1-"+nameFull);
		c1_name = getTitle();
		c1_nameNoExt = substring(c1_name, 0, indexOf(c1_name, ".tif"));
		run("Reslice [/]...", "output=1.000 start=Top avoid");
		selectWindow("Reslice of "+c1_nameNoExt);
		saveAs("TIFF", saveDirTrain+fs+nameNoExt+"_xz.tif");
		close(nameNoExt+"_xz.tif");
		
		selectWindow(c1_name);
		run("Reslice [/]...", "output=1.000 start=Left avoid");
		selectWindow("Reslice of "+c1_nameNoExt);
		saveAs("TIFF", saveDirTrain+fs+nameNoExt+"_yz.tif");
		close(nameNoExt+"_yz.tif");

		//orthogonal for cd13
		selectWindow("C3-"+nameFull);
		c3_name = getTitle();
		c3_nameNoExt = substring(c3_name, 0, indexOf(c3_name, ".tif"));
		run("Reslice [/]...", "output=1.000 start=Top avoid");
		selectWindow("Reslice of "+c3_nameNoExt);
		saveAs("TIFF", saveDirLabel+fs+nameNoExt+"_xz.tif");
		close(nameNoExt+"_xz.tif");

		selectWindow(c3_name);
		run("Reslice [/]...", "output=1.000 start=Left avoid");
		selectWindow("Reslice of "+c3_nameNoExt);
		saveAs("TIFF", saveDirLabel+fs+nameNoExt+"_yz.tif");
		close(nameNoExt+"_xz.tif");

		run("Close All");
	}
}
