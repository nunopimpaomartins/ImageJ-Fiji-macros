print("\\Clear");
fs = File.separator;

saveDir = getDirectory("directory to save image");

saveImg = saveDir + fs + "image";
if (!File.exists(saveImg)) {
	File.makeDirectory(saveImg);
};
saveGt = saveDir + fs + "target";
if (!File.exists(saveGt)) {
	File.makeDirectory(saveGt);
};

title = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);

setBatchMode(true);
for( i = 1; i <= frames ; i += 2) {
	selectWindow(title);
	Stack.setFrame(i);
	run("Duplicate...", "title=image");
	selectWindow("image");
	saveAs("TIFF", saveImg + fs + "image_" + IJ.pad(i, 3) + ".tif");
	close("image_" + IJ.pad(i, 3) + ".tif");
	selectWindow(title);
	Stack.setFrame(i+1);
	run("Duplicate...", "title=target");
	selectWindow("target");
	saveAs("TIFF", saveGt + fs + "image_" + IJ.pad(i, 3) + ".tif");
	close("image_*");
};
setBatchMode("exit and display");
beep();