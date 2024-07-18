print("\\Clear");
imgDir = getDirectory("Choose image directory for stitching");
fileList = getFileList(imgDir);
sliceN = 151;
imageName = "results_m4_";
count = 0;

//Save directory
saveDir = imgDir+File.separator+"stitched";
if(!File.exists(saveDir)){
	File.makeDirectory(saveDir);
};

setBatchMode(true);
for(i=1; i<fileList.length; i+=16){
	count+=1;
	run("Grid/Collection stitching", "type=[Grid: row-by-row] order=[Right & Down                ] grid_size_x=4 grid_size_y=4 tile_overlap=0 first_file_index_i="+i+" directory="+imgDir+" file_names="+imageName+"{iiii}.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
	saveName = "stitched_image_"+count+".tif";
	saveAs("TIFF", saveDir+File.separator+saveName);
	close(saveName);
	showProgress(i/fileList.length);
};
setBatchMode("exit and display");
print("Done");
beep();