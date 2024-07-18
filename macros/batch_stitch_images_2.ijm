print("\\Clear");
imgDir = getDirectory("Choose image directory for stitching");
fileList = getFileList(imgDir);
//sliceN = 151;
//imageName = "results_m4_";
count = 1;

//Save directory
saveDir = imgDir+File.separator+"stitched";
if(!File.exists(saveDir)){
	File.makeDirectory(saveDir);
};

name_previous = "";
setBatchMode(true);
for(i=1; i<fileList.length; i+=12){
	nameFull = fileList[i];
	nameNoExt = substring(nameFull, 0, indexOf(nameFull, "__0"));

	if(i<10000){
		imageName = substring(nameFull, 0, indexOf(nameFull, ".tif")-4);
		name_var = "iiii";
	} else {
		imageName = substring(nameFull, 0, indexOf(nameFull, ".tif")-5);
		name_var = "iiiii";
	}

	if(nameNoExt != name_previous) {
		count = 0;
	};
	count+=1;

	
	run("Grid/Collection stitching", "type=[Grid: row-by-row] order=[Right & Down                ] grid_size_x=4 grid_size_y=3 tile_overlap=0 first_file_index_i="+i+" directory="+imgDir+" file_names="+imageName+"{"+name_var+"}.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
	saveName = nameNoExt+"_stitched_"+count+".tif";
	saveAs("TIFF", saveDir+File.separator+saveName);
	close(saveName);
	showProgress(i/fileList.length);
	name_previous = nameNoExt;
};
setBatchMode("exit and display");
print("Done");
beep();