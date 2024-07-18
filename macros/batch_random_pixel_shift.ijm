print("\\Clear");
fs = File.separator;

imgDir = getDirectory("Image directory");
imgList = getFileList(imgDir);
print("Image folder: "+imgDir);
print("File list length: "+imgList.length);

setBatchMode(true);
for(i=0;i<imgList.length;i++){
	if(endsWith(imgList[i], ".tif")){
		open(imgDir+fs+imgList[i]);
		filename = getTitle();
		filenameNoExt = File.nameWithoutExtension;

		x_offset = 0;
		y_offset = 0;

		x_offset = randomize_shift(0.05, 0.1);
		print("X shift: "+x_offset);
		y_offset = randomize_shift(0.05, 0.1);
		print("Y shift: "+y_offset);
		
		if (random > 0.5){
			x_offset *= -1;
		};
		if (random > 0.5){
			y_offset *= -1;
		};
		run("Translate...", "x="+x_offset+" y="+y_offset+" interpolation=Bicubic");
		saveAs("TIFF", imgDir+fs+filename);
		run("Close All");
	}
}
beep();
setBatchMode(false);

function randomize_shift(lower_bound, upper_bound){
	init_value = random;
	while (init_value < lower_bound || init_value > upper_bound) {
		init_value = random;
		//print(init_value);
	}
	return floor(init_value*100);
}