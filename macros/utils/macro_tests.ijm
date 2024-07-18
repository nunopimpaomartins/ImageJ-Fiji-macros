/*
 * Macro with different tests
 */
//2 var for loop
for(i = 1, j = 5; i < 5 && j > 1; i++, j--){
	print("i: "+i+" // j:"+ j);
}


//2 var for loop inside for loop
total_slices = 3200;
n_views = 5;

for(i = 1; i <= n_views; i++){
	print("\ni: "+i+"\n___");
	for(j = n_views, k = n_views; j > 1 && k >= 1; j--, k--) {
		if (k == i){
			k -= 1;
		}
		print("j: "+j+" // k: "+k);
	}
}
