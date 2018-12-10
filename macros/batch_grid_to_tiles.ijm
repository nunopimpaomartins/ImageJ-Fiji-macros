print("\\Clear");
fs = File.separator;
img_dir = getDirectory("Choose image directory");
img_list = getFileList(img_dir);
print("Total number of files in folder: "+img_list.length);

save_dir = img_dir+fs+"tile_images";
File.makeDirectory(save_dir);

Dialog.create("Grid to tile:");
Dialog.addMessage("Specify the number of rows (x) and collumns (y) of the grid to convert to tiles.");
Dialog.addNumber("Number of row (x):", 3);
Dialog.addNumber("Number of collumns (y):", 3);
Dialog.addString("File extension: ", ".dv");
Dialog.show();
x = Dialog.getNumber();
y = Dialog.getNumber();
extension = Dialog.getString();

count=0;
for(j=0;j<img_list.length;j++){
	if(endsWith(img_list[j], extension)==true){
		count+=1;
	};
};
print("Number of "+extension+" files: "+count);

setBatchMode(true);
for(i=0;i<img_list.length;i++){
	if (endsWith(img_list[i], extension) == true) {
		showProgress(-i/img_list.length);
		run("Bio-Formats Importer", "open=["+img_dir+fs+img_list[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		title_full = getTitle;
		title_noext = File.nameWithoutExtension;
		Stack.getDimensions(width, height, channels, slices, frames);
		for(k=0;k<y;k++){
			for(j=0;j<x;j++){
				selectWindow(title_full);
				run("Specify...", "width="+width*(1/x)+" height="+height*(1/y)+" x="+j*width*(1/x)+" y="+k*height*(1/y));
				run("Duplicate...", "title="+title_noext+"_x"+IJ.pad(j, 2)+"_y"+IJ.pad(k, 2)+" duplicate");
				selectWindow(title_noext+"_x"+IJ.pad(j, 2)+"_y"+IJ.pad(k, 2));
				saveAs("Tiff", save_dir+fs+title_noext+"_x"+IJ.pad(j, 2)+"_y"+IJ.pad(k, 2)+".tif");
				close();
			};
		};
	
		selectWindow(title_full);
		close();
	};
};
setBatchMode(false);
print("Done!");