//Setup
setOption("ShowRowNumbers", true);
run("Set Measurements...", "area mean standard modal min centroid perimeter shape feret's integrated median limit display redirect=None decimal=3");

save_dir = getDirectory("Choose a directory to save data sheets.");
title = getTitle();
print("Duplicating image");
run("Duplicate...", "title=[masked image]");
//run("Gamma...", "value=0.50");
//run("Gaussian Blur...", "sigma=2");
//showStatus("Applying Threshold");
print("Applying Li Threshold");
setAutoThreshold("Li dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Watershed");

waitForUser("Select cell region");
setTool("polygon");
run("Properties...", "unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1");
getStatistics(selection_area, selection_mean, selection_min, selection_max, selection_std, selection_histogram);
print("area: "+selection_area);
print("Detecting spots");
run("Analyze Particles...", "size=1-10000 pixel display exclude clear add");
run("Clear Results");

selectWindow(title);
getPixelSize(unit, pw, ph);

run("Duplicate...", "title=[test img]");
run("Properties...", "unit=pixel pixel_width=1 pixel_height=1 voxel_depth=1");
roiManager("Show All");
roiManager("Measure");
n_points = nResults;

print("Creating spot coordenate list");
call("ij.gui.ImageWindow.setNextLocation", 10, 10);
point_list = "point CM list";
newImage(point_list, "32-bit", 2, n_points, 1);

for(i=0;i<n_points;i++) {
	showProgress(i/n_points);
	selectWindow(point_list);
	x = getResult("X",i);
	y = getResult("Y",i);
	//print(x, y);
	setPixel(0, i, x);
	setPixel(1, i, y);
};

run("Clear Results");
radius = 50;
print("Calculating Photon count number in r radius.");

setOption("ShowRowNumbers", false);
setBatchMode(true);
selectWindow(point_list);
point_list_id = getImageID();
point_list_n = getHeight();
table_name = "[Photons average table]";
table_name_2 = "Photons average table";
run("New... ", "name="+table_name+" type=Table");
print(table_name, "r ; avg");
/*
for(i=0;i<radius;i++) {
	showProgress(i/radius);
	avg = photon_count_avg(i);
	print(table_name, i+" ; "+avg);
};
updateResults();
selectWindow(table_name_2);
saveAs("Results", save_dir+File.separator+table_name_2+".csv");*/
run("Select None");

print("Calculating Average number of spots in r radius.");
showStatus("Calculating Average number of spots in r radius.");
run("Clear Results");
for(i=0;i<radius;i++) {
	showProgress(i/radius);
	avg = point_avg(i);
	setResult("r", i, i);
	setResult("n", i, avg);
};
updateResults();

print("Calculating K(r)");
showStatus("Calculating K(r)");
selectWindow(point_list);
for (r=0;r<radius;r++){
	showProgress(r/radius);
	k = ripley_k(r, n_points, selection_area);
	l = l_function(k);
	setResult("r", r, r);
	//setResult("Area r", r, PI*pow(r,2));
	setResult("K(r)", r, k);
	setResult("L(r)", r, l);
	setResult("L(r)-r", r, l-r);
};
updateResults();
selectWindow("Results");
saveAs("Results", save_dir+File.separator+"Results.xls");
setBatchMode(false);

//plotting the values
print("Plotting calculated values");
r_values = newArray(nResults);
k_values = newArray(nResults);
l_values = newArray(nResults);
lr_values = newArray(nResults);
for (f=0;f<nResults;f++) {
	r_values[f] = getResult("r", f);
	k_values[f] = getResult("K(r)", f);
	l_values[f] = getResult("L(r)", f);
	lr_values[f] = getResult("L(r)", f)-getResult("r", f);
};

Plot.create("K(r) function", "r", "K(r)", r_values, k_values);
Plot.show();
Plot.create("L(r) function", "r", "L(r)", r_values, l_values);
Plot.show();
Plot.create("L(r)-r function", "r", "L(r)-r", r_values, lr_values);
Plot.show();

/*selectWindow("Log");
id_log = 
close();*/

function ripley_k (r, n_points, area) {
	//	K(r) = A * sum(i=1; n) sum(j=1;n) (delta/n^2)
	/*
	 * for i =! j
	 * delta - is the distance between i and j
	 *    if delta < r, delta = 1
	 *    if delta >= r, delta = 0
	 * n_points is the number of points
	 * r is the sparial scale (radius)
	 * 
	 */
	total_delta = 0;
	n_count = 0;
	
	//calculate area
	
	for(j=0;j<point_list_n;j++) {
		for(k=j+1;k<point_list_n;k++) {
			if (j!=k) {
				delta = euclidian_2d( getPixel(0,j) , getPixel(1,j), getPixel(0,k), getPixel(1,k) );
				//print(delta);
			};
			if (delta < r) {
				delta = 1;
			} else {
				delta = 0;
			};
			if (n_points == 0) {
				n_points =1;
			};
			total_delta += (delta/pow(n_points,2));
		};
	};
	 kfunction = area*total_delta;
	 return kfunction;
};

function l_function (k_function) {
	/*
	 * L(r) = sqrt( K(r) / pi) )
	 * 
	 * this function linearizes the radial indexes calculated by K(r)
	 */
	 lfunction = sqrt((k_function/PI));
	 return lfunction;
};

function euclidian_2d (x1, y1, x2, y2) {
	/*
	 * d(p,q) = sqrt ( (qx-px)^2 + (qy-py)^2 + (qz-pz)^2)
	 */
	d = 0;
	x_d = x2-x1;
	y_d = y2-y1;
	d =sqrt( pow((x_d),2) + pow((y_d),2));
	return d;
};

function photon_count_avg (r) {
	sum_photons=0;
	//count = 0;
	run("Clear Results");
	//selectWindow(point_list);
	//point_list_n = getHeight();
	selectWindow("test img");
	run("Measure");
	total_rawintden = getResult("RawIntDen", nResults-1);
	for (j=0;j<point_list_n;j++) {
		showProgress(j/point_list_n);
		selectWindow(point_list);
		x=getPixel(0,j);
		y=getPixel(1,j);
		selectWindow("test img");
		makePoint(x,y);
		run("Enlarge...", "enlarge="+r+" pixel");
		run("Measure");
		density = getResult("RawIntDen", nResults-1);
		sum_photons += density/*/total_rawintden*/;
		//count += 1;
	};
	avg = sum_photons/total_rawintden;
	return avg;
};

function point_avg (r) {
	sum_dist=0;
	count = 0;
	//selectWindow(point_list);
	//point_list_n = getHeight();
	for(j=0;j<point_list_n;j++) {
		for(k=j+1;k<point_list_n;k++) {
			if (j!=k) {
				if (isActive(point_list_id)==false) {
					selectWindow(point_list);
				};
				dist = euclidian_2d ( getPixel(0,j) , getPixel(1,j), getPixel(0,k), getPixel(1,k) );
				if (dist <= r) {
					count += 1;
					sum_dist += dist;
				};
			};
		};
	};
	if (count == 0) {
		count=1;
	};
	avg = sum_dist/count;
	return avg;
};

setOption("ShowRowNumbers", true);