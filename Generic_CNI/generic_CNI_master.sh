
# Author: Samet Keserci
# Usage: sh generic_CNI_master.sh [drug_name]


drug_name=$1

nodelist=${drug_name}_pub_nodelist
edgelist=${drug_name}_pub_edgelist
authorpub=${drug_name}_scopus_pub_auth

# calculate the citations, PIr and RRBR scores
psql -d elsevier -v node_list=$nodelist -v edge_list=$edgelist -v -f test_parameter.sql
psql -d elsevier -v author_pub=$authorpub -f author_pir_rrbr_scores.sql

# Renaming the tables according to drug name

# drop old ones
psql -d elsevier -c "drop table if exists  ${drug_name}_author_pir_degenerate_rrbr"
psql -d elsevier -c "drop table if exists  ${drug_name}_author_pir_rrbr"
psql -d elsevier -c "drop table if exists  ${drug_name}_test_network"
psql -d elsevier -c "drop table if exists  ${drug_name}_testnetwork_citation"
psql -d elsevier -c "drop table if exists  ${drug_name}_testnetwork_pub_pir"
# rename the new ones
psql -d elsevier -c "alter table drug_author_pir_degenerate_rrbr rename to ${drug_name}_author_pir_degenerate_rrbr"
psql -d elsevier -c "alter table drug_author_pir_rrbr rename to ${drug_name}_author_pir_rrbr"
psql -d elsevier -c "alter table drug_test_network rename to ${drug_name}_test_network"
psql -d elsevier -c "alter table drug_testnetwork_citation rename to ${drug_name}_testnetwork_citation"
psql -d elsevier -c "alter table drug_testnetwork_pub_pir rename to ${drug_name}_testnetwork_pub_pir"
