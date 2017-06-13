
SHELL := /bin/bash

HASDOCKER ?= $(shell which docker)

DOC := $(if $(HASDOCKER), docker run --net host --rm -v $$PWD:/work -w /work docker.dragonfly.co.nz/auckland_bivalves:v2,)


OUTPUT_DIR=build
TARGET=report.pdf


KNITR = $(addsuffix .tex, $(basename $(shell find knitr -iname "*.rnw")))
PACKAGES = ggplot2 dplyr reshape2 
KNITR_BASE = $(addprefix $(OUTPUT_DIR)/, $(addsuffix .tex, $(basename $(wildcard *.rnw))))
KNIT_COMMAND = library(knitr);opts_chunk\$$set(warning=F, message = FALSE,echo=F,results='asis',error=FALSE,fig.lp='fig:',fig.path='images/');

COCKLE_BEACHES = Eastern Kawakawa Grahams Aotea Waiotahe Te Ruakaka Mangawhai Whangamata Otumoetai Ngunguru Whangapoua
PIPI_BEACHES = Kawakawa Grahams Waiotahe Te Ruakaka Mangawhai Whangamata Otumoetai Ngunguru Whangapoua

ALL_BEACHES = Eastern Kawakawa Grahams Aotea Waiotahe Te Ruakaka Mangawhai Whangamata Otumoetai Ngunguru Whangapoua

COCKLE_DIRS = $(addprefix knitr/beach_summaries/,$(COCKLE_BEACHES))
PIPI_DIRS   = $(addprefix knitr/beach_summaries/,$(PIPI_BEACHES))

BEACH_DIRS  = $(addprefix knitr/beach_summaries/,$(ALL_BEACHES))
SPECIES = Cockle_ Pipi_

BEACH_DATA_ASSETS = harvest_table.Rdata LF_table.Rdata stratum_table.Rdata
BEACH_DATA_COCKLE = $(foreach DDIR,$(PIPI_DIRS), $(addprefix $(DDIR)/Cockle_, $(BEACH_DATA_ASSETS)))
BEACH_DATA_PIPI = $(foreach DDIR,$(PIPI_DIRS), $(addprefix $(DDIR)/Pipi_, $(BEACH_DATA_ASSETS)))
BEACH_DATA = $(BEACH_DATA_COCKLE) $(BEACH_DATA_PIPI)

ALL_DATA_ASSETS = lookup.Rdata harvest_table.Rdata summary_table.Rdata LFs.Rdata comparable_strata.Rdata
ALL_DATA = $(addprefix knitr/beach_summaries/,$(ALL_DATA_ASSETS))

PLOTS_N_TABS_ASSETS = map.tex this_year_by_stratum.tex combined_pop_est.tex LF_tab.tex LF_year_fig.tex
$(foreach DDIR,$(PIPI_DIRS), $(addprefix $(DDIR)/, $(PLOTS_N_TABS_SPECIES)))
PLOTS_N_TABS_PIPI = $(foreach DDIR,$(PIPI_DIRS), $(addprefix $(DDIR)/Pipi_, $(PLOTS_N_TABS_ASSETS)))
PLOTS_N_TABS_COCKLE = $(foreach DDIR,$(COCKLE_DIRS), $(addprefix $(DDIR)/Cockle_, $(PLOTS_N_TABS_ASSETS)))
PLOTS_N_TABS = $(PLOTS_N_TABS_COCKLE) $(PLOTS_N_TABS_PIPI)

#SUBSTR_PLOTS = $(addsuffix /sed_map.tex, $(COCKLE_DIRS))

COCKLE_RESULTS = $(addprefix knitr/beach_summaries/,$(addsuffix /Cockle_results.tex,$(COCKLE_BEACHES)))
PIPI_RESULTS = $(addprefix knitr/beach_summaries/,$(addsuffix /Pipi_results.tex,$(PIPI_BEACHES)))
SPECIES_RESULTS = $(COCKLE_RESULTS) $(PIPI_RESULTS)
BEACH_RESULTS = $(addsuffix /beach_results.tex, $(BEACH_DIRS))

COCKLE_ASSETS := $(COCKLE_RESULTS) $(PLOTS_N_TABS_COCKLE) $(BEACH_DATA_COCKLE)
PIPI_ASSETS := $(PIPI_RESULTS) $(PLOTS_N_TABS_PIPI) $(BEACH_DATA_PIPI)

###################################################
#### Parameters ###################################
###################################################

# use pattern specific variables
#$(PLOTS_N_TABS_COCKLE): SPECIE:=Cockle_#
$(COCKLE_ASSETS): SPECIE:=Cockle_#
$(COCKLE_ASSETS): SPEC='Cockle'#
$(COCKLE_ASSETS): SPC='cockles'#
$(COCKLE_ASSETS): SIZE=30#
$(COCKLE_ASSETS): RECSIZE=15#

#$(PLOTS_N_TABS_PIPI): SPECIE:=Pipi_# Not sure why this is needed, but make doesnt find it otherwise - although my understanding is that it should propagate from the results as this is a prereq of the results. Hmm
$(PIPI_ASSETS): SPECIE:=Pipi_#
$(PIPI_ASSETS): SPEC='Pipi'#
$(PIPI_ASSETS): SPC='pipi'#
$(PIPI_ASSETS): SIZE=50#
$(PIPI_ASSETS): RECSIZE=20#

####################################################
#### BUILD PROCESS #################################
####################################################
.SECONDEXPANSION:
# do not remove intermediates
.SECONDARY:
#search paths 
VPATH = ./knitr/beach_summaries ./

all: $(TARGET) Northern-shellfish-2016-17-draft.pdf | $(BEACH_DIRS)

Northern-shellfish-2016-17-draft.pdf: $(TARGET) | $(BEACH_DIRS)
	$(DOC) gs -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile=Northern-shellfish-2016-17-draft.pdf report.pdf	

$(TARGET): $(OUTPUT_DIR)/$(TARGET)
	$(DOC) cp $(OUTPUT_DIR)/$(TARGET) $(TARGET)

$(OUTPUT_DIR)/$(TARGET): $(TARGET:%.pdf=%.tex) $(OUTPUT_DIR) $(KNITR_BASE) #$(KNITR_BASE)
	$(DOC) bash -c "(TEXINPUTS=.///: xelatex -output-directory=$(OUTPUT_DIR) $<) && (TEXINPUTS=.///: biber --output_directory=$(OUTPUT_DIR) $(<:%.tex=%)) && (TEXINPUTS=.///: xelatex -output-directory=$(OUTPUT_DIR) $<)"

$(OUTPUT_DIR)/results.tex: results.rnw \
	knitr/beach_summaries/summary_table_cockle.Rdata\
	knitr/beach_summaries/lookup.Rdata\
	knitr/beach_summaries/summary_table_pipi.Rdata\
	$(SPECIES_RESULTS)\
	$(BEACH_RESULTS) \
	$(SUBSTR_PLOTS)
	$(DOC) Rscript --vanilla -e "$(KNIT_COMMAND) knit('results.rnw',output='$(OUTPUT_DIR)/results.tex')"

$(OUTPUT_DIR):
	$(DOC) mkdir -p $(OUTPUT_DIR)

$(OUTPUT_DIR)/%.tex: %.rnw $(KNITR)
	$(DOC) Rscript --vanilla -e "$(KNIT_COMMAND) knit('$(<F)',output='$(OUTPUT_DIR)/$(@F)')"

######### substrate plots ###########

#$(SUBSTR_PLOTS): %.tex: $$(@F:.tex=_temp) \
#	knitr/beach_summaries/lookup.Rdata \
#	knitr/aki2015_sediment_data_reportready.csv
#	$(DOC) Rscript --vanilla -e "$(KNIT_COMMAND) knit(text = knit_expand(file = '$(@D)/../$(*F)_temp',beach_short = '$(notdir $(@D))'), output = '$(@D)/$(@F)')"

######### beach results ###########

$(BEACH_RESULTS): %.tex: %.rnw \
	$(SPECIES_RESULTS)
	$(DOC) Rscript --vanilla -e "$(KNIT_COMMAND) knit(text = knit_expand(file = '$(@D)/beach_results.rnw',pth='$(@D)'),output = '$(@D)/beach_results.tex')"

######### Species results ###########


$(SPECIES_RESULTS): %.tex: %.rnw \
	$$(addprefix $$(@D)/$$(SPECIE), $(PLOTS_N_TABS_ASSETS))
	$(DOC) Rscript --vanilla -e "$(KNIT_COMMAND) knit(text = knit_expand(file = '$(@D)/$(<F)',pth='$(@D)' ,beach = '$(notdir $(@D))'),output = '$(@D)/$(@F)')"

######### Species assets ###########

$(BEACH_DATA): $(PLOTS_N_TABS)

$(PLOTS_N_TABS): %.tex: $$(subst $$(SPECIE),,$$(@F:.tex=_templ)) $(ALL_DATA)
	$(DOC) Rscript --vanilla -e "$(KNIT_COMMAND) knit(text = knit_expand(file = '$(@D)/../$(subst $(SPECIE),,$(*F))_templ',beach_short = '$(notdir $(@D))', species = $(SPEC),spc = $(SPC),size = $(SIZE),rec_size = $(RECSIZE)),output = '$(@D)/$(@F)')"

############################################

###### general results ######
#knitr/%.tex: knitr/%.rnw
#	$(DOC) Rscript --vanilla -e "$(KNIT_COMMAND) knit('$(@D)/$(<F)', output = '$(@D)/$(@F)')"

#knitr/beach_summaries/%.Rdata: knitr/beach_summaries/%.r

knitr/beach_summaries/sampling_map_src.Rdata: knitr/beach_summaries/sampling_map_src.r
	$(DOC) bash -c "cd $(@D); Rscript sampling_map_src.r"

knitr/beach_summaries/sampling_%.tex: knitr/beach_summaries/sampling_%.rnw\
	knitr/beach_summaries/sampling_tables.Rdata
	$(DOC) Rscript --vanilla -e "$(KNIT_COMMAND) knit('$(@D)/$(<F)',output = '$(@D)/$(@F)')"

knitr/beach_summaries/sampling_map_src.tex: knitr/beach_summaries/sampling_map_src.rnw\
	knitr/beach_summaries/sampling_map_src.Rdata
	$(DOC) Rscript --vanilla -e "$(KNIT_COMMAND) knit('$(@D)/sampling_map_src.rnw', output = '$(@D)/sampling_map_src.tex')"

knitr/beach_summaries/%.tex knitr/beach_summaries/%.Rdata:knitr/beach_summaries/%.rnw \
	$(ALL_DATA)
	$(DOC) Rscript --vanilla -e "$(KNIT_COMMAND) knit('$(@D)/$(<F)',output = '$(@D)/$(@F)')"

############################
###### data assets #########
############################

#LEAVE THIS ALONE DUE TO CROSS DEPENDENCIES

#knitr/beach_summaries/beach_data.Rdata: knitr/beach_summaries/read_tables.r
#	$(DOC) cd $(@D); Rscript --vanilla read_tables.r

knitr/beach_summaries/sampling_tables.Rdata: knitr/beach_summaries/make_sampling_table.r\
	knitr/beach_summaries/lookup.Rdata \
	knitr/beach_summaries/beach_data.Rdata
	$(DOC) bash -c "cd $(@D); Rscript make_sampling_table.r"

knitr/beach_summaries/summary_table.Rdata: knitr/beach_summaries/make_summary_table.r \
	knitr/beach_summaries/beach_data.Rdata
	$(DOC) bash -c "cd $(@D); Rscript --vanilla make_summary_table.r"

knitr/beach_summaries/LFs.Rdata: knitr/beach_summaries/make_LF_tables.r \
	knitr/beach_summaries/beach_data.Rdata
	$(DOC) bash -c "cd $(@D); Rscript --vanilla make_LF_tables.r"

knitr/beach_summaries/comparable_strata.Rdata: knitr/beach_summaries/make_comparable_strata.r \
	knitr/beach_summaries/beach_data.Rdata
	$(DOC) bash -c "cd $(@D); Rscript --vanilla make_comparable_strata.r"

knitr/beach_summaries/harvest_table.Rdata: knitr/beach_summaries/make_harvest_table.r \
	knitr/beach_summaries/summary_table.Rdata \
	knitr/beach_summaries/beach_data.Rdata
	$(DOC) bash -c "cd $(@D); Rscript --vanilla make_harvest_table.r"

#knitr/substrate_table.tex: knitr/substrate_table.rnw\
#	knitr/beach_summaries/lookup.Rdata \
#	knitr/aki2015_sediment_data_reportready.csv
#	$(DOC) Rscript --vanilla -e "$(KNIT_COMMAND) knit('$(@D)/$(<F)', output = '$(@D)/$(@F)')"


$(BEACH_DIRS):
	$(DOC) mkdir -p $@

#Sometimes we want to blow away all of the R code output as well as just the latex stuff
superclean: clean
	find knitr -iname "*.tex" -delete
	find knitr -iname "*.pdf" -delete
	find knitr -iname "*.png" -delete
	find knitr -iname "images" -delete

clean:
	rm -rf  $(OUTPUT_DIR) $(TARGET) 


