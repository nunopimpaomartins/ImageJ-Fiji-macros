saveDir = getDirectory("Choose a Directory to save");
print("Save directory: "+saveDir);

title = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);
padlen = 5;
count = 0;
z_length = 3;

run("Statistics");
max = getResult("Max", nResults-1);
min = getResult("Min", nResults-1);
//print(max+" "+min)
/*if(min < 0){
	min = 0;
};*/
setMinAndMax(min-10, max+10);
run("8-bit");


setBatchMode(true);
for(i = 2; i < slices; i++){
	for(j = 0; (j+1)*128 <= height; j++) {
		for(k = 0; (k+1)*128 <= width; k++) {
			selectWindow(title);
			count += 1;
			x = k*128;
			y = j*128;

			if(z_length % 2 != 0 && z_length >= 3){
				z_offset = floor(z_length/2);
			} else {
				exit("Z stack size is even, should be odd");
			};
			if(x+128 <= width || y+128 <= height) {
				run("Specify...", "width=128 height=128 x="+x+" y="+y+" slice="+i);
				run("Duplicate...", "title=tile duplicate range="+(i-z_offset)+"-"+(i+z_offset));
				img_name = "image_rawYZ_"+IJ.pad(count, padlen)+".tif";
				saveAs("TIFF", saveDir+File.separator+img_name);
				close(img_name);
			}
		}
	}
};
setBatchMode("exit and display");
beep();