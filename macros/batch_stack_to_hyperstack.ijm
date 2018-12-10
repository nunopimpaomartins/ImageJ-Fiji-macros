print("\\Clear");
fs = File.separator;
img_dir = getDirectory("Choose image directory");
img_list = getFileList(img_dir);
print("Total number of files: "+img_list.length);

save_dir = img_dir+fs+"hyperstacks";
File.makeDirectory(save_dir);

Dialog.create("Hyperstack dimensions");
Dialog.addMessage("Input the number of channels, slices (Z) and frames (T) for hyperstack conversion.");
Dialog.addNumber("Number of channels:", 3);
Dialog.addNumber("Number of z slices:", 20);
Dialog.addNumber("Number of time frames:", 1);
Dialog.addString("File extension: ", ".dv");
Dialog.show();
channels = d2s(Dialog.getNumber(), 0);
slices = d2s(Dialog.getNumber(), 0);
frames = d2s(Dialog.getNumber(), 0);
extension = Dialog.getString();

count=0;
for(j=0;j<img_list.length;j++){
	if(endsWith(img_list[j], extension)==true){
		count+=1;
	};
};
print("Number of "+extension+" files: "+count);

setBatchMode(true);
for(i=0;i<img_list.length;i++){
	if (endsWith(img_list[i], extension) == true) {
	showProgress(-i/img_list.length);
	run("Bio-Formats Importer", "open=["+img_dir+fs+img_list[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	full_title = getTitle;
	title_noext = File.nameWithoutExtension;
	run("Stack to Hyperstack...", "order=xyczt(default) channels="+channels+" slices="+slices+" frames="+frames+" display=Color");
	saveAs("Tiff", save_dir+fs+title_noext+".tif");
	selectWindow(title_noext+".tif");
	close();
	};
};
run("Close All");
setBatchMode(false);
print("Done!");