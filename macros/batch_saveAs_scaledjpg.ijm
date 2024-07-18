imgDir = getDirectory("Choose a Directory to save");
print("Save directory: "+imgDir);

dirList = getFileList(imgDir);
print("List length: "+dirList.length);

for (i = 0; i < dirList.length; i++) {
	if(endsWith(dirList[i], "tif")) {
		open(imgDir+File.separator+dirList[i]);
		title = getTitle();
		subtitle = substring(title, 0, indexOf(title, ".tif"));
		resetMinAndMax;
		run("Properties...", "unit=µm pixel_width=0.2990939 pixel_height=0.2990939 voxel_depth=0.3000000");
		run("Scale Bar...", "width=50 height=4 font=14 color=White background=None location=[Lower Right] bold hide overlay");
		saveAs("JPEG", imgDir+File.separator+subtitle+".jpg");
		run("Close All");
	}
}