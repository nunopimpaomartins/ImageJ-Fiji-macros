data_dir = getDirectory("Choose image folder.");
file_extension = ".tif"; //needs the ".:, otherwise it will not save with the proper name
filter = "_ch1";

fileList = getFileList(data_dir);
fileList = Array.sort(fileList);

save_dir_top = data_dir+File.separator+"1sthalf";
if(!File.exists(save_dir_top)){
	File.makeDirectory(save_dir_top);
};
save_dir_bottom = data_dir+File.separator+"2ndhalf";
if(!File.exists(save_dir_bottom)){
	File.makeDirectory(save_dir_bottom);
};

setBatchMode(true);
for(i=0; i<fileList.length; i++){
	if(endsWith(fileList[i], file_extension)){
		showProgress((i+1), fileList.length);
		if(indexOf(fileList[i], filter) > 0){
			run("Bio-Formats Importer", "open=["+data_dir+File.separator+fileList[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			filename = getTitle();
			title = substring(filename, 0, indexOf(filename, file_extension));
			
			Stack.getDimensions(width, height, channels, slices, frames);
			titletemp = title+"half";
			run("Duplicate...", "title=["+titletemp+"] duplicate range=1-"+round(slices/2)+" use");
			saveAs("Tiff", save_dir_top+File.separator+titletemp+".tif");
			close(titletemp+".tif");
			
			selectWindow(filename);
			run("Duplicate...", "title=["+titletemp+"] duplicate range="+round(slices/2)+"-"+slices+" use");
			saveAs("Tiff", save_dir_bottom+File.separator+titletemp+".tif");
			run("Close All");
		}
	}
}
setBatchMode("exit and display");
print("done");