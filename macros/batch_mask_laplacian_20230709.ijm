print("\\Clear");
fs = File.separator;
file_extension = ".tif";

data_dir = getDirectory("Choose image folder.");
print(data_dir);
file_list = getFileList(data_dir);
print("File list number: "+file_list.length);
file_list = Array.sort(file_list);

save_dir = data_dir+fs+"mask_gt";
if(!File.exists(save_dir)){
	File.makeDirectory(save_dir);
};

setBatchMode(true);
for(i=0; i<file_list.length; i++){
	showProgress(i, file_list.length);
	if(endsWith(file_list[i], file_extension)){
		run("Bio-Formats Importer", "open=["+data_dir+fs+file_list[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		filename = getTitle();
		title = substring(filename, 0, indexOf(filename, file_extension));
		
		run("Gaussian Blur...", "sigma=2 stack");
//		run("FeatureJ Laplacian", "compute smoothing=2");
//		selectWindow(filename+" Laplacian");
		setOption("BlackBackground", true);
		run("Convert to Mask", "method=Otsu background=Dark calculate black");
		
		saveAs("Tiff", save_dir+fs+title+"_mask.tif");
		run("Close All");
	};
};

setBatchMode("exit and display");
print("done");
beep();