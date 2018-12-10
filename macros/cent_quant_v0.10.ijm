/*
 * author: Nuno Pimpão Martins
 * IGC 2017, Feb
 */
 
//SETUP
print("\\Clear");
run("Set Measurements...", "area mean standard modal min centroid feret's integrated median limit display redirect=None decimal=4");
run("Options...", "black pad");
run("3D OC Options", "volume nb_of_obj._voxels integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value dots_size=5 font_size=10 show_numbers redirect_to=none");
roiManager("reset");
if(isOpen("Results")==true) {
	run("Clear Results");
};
roiManager("reset");

/*
 * The Macro code starts here
 */
title = getTitle();
print("Image Title: "+title);

OC_results_table_centrin = "Statistics for 3D-OC centrin for "+title;
OC_results_table_perecentrin = "Statistics for 3D-OC perecentrin for "+title;
if(isOpen(OC_results_table_centrin)==true) {
		selectWindow(OC_results_table_centrin);
		run("Close");
};
if(isOpen(OC_results_table_perecentrin)==true) {
		selectWindow(OC_results_table_perecentrin);
		run("Close");
};

run("Z Project...", "projection=[Max Intensity]");

selectWindow("MAX_"+title);
run("Split Channels");
max_gfp = "max_centrin";
selectWindow("C2-MAX_"+title);
rename(max_gfp);
max_rfp = "max_preicentrin";
selectWindow("C3-MAX_"+title);
rename(max_rfp);
selectWindow("C1-MAX_"+title);
close();

selectWindow(title);
run("Z Project...", "projection=[Sum Slices]");
run("Split Channels");
selectWindow("C1-SUM_"+title);
close();
sum_gfp = "sum_centrin";
selectWindow("C2-SUM_"+title);
rename(sum_gfp);
sum_rfp = "sum_perecentrin";
selectWindow("C3-SUM_"+title);
rename(sum_rfp);

run("Tile");
waitForUser("Checkpoint", "Check Images. \n If the images are not fine, press ESC");

selectWindow(sum_gfp);
close();
selectWindow(sum_rfp);
close();

selectWindow(title);
run("Z Project...", "projection=[Average Intensity]");

selectWindow("AVG_"+title);
run("Split Channels");
avg_gfp = "avg_centrin";
selectWindow("C2-AVG_"+title);
rename(avg_gfp);
avg_rfp = "avg_preicentrin";
selectWindow("C3-AVG_"+title);
rename(avg_rfp);
selectWindow("C1-AVG_"+title);
close();


run("Tile");
//-----------------------------------------------------------------------------------------------------------------------------//
//getting centriole area for centrin channel
selectWindow(max_gfp);
setAutoThreshold("Yen dark");
getThreshold(gfp_min_thesh, gfp_max_thesh);
print("min threshold: "+gfp_min_thesh);
print("max threshold: "+gfp_max_thesh);
setOption("BlackBackground", true);
run("Convert to Mask");

run("Analyze Particles...", "size=5-2500 pixel display exclude clear add");
selectWindow(max_gfp);
/*
//if (gfp_count > 2) {
	Dialog.create("Select ROI centriole numbers");
	Dialog.addNumber("Centriole nb1, is ROI: ", 1);
	Dialog.addNumber("Centriole nb2, is ROI: ", 2);
	Dialog.show();
	cent1_roi = Dialog.getNumber();
	cent2_roi = Dialog.getNumber();
//}
//print(cent1_roi);
//print(cent2_roi);
cents_nbs = newArray(cent1_roi, cent2_roi);
*/
Dialog.create("Centriole number and position");
Dialog.addMessage("Write down centriole position divided by commas ( , )");
Dialog.addString("Centriole nbs", "1,2,3");
Dialog.show();
input = Dialog.getString();
centrioles_2d = split(input, ",");

//calculating values for centin channel
background_values_gfp = newArray();
selectWindow(avg_gfp);
for (i=0;i<centrioles_2d.length;i++) {
	roiManager("select", centrioles_2d[i]-1);
	run("Enlarge...", "enlarge=5 pixel");
	run("Make Band...", "band=0.13");
	getStatistics(selection1_area, selection1_mean, selection1_min, selection1_max, selection1_std, selection1_hist);
	print("background: "+selection1_mean);
	background_values_gfp = Array.concat(background_values_gfp, selection1_mean);
};
//Array.show(background_values_gfp);
Array.getStatistics(background_values_gfp, a_min, a_max, gfp_bg_mean, a_std);
print("gfp_bg_mean: "+gfp_bg_mean);
selectWindow(avg_gfp);
close();

run("Select None");

selectWindow(title);
run("Split Channels");
selectWindow("C2-"+title);
run("3D Objects Counter", "threshold="+gfp_min_thesh+" slice=22 min.=20 max.=15728640 exclude_objects_on_edges objects statistics summary");


selectWindow("Objects map of C2-"+title);
run("Z Project...", "projection=[Max Intensity]");
setAutoThreshold("Default dark");
selectWindow("Objects map of C2-"+title);

close();
run("Tile");
waitForUser("Check centriole numbers in Objects map");
//-----------------------------------------------------------------------------//
//specify which are the objectives from the detected ones
//due to way how AP and 3D-OC works, number identification is different

Dialog.create("Centriole number and position");
Dialog.addMessage("Write down centriole position divided by commas ( , )");
Dialog.addString("Centriole nbs", "1,2,3");
Dialog.show();
input = Dialog.getString();
centrioles_3d = split(input, ",");

selectWindow("MAX_Objects map of C2-"+title);
close();

print(" \n Centrin channel quantification \n Values added to results table");
for(j=0;j<centrioles_3d.length;j++) {
	obj_voxel = getResult("Nb of obj. voxels", centrioles_3d[j]-1);
	print("obj_voxel: "+obj_voxel);
	obj_intDen = getResult("IntDen", centrioles_3d[j]-1);
	print("obj_intDen: "+obj_intDen);
	bg_intDen = gfp_bg_mean*obj_voxel;
	print("bg_intDen: "+bg_intDen);
	signal_intDen = obj_intDen-bg_intDen;
	print("signal_intDen: "+signal_intDen);
	setResult("Background intDen", centrioles_3d[j]-1, bg_intDen);
	setResult("Signal intDen", centrioles_3d[j]-1, signal_intDen);
};

if (isOpen("Results")==true) {
	IJ.renameResults(OC_results_table_centrin);
};

selectWindow(max_gfp);
close();


//-----------------------------------------------------------------------------------------------------------------------------//
//calculating background valuies for perecentrin channel
print(" \n Calculating background for Perecentrin");
background_values_rfp = newArray();

selectWindow(avg_rfp);
//Array.show(centrioles_2d);
for (i=0;i<centrioles_2d.length;i++) {
	roiManager("select", centrioles_2d[i]-1);
	run("Enlarge...", "enlarge=5 pixel");
	run("Make Band...", "band=0.13");
	getStatistics(selection1_area, selection2_mean, selection1_min, selection1_max, selection1_std, selection1_hist);
	print("background: "+selection2_mean);
	background_values_rfp = Array.concat(background_values_rfp, selection2_mean);
};
//Array.show(background_values_rfp);
Array.getStatistics(background_values_rfp, a_min, a_max, rfp_bg_mean, a_std);
print("rfp_bg_mean: "+rfp_bg_mean);
selectWindow(avg_rfp);
close();

run("Select None");

selectWindow(max_rfp);
setAutoThreshold("Yen dark");
getThreshold(rfp_min_thesh, rfp_max_thesh);
print("min threshold: "+rfp_min_thesh);
print("max threshold: "+rfp_max_thesh);

selectWindow("C3-"+title);
run("3D Objects Counter", "threshold="+rfp_min_thesh+" slice=22 min.=20 max.=15728640 exclude_objects_on_edges objects statistics summary");

selectWindow("Objects map of C3-"+title);
run("Z Project...", "projection=[Max Intensity]");
setAutoThreshold("Default dark");
selectWindow("Objects map of C3-"+title);
close();
run("Tile");
waitForUser("Check centriole numbers in Objects map");

//-----------------------------------------------------------------------------//
//specify which are the objectives from the detected ones
//due to way how AP and 3D-OC works, number identification is different

Dialog.create("Centriole number and position");
Dialog.addMessage("Write down centriole position divided by commas ( , )");
Dialog.addString("Centriole nbs", "1,2,3");
Dialog.show();
input = Dialog.getString();
centrioles_3d = split(input, ",");

selectWindow("MAX_Objects map of C3-"+title);
close();

print("centrioles_3d.length: "+centrioles_3d.length);
print(" \n Perecentrin channel quantification \n Values added to results table");
for(j=0;j<centrioles_3d.length;j++) {
	obj_voxel = getResult("Nb of obj. voxels", centrioles_3d[j]-1);
	print("obj_voxel: "+obj_voxel);
	obj_intDen = getResult("IntDen", centrioles_3d[j]-1);
	print("obj_intDen: "+obj_intDen);
	bg_intDen = rfp_bg_mean*obj_voxel;
	print("bg_intDen: "+bg_intDen);
	signal_intDen = obj_intDen-bg_intDen;
	print("signal_intDen: "+signal_intDen);
	setResult("Background intDen", centrioles_3d[j]-1, bg_intDen);
	setResult("Signal intDen", centrioles_3d[j]-1, signal_intDen);
};


if (isOpen("Results")==true) {
	IJ.renameResults(OC_results_table_perecentrin);
};

run("Close All");

//selectWindow(max_rfp);
//close();

print("Done!");