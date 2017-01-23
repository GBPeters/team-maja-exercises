# Imports
from os import mkdir, path, system
from random import sample
from urllib import urlretrieve
from zipfile import ZipFile

import folium
from osgeo.ogr import wkbPoint, Feature, GetDriverByName, Geometry
from osgeo.osr import SpatialReference, CoordinateTransformation

# Constants
DATA_DIR = "../data"
POINTS_FILE = "places.shp"
SHP_DRIVER = GetDriverByName("ESRI Shapefile")


def downloadData(url, datadir=DATA_DIR):
    """
    Download and extract a zip file
    :param url: Url to download
    :param datadir: Local directory to extract data to
    :return: None
    """
    try:
        mkdir(datadir)
    except:
        pass
    dest = path.join(datadir, path.basename(url))
    urlretrieve(url, dest)
    zfile = ZipFile(dest)
    zfile.extractall(datadir)


def openShapeFile(filename=POINTS_FILE, datadir=DATA_DIR):
    '''
    Open an ESRI Shapefile
    :param filename: The local filename to open
    :param datadir: The directory where the file is stored
    :return: The datasource object
    '''
    p = path.join(datadir, filename)
    return SHP_DRIVER.Open(p)


def selectRandomPoints(source, npoints):
    """
    Select a random sample of points from a given datasource
    :param source: The Datasource to extract from
    :param npoints: The number of points to sample.
    :return: A list with (x, y) tuples extracted from the datasource
    """
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


def createWKTFromXY(x, y):
    """
    Creates a WKT from specified x and y
    :param x: The x-coordinate
    :param y: The y-coordinate
    :return: A WKT string
    """
    return "POINT (%f %f)" % (x, y)


def transformGeometry(geom, source=4326, target=4326):
    """
    Transform a geometry.
    :param geom: The geometry to transform
    :param source: The source SRS EPSG code
    :param target: The target SRS EPSG code
    :return: The transformed geometry. Note, the original geometry is transformed, so technically this return is redundant.
    """
    s = SpatialReference()
    t = SpatialReference()
    s.ImportFromEPSG(source)
    t.ImportFromEPSG(target)
    tf = CoordinateTransformation(s, t)
    geom.Transform(tf)
    return geom


def writePointsToShapefile(coords, filename, datadir=DATA_DIR, lyrname="lyr", epsg=4326):
    """
    Write a list of (x, y) tuples to an ESRI Shapefile
    :param coords: The list of (x, y) tuples
    :param filename: The name of target shapefile
    :param datadir: The directory of target shapefile
    :param lyrname: The name of the layer to store the points in
    :param epsg: The EPSG code of the target layer
    :return:
    """
    fn = path.join(datadir, filename)
    ds = SHP_DRIVER.CreateDataSource(fn)
    srs = SpatialReference()
    srs.ImportFromEPSG(epsg)
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
    """
    Export an ESRI shapefile to a KML file
    :param infile: The source shapefile name
    :param outfile: The target KML file name
    :param datadir: The directory for source an target files
    :return: None
    """
    inpath = path.join(datadir, infile)
    outpath = path.join(datadir, outfile)
    sh = "ogr2ogr -f KML %s %s" % (path.abspath(outpath), path.abspath(inpath))
    system(sh)


def exportShapefiletoGeoJSON(infile, outfile, datadir=DATA_DIR):
    """
    Export an ESRI shapefile to a GeoJSON file
    :param infile: The source shapefile name
    :param outfile: The target GeoJSON file name
    :param datadir: The directory for source an target files
    :return: None
    """
    inpath = path.join(datadir, infile)
    outpath = path.join(datadir, outfile)
    sh = "ogr2ogr -f GeoJSON %s %s" % (path.abspath(outpath), path.abspath(inpath))
    system(sh)


def loadFoliumMap(filename, datadir=DATA_DIR):
    """
    Create a Folium/Leaflet map showing the contents of a GeoJSON file
    :param filename: The GeoJSON file name
    :param datadir: The directory containing the file
    :return: A Folium Map object
    """
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
