saveDir = getDirectory("Choose a Directory to save");
print("Save directory: "+saveDir);

title = getTitle();
nameNoExt = substring(title, 0, indexOf(title, ".tif"));
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
	for(j = 0; j*128 < 318; j++) {
		for(k = 0; k*128 < 508; k++) {
			selectWindow(title);
			count += 1;
			x = k*128;
			y = j*128;
//			if( x+128 > width) {
//				x = width - 128;
//			};
//			if( y+128 > height) {
//				y = height - 128;
//			};
			if(x+128 > width || y+128 > height) {
				continue;
			};
			run("Specify...", "width=128 height=128 x="+x+" y="+y+" slice="+i);
			run("Duplicate...", "title=tile");
//			img_name = "image_rawXZ_"+IJ.pad(count, padlen)+".tif";
			img_name = nameNoExt+"_"+IJ.pad(count, padlen)+".tif";
			saveAs("TIFF", saveDir+File.separator+img_name);
			close(img_name);
		}
	}
};
setBatchMode("exit and display");
beep();