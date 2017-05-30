
This scripts generates scores of authors and publications based on the drug development network.

**Scripts:**    

*1-generic_CNI.sh*    
It is the main script to call other sub scripts. Drug name MUST be passed as a parameters.    

ex usage: sh generic_CNI_master.sh alemtuzumab    

*2-pub_pir_scores.sql*      
It generates the weighted citation score of the publication in the network, and the score called as "pub_pir" where PIR stands for propagated in-degree rank.     

*3-author_pir_rrbr_scores.sql*      
It generates the author raw PIR and RRBR scores where PIR stansd for propagated in-degree rank, RRBR stands for the revised ratio of basic rank.  

At the and of the process: we will have following five tables:  
  
_{drug_name}_author_pir_degenerate_rrbr  
_{drug_name}_author_pir_rrbr    
_{drug_name}_author_pir_rrbr_merged    
_{drug_name}_test_network   
_{drug_name}_testnetwork_citation  
_{drug_name}_testnetwork_pub_pir  
  
where _{drug_name}_ is the parameter that passed as a drug name.
