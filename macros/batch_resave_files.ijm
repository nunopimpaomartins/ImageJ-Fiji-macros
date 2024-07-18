fs = File.separator;
imgDir = getDirectory("Choose a directory with images to save again.");
print("Save directory: "+imgDir);
dirList = getFileList(imgDir);
Array.sort(dirList);
print("List length: "+dirList.length);

saveDir = imgDir+fs+"tiffs";
if(!File.exists(saveDir)){
	File.makeDirectory(saveDir);
};

setBatchMode(true);
for (i = 0; i < dirList.length; i++) {
	if(endsWith(dirList[i], "tiff")) {
		open(imgDir+fs+dirList[i]);
		title = getTitle();
		subtitle = substring(title, 0, indexOf(title, ".ome."));
		saveAs("TIFF", saveDir+fs+subtitle+".tif");
		run("Close All");
	};
};
setBatchMode("exit and display");