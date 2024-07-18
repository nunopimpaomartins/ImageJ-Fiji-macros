print("\\Clear");
file_extension = ".lsm";

data_dir = getDirectory("Choose image folder.");
print(data_dir);
data_dir_splitarray = split(data_dir, "\\");
dir_name = data_dir_splitarray[data_dir_splitarray.length-1];
// print(dir_name);

fileList = getFileList(data_dir);
fileList = Array.sort(fileList);

save_dir = data_dir+File.separator+"tiff_files";
if(!File.exists(save_dir)){
	File.makeDirectory(save_dir);
};

setBatchMode(true);
for(i=0; i<fileList.length; i++){
	showProgress(i, fileList.length);
	if(endsWith(fileList[i], file_extension)){
		showProgress((i+1), fileList.length);
		run("Bio-Formats Importer", "open=["+data_dir+File.separator+fileList[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		filename = getTitle();
		title = substring(filename, 0, indexOf(filename, file_extension));
		Stack.getDimensions(temp_width, temp_height, temp_channels, temp_slices, temp_frames);
		if(temp_channels > 1){
			run("Split Channels");
			for(j=1; j<=temp_channels; j++){
				selectWindow("C"+j+"-"+filename);
				saveAs("Tiff", save_dir+File.separator+dir_name+"_"+title+"_ch"+j+".tif");
				close(dir_name+"_"+title+"_ch"+j+".tif");
			};
		} else {
			saveAs("Tiff", save_dir+File.separator+dir_name+"_"+title+".tif");
			close(dir_name+"_"+title+".tif");
		};
	};
};
setBatchMode("exit and display");
print("done");
