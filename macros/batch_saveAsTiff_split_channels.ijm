print("\\Clear");
fs = File.separator;
file_extension = ".lsm";

data_dir = getDirectory("Choose image folder.");
print(data_dir);
file_list = getFileList(data_dir);
print("File list number: "+file_list.length);
file_list = Array.sort(file_list);

save_dir = data_dir+fs+"tiff_files";
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
		Stack.getDimensions(temp_width, temp_height, temp_channels, temp_slices, temp_frames);
		if(temp_channels > 1){
			run("Split Channels");
			for(j=1; j<=temp_channels; j++){
				selectWindow("C"+j+"-"+filename);
				saveAs("Tiff", save_dir+fs+title+"_ch"+j+".tif");
				close(title+"_ch"+j+".tif");
			};
		} else {
			saveAs("Tiff", save_dir+fs+title+".tif");
			close(title+".tif");
		};
	};
};

setBatchMode("exit and display");
print("done");
beep();
