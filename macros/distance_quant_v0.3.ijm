/*
 * Macro for polarity assessment through distance to the nucleus and angle of the centromere position.
 *
 * author: Nuno Pimpão Martins
 * IGC 2018
 * v0.3
*/

//Setup
requires("1.41f");
print("\\Clear");
months = newArray("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Date: "+year+"/"+months[month]+"/"+IJ.pad(dayOfMonth, 2)+" "+IJ.pad(hour, 2)+":"+IJ.pad(minute, 2)+":"+IJ.pad(second, 2));
startTime = getTime();
roiManager("reset");
run("Set Measurements...", "area mean standard modal min centroid fit shape feret's integrated median limit display redirect=None decimal=4");
run("Clear Results");
fs = File.separator;


//Checking if any images are open.
//If not, opens one.
if (nImages == 0) {
	run("Bio-Formats Importer");
	img_dir = File.directory;
	print("Dir: "+img_dir);
} else {
	run("Select None");
	img_dir = getInfo("image.directory");
	print("Dir: "+img_dir);
	//print("Else");
};

//Selecting channels to use (ex. nuclei - 1, tubullin - 2, cent - 3, etc.)
Stack.getDimensions(width, height, channels, slices, frames);
channel_array = newArray();
for(i=1;i<=channels;i++){
	channel_array = Array.concat(channel_array, d2s(i, 0));
};
//channel_array = Array.concat(channel_array, "None");
Dialog.create("Choose channels");
Dialog.addMessage("Choose channels to \n segment nuclei and \n segment centrioles.");
Dialog.addChoice("Nuclei Channel:", channel_array);
Dialog.addChoice("Centriole Channel:", channel_array);
Dialog.addChoice("Tubullin (spindle) ch:", channel_array);
Dialog.addRadioButtonGroup("Do angle and distance measurements?", newArray("Yes", "No"), 1, 2, "Yes");
Dialog.addRadioButtonGroup("Do quantification measurements?", newArray("Yes", "No"), 1, 2, "Yes");
Dialog.show();
nuc_ch = d2s(Dialog.getChoice, 0);
cent_ch= d2s(Dialog.getChoice, 0);
tub_ch = d2s(Dialog.getChoice, 0);
measure_2d = Dialog.getRadioButton();
measure_quant = Dialog.getRadioButton();
print("Nucleus channel: "+nuc_ch);
print("Cent channel: "+cent_ch);
print("Tubullin channel: "+tub_ch);
print("Do Angle and Distance measurements: "+measure_2d);
print("Do Int Quantification: "+measure_quant);

//Image properties and name
filename = getTitle();
title = File.nameWithoutExtension();
if (title != substring(filename, 0, indexOf(filename, "."))) {
	title = substring(filename, 0, indexOf(filename, "."));
};
print("Image filename: "+filename);
print("Image Title: "+title);
getVoxelSize(w, h, d, unit);
if (w!=h || w==1){
	waitForUser("Is the image properly scaled? \nIf not, please correct.");
	run("Properties...");
};

//Creating save directory
save_dir = img_dir+fs+title+"_data";
File.makeDirectory(save_dir);

////////////////////////////////////
//// Processing and measurement ////
////////////////////////////////////
//metaphase detection
setBatchMode(true);
run("Z Project...", "projection=[Max Intensity]");
run("Split Channels");
selectWindow("C"+nuc_ch+"-MAX_"+filename);
run("Subtract Background...", "rolling=50 sliding");
setAutoThreshold("Yen dark no-reset");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Analyze Particles...", "size=30-Infinity display exclude clear add");

//storing nucleus information to use later
//should have 4 parts, X and Y nucleus centroid coordinates (separate), Major axis size and angle
nuc = newArray(4);
nuc[0] = getResult("X");
nuc[1] = getResult("Y");
nuc[2] = getResult("Major"); //major axis size
nuc[3] = getResult("Angle"); //major axis angle
print("Nucleus centroid coordinates (um) - X: "+nuc[0]+" Y: "+nuc[1]+"\n Major (µm): "+nuc[2]+"\n Major angle: "+nuc[3]);
print("Nucleus centroid coordinates (px) - X: "+(nuc[0]/w)+" Y: "+(nuc[1]/w));
if (roiManager("count") == 1) {
	roiManager("select", 0);
	roiManager("rename", "nucleus");
} else if (roiManager("count")>1) {
	print("More than 1 nucleus were detected. Adjust detection");
};

//trick to have all coordinates of nucleus periphere
run("Make Band...", "band="+w);
run("Create Mask");
run("Points from Mask");
Roi.getCoordinates(xpoints, ypoints);
print("Creating nucleus coordenate list");
call("ij.gui.ImageWindow.setNextLocation", 10, 10);
nuc_coord_list = "nuc coord list";
newImage(nuc_coord_list, "32-bit", 2, xpoints.length, 1);
for(o=0;o<xpoints.length;o++) {
	selectWindow(nuc_coord_list);
	setPixel(0, o, xpoints[o]);
	setPixel(1, o, ypoints[o]);
	showStatus("Filling nuc coord list");
	showProgress(-o/xpoints.length);
};
selectWindow("Mask");
close();

//enlarge nucleus selection for centriole detection
selectWindow("C"+nuc_ch+"-MAX_"+filename);
roiManager("select", roiManager("count")-1);
run("Enlarge...", "enlarge=5");
roiManager("add");
roiManager("select", roiManager("count")-1);
roiManager("rename", "periphere");
roiManager("Save", save_dir+fs+title+"_nucleusROIset.zip");
run("Duplicate...", "title=nucleus_mask");
saveAs("Tiff", save_dir+fs+"nucleus_mask.tif");
selectWindow("nucleus_mask.tif");
close();

//centriole detection and storing
selectWindow("C"+cent_ch+"-MAX_"+filename);
run("Subtract Background...", "rolling=50 sliding");
setAutoThreshold("Yen dark no-reset");
setOption("BlackBackground", true);
run("Convert to Mask");
roiManager("select", roiManager("count")-1);
run("Analyze Particles...", "size=20-Infinity pixel display exclude clear add");
run("Duplicate...", "title=cent_mask");
saveAs("Tiff", save_dir+fs+"cent_mask.tif");
selectWindow("cent_mask.tif");
close();

//storing centriole centroid coordinates
cent = newArray(nResults);
for (n=0; n<nResults;n++) {
	cent[n] = toString(getResult("X", n)+"; "+getResult("Y", n));
	roiManager("select", n);
	roiManager("rename", "cent_"+n);
};
roiManager("Save", save_dir+fs+title+"_centsROIset.zip");

/////////////////////////////////////////////////////////
//Measurements of the angles, distances and intensities//
/////////////////////////////////////////////////////////
run("Clear Results");
for (j=0;j<cent.length;j++) {
	print("\nCentriole_"+j);
	current_cent = split(cent[j], ";");
	D = distance_2d(current_cent, nuc);
	print("Distance to Nucleus centroid (µm): "+D);
	setResult("Centriole X coord (µm)", j, current_cent[0]);
	setResult("Centriole Y coord (µm)", j, current_cent[1]);
	setResult("Centriole X coord (px)", j, parseFloat(current_cent[0])/w);
	setResult("Centriole Y coord (px)", j, parseFloat(current_cent[1])/w);
	setResult("Dist to Nuc centroid (µm)", j, D);
	setResult("Dist to Nuc centroid (px)", j, D/w);

	cent_min_d = newArray();
	for(k=0;k<xpoints.length;k++) {
		current_cent_px = newArray();
		for(l=0;l<current_cent.length;l++) {
			v = parseFloat(current_cent[l])/w; //beacause it is in um -> passing to px
			current_cent_px = Array.concat(current_cent_px,v);
		};
		selectWindow(nuc_coord_list);
		current_coord = newArray(getPixel(0, k), getPixel(1, k));
		dis = distance_2d (current_cent_px, current_coord);
		cent_min_d = Array.concat(cent_min_d, dis);
		showStatus("Calculating distances to cent"+j);
		showProgress(-k/xpoints.length);
	};
	Array.getStatistics(cent_min_d, min, max, mean, stdDev);
	sorted = Array.sort(cent_min_d);

	//step to reject the coordinates farther away than Mean-(1.5*StdDev)
	//which is avg_min == dist < mean-1.5*stdDev
	for (m=0;m<sorted.length;m++){
		if(parseFloat(sorted[m])>mean-(1.5*stdDev)){
			sorted = Array.trim(sorted, m);
		};
		showStatus("Trimming array");
		showProgress(-m/sorted.length);
	};
	Array.getStatistics(sorted, min_sorted, max_sorted, mean_sorted, stdDev_sorted);

	print("Min dist cent"+j+" to DNA (px): "+min);
	print("Min dist cent"+j+" to DNA (µm): "+min*w);
	print("Average Min distance from cent"+j+" to DNA (px): "+mean_sorted);
	print("Average Min distance from cent"+j+" to DNA (µm): "+mean_sorted*w);
	setResult("Min dist to DNA (µm)", j, min*w);
	setResult("Avg min to DNA (µm)", j, mean_sorted*w);
	makeLine(nuc[0]/w, nuc[1]/w, current_cent[0]/w, current_cent[1]/w);
	roiManager("add");
	roiManager("select", roiManager("count")-1);
	roiManager("rename", "d_"+j);
	List.setMeasurements;
	current_angle = List.getValue("Angle");
	print("Raw angle of cent"+j+": "+current_angle);

	//negative angles are clockwise angles. If smaller than -90, it is to convert the angle in counter-clockwise.
	if (current_angle < -90) {
		current_angle = 360-sqrt(pow(current_angle,2));
	};
	angle_dif = sqrt(pow((current_angle-nuc[3]),2));
	print("Alpha (angle difference): "+angle_dif);
	setResult("Alpha", j, angle_dif);
};

//Distance between centrioles
if( nResults == 2){
	centriole_1 = newArray();
	centriole_1 = Array.concat(centriole_1,parseFloat(getResult("Centriole X coord (µm)", 0)));
	centriole_1 = Array.concat(centriole_1,parseFloat(getResult("Centriole Y coord (µm)", 0)));
	centriole_2 = newArray();
	centriole_2 = Array.concat(centriole_2,parseFloat(getResult("Centriole X coord (µm)", 1)));
	centriole_2 = Array.concat(centriole_2,parseFloat(getResult("Centriole Y coord (µm)", 1)));
	centriole_dist = distance_2d(centriole_1, centriole_2);
	print("\nDistance between centrioles (µm): "+centriole_dist);
	setResult("Distance between centrioles (µm)", 0, centriole_dist);
	setResult("Distance between centrioles (µm)", 1, "-");
	print("Distance between centrioles (px): "+centriole_dist/w);
	setResult("Distance between centrioles (px)", 0, centriole_dist/w);
	setResult("Distance between centrioles (px)", 1, "-");
} else {
	print("More than 2 centrioles may have been detected, restrict detection.");
};
roiManager("Save", save_dir+fs+title+"_centslinesROIset.zip");

if(isOpen("Results")==true){
	selectWindow("Results");
	IJ.renameResults(title+"_2d_results.csv");
	saveAs("Results", save_dir+fs+title+"_2d_results.csv");
};

//Spindle detection and signal quantification
/*
* SUM projection for signal quantification
*/
selectWindow(filename);
run("Z Project...", "projection=[Sum Slices]");
run("Split Channels");
close("C"+cent_ch+"-SUM_"+filename);
close("C"+nuc_ch+"-SUM_"+filename);
selectWindow("C"+tub_ch+"-MAX_"+filename);
roiManager("reset");
roiManager("Open", save_dir+fs+title+"_nucleusROIset.zip");
roiManager("select", roiManager("count")-1); //to select the last ROI, which should be periphere of the cell
setAutoThreshold("Li dark no-reset");
run("Convert to Mask");
run("Analyze Particles...", "size=10-Infinity display exclude clear add");
roiManager("select", roiManager("count")-1);
roiManager("rename", "spindle");
roiManager("save", save_dir+fs+title+"_spindleROI.roi");
run("Duplicate...", "title=spindle_mask");
saveAs("TIFF", save_dir+fs+"spindle_mask.tif");
close("spindle_mask");
selectWindow("C"+tub_ch+"-SUM_"+filename);
roiManager("select", roiManager("count")-1);
List.setMeasurements;
spindle_intDen = List.getValue("IntDen");
spindle_rawintDen = List.getValue("RawIntDen");
print("\nIntensity quantification\n");
print("Spindle IntDen: "+spindle_intDen);
print("Spindle RawIntDen: "+spindle_rawintDen);

/*
* Min projection for background estimation
*/
selectWindow(filename);
run("Z Project...", "projection=[Min Intensity]");
run("Split Channels");
close("C"+cent_ch+"-MIN_"+filename);
close("C"+nuc_ch+"-MIN_"+filename);
selectWindow("C"+tub_ch+"-MIN_"+filename);
roiManager("select", roiManager("count")-1);
List.setMeasurements;
spindle_bkgIntDen = List.getValue("IntDen");
spindle_bkgRawIntDen = List.getValue("RawIntDen");
print("Spindle background IntDen: "+spindle_bkgIntDen);
print("Spindle background RawIntDen: "+spindle_bkgRawIntDen);

if(isOpen(title+"_2d_results.csv")==true){
	selectWindow(title+"_2d_results.csv");
	IJ.renameResults("Results");
};
setResult("Spindle IntDen", 0, spindle_intDen);
setResult("Spindle IntDen", 1, "-");
setResult("Spindle RawIntDen", 0, spindle_rawintDen);
setResult("Spindle RawIntDen", 1, "-");
setResult("Spindle Bkg IntDen", 0, spindle_bkgIntDen);
setResult("Spindle Bkg IntDen", 1, "-");
setResult("Spindle Bkg RawIntDen", 0, spindle_bkgRawIntDen);
setResult("Spindle Bkg RawIntDen", 1, "-");
setResult("Spindle Signal IntDen", 0, spindle_intDen-spindle_bkgIntDen);
setResult("Spindle Signal IntDen", 1 , "-");
setResult("Spindle Signal RawIntDen", 0, spindle_rawintDen-spindle_bkgRawIntDen);
setResult("Spindle Signal RawIntDen", 1, "-");
print("Spindle Signal (SUM-MIN proj of the same area) IntDen: "+spindle_intDen-spindle_bkgIntDen);
print("Spindle Signal (SUM-MIN proj of the same area) IntDen: "+spindle_rawintDen-spindle_bkgRawIntDen);

roiManager("reset");
roiManager("open", save_dir+fs+title+"_centsROIset.zip");
cent_count = roiManager("count");
roiManager("open", save_dir+fs+title+"_spindleROI.roi");
spindleroi_index=roiManager("count")-1;
print("spindle index: "+spindleroi_index);
pole1_index=0;
pole2_index=0;

////////////////////////////////////
//Centriole and pole measuremente.//
////////////////////////////////////
for(p=0;p<cent_count;p++){
	print("\n");
	selectWindow("C"+tub_ch+"-SUM_"+filename);
	roiManager("select", p);
	List.setMeasurements;
	cent_intDen=List.getValue("IntDen");
	cent_rawIntDen=List.getValue("RawIntDen");
	setResult("Cent IntDen", p, cent_intDen);
	setResult("Cent RawIntDen", p, cent_rawIntDen);
	print("Cent"+p+" IntDen: "+cent_intDen);
	print("Cent"+p+" RawIntDen: "+cent_rawIntDen);

	selectWindow("C"+tub_ch+"-MIN_"+filename);
	roiManager("select", p);
	List.setMeasurements;
	cent_bkgIntDen=List.getValue("IntDen");
	cent_bkgRawIntDen=List.getValue("RawIntDen");
	setResult("Cent Bkg IntDen", p, cent_bkgIntDen);
	setResult("Cent Bkg RawIntDen", p, cent_bkgRawIntDen);
	print("Cent"+p+" Bkg IntDen: "+cent_bkgIntDen);
	print("Cent"+p+" Bkg RawIntDen: "+cent_bkgRawIntDen);
	setResult("Cent Signal IntDen", p, cent_intDen-cent_bkgIntDen);
	setResult("Cent Signal RawIntDen", p, cent_rawIntDen-cent_bkgRawIntDen);
	print("Cent "+p+" Signal IntDen: "+cent_intDen-cent_bkgIntDen);
	print("Cent "+p+" Signal RawIntDen: "+cent_rawIntDen-cent_bkgRawIntDen);

	//pole is the common area between spindle and enlarged centriole
	selectWindow("C"+tub_ch+"-SUM_"+filename);
	roiManager("select", p);
	run("Enlarge...", "enlarge=1");
	roiManager("add");
	roiManager("select", newArray(spindleroi_index, roiManager("count")-1));
	roiManager("AND");
	roiManager("add");
	roiManager("select", roiManager("count")-1);
	roiManager("rename", "pole_"+p);
	if(p==0){
		pole1_index=roiManager("count")-1;
	} else if (p==1) {
		pole2_index=roiManager("count")-1;
	};
	List.setMeasurements;
	pole_intDen=List.getValue("IntDen");
	pole_rawIntDen=List.getValue("RawIntDen");
	setResult("Pole IntDen", p, pole_intDen);
	setResult("Pole RawIntDen", p, pole_rawIntDen);
	print("Pole "+p+" IntDen: "+pole_intDen);
	print("Pole "+p+" RawIntDen: "+pole_rawIntDen);

	selectWindow("C"+tub_ch+"-MIN_"+filename);
	roiManager("select", roiManager("count")-1);
	List.setMeasurements;
	pole_bkgIntDen = List.getValue("IntDen");
	pole_bkgRawIntDen = List.getValue("RawIntDen");
	setResult("Pole Bkg IntDen", p, pole_bkgIntDen);
	setResult("Pole Bkg RawIntDen", p, pole_bkgRawIntDen);
	print("Pole "+p+" Bkg IntDen: "+pole_bkgIntDen);
	print("Pole "+p+" Bkg RawIntDen: "+pole_bkgRawIntDen);
	setResult("Pole Signal IntDen", p, pole_intDen-pole_bkgIntDen);
	setResult("Pole Signal RawIntDen", p, pole_rawIntDen-pole_bkgRawIntDen);
	print("Pole "+p+" Signal IntDen: "+pole_intDen-pole_bkgIntDen);
	print("Pole "+p+" Signal RawIntDen: "+pole_rawIntDen-pole_bkgRawIntDen);
};
roiManager("select", newArray(0, 1, pole1_index-1, pole2_index-1));
roiManager("delete");
roiManager("save", save_dir+fs+title+"_polesROIset.zip");


///////////////////////////////////////////////
///////////// Closing down ////////////////////
///////////////////////////////////////////////
//Closing windows and saving final files
if(isOpen("Results")){
	saveAs("Results", save_dir+fs+title+"_2d_results.csv");
};

selectWindow(filename);
close("\\Others");
setSlice(nSlices/2);
setBatchMode(false);
roiManager("reset");
roiManager("Open", save_dir+fs+title+"_centslinesROIset.zip");
roiManager("Open", save_dir+fs+title+"_polesROIset.zip");
roiManager("Open", save_dir+fs+title+"_nucleusROIset.zip");
roiManager("Save", save_dir+fs+title+"_finalROIset.zip");
selectWindow("Log");
endTime=getTime();
print("Analysis complete. \nDuration: "+(endTime-startTime)/1000+" s.");
saveAs("Text..", save_dir+fs+title+"_log.txt");
print("Command finished");

function distance_2d (array_1, array_2) {
	//euclidean distance in 2d
	// d = sqrt ( (x2 - x1) ^2 + (y2 - y1)^2)
	d = sqrt( pow(array_2[0]-array_1[0],2) + pow(array_2[1]-array_1[1],2));
	return d
};
