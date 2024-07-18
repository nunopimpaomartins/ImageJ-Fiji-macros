imgDir = getDirectory("Choose directory containing images.");
print("Save directory: "+imgDir);
dirList = getFileList(imgDir);
//print("List length: "+dirList.length);
//dirList = Array.sort(dirList);

saveDir = imgDir + "frames_remaining";
if(!File.exists(saveDir)) {
	File.makeDirectory(saveDir);
};

nTiles = (4 ^ 2);
nZslices = dirList.length/nTiles;

/*if (nZslices == parseInt(nZslices)) {
	exit("number of Z Slices is not an integer, check tile size.");
};*/

firstInd = dirList.length - 16;

setBatchMode(true);
for (i = firstInd; i < dirList.length; i++) {
	if(endsWith(dirList[i], "tif")) {
		open(imgDir+File.separator+dirList[i]);
		title = getTitle();
		subtitle = substring(title, 0, indexOf(title, ".tif"));
		selectWindow(title);
		getStatistics(img_area, img_mean, img_min, img_max, img_std, img_histogram);
		setSlice(1);
		run("Duplicate...", "title=frame_to_save");
		selectWindow("frame_to_save");
		denormalize("frame_to_save", img_min, img_max);
		saveAs("TIFF", saveDir+File.separator+subtitle+".tif");
		run("Close All");
	}
}
setBatchMode("exit and display");
beep();

function denormalize(img, img_min, img_max){
	//Min Max de-normalization between [0,255]
	selectWindow(img);
	if(bitDepth() == 24){
		exit("Does not work with RGB images");
	} else if(bitDepth()!=32){
		run("32-bit");
	};
	getDimensions(width, height, channels, slices, frames);
	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			px_value = getPixel(i, j);
			px_denom = (px_value - img_min) * (255 / (img_max - img_min));
			setPixel(i, j, px_denom);
		}
	}
}