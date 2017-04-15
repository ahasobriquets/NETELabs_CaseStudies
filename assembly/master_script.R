# Assembles data for all five drugs by calling individual scripts consecutively

# Run load_citation. TThis script flattens Eric Livingston's data to generate
# a list of pmid1s of cited references derived from reviews of relevant literature

source("~//NETELabs_CaseStudies/Review_Master/load_core_citation_data.R")

# Run alemtuzumab_merge.R
source("~/NETELabs_CaseStudies/assembly/alemtuzumab_assembly/alemtuzumab_merge.R")

# Run imatinib_merge.R
source ("~/NETELabs_CaseStudies/assembly/imatinib_assembly/imatinib_merge.R")

# Run nelarabine_merge.R
source ("~/NETELabs_CaseStudies/assembly/nelarabine_assembly/nelarabine_merge.R")

# Run ramucirumab_merge.R
source ("~/NETELabs_CaseStudies/assembly/ramucirumab_assembly/ramucirumab_merge.R")

# Run sunitinib_merge.R
source ("~/NETELabs_CaseStudies/assembly/sunitinib_assembly/sunitinib_merge.R")














