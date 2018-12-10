print("\\Clear");
dir = getDirectory("Choose file directory to create Z Max Proj.");
print("File dir: "+dir);
current_dir = File.getName(dir);
list = getFileList(dir);
print(list.length);
fs = File.separator;
File.makeDirectory(dir+fs+current_dir+"_max_proj");
save_dir=dir+fs+current_dir+"_max_proj";
print(save_dir);

setBatchMode(true);
for (i=0;i<list.length;i++) {
	showProgress(i, list.length);
	if (endsWith(list[i], ".dv")==1) {
		print(list[i]);
		run("Bio-Formats Importer", "open=["+dir+fs+list[i]+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT ");
		title = getTitle();
		print(title);
		run("Z Project...", "type=[Max Intensity]");
		selectWindow("MAX_"+title);
		run("Split Channels");
		selectWindow("C1-MAX_"+title);
		saveAs("Tiff", save_dir+fs+title+"_Chan_1_max_proj.tif");
		selectWindow("C2-MAX_"+title);
		saveAs("Tiff", save_dir+fs+title+"_Chan_2_max_proj.tif");
		run("Close All");
	};
};
setBatchMode(false);
print("Done!");