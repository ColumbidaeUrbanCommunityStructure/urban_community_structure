library(sf)
library(auk)
library(tidyverse)

filename = function(directory, filename) {
  paste(directory, filename, sep = '/')
}

mkdir = function(mainDir, subDir) {
  ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)
  filename(mainDir, subDir)
}

TMP_DIR = '/tmp'

DATA_OUTPUT_DIR = mkdir(mkdir('../../', 'data'), 'generated')
GEO_DATA_OUTPUT_DIR = mkdir(DATA_OUTPUT_DIR, 'geo')

EBIRD_DATA_OUTPUT_DIR = mkdir(DATA_OUTPUT_DIR, 'ebird')

