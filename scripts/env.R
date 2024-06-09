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
library(GGally)
library(ggtree)
library(ggrepel)
library(aplot)
library(foreach)
library(fundiversity)
library(scales)
library(MuMIn)
library(VSURF)
library(cowplot)
library(ggplot2)
library(phytools)
library(treedataverse) # BiocManager::install("YuLab-SMU/treedataverse")
library(devtools)
install_github("eliotmiller/clootl")
library(clootl)
sf::sf_use_s2(FALSE)
options(scipen=99999)
options(na.action = "na.fail") 

filename = function(directory, filename) {
  paste(directory, filename, sep = '/')
}

mkdir = function(mainDir, subDir) {
  ifelse(!dir.exists(file.path(mainDir, subDir)), dir.create(file.path(mainDir, subDir)), FALSE)
  filename(mainDir, subDir)
}

standardise = function(actual_value, mean_value, sd_value) { 
  (actual_value - mean_value) / sd_value
}

test_value_wilcox = function(name, normalised_list) {
  wilcox_test_result = wilcox.test(normalised_list, mu = 0.5, na.rm = T)
  
  significance = ifelse(wilcox_test_result$p.value < 0.0001, '***', 
                        ifelse(wilcox_test_result$p.value < 0.001, '**', 
                               ifelse(wilcox_test_result$p.value < 0.01, '*', '')))
  m = median(normalised_list, na.rm = T)
  
  paste(name, 'median', round(m, 2), significance)
}

# Working directories - not stored in repo
TMP_DIR = '/tmp'

WORKING_OUTPUT_DIR = mkdir('../../../', 'urban_community_structure_wrk')
GEO_WORKING_OUTPUT_DIR = mkdir(WORKING_OUTPUT_DIR, 'geo')
EBIRD_WORKING_OUTPUT_DIR = mkdir(WORKING_OUTPUT_DIR, 'ebird')
BIRDLIFE_WORKING_OUTPUT_DIR = mkdir(WORKING_OUTPUT_DIR, 'birdlife')
EARTH_ENGINE_WORKING_OUTPUT_DIR = mkdir(WORKING_OUTPUT_DIR, 'earthengine')

KEYS_DIR = mkdir(WORKING_OUTPUT_DIR, 'auth')

# Distributed data - stored in repo
DATA_OUTPUT_DIR = mkdir(mkdir('../../', 'data'), 'generated')
CITY_DATA_OUTPUT_DIR = mkdir(DATA_OUTPUT_DIR, 'city')
TAXONOMY_OUTPUT_DIR = mkdir(DATA_OUTPUT_DIR, 'taxonomy')
COMMUNITY_OUTPUT_DIR = mkdir(DATA_OUTPUT_DIR, 'community')

PROVIDED_DATA = mkdir(mkdir('../..', 'data'), 'provided')
PHYLO_TREE = filename(PROVIDED_DATA, 'phylogeny__stage2_hackett_mcc_no_neg.tre')

FIGURES_OUTPUT_DIR = mkdir('../../', 'figures')

normalised_colours_scale = scale_colour_gradient2(
  low = "darkgreen",
  mid = "yellow",
  high = "red",
  midpoint = 0.5,
  space = "Lab",
  na.value = "grey50",
  guide = "colourbar",
  aesthetics = "colour",
  limits = c(0, 1)
)

normalised_size_scale = scale_size_continuous( 
  range = c(0, 1) 
)


# Third Party Data downloaded locally
# ------------------------------------
downloaded_data_file = function(file) {
  paste('/Users/james/Dropbox/PhD/', file, sep = '')
}

# My mapping from Birdlife V8 to Jetz, this maps down the birdlife taxonomy versions to Birdlife V3 and thus Jetz. 
# This version contains no extinct species.
MY_BIRDLIFE_COL_MAPPING = downloaded_data_file('BirdLife/Taxonomy/birdlife_v8_columbidae_taxonomy_to_jetz.csv')

# Avonet can be downloaded here
# https://figshare.com/s/b990722d72a26b5bfead
DL_AVONET = downloaded_data_file('Avonet/TraitData/AVONET2_eBird.csv')

# The country boundandaries can be downloaded from the world bank here:
# https://datacatalog.worldbank.org/search/dataset/0038272/World-Bank-Official-Boundaries
DL_COUNTRY_BOUNDARIES = downloaded_data_file('WorldBank_countries_Admin0_10m/WB_countries_Admin0_10m.shp')
DL_COUNTRY_BOUNDARIES_CLEANED = downloaded_data_file('WorldBank_countries_Admin0_10m/WB_countries_Admin0_10m.shp')

read_country_boundaries = function() {
  if (file.exists(DL_COUNTRY_BOUNDARIES_CLEANED)) {
    read_sf(DL_COUNTRY_BOUNDARIES_CLEANED)
  } else {
    countries_cleaned = st_simplify(st_read(DL_COUNTRY_BOUNDARIES), dTolerance = 0.02)
    st_write(countries_cleaned, DL_COUNTRY_BOUNDARIES_CLEANED)
    countries_cleaned
  }
}

# A download of the birdlife distributions can be requested from here:
# https://datazone.birdlife.org/species/requestdis
DL_BIRDLIFE_DISTRIBUTIONS = downloaded_data_file('Birdlife/Distribution/SppDataRequest_columbidae/SppDataRequest.shp')

# The taxonomy can be downloaded here:
# https://datazone.birdlife.org/species/taxonomy
DL_BIRDLIFE_TAXONOMY = downloaded_data_file('BirdLife/Taxonomy/Handbook of the Birds of the World and BirdLife International Digital Checklist of the Birds of the World_Version_8.xlsx')

# These have been exported to a shape file using google earth engine.
# https://developers.google.com/earth-engine/datasets/catalog/RESOLVE_ECOREGIONS_2017
DL_RESOLVE = downloaded_data_file('Ecoregions2017/Ecoregions2017.shp')
DL_RESOLVE_CLEANED = downloaded_data_file('Ecoregions2017/Ecoregions2017_Cleaned.shp')

read_resolve = function() {
  if (file.exists(DL_RESOLVE_CLEANED)) {
    read_sf(DL_RESOLVE_CLEANED)
  } else {
    resolve_cleaned = st_simplify(st_buffer(read_sf(DL_RESOLVE), 0), dTolerance = 0.02)
    st_write(resolve_cleaned, DL_RESOLVE_CLEANED)
    resolve_cleaned
  }
}

# ebird data can be downloaded here:
# https://science.ebird.org/en/use-ebird-data/download-ebird-data-products
DL_EBIRD_SAMPLE_DATA_RAW = downloaded_data_file('eBird/ebd_sampling_relNov-2023/ebd_sampling_relNov-2023.txt')
DL_EBIRD_DATA_RAW = downloaded_data_file('eBird/ebd_relNov-2023/ebd_relNov-2023.txt')

# See here for links to download:
# https://science.ebird.org/en/use-ebird-data/the-ebird-taxonomy
DL_EBIRD_TAXONOMY = downloaded_data_file('eBird/taxonomy_2023/ebird_taxonomy_v2023.csv')
DL_EBIRD_TAXONOMY_2021 = downloaded_data_file('eBird/taxonomy_2021/ebird_taxonomy_v2021.csv')

# eBird: Status & Trends
# This data can be downloaded here:
# https://science.ebird.org/en/status-and-trends/species/#columb2
DL_EBIRD_EUCDOV_RANGE = downloaded_data_file('eBird/eucdov_range_2022/eucdov_range_2022.gpkg')
DL_EBIRD_ROCPIG_RANGE = downloaded_data_file('eBird/rocpig_range_2022/rocpig_range_2022.gpkg')
DL_EBIRD_SPODOV_RANGE = downloaded_data_file('eBird/spodov_range_2022/spodov_range_2022.gpkg')
