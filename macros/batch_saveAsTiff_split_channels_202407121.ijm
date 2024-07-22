/*
* Macro to split image channels and save as tiff files
* author: Nuno Pimpao Martins, iMM/IGC
*/
print("\\Clear");

#@ File (label = "Path to folder with original image files", style = "directory") imgDir
#@ String (label= "Extension of original images", style = "text field") fileExtension
#@ Boolean (label = "Save channels in independent folders?") splitFolders
fs = File.separator;

print("Image folder: "+imgDir);
print("Image Extension: "+fileExtension);
splitFolderValue = "No";
if(splitFolders == 1){splitFolderValue = "Yes";} else {splitFolderValue = "No";};
print("Split channels into different folders: "+ splitFolderValue);

file_list = getFileList(imgDir);
print("Total number of files in folder: "+file_list.length);
file_list = Array.sort(file_list);
count = 0;
for(i = 0; i < file_list.length; i++){
    if(endsWith(file_list[i], fileExtension)){
        count += 1;
    };
};
print("Number of images to convert: "+ count);

save_dir = "";
save_dir_array = newArray();
if(splitFolders){
    for(i = 0; i < 4; i++){
        save_dir_array = Array.concat(save_dir_array, imgDir+fs+"ch"+(i+1));
    };
    for(i = 0; i < save_dir_array.length; i++){
        if(!File.exists(save_dir_array[i])){
            File.makeDirectory(save_dir_array[i]);
        };
    }
} else {
    save_dir = imgDir+fs+"tiff_files";
    if(!File.exists(save_dir)){
        File.makeDirectory(save_dir);
    };
};

setBatchMode(true);
for(i=0; i<file_list.length; i++){
	showProgress(i, file_list.length);
	if(endsWith(file_list[i], fileExtension)){
		run("Bio-Formats Importer", "open=["+imgDir+fs+file_list[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		filename = getTitle();
		title = substring(filename, 0, indexOf(filename, fileExtension));
		Stack.getDimensions(temp_width, temp_height, temp_channels, temp_slices, temp_frames);
		if(temp_channels > 1){
			run("Split Channels");
			for(j=1; j<=temp_channels; j++){
				selectWindow("C"+j+"-"+filename);
				if(splitFolders){
					saveAs("Tiff", save_dir_array[(j-1)]+fs+title+".tif");
				} else {
					saveAs("Tiff", save_dir+fs+title+"_ch"+j+".tif");
				}
				close(title+"_ch"+j+".tif");
			};
		} else {
			saveAs("Tiff", save_dir+fs+title+".tif");
		};
		close(title+".tif");
	};
};

setBatchMode("exit and display");
print("done");
beep();
