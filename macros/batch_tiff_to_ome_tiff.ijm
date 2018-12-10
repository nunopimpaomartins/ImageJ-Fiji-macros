setBatchMode(true);
print("\\Clear");
dir = getDirectory("Choose file dir");
print("dir: "+dir);
list = getFileList(dir);
print("Number o files: "+list.length);
fs = File.separator;

save_dir=dir+fs+"ome_files";
File.makeDirectory(save_dir);
print("Saving files in: "+save_dir);

for(i=0;i<list.length;i++) {
	if(endsWith(list[i], ".tif") == true || endsWith(list[i], ".tiff") == true) {
		print("File nr: "+i+1);
		run("Bio-Formats Importer", "open=["+dir+fs+list[i]+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
		title = File.nameWithoutExtension();
		print("Image title: "+title);
		run("Bio-Formats Exporter", "save=["+save_dir+fs+title+".ome.tif] compression=Uncompressed");
		run("Close All");
		print("done");
	};
	showProgress(-i/list.length);
};
print("All done");
setBatchMode(false);