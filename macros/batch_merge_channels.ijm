fs = File.separator;
imgDir = getDirectory("Choose a image directory");
print("Image directory: "+imgDir);
fileList = getFileList(imgDir);
//Array.show(fileList);
fileList = Array.sort(fileList);
//Array.show(fileList2);
print("File number in directory: "+fileList.length);

parentDir = File.getParent(imgDir);
saveDir = parentDir+fs+"merged_images";
if(!File.exists(saveDir)){
	File.makeDirectory(saveDir);
};

//setBatchMode(true);
for (i=0; i<fileList.length; i+=5){
	for(j=0;j<5;j++){
		if(endsWith(fileList[i+j], ".tif")){
			open(imgDir+fs+fileList[i+j]);
			if(j==0){
				title = getTitle();
			};
		};
	};
	titleNoExt = substring(title, 0, indexOf(title, ".tif"));
	run("Merge Channels...", "c1="+fileList[i]+" c2="+fileList[i+1]+" c3="+fileList[i+2]+" c4="+fileList[i+3]+" c5="+fileList[i+4]+" create");
	selectWindow("Composite");
	saveAs("TIFF", saveDir+fs+titleNoExt+"_merged.tif");
	run("Close All");
};
//setBatchMode("exit and display");
print("Done");
beep();