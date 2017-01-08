#  Alemtuzumab Code Book
### Root is alemtuzumab, a humanized anti-CD52 monoclonal antibody,  also known as Campath, CamPath-1 H, and Lemtrada. FDA approval for Campath was granted in May 2001. In searching for publications, clinical trials etc. a 60 day allowance was made for 'publication lag'.

## Workflow Description

1. Root (alemtuzumab) to FDA: This is a single edge between two nodes. Root and FDA.

2. Root to Clinical Trials: This is also a single edge between two nodes. Root and CT. A 
manual search of clinicaltrials.gov revealed 5 clinical trials that began before 7/31/2001 
although all of them completed well after that date. Thus, none of them have been included in the restrospective trace but they are used to indicate post-alemtuzumab activity. 


3. Root to PMID1: Multiple nodes exist in PMID1. The basis for nodes is a PubMed
Search for Alemtuzumab or Campath restricted from 01/01/1900 to 07/31/2001 (approval date plus
60 days for publication lag). Each node corresponds to on publication (PMID). Only one edge 
is drawn from root to a given PMID1 node. **How is redundancy between CT and PMID1 to be handled?**

4. FDA to PMID1:  FDA approval for Campath was granted in May 2001. The FDA Oncology 
Center of  Excellence published an Approval Summary paper in 2008- PMID 18305062. A single 
PMID was  extracted from the approval documents on the Drugs@FDA website. Cheson et al. 
(1996) PMID: 8652811. 

5. Clinical Trials to PMID 1. A  search in PubMed using criteria of alemtuzumab, publication type of clinical trial, and date restricted to 7/31/2001 or earlier (((alemtuzumab) AND "clinical trial"[Publication Type])) AND ("1900/01/01"[Date - Publication] : "2001/07/31"[Date - Publication]) 










