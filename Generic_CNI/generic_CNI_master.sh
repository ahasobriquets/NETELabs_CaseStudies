
# Author: Samet Keserci
# Usage: sh generic_CNI_master.sh [drug_name]
# Date: 02/06/17

drug_name=$1

nodelist=${drug_name}_pub_nodelist
edgelist=${drug_name}_pub_edgelist
authorpub=${drug_name}_scopus_pub_auth


# create tables for
psql -d elsevier -v drug_name=$drug_name -f create_scopus_tables.sql

# load scopus data
sh load_scopus_data.sh $drug_name

# calculate the citations, PIr and RRBR scores
psql -d elsevier -v node_list=$nodelist -v edge_list=$edgelist -v -f test_parameter.sql
psql -d elsevier -v author_pub=$authorpub -f author_pir_rrbr_scores.sql

# Renaming the tables according to drug name

# drop old ones
psql -d elsevier -c "drop table if exists  ${drug_name}_author_pir_degenerate_rrbr"
psql -d elsevier -c "drop table if exists  ${drug_name}_author_pir_rrbr_final"
psql -d elsevier -c "drop table if exists  ${drug_name}_author_pir_rrbr"
psql -d elsevier -c "drop table if exists  ${drug_name}_test_network"
psql -d elsevier -c "drop table if exists  ${drug_name}_testnetwork_citation"
psql -d elsevier -c "drop table if exists  ${drug_name}_testnetwork_pub_pir"
psql -d elsevier -c "drop table if exists  ${drug_name}_author_pir_rrbr_merged"
# rename the new ones
psql -d elsevier -c "alter table drug_author_pir_degenerate_rrbr rename to ${drug_name}_author_pir_degenerate_rrbr"
psql -d elsevier -c "alter table drug_author_pir_rrbr rename to ${drug_name}_author_pir_rrbr"
psql -d elsevier -c "alter table drug_author_pir_rrbr_final rename to ${drug_name}_author_pir_rrbr_final"
psql -d elsevier -c "alter table drug_author_pir_rrbr_merged rename to ${drug_name}_author_pir_rrbr_merged"
psql -d elsevier -c "alter table drug_test_network rename to ${drug_name}_test_network"
psql -d elsevier -c "alter table drug_testnetwork_citation rename to ${drug_name}_testnetwork_citation"
psql -d elsevier -c "alter table drug_testnetwork_pub_pir rename to ${drug_name}_testnetwork_pub_pir"

psql -d elsevier -c "\copy ${drug_name}_author_pir_rrbr_final to '/labdata1/NETELabs_CaseStudies/${drug_name}/${drug_name}_author_pir_rrbr_final.csv' with delimiter ',' csv header; "


# change the name in the following table and then run it
sed -i "/drug/$drug_name/g" create_edge_node_list.sql
# run the scripts
psql -d elsevier -f create_edge_node_list.sql

# convert it its original state
sed -i "/$drug_name/drug/g" create_edge_node_list.sql

#
