saveDir = getDirectory("Choose a Directory to save");
print("Save directory: "+saveDir);

title = getTitle();
subtitle = substring(title, 0, indexOf(title, "_ch"));
//print(subtitle);
Stack.getDimensions(width, height, channels, slices, frames);
padlen = 5;
count = 0;

setBatchMode(true);
for(i = 1; i <= slices; i++){
	selectWindow(title);
	setSlice(i);
	count += 1;
	run("Duplicate...", "title=tile");
	saveAs("TIFF", saveDir+File.separator+subtitle+"_image_"+IJ.pad(count, padlen)+".tif");
	close(subtitle+"_image_"+IJ.pad(count, padlen)+".tif");
};
setBatchMode(false);