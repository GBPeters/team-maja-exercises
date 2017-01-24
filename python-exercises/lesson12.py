import matplotlib.pyplot as plt
from os import path, system
from osgeo import gdal
from osgeo.gdalconst import GDT_Float32

import numpy as np

from miscfunctions import DATA_DIR

LANDSAT_URL = "http://dl.dropboxusercontent.com/s/zb7nrla6fqi1mq4/LC81980242014260-SC20150123044700.tar.gz"
BAND4_NAME = "LC81980242014260LGN00_sr_band4.tif"
BAND5_NAME = "LC81980242014260LGN00_sr_band5.tif"


def calculateNDWI(band4file=BAND4_NAME, band5file=BAND5_NAME, outfile="ndwi.tif", datadir=DATA_DIR):
    band4p = path.join(datadir, band4file)
    band5p = path.join(datadir, band5file)
    band4ds = gdal.Open(band4p)
    band5ds = gdal.Open(band5p)
    band4 = band4ds.ReadAsArray(0, 0, band4ds.RasterXSize, band4ds.RasterYSize)
    band5 = band5ds.ReadAsArray(0, 0, band5ds.RasterXSize, band5ds.RasterYSize)
    band4 = band4.astype(np.float32)
    band5 = band5.astype(np.float32)
    mask = np.greater(band4 + band5, 0)
    with np.errstate(invalid="ignore"):
        ndwi = np.choose(mask, (-99, (band4 - band5) / (band4 + band5)))
    drv = gdal.GetDriverByName("GTiff")
    outp = path.join(datadir, outfile)
    ndwids = drv.Create(outp, band4ds.RasterXSize, band4ds.RasterYSize, 1, GDT_Float32)
    ndwiband = ndwids.GetRasterBand(1)
    ndwiband.WriteArray(ndwi, 0, 0)
    ndwiband.SetNoDataValue(-99)
    ndwids.SetProjection(band4ds.GetProjection())
    ndwids.SetGeoTransform(band4ds.GetGeoTransform())
    ndwiband.FlushCache()
    ndwids.FlushCache()


def reprojectRaster(infile, outfile, epsg=4326, datadir=DATA_DIR):
    inp = path.abspath(path.join(datadir, infile))
    outp = path.abspath(path.join(datadir, outfile))
    proj4 = "EPSG:%d" % epsg
    sh = 'gdalwarp %s %s -t_srs "%s"' % (inp, outp, proj4)
    system(sh)


def plotGTiff(filename, datadir=DATA_DIR):
    p = path.join(datadir, filename)
    ds = gdal.Open(p)
    r = ds.ReadAsArray(0, 0, ds.RasterXSize, ds.RasterYSize)
    plt.imshow(r, interpolation="nearest", vmin=0, cmap=plt.cm.gist_earth)
    plt.show()


if __name__ == "__main__":
    # downloadData(LANDSAT_URL)
    calculateNDWI()
    reprojectRaster("ndwi.tif", "ndwi84.tif")
    plotGTiff("ndwi84.tif")
