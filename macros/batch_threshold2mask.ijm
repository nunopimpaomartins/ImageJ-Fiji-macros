print("\\Clear");
fs = File.separator;

imgDir = getDirectory("Choose image directory");
parentDir = File.getParent(imgDir);
saveDir = parentDir +fs+"masks_bc";
if(!File.exists(saveDir)){
  File.makeDirectory(saveDir);
};
fileList = getFileList(imgDir);
print("image dir: "+imgDir);
print("Number of files: "+fileList.length);

setBatchMode(true);
for(i=0; i<fileList.length;i++){
  showProgress(-i/fileList.length);
  if(endsWith(fileList[i], ".tif")){
    open(imgDir+fs+fileList[i]);
    title = getTitle();
    titleNoExt = File.nameWithoutExtension();
    setAutoThreshold("Li dark");
    setOption("BlackBackground", true);
    run("Convert to Mask");
    saveAs("TIFF", saveDir+fs+titleNoExt+".tif");
    run("Close All");
  }
};
setBatchMode(false);
print("Done");
