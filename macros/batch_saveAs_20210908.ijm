data_dir = "D:/Data/3dliver_local/Sarah/prim.Hep.WT_APPLKO_OA_builtUp_060921/";

fileList = getFileList(data_dir);
fileList = Array.sort(fileList);

save_dir = data_dir+File.separator+"tiff_files";
if(!File.exists(save_dir)){
	File.makeDirectory(save_dir);
};

setBatchMode(true);
for(i=0; i<fileList.length; i++){
	if(endsWith(fileList[i], ".oir")){
		run("Bio-Formats Importer", "open=["+data_dir+File.separator+fileList[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		filename = getTitle();
		title = substring(filename, 0, indexOf(filename, ".oir"));
		saveAs("Tiff", save_dir+File.separator+title+".tif");
	}
}
setBatchMode("exit and display");
print("done");