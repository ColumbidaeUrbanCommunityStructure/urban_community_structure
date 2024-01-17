library(sf)
library(tidyverse)
library(dplyr)
library(dbplyr)
library(readxl)
library(stringr)
library(phytools)
library(ebirdst)
library(terra)
library(vegan)
library(tidyr)
library(multcomp)
library(ggpubr)
library(picante)
library(fundiversity)

options(scipen=99999)

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

KEYS_DIR = mkdir(WORKING_OUTPUT_DIR, 'auth')

DATA_OUTPUT_DIR = mkdir(mkdir('../../', 'data'), 'generated')
CITY_DATA_OUTPUT_DIR = mkdir(DATA_OUTPUT_DIR, 'city')
TAXONOMY_OUTPUT_DIR = mkdir(DATA_OUTPUT_DIR, 'taxonomy')
COMMUNITY_OUTPUT_DIR = mkdir(DATA_OUTPUT_DIR, 'community')

PROVIDED_DATA = mkdir(mkdir('../..', 'data'), 'provided')
PHYLO_TREE = filename(PROVIDED_DATA, 'phylogeny__stage2_hackett_mcc_no_neg.tre')

FIGURES_OUTPUT_DIR = mkdir('../../', 'figures')
