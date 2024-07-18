from ij import IJ, ImagePlus, ImageStack
from ij.process import ImageStatistics as IS
from ij.process import ImageProcessor as IP

def main():
	imp = IJ.getImage()
	title = imp.getTitle()
	stack = imp.getImageStack()
	print title

	ip = imp.getProcessor()
	options = IS.MEAN | IS.MEDIAN | IS.MIN_MAX
	stats = IS.getStatistics(ip, options, imp.getCalibration())
	max_value = stats.max
	min_value = stats.min
	normalize(min_value, max_value)

def normalize(min_ref, max_ref):
#	Min Max normalization between [min_new, max_new], typically -> [0,1]
#	px_nom = (px_value - min) * max_new / (max - min) + min_new
	imp_temp = IJ.getImage()
	stack_temp = imp_temp.getImageStack()
	width = imp_temp.getWidth()
	height = imp_temp.getHeight()
	nSlices = imp_temp.getNSlices()
	#width, height, nChannels, nSlices, nFrames = stack_temp.getDiemntions()
	
	for z in range(nSlices):
		for j in range(height):
			for i in range(width):
				px_value = imp_temp[i][j][z]
				px_norm = (px_value - min_ref) * 1 / (max_ref - min_ref) + 0
#				px_norm = float(px_norm)
				imp3[i][j][z] = px_norm
	a = 0
	return a

main()