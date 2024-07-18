image_name = getTitle();

Stack.getDimensions(width, height, channels, slices, frames);
if(frames == 1){
	max_length = slices;
} else {
	max_length = frames;
};

avg_window_size = 1; //average of 3 images, -1 and +1

setBatchMode(true);
for(i=1; i<=max_length; i++){
	showProgress(-i/max_length);
	selectWindow(image_name);
	if(i==1){
//		i=1;
		Stack.setFrame(i);
		run("Duplicate...", "title=temp_stack");
	} else if (i==max_length){
		Stack.setFrame(i);
		run("Duplicate...", "title=temp_final");
		run("Concatenate...", "  image1=temp_stack image2=temp_final image3=[-- None --]");
	} else {
//		i=2;
		run("Duplicate...", "title=stack_proj duplicate range="+(i-1)+"-"+(i+1));
		selectWindow("stack_proj");
		run("Z Project...", "projection=[Average Intensity]");
		close("stack_proj");
		run("Concatenate...", "title=temp_stack image1=temp_stack image2=AVG_stack_proj image3=[-- None --]");
	}
}
setBatchMode("exit and display");