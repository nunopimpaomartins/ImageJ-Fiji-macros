//data_dir = "D:/Data/3dliver_local/Sarah/prim.Hep.WT_APPLKO_OA_Chase_060921/";
data_dir = getDirectory("Choose image dir");

fileList = getFileList(data_dir);
//fileList = Array.sort(fileList);

save_dir = data_dir+File.separator+"to_restore";
if(!File.exists(save_dir)){
	File.makeDirectory(save_dir);
};

setBatchMode(true);
for(i=0; i<fileList.length; i++){
	if(endsWith(fileList[i], ".tif")){
		open(fileList[i]);
		filename = getTitle();
		title = substring(filename, 0, indexOf(filename, ".tif"));
		run("Duplicate...", "title=channel1 duplicate channels=1");
		selectWindow("channel1");
		saveAs("Tiff", save_dir+File.separator+title+".tif");
//		close(title+".tif");
		run("Close All");
	}
}
setBatchMode("exit and display");
print("done");