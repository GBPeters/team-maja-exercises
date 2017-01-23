# Imports
from os import mkdir, path, system
from osgeo.ogr import wkbPoint, Feature, GetDriverByName, Geometry
from osgeo.osr import SpatialReference, CoordinateTransformation
from random import sample
from urllib import urlretrieve
from zipfile import ZipFile

import folium

# Constants
DATA_DIR = "../data"
POINTS_FILE = "places.shp"
SHP_DRIVER = GetDriverByName("ESRI Shapefile")


def downloadData(url, datadir=DATA_DIR):
    try:
        mkdir(datadir)
    except:
        pass
    dest = path.join(datadir, path.basename(url))
    urlretrieve(url, dest)
    zfile = ZipFile(dest)
    zfile.extractall(datadir)


def openShapeFile(filename=POINTS_FILE, datadir=DATA_DIR):
    p = path.join(datadir, filename)
    return SHP_DRIVER.Open(p)


def selectRandomPoints(source, npoints):
    layer = source.GetLayer()
    c = layer.GetFeatureCount()
    if npoints > c:
        npoints = c
    s = sample(range(0, c), npoints)
    xys = []
    for i in s:
        f = layer.GetFeature(i)
        geom = f.GetGeometryRef()
        x = geom.GetX()
        y = geom.GetY()
        xys.append((x, y))
    return xys


def createWKTFromXY(lon, lat):
    return "POINT (%f %f)" % (lon, lat)


def transformGeometry(geom, source=4326, target=4326):
    s = SpatialReference()
    t = SpatialReference()
    s.ImportFromEPSG(source)
    t.ImportFromEPSG(target)
    tf = CoordinateTransformation(s, t)
    geom.Transform(tf)
    return geom


def writePointsToShapefile(coords, filename, datadir=DATA_DIR, lyrname="lyr", crs=4326):
    fn = path.join(datadir, filename)
    ds = SHP_DRIVER.CreateDataSource(fn)
    srs = SpatialReference()
    srs.ImportFromEPSG(crs)
    layer = ds.CreateLayer(lyrname, srs, wkbPoint)
    lyrdef = layer.GetLayerDefn()
    for x, y in coords:
        p = Geometry(wkbPoint)
        p.SetPoint(0, x, y)
        f = Feature(lyrdef)
        f.SetGeometry(p)
        layer.CreateFeature(f)
        f = None
    ds = None


def exportShapefiletoKML(infile, outfile, datadir=DATA_DIR):
    inpath = path.join(datadir, infile)
    outpath = path.join(datadir, outfile)
    sh = "ogr2ogr -f KML %s %s" % (path.abspath(outpath), path.abspath(inpath))
    system(sh)


def exportShapefiletoGeoJSON(infile, outfile, datadir=DATA_DIR):
    inpath = path.join(datadir, infile)
    outpath = path.join(datadir, outfile)
    sh = "ogr2ogr -f GeoJSON %s %s" % (path.abspath(outpath), path.abspath(inpath))
    system(sh)


def loadFoliumMap(filename, datadir=DATA_DIR):
    fn = path.join(datadir, filename)
    fmap = folium.Map(location=[52, 5.7], zoom_start=6)
    fmap.choropleth(geo_path=fn)
    return fmap

if __name__ == "__main__":
    downloadData("http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip")
    xys = selectRandomPoints(openShapeFile(), 2)
    writePointsToShapefile(xys, "points.shp")
    exportShapefiletoKML("points.shp", "points.kml")
    exportShapefiletoGeoJSON("points.shp", "points.geojson")
