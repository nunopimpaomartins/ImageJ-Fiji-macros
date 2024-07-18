run("Select None");
run("Clear Results");

image_name = getTitle();

Stack.getDimensions(width, height, channels, slices, frames);
getVoxelSize(px_w, px_h, px_depth, unit);

for(i=0; i<width; i++){
	showProgress(i, width);
	run("Select None");
	makeLine(i, 0, i, height, 1);
	int_profile = getProfile();
	dist_profile = newArray(int_profile.length);
	for(j=0; j<dist_profile.length; j++){
		dist_profile[j] = j*px_h;
	};
	tolerance = 100;
	y_minima = Array.findMinima(int_profile, tolerance);
	// while(y_minima.length < 3){
	// 	tolerance -= 10;
	// 	if(tolerance <= 0){
	// 		continue;
	// 	};
	// 	y_minima = Array.findMinima(int_profile, tolerance);
	// };
	if(y_minima.length < 3){
		setResult("T", i, i);
		setResult("Distance", i, "null");
		continue;
	};
	Array.sort(y_minima);

	minima_index = y_minima[1];
	peak_first = fit_gaussian(dist_profile, int_profile, minima_index, "first");
	peak_second = fit_gaussian(dist_profile, int_profile, minima_index, "last");
	distance = peak_second - peak_first;
	setResult("T", i, i);
	setResult("Distance", i, distance);
	// print(distance);
	// Array.show(int_profile, dist_profile, y_minima);
	// break;
};
updateResults();

function fit_gaussian(x_array, y_array, index, flag){
	x_array_partial = newArray();
	y_array_partial = newArray();
	if(flag == "first"){
		x_array_partial = Array.trim(x_array, index);
		y_array_partial = Array.trim(y_array, index);
	} else if(flag == "last"){
		x_array_partial = Array.slice(x_array, index, x_array.length);
		y_array_partial = Array.slice(y_array, index, y_array.length);
	};
	Fit.doFit("Gaussian", x_array_partial, y_array_partial);
	c = Fit.p(2);
	return c;
};
