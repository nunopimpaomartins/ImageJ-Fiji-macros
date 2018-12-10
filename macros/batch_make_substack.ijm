print("\\Clear");
fs = File.separator;

img_dir = getDirectory("Choose file directory");
print("Directory: "+img_dir);
file_list = getFileList(img_dir);
print("File number: "+file_list.length);

save_dir = img_dir+fs+"substacks";
File.makeDirectory(save_dir);
print("Save dir:"+save_dir);

setBatchMode(true);
for(i=0;i<file_list.length;i++){
	if(endsWith(file_list[i], ".tif")==true) {
		run("Bio-Formats Importer", "open=["+img_dir+fs+file_list[i]+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		filename=getTitle();
		print("Full filename: "+filename);
		title = File.nameWithoutExtension;
		print("Title: "+title);

		Stack.getDimensions(width, height, channels, slices, frames);
		frac = (20*slices)/100;
		run("Make Substack...", "channels=1-2 slices="+round(frac)+"-"+slices-round(frac));

		saveAs("TIFF", save_dir+fs+title+"_sub.tif");
		run("Close All");
	};
};
setBatchMode(false);
print("Macro Done!");