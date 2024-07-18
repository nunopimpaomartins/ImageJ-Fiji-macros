n_rows = nResults();
diameter = 3;
r = Math.floor((diameter/2));

if(isNaN(getResult("T (s)", 0))){
	for(k=0; k<n_rows; k++){
		setResult("T (s)", k, (k*0.14));
	};
};

for(i=0; i<n_rows; i++){
	showProgress(i, n_rows);
	value_array = newArray();
	if(i-r>=0){
		for(j=r; j>0; j--){
			previous_row = getResult("Distance", i-j);
			if(!isNaN(previous_row)) {
				// previous_row = current_row;
				value_array = Array.concat(value_array, previous_row);
			};
		};
	};
	current_row = getResult("Distance", i);
	if(!isNaN(current_row)){
		value_array = Array.concat(value_array, current_row);
	};
	if(i+r<=n_rows-1){
		for(j=r; j>0; j--){
			next_row = getResult("Distance", i+j);
			if(!isNaN(next_row)) {
				// next_row = current_row;
				value_array = Array.concat(value_array, next_row);
			};
		};
	};
	// Array.getStatistics(value_array, array_min, array_max, array_mean, array_stdDev);
	array_mean = mean(value_array);
	setResult("Distance avg "+diameter, i, array_mean);
};

function mean(array){
	number_of_elements = array.length;
	sum = 0;
	for(idx=0; idx<number_of_elements; idx++){
		sum += array[idx];
	};
	arithmetic_mean = sum/number_of_elements;
	return arithmetic_mean;
}
