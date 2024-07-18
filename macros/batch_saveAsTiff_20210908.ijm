data_dir = getDirectory("Choose image folder.");
file_extension = ".oir"; //needs the ".:, otherwise it will not save with the proper name

fileList = getFileList(data_dir);
fileList = Array.sort(fileList);

save_dir = data_dir+File.separator+"tiff_files";
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
		saveAs("Tiff", save_dir+File.separator+title+".tif");
		close(title+".tif");
	}
}
setBatchMode("exit and display");
print("done");