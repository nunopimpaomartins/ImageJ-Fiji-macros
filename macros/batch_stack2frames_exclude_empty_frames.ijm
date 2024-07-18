#@ File (label="Input image folder", style="directory") trainImgDir
#@ File (label="Label image folder", style="directory") trainLabDir
fs = File.separator;

//input image forlder path and number of files
print("Image folder: "+ trainImgDir);
fileList_input= getFileList(trainImgDir);
print("number of input files: "+fileList_input.length);

//label image forlder path and number of files
print("label folder: "+trainLabDir);
filelist_label = getFileList(trainLabDir);
print("number of label files: "+filelist_label.length);

saveDirInput = trainImgDir+fs+"input";
if(!File.exists(saveDirInput)){
	File.makeDirectory(saveDirInput);
};
saveDirLabel = trainLabDir+fs+"label";
if(!File.exists(saveDirLabel)){
	File.makeDirectory(saveDirLabel);
};

setBatchMode(true);
for(i=0; i<fileList_input.length && i<filelist_label.length; i++) {
	if(endsWith(fileList_input[i], ".tif") && endsWith(filelist_label[i], ".tif")){
		open(trainImgDir+fs+fileList_input[i]);
		filename_input = getTitle();
//		print(filename_input);
		filename_input_rename = "input_"+filename_input;
		selectWindow(filename_input);
		rename(filename_input_rename);
//		print(filename_input_rename);
		
		open(trainLabDir+fs+filelist_label[i]);
		filename_label = getTitle();
//		print(filename_label);
		filename_label_rename = "lab_"+filename_label;
		selectWindow(filename_label);
		rename(filename_label_rename);
//		print(filename_label_rename);
		
		nameNoExt = substring(filename_input, 0, indexOf(filename_input, ".tif"));
		
		//input dimensions
		selectWindow(filename_input_rename);
		Stack.getDimensions(width_input, height_input, channels_input, slices_input, frames_input);
		//label dimensions
		selectWindow(filename_label_rename);
		Stack.getDimensions(width_label, height_label, channels_label, slices_label, frames_label);
//		setBatchMode("exit and display");
//		waitForUser;

		if(width_input != width_label || height_input != height_label || channels_input != channels_label || slices_input != slices_label) {
			print("Some dimensions do not match");
			print("Do not match: "+filename_input_rename+" and "+filename_label_rename);
			run("Close All");
			continue;
		};
		
		padlen = 7;
		count = 0;
		
		for(j = 1; j <= slices_input; j++){
			count += 1;
			
			selectWindow(filename_input_rename);
			setSlice(j);
			run("Duplicate...", "title=frame_input_"+j);
			List.setMeasurements;
			rawIntDen_input = List.getValue("RawIntDen");

			selectWindow(filename_label_rename);
			setSlice(j);
			run("Duplicate...", "title=frame_label_"+j);
			List.setMeasurements;
			rawIntDen_label = List.getValue("RawIntDen");

			if(rawIntDen_input == 0 || rawIntDen_label == 0){
				close("frame_input_"+j);
				close("frame_label_"+j);
				continue;
			}
			selectWindow("frame_input_"+j);
			saveAs("TIFF", saveDirInput+fs+nameNoExt+"_"+IJ.pad(count, padlen)+".tif");
			close(nameNoExt+"_"+IJ.pad(count, padlen)+".tif");

			selectWindow("frame_label_"+j);
			saveAs("TIFF", saveDirLabel+fs+nameNoExt+"_"+IJ.pad(count, padlen)+".tif");
			close(nameNoExt+"_"+IJ.pad(count, padlen)+".tif");
		};
		close(filename_input_rename);
		close(filename_label_rename);
	};
};
setBatchMode("exit and display");
print("done");
beep();