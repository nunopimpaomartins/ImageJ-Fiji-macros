data_dir = getDirectory("Choose image folder.");
file_extension = ".tif"; //needs the ".:, otherwise it will not save with the proper name

fileList = getFileList(data_dir);
fileList = Array.sort(fileList);

save_dir = data_dir+File.separator+"subsampled_tiff";
if(!File.exists(save_dir)){
	File.makeDirectory(save_dir);
};

setBatchMode(true);
for(i=0; i<fileList.length; i++){
	if(endsWith(fileList[i], file_extension)){
		showProgress((i+1), fileList.length);
		run("Bio-Formats Importer", "open=["+data_dir+File.separator+fileList[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		filename = getTitle();
		title = substring(filename, 0, indexOf(filename, file_extension));
		Stack.getDimensions(width, height, channels, slices, frames);
		run("Slice Keeper", "first=1 last="+slices+" increment=3");
		selectWindow(filename+" kept stack");
		saveAs("Tiff", save_dir+File.separator+title+"_subsampled.tif");
		run("Close All");
	}
}
setBatchMode("exit and display");
print("done");