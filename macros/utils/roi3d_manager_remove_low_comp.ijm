run("3D Manager");

Ext.Manager3D_Count(nb_obj); 

test_array = newArray(nb_obj);
for(i=0; i<nb_obj; i++){
	Ext.Manager3D_Select(i);
//	Ext.Manager3D_Measure3D(i, "Spher", value);
	Ext.Manager3D_Measure();
//	if(i==0){
//		print(value);
//	}
//	test_array[i] = value;
}
Array.show(test_array);