print("\\Clear");
fs = File.separator;
imgDir = getDirectory("Choose a Directory with images to bin/convert");
print("Image source directory: "+imgDir);

fileList = getFileList(imgDir);
print("File list length: "+fileList.length);

parentDir = File.getParent(imgDir);
saveDir = parentDir+fs+"trainLabels_bc_bin2";
if(!File.exists(saveDir)){
  File.makeDirectory(saveDir);
};

setBatchMode(true);
for(i=0; i<fileList.length;i++) {
  showProgress(-i/fileList.length);
  if(endsWith(fileList[i], ".tif")) {
    open(fileList[i]);
    title = getTitle();
		subtitle = substring(title, 0, indexOf(title, ".tif"));
    run("Bin...", "x=2 y=2 bin=Max");
    saveAs("TIFF", saveDir+fs+subtitle+".tif");
    run("Close All");
  }
}
setBatchMode(false);
