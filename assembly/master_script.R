# Assembles data for all five drugs by calling individual scripts consecutively

# Run load_core_citation. This script flattens Eric Livingston's data to generate
# a list of pmid1s of cited references derived from reviews of relevant literature

source("~//NETELabs_CaseStudies/Review_Master/load_core_citation_data.R")

# Run pazdur.R Assembles cited references from FDA Approval Summary papers

source("~//NETELabs_CaseStudies/Review_Master/pazdur.R")

# Run alemtuzumab_merge.R
source("~/NETELabs_CaseStudies/assembly/alemtuzumab_merge.R")

# Run imatinib_merge.R
source ("~/NETELabs_CaseStudies/assembly/imatinib_merge.R")

# Run nelarabine_merge.R
source ("~/NETELabs_CaseStudies/assembly/nelarabine_merge.R")

# Run ramucirumab_merge.R
source ("~/NETELabs_CaseStudies/assembly/ramucirumab_merge.R")

# Run sunitinib_merge.R
source ("~/NETELabs_CaseStudies/assembly/sunitinib_merge.R")

# Run metadata.R - collects edge counts by node type
source ("~/NETELabs_CaseStudies/assembly/metadata.R")

# Run five_pack to assemble data for Eric
source("~/NETELabs_CaseStudies/five_pack_stageI_assembly.R")
















