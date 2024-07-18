saveDir = getDirectory("Choose a Directory to save");
print("Save directory: "+saveDir);

title = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);
padlen = 5;
count = 0;

setBatchMode(true);
for(i = 1; i <= slices; i++){
	for(j = 0; (j+1)*128 < height; j++) {
		for(k = 0; (k+1)*128 < width; k++) {
			selectWindow(title);
			count += 1;
			x = k*128;
			y = j*128;
			/*if( x+128 > width) {
				x = width - 128;
			};
			if( y+128 > height) {
				y = height - 128;
			};*/
			if(x+128 < width || y+128 < height) {
				run("Specify...", "width=128 height=128 x="+x+" y="+y+" slice="+i);
				run("Duplicate...", "title=tile");
				saveAs("TIFF", saveDir+File.separator+"image_"+IJ.pad(count, padlen)+".tif");
				close("image_"+IJ.pad(count, padlen)+".tif");
			}
		}
	}
};
setBatchMode(false);