img_dir = getDirectory("choose image");

file_list = getFileList(img_dir);

save_dir = img_dir+"rescaled/"
if(!File.exists(save_dir)){
	File.makeDirectory(save_dir);
};

setBatchMode(true);
for(i = 0 ; i < file_list.length; i++){
	if(endsWith(file_list[i], ".tif")){
		open(img_dir+file_list[i]);
		title = getTitle();
		print("Image title: "+title);
		save_name = substring(title, 0, indexOf(title, ".tif"));
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
//		print(min);
//		print(max);
		selectWindow(title);
		setMinAndMax(0, 65535);
		run("16-bit");
		saveAs("TIFF", save_dir+save_name+"_rescaled.tif");
		run("Close All");
	};
};
setBatchMode("exit and display");
print("Done");
