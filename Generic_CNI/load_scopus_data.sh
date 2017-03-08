
# Author: Samet Keserci
# Usage: sh load_scopus_data.sh [drug_name]
# Date: 03/07/17



drug_name=$1

# load data from the directory  /labdata1/NETELabs_CaseStudies/${drug_name}/scopus_data/

psql -d elsevier -c "\copy ${drug_name}_scopus_pub_affs from '/labdata1/NETELabs_CaseStudies/${drug_name}/scopus_data/pub_affs.csv' with delimiter ',' csv header; "
psql -d elsevier -c "\copy ${drug_name}_scopus_pub_auth_affs from '/labdata1/NETELabs_CaseStudies/${drug_name}/scopus_data/pub_auth_affs.csv' with delimiter ',' csv header; "
psql -d elsevier -c "\copy ${drug_name}_scopus_pub_auth from '/labdata1/NETELabs_CaseStudies/${drug_name}/scopus_data/pub_auth.csv' with delimiter ',' csv header; "
psql -d elsevier -c "\copy ${drug_name}_scopus_pub_cites from '/labdata1/NETELabs_CaseStudies/${drug_name}/scopus_data/pub_cites.csv' with delimiter ',' csv header; "
psql -d elsevier -c "\copy ${drug_name}_scopus_pub_idx from '/labdata1/NETELabs_CaseStudies/${drug_name}/scopus_data/pub_idx.csv' with delimiter ',' csv header; "
psql -d elsevier -c "\copy ${drug_name}_scopus_pub_key from '/labdata1/NETELabs_CaseStudies/${drug_name}/scopus_data/pub_key.csv' with delimiter ',' csv header; "
psql -d elsevier -c "\copy ${drug_name}_scopus_pub_out from '/labdata1/NETELabs_CaseStudies/${drug_name}/scopus_data/pub_out.csv' with delimiter ',' csv header; "
psql -d elsevier -c "\copy ${drug_name}_scopus_pub_src from '/labdata1/NETELabs_CaseStudies/${drug_name}/scopus_data/pub_src.csv' with delimiter ',' csv header; "
psql -d elsevier -c "\copy ${drug_name}_scopus_pub_subj from '/labdata1/NETELabs_CaseStudies/${drug_name}/scopus_data/pub_subj.csv' with delimiter ',' csv header; "


# handle de null values in doc_count columns
psql -d elsevier -c "update ${drug_name}_scopus_pub_auth set doc_count=(case when doc_count='' then '0' else doc_count end);"
psql -d elsevier -c "alter table ${drug_name}_scopus_pub_auth alter column doc_count type Integer using doc_count::integer;"
