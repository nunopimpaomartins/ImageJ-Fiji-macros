print("\\Clear");
fs = File.separator;
file_extension = ".ome.tif";

data_dir = getDirectory("Choose data folder");
print(data_dir);
file_list = getFileList(data_dir);
print("Number of files in data folder: "+file_list.length);
file_list = Array.sort(file_list);

folder_list = newArray();
for(i = 0; i < file_list.length; i++){
//	print(file_list[i]);
	if(endsWith(file_list[i], "/")){
		folder_list = Array.concat(folder_list, file_list[i]);
	};
};

//print(folder_list.length);
//print(folder_list[0]);
//stop;

parent_dir = File.getParent(data_dir);
save_dir = parent_dir+fs+"tiff_files";
if(!File.exists(save_dir)){
	File.makeDirectory(save_dir);
};

setBatchMode(true);
for(i=0; i<file_list.length; i++){
	showProgress(i, file_list.length);
	image_list = getFileList(data_dir+folder_list[i]);
	for(j = 0; j < image_list.length; j++){
		if(endsWith(data_dir+folder_list[i]+fs+image_list[j], file_extension)){
			run("Bio-Formats Importer", "open=["+data_dir+fs+folder_list[i]+fs+image_list[j]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			//get image name
			filename = getTitle();
			title = substring(filename, 0, indexOf(filename, file_extension));
			
			//reorder hyperstack
			run("Hyperstack to Stack");
			run("Stack to Hyperstack...", "order=xyzct channels=3 slices=250 frames=1 display=Color");

			Stack.getDimensions(temp_width, temp_height, temp_channels, temp_slices, temp_frames);
			if(temp_channels > 1){
				run("Split Channels");
				for(k=1; k<=temp_channels; k++){
					selectWindow("C"+k+"-"+filename);
					saveAs("Tiff", save_dir+fs+title+"_ch"+k+".tif");
					close(title+"_ch"+k+".tif");
				};
			} else {
				saveAs("Tiff", save_dir+fs+title+".tif");
				close(title+".tif");
			};
		};
	};
//	if(i > 5){
//		break;
//	};
};

setBatchMode("exit and display");
print("done");
beep();
