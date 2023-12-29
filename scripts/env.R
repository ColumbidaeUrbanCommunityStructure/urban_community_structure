library(sf)
library(tidyverse)
library(dplyr)
library(dbplyr)
library(xlsx)
library(stringr)
library(phytools)

filename = function(directory, filename) {
  paste(directory, filename, sep = '/')
}

mkdir = function(mainDir, subDir) {
  ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)
  filename(mainDir, subDir)
}

TMP_DIR = '/tmp'

WORKING_OUTPUT_DIR = mkdir('/Users/james/Projects', 'urban_community_structure_wrk')
GEO_WORKING_OUTPUT_DIR = mkdir(WORKING_OUTPUT_DIR, 'geo')

EBIRD_WORKING_OUTPUT_DIR = mkdir(WORKING_OUTPUT_DIR, 'ebird')

BIRDLIFE_WORKING_OUTPUT_DIR = mkdir(WORKING_OUTPUT_DIR, 'birdlife')

DATA_OUTPUT_DIR = mkdir(mkdir('../../', 'data'), 'generated')
GEO_DATA_OUTPUT_DIR = mkdir(DATA_OUTPUT_DIR, 'geo')

EBIRD_DATA_OUTPUT_DIR = mkdir(DATA_OUTPUT_DIR, 'ebird')

TAXONOMY_OUTPUT_DIR = mkdir(DATA_OUTPUT_DIR, 'taxonomy')

PROVIDED_DATA = mkdir(mkdir('../..', 'data'), 'provided')

PHYLO_TREE = filename(PROVIDED_DATA, 'phylogeny__stage2_hackett_mcc_no_neg.tre')
