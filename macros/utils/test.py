from ij import IJ, ImagePlus
from script.imglib import ImgLib

imp = IJ.getImage()
IJ.run(imp, "Merge Channels...", "c1=exported_tiffs-1 c2=exported_tiffs-2 c3=peaks-Dilation create keep");

stack = imp.getImageStack()
#img = ImgLib.wrap(stack)

width = imp.getWidth()
height = imp.getHeight()
nSlices = imp.getNSlices()
#width, height, nChannels, nSlices, nFrames = stack_temp.getDiemntions()

print width
print height
print nSlices