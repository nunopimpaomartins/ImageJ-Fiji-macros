filepath = "D:\\Data\\3dliver_local\\CageAnalysis\\superpixel_analysis\\filtered_tables\\"
filename = "superpixels_diff8_c0p01_filtered_labels_minsmaller150.csv"
file_string = File.openAsRawString(filepath+filename);

title = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);

//file_string = replace(file_string, "\n", "");
filtered_array = split(file_string, "\n");
//Array.show(filtered_array);
filtered_array_names = newArray(filtered_array.length);
for(i = 0; i < filtered_array.length; i++) {
	split_line = split( filtered_array[i], "," );
	filtered_array_names[i] = String.trim(split_line[1]);
};
//Array.show("title", filtered_array, filtered_array_names);
//print(find_array_index(filtered_array_names, " obj112-val112"));
//stop;

run("3D Manager");
Ext.Manager3D_Count(count);
print("Initial number of elements: ", count);
Ext.Manager3D_DeselectAll();
// Ext.Manager3D_MultiSelect();

for(i = count-1; i >= 0; i--){
	Ext.Manager3D_GetName(i, roiname);
	name_split = split(roiname, '-');
	if(find_array_index(filtered_array_names, name_split[1]) < 0){
		//		print("Not found :"+name);
		Ext.Manager3D_Select(i);
		Ext.Manager3D_Delete();
	};
	Ext.Manager3D_DeselectAll();
};

// newImage("mask", "8-bit black", width, height, slices);
// selectWindow("mask");
// Ext.Manager3D_FillStack(255, 255, 255);

Ext.Manager3D_Count(newcount);
if(filtered_array.length != newcount){
    print("Filtered table numbers and remaining ROIs defer in size.");
    print(filtered_array.length+" "+newcount);
}
print("done");

/*
 * Functions
 */

function find_array_index(array, substr) {
	index = -1;
	for( idx = 0; idx < array.length; idx++){
		if(array[idx] == substr){
			index = idx;
			break;
		}
	}
	return index;
};
