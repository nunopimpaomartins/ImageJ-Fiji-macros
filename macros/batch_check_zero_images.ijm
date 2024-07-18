print("\\Clear");
fs = File.separator;
imgDir = getDirectory("Choose a Directory to to load images from");
print("Img directory: "+imgDir);
imgList = getFileList(imgDir);
imgList_sorted = Array.sort(imgList);
print("Number of images in dir: "+imgList.length);

empty_images = newArray();

setBatchMode(true);
for(i=0; i<imgList_sorted.length;i++){
//	showProgress(i/imgList_sorted.length);
	if(endsWith(imgList_sorted[i], ".tif")){
		open(imgDir+fs+imgList_sorted[i]);
//		resetMinAndMax;
//		getMinAndMax(min, max);
		getStatistics(area, mean, min, max, std, histogram);
//		print(min+" "+max);
//		if(max == 0){
		if(mean < 200){
			empty_images = Array.concat(empty_images, imgList_sorted[i]);
		};
		run("Close All");
	};
};
setBatchMode("exit and display");
beep();
print("Done");
Array.show(empty_images);