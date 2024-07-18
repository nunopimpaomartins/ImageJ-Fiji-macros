saveDir = getDirectory("Choose a Directory to save");
print("Save directory: "+saveDir);

title = getTitle();
titleNoExt = substring(title, 0, indexOf(title, ".lsm"));

Stack.getDimensions(width, height, channels, slices, frames);
padlen = 5;
count = 0;

run("Split Channels");
for(i = 1; i <= channels; i++){
	selectWindow("C"+i+"-"+title);
//	run("Duplicate...", "title=substack duplicate range=1-"+(slices));
	saveAs("TIFF", saveDir+File.separator+titleNoExt+"_ch"+i+".tif");
	close(titleNoExt+"_ch"+i+".tif");
	close("C"+i+"-"+title);
}
