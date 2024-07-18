print("\\Clear");
fs = File.separator;
imgDir = getDirectory("Choose a Directory to to load images from");
print("Img directory: "+imgDir);
imgList = getFileList(imgDir);
print("Number of images in dir: "+imgList.length);

saveDir = getDirectory("Choose directory to save images");

setBatchMode(true);
for (i = 0; i < imgList.length; i++) {
	showProgress(-i/imgList.length);
	if(endsWith(imgList[i], "tif")) {
		open(imgDir+File.separator+imgList[i]);
		title = getTitle();
		subtitle = substring(title, 0, indexOf(title, ".tif"));

		selectWindow(title);
		run("Duplicate...", "title=R");
		rename("G");
		run("Duplicate...", "title=R");
		rename("B");

		run("Merge Channels...", "c1="+title+" c2=G c3=B ignore");
		saveAs("TIFF", saveDir+fs+subtitle+".tif");
		run("Close All");
	}
}
setBatchMode(false);
