import tarfile
from mimetypes import guess_type
from os import mkdir, path
from urllib import urlretrieve
from zipfile import ZipFile

DATA_DIR = "../data"


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
    mt = guess_type(dest)
    mt = mt[0]
    if mt == "application/zip":
        zfile = ZipFile(dest)
        zfile.extractall(datadir)
    elif mt == "application/x-tar" or mt == "application/gzip" or mt == "application/bzip" or mt == "application/tgz":
        tfile = tarfile.open(dest)
        tfile.extractall(datadir)
