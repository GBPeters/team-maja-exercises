#!/bin/bash

# 12-01-17, Team Maja - Simon Veen & Gijs Peters
#
# This script downloads the source zipfile, extracts it,
# calculates NDVI, resamples and reprojects.
#
# A new folder 'data' is created in the current directory, if it not yet exists.
# All files will be downloaded and created inside this folder.
#

# Constants
folder_name="data"
fn_zip="gewata.zip"
data_url="https://raw.githubusercontent.com/GeoScripting-WUR/IntroToRaster/gh-pages/data/$fn_zip"
fn_ndvi="ndvi.tif"
fn_res="ndvi_resampled.tif"
fn_reproj="ndvi_reprojected.tif"

# Create data folder in current directory, remove any existing files used in this script
echo "Creating data folder..."
mkdir -p data
cd ./data
rm -f $fn_ndvi
rm -f $fn_res
rm -f $fn_reproj

# Download and unzip data in data folder, set input file to present Landsat-7 ETM+ images
echo "Extracting data..."
curl -SO $data_url
unzip -o $fn_zip
fn_in=$(ls LE7*.tif)

# Copy file and calculate NDVI
echo "Creating NDVI GeoTIFF..."
gdal_calc.py -A $fn_in --A_band=4 -B $fn_in --B_band=3  --outfile=$fn_ndvi  --calc="(A.astype(float)-B)/(A.astype(float)+B)" --type='Float32'

# Resample file
echo "Resampling NDVI GeoTIFF..."
gdalwarp -tr 60 60 -r cubic $fn_ndvi $fn_res

# Reproject file
echo "Reproject Resampled GeoTIFF"
gdalwarp -t_srs EPSG:4326 $fn_res $fn_reproj

# Finishing, if required, unused (temporary) files should be removed here.
echo "Finished."
