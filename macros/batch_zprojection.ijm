print("\\Clear");
fs=File.separator;
projection_array=newArray("Average Intensity", "Max Intensity", "Min Intensity", "Sum Slices", "Standard Deviation", "Median");

if(nImages>0){
	showMessageWithCancel("Open images","At least 1 image is open. All images will be closed before proceeding.");
	run("Close All");
};

wdir = getDirectory("Choose image folder.");
print("Working directory: "+wdir);
file_list = getFileList(wdir);
print("Total number of files in folder: "+file_list.length);

savedir=wdir+fs+"projections";
File.makeDirectory(savedir);

Dialog.create("Confirm channels and their names:");
Dialog.addMessage("Specify the channel name, order and type of projection you want to do.");
Dialog.addChoice("Projection type: ", projection_array, "Max Intensity");
Dialog.addMessage("Choose channel names in order. If it does not have 3 channels, name it none");
Dialog.addString("Channel number 1:", "DAPI");
Dialog.addString("Channel number 2:", "GFP");
Dialog.addString("Channel number 3:", "RFP");
Dialog.addString("File extension: ", ".dv");
Dialog.show();
proj = Dialog.getChoice();
ch1 = Dialog.getString();
ch2 = Dialog.getString();
ch3 = Dialog.getString();
extension = Dialog.getString();


count=0;
for(i=0;i<file_list.length;i++){
	if(endsWith(file_list[i], extension)==true){
		count++;
	};
};
print("Number of dv files: "+count);

setBatchMode(true);
for(j=0;j<file_list.length;j++){
	if(endsWith(file_list[j], extension)==true){
		showProgress(-j/file_list.length);
		run("Bio-Formats Importer", "open=["+wdir+fs+file_list[j]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		filename = getTitle();
		title = File.nameWithoutExtension;
		run("Z Project...", "projection=["+proj+"]");
		prefix="foo";
		if(proj==projection_array[1]){
			prefix="MAX_";
		} else if(proj==projection_array[3]) {
			prefix="SUM_";
		} else if(proj==projection_array[2]) {
			prefix="MIN_";
		} else if(proj==projection_array[0]){
			prefix="AVG_";
		} else if(proj==projection_array[4]){
			prefix="STD_";
		} else if(proj==projection_array[5]){
			prefix="MED_";
		};
		selectWindow(prefix+filename);
		run("Split Channels");
		selectWindow("C1-"+prefix+filename);
		channel1=title+"_"+ch1;
		rename(channel1);
		resetMinAndMax;
		saveAs("TIFF", savedir+fs+channel1+".tif");
		selectWindow("C2-"+prefix+filename);
		channel2=title+"_"+ch2;
		rename(channel2);
		resetMinAndMax;
		saveAs("TIFF", savedir+fs+channel2+".tif");
		if(ch3!="none"){
			selectWindow("C3-"+prefix+filename);
			channel3=title+"_"+ch3;
			rename(channel3);
			resetMinAndMax;
			saveAs("TIFF", savedir+fs+channel3+".tif");
			run("Merge Channels...", "c1="+channel3+".tif c2="+channel2+".tif c3="+channel1+".tif create keep");
		} else {
			run("Merge Channels...", "c1="+channel2+".tif c3="+channel1+".tif create keep");
		};
		selectWindow("Composite");
		saveAs("TIFF", savedir+fs+title+"_composite.tif");
		run("RGB Color");
		saveAs("Jpeg...", savedir+fs+title+"_rgp.jpeg");
		run("Close All");
	};
};
setBatchMode(false);

print("Macro Done");