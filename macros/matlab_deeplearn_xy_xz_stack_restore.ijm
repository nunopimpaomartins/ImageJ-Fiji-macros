total_slices = 2048;
n_views = 4;
zSlices = 512; 
/*
 * 510 in case of  xz_yz_3d nets
 * 512 in xz_yz nets
 * or 732 for full frame
 */

title = getTitle();
for(i = 1; i <= n_views; i++){
	selectWindow(title);
	//print("\ni: "+i+"\n___");
	run("Duplicate...", "title=view"+i+" duplicate");
	for(j = n_views, k = n_views, count = 0, loops = n_views; loops > 1; j--, k--, count++, loops--) {
		selectWindow("view"+i);
		if (k == i){
			k -= 1;
		}
		if(k == 0){
			k = 1;
		}
		run("Slice Remover", "first="+k+" last="+(total_slices-(zSlices*count))
+" increment="+j);
		//print(total_slices-(640*count));
		//print("j: "+j+" // k: "+k+" // count: "+count);
	}
}