print("\\Clear");
fs = File.separator;
file_extension = ".tif";

data_dir = getDirectory("Choose image folder.");
print(data_dir);
file_list = getFileList(data_dir);
print("File list number: "+file_list.length);
file_list = Array.sort(file_list);

save_dir = data_dir+fs+"input_slices";
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
//		getMinAndMax(min, max);
//		print(min+" , "+max);
		for(j=1; j<=temp_slices; j++){
			selectWindow(filename);
			setSlice(j);
			run("Duplicate...", "title=dup");
			getStatistics(area, mean, min, max, std, histogram);
			print(title+"_z"+IJ.pad(j, 3)+" ; min: "+min+"; max:"+max);
			normalize_mi_ma("dup", 0, 1);
			run("Copy");
			newImage("Temp", "32-bit black", 512, 512, 1);
			selectWindow("Temp");
			run("Paste");
			selectWindow("Temp");
			saveAs("Tiff", save_dir+fs+title+"_z"+IJ.pad(j, 3)+".tif");
			close(title+"_z"+IJ.pad(j, 3)+".tif");
			close("dup");
		};
		close(filename);
	};
};

setBatchMode("exit and display");
print("done");
beep();


function normalize_mi_ma(x, min_val, max_val){
	//Min Max normalization between [0,1]
	min_new = min_val;
	max_new = max_val;
	selectWindow(x);
	if(bitDepth() == 24){
		exit("Does not work with RGB images");
	} else if(bitDepth()!=32){
		run("32-bit");
	};
	getStatistics(area, mean, min, max, std, histogram);
	getDimensions(width, height, channels, slices, frames);
	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			px_value = getPixel(i, j);
			px_nom = (px_value - min) * max_new / (max - min) + min_new;
			setPixel(i, j, px_nom);
		}
	}
}