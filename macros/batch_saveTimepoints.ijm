//data_dir = "D:/Data/3dliver_local/Sarah/prim.Hep.WT_APPLKO_OA_Chase_060921/";

if(nImages == 0){
	exit("No images open.");
};

save_dir = getDirectory("Dir to save images");;

filename = getTitle();
filename_noext = substring(filename, 0, indexOf(filename, ".tif"));
Stack.getDimensions(width, height, channels, slices, frames);
frames_length = lengthOf(toString(frames));
//print(frame_length);

setBatchMode(true);
for(i=0; i<frames; i++){
	showProgress(i, frames);
	selectWindow(filename);
	run("Duplicate...", "title=temp_t duplicate frames="+(i+1));
	selectWindow("temp_t");
	temp_name = filename_noext+"_"+IJ.pad(i, frames_length);
	saveAs("Tiff", save_dir+File.separator+temp_name+".tif");
	close(temp_name+".tif");
}
setBatchMode("exit and display");
print("done");