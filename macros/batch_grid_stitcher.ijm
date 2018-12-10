print("\\Clear");
wdir = getDirectory("Imag dir");
list = getFileList(wdir);
fs = File.separator;
print("File number: "+list.length);
save_dir = wdir+fs+"grids";
File.makeDirectory(save_dir);

Dialog.create("Specify number of tiles per grid:");
Dialog.addMessage("Specify the number of tiles per grid and the base name.");
Dialog.addNumber("Number of tiles per grid:", 9);
Dialog.addString("File basename: ", "tile_{ii}.tif");
Dialog.show();
tiles = Dialog.getNumber();
basename = Dialog.getString();

setBatchMode(true);
for (i = 1; i < list.length; i+=9) {
	showProgress(-i/list.length);
	run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x=3 grid_size_y=3 tile_overlap=40 first_file_index_i="+i+" directory=["+wdir+"] file_names="+basename+" output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
	saveAs("Tiff", save_dir+fs+"grid_"+i+".tif");
	selectWindow("grid_"+i+".tif");
	close();
};
setBatchMode(false)

print("Macro Done!");