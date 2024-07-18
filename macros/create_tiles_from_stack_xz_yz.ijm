saveDir = getDirectory("Choose a Directory to save");
print("Save directory: "+saveDir);

title = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);
padlen = 7;
count = 0; //increment 2048 for 512x512

// To convert to 8 bit, for training
//run("Statistics");
//max = getResult("Max", nResults-1);
//min = getResult("Min", nResults-1);
//print(max+" "+min)
//setMinAndMax(min-10, max+10);
//run("8-bit");

setBatchMode(true);
for(i = 1; i <= slices; i++){
	for(j = 0; j*128 < 384; j++) {
		for(k = 0; k*128 < 512; k++) {
			selectWindow(title);
			count += 1;
			x = k*128;
			y = j*128;
			if( x+128 > width) {
				x = width - 128;
			};
			if( y+128 > height) {
				y = height - 128;
			};
			run("Specify...", "width=128 height=128 x="+x+" y="+y+" slice="+i);
			run("Duplicate...", "title=tile");
			img_name = "image_rawYZ_"+IJ.pad(count, padlen)+".tif";
			saveAs("TIFF", saveDir+File.separator+img_name);
			close(img_name);
		}
	}
};
setBatchMode(false);
beep();