# Imagej-Fiji-macros

My repository for ImageJ/Fiji macros built and used at the facility with different objectives.

Will be adding macros, code and description overtime.

## Macro list:
+ distance_quant
+ ripley_k_function
+ batch_stack_to_hyperstack
+ 2p_FFT
+ batch_grid_stitcher
+ batch_grid_to_tiles
+ batch_make_substack
+ batch_tiff_to_ome_tiff
+ cent_quant
+ dv_max_proj_batch
+ lif_to_tif
+ mt_speed_from_curve
+ quality_control_psf_analyser
+ quality_control_coloc
+ batch_zprojection

___

### distance_quant
   ```
   latest version: v0.3
   ```

   This macro detects the centrioles on the periphere of a a metaphase plate and saves it's centroid coordinates to get both the position from the nucleus and the angle to check for cell assymetry during division. The angle is calculated based on the major axis of an elipse taken from the metaphase nucleus.

   In addition to these measurments, it also quantifies the tubullin/gfp signal intensity at the spindle, centriole and the pole around the centriole.

   Changelog:

   - 0.2.4: estimating flurescence signal by calculating the background values through a MIN projection and subtracting this value from the SUM projection measured one.

   Usage instructions will be added in the future.

### ripley_k_function
   ```
   latest version: v0.1.10
   ```

   At the time this macro was done, there was no ImageJ/Fiji pluging for Ripley K clustering, which we needed for some cluster analysis of dSTORM images. It is a very rude and slow implementation of the clustering function.

   Usage instructions will be added in the future with additional notes.

### batch_stack_to_hyperstack
   As the name suggests, this macro converts stacks of images into hyperstacks. To be used when there is a problem while saving data or to convert specific images.

### 2p_FFT
   The Prairie multiphoton at our facility had a faulty stage movement which created a stripped pattern in the acquired images. This macro finds maxima in the FFT image and clears them to eliminate stripes in the image.

### batch_grid_stitcher
   Macro to stitch grids/mosaics of images inside a folder by specifying the total grid size and the file basename.

   Currently, stitches files in a "snake by rows" order from "Right and Down".

### batch_grid_to_tiles
   The opposite of the previous macro, converts a grid/mosaic of images into their tiles. The user must specify the number of rows and collumns by grid and the image extension.

### batch_make_substack
   Creates a substack of the original image and saves it separately. Currently makes a substack in the Z dimension, keeps all the Timeframes and Color channels.

### batch_tiff_to_ome_tiff
   Converts all tiff files inside a folder to OME TIFF using BioFormats. It is a bit slow.

### cent_quant
   ```
   latest version: v0.10
   ```

   Workflow to detect and quantify centriole signal in 3D, excluding local background determined per centriole and subtracted from the measured intensities.

### dv_max_proj_batch
   A batch macro that runs on all the DV files present on the folder, to create a MIP and save each channel separately.

### lif_to_tif
   ```
   latest version: v1.8
   ```

   A macro initially done to batch convert and save all the series inside a LIF (Leica) file into separate TIF or OME TIF files. It can convert more file types as ND(MetaMorph) or ND2 (Nikon NIS Elements). Can batch convert all files inside a folder.

### mt_speed_from_curve
   ```
   latest version: v0.6
   ```

   A workflow that measures MicroTubule speed through the slope of the kimigraph of the MT movement, returning the average speed of the slope. This is done through by drawing the MT movement on a MIP and then doing the measurement in the original stack by extracting several slopes of the kimigraph and then fiting them to a straight line.

### quality_control_psf_analyser
   ```
   latest version: v2.1.3
   ```

   Workflow developed at the facility to more automatically and with less user interaction to automatically detect beads in the field of view and then measure their PSF FWHM using the MetroloJ plugin.

   Changelog:

      + v2.1.3 - added batch mode to speed up the process of duplicating beads and then measuring them.

### quality_control_coloc
   ```
   latest version: v0.8
   ```

   Macro developed at the facility to more automatically and with less user interaction check the chromatic shift between multicolor beads and retrieve an average to be used for chromatic shift correction created by the illumination or the microscope itself.

#### Changelog:

   v0.8:

      + It can now run a minimum of 2 channels and a maximum of 4.
      + Rewrote code for difference and calculations between channels for a more automated manner.
      + Rewrote code for value concatenation and summary.
      + Added incrementation to csv tables of each bead when saving.
      + Saves as csv with comma separation instead of semicolon.

### batch_zprojection

   Script that allows to do a batch macro of all the files inside a folder with the same extension (.dv, .tif, etc.) and up to 3 channels. It allows the user to chose which type of projection he wants to do and saves every channel as a tiff file and a RGB overlay image of all channels for faster checking.
