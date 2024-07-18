startTime = getTime();
title = getTitle();
print(title);

width = getWidth();
height = getHeight();

pixelValues = newArray(width*height);

for(i=0; i<width; i++){
	for(j=0; j<height; j++){
		value = getPixel(i, j);
		pixelValues[i*height+j] = value;
		showProgress((i+j), (pixelValues.length));
	}
}

/*pixelValues_concat = newArray();

for(i=0; i<width; i++){
	for(j=0; j<height; j++){
		value = getPixel(i, j);
		pixelValues_concat = Array.concat(pixelValues_concat, value);
		showProgress((i+j), (width+height));
	}
}*/

Array.show("arrays", pixelValues);
Array.getStatistics(pixelValues, min, max, mean, stdDev);
print(min+" "+max+" "+mean+" "+stdDev);

min_perc = getPercentile(pixelValues, 3);
max_perc = getPercentile(pixelValues, 99.7);

print("Min perc: "+min_perc);
print("Max perc: "+max_perc);
setMinAndMax(min_perc, max_perc);

/*Array.getStatistics(pixelValues_concat, min_2, max_2, mean_2, stdDev_2);
print(min_2+" "+max_2+" "+mean_2+" "+stdDev_2);*/

endTime = getTime();
print("Duration :"+((endTime-startTime)/1000));

function getPercentile(array, percentile) {
	sortedArray = array;
	sortedArray = Array.sort(sortedArray);
	perc = parseFloat(percentile)/100;
	perc_ind = floor(parseFloat(sortedArray.length*perc));
	percentile_value = sortedArray[perc_ind];
	return percentile_value;
};
