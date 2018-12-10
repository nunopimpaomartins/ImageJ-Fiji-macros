print("\\Clear");
fs=File.separator;
run("Clear Results");

run("Bio-Formats Importer");
waitForUser("Check the Image for drift and problems.");
title=getTitle;
print("Current title: "+title);
basename=getString("Write down the name of the file to be saved", "name of the image");
print("Saving data as: "+basename);

drift_cor = getBoolean("Correct drift? Uses Image stabilizer plugin.");

//dir=getInfo("image.directory");
dir=File.directory;
print("Image Directory: "+dir);
save_dir=dir+fs+"analysis_"+basename;
File.makeDirectory(save_dir);

run("Properties...");
getPixelSize(unit, pxW, pxH);
print(unit+" "+pxW+" "+pxH);
T=Stack.getFrameInterval();
//print(T);

run("Split Channels");
selectWindow("C2-"+title);
close();
selectWindow("C1-"+title);
if(drift_cor == true){
	run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001");
};

//checking MT tracks or path
mip = "time_proj";
if(isOpen(mip)==false){
	run("Z Project...", "projection=[Max Intensity]");
	rename(mip);
};

table_name = "[Average Speed]";
table_name2="Average Speed";
//run("New... ", "name="+table_name+" type=Table");
Table.create(table_name2);

analysis=true;
counter=0;

while(analysis==true){
	speed_values=newArray();
	roiManager("reset");
	selectWindow(mip);
	setTool("polyline");
	if(counter==1){
		roiManager("open", save_dir+fs+"MTroi.roi");
	} else if(counter>1) {
		roiManager("open", save_dir+fs+"MTroi.zip");
	}
	waitForUser("Select MT to analyze");
	roiManager("add");
	if(counter==0){
		roiManager("save", save_dir+fs+"MTroi.roi");
	} else {
		roiManager("save", save_dir+fs+"MTroi.zip");
	};
	selectWindow("C1-"+title);
	run("Restore Selection");

	roiManager("reset");
	//create kimogram to measure speed
	run("Reslice [/]...", "output="+pxW+" start=Top avoid");
	reslice = getTitle();
	//print(reslice);
	run("Tubeness", "sigma="+pxW+" use");
	run("Convolve...", "text1=[1 0 -1\n2 0 -2\n1 0 -1] normalize");
	run("Convolve...", "text1=[1 2 1\n0 0 0\n-1 -2 -1] normalize");
	//resetMinAndMax;
	setAutoThreshold("Otsu dark no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Analyze Particles...", "size=30-Infinity pixel add clear");
	
	nlines = roiManager("count");
	for(i=0;i<nlines;i++){
		roi_x=getROIcoords(i,"x");
		roi_y=getROIcoords(i,"y");
		spd=getROIslope(roi_x,roi_y);
		speed_values=Array.concat(speed_values,spd);
	};
		
	Array.getStatistics(speed_values, min, max, spd_avg, spd_stdDev);
	
	print("Average slope: "+spd_avg);
	Table.set("n", counter, counter+1, table_name2);
	Table.set("Avg speed", counter, spd_avg, table_name2);
	Table.set("Std Dev", counter, spd_stdDev, table_name2);
	Table.set("n slopes", counter, speed_values.length, table_name2);
	
	Table.update(table_name2);

	roiManager("reset");
	if(counter==0){
		roiManager("open", save_dir+fs+"MTroi.roi");
	} else if(counter>=1) {
		roiManager("open", save_dir+fs+"MTroi.zip");
	};
	selectWindow(mip);
	roiManager("show all");
	
	selectWindow("C1-"+title);
	roiManager("show all");
	doCommand("Start Animation [\\]");
	query=getBoolean("Continue analysis?");
	if(query==false){
		analysis=false;
	};
	selectWindow("C1-"+title);
	run("Stop Animation");
	selectWindow("tubeness of "+reslice);
	saveAs("TIFF", save_dir+fs+"tubeness_of_"+basename+"_"+counter+".tif");
	close();
	selectWindow(reslice);
	saveAs("TIFF", save_dir+fs+"reslice_of_"+basename+"_"+counter+".tif");
	close();
	counter+=1;
};
Table.save(save_dir+fs+basename+"_results.csv", table_name2);
close(table_name2);
selectWindow(mip);
saveAs("TIFF", save_dir+fs+basename+"_mip.tif");
run("Close All");
//close("\\Others");

function getROIcoords (n, xy_coord) {
	roiManager("select", n);
	Roi.getCoordinates(roi_array1, roi_array2);
	if(xy_coord=="x") {
		return roi_array1;
	} else if(xy_coord=="y"){
		return roi_array2;
	};
};

function getROIslope (array1, array2) {
	n=array1.length;
	x_calib = newArray();
	y_calib = newArray();
	for(i=0;i<n;i++){
		x_calib=Array.concat(x_calib,array1[i]*pxW);
		y_calib=Array.concat(y_calib,array2[i]*T);
	};
	Fit.logResults;
	Fit.doFit("Straight Line", y_calib, x_calib);
	b = Fit.p(1);
	print("Slope: "+b);
	return b;
};
