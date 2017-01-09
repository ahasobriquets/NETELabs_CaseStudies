#  Alemtuzumab Code Book

## A cure informatics network (Williams et al. 2015), with modifications introduced by this collaborative effort, is being constructed for the anti-cancer biological, Alemtuzumab. 

1. The data in this case study are modeled as a network of nodes connected by edges
2. Allowed node types are
  * root
  * ct (clinical trial in NCT database with NCT ID as uid or clinical trial(s) not in NCT database- designated as alemtuzumab_ct
  * fda
  * pmid1
  * pmid2
  * grant
  * institution (may not be needed)
  * author (may not be needed)

3. The term root is reserved for alemtuzumab, a humanized anti-CD52 monoclonal antibody,  also known as Campath, CamPath-1 H, and Lemtrada. FDA approval for Campath was granted in May 2001. In searching for publications, clinical trials etc. a 60 day allowance was made for 'publication lag'.

4. Data are stored in a four column format where source and target contain unique identifiers for nodes and stype and ntype refer to node types for source and target respectively. An example 
is provided below and does not necessarily represent real data for the alemtuzumab network.

| source | stype | target | ttype |
|  :---   | :--- | :--- | :--- |
| Campath | root | NCT11265 | ct |
| Campath | root | 8652811  | pmid1 |

5. Ancillary files
  * alemtuzumab_fda: copy of BLA approval includes a single PMID 8652811 from the Medical Review
  * alemtuzumab_npl: non-patent literature citations scraped from the Espacenet data for alemtuzumab. 
  * alemtuzumab.csv: patents data from EspaceNet
  * alemtuzumab_pubmed: pre 7/31/2001 search for Campath or Alemtuzumab in Pubmed
  * alemtuzumab_pubmed_nct: pre 7/31/2001 search for Campath or Alemtuzumab in Pubmed with publication type set to clinical trial
  * campath_patent: npl scraped from a Google Patennts search for Campath- the original patent granted to Waldmann. US5846534A in 1998.

## Workflow Description

1. root (alemtuzumab) to fda: This is a single edge between two nodes. Root and FDA.
2. root to clinical trials: This is also a single edge between two nodes. root and ct. A manual search of clinicaltrials.gov revealed 5 clinical trials that began before 7/31/2001 
although all of them completed well after that date. Thus, none of them have been included in the restrospective trace but they are used to indicate post-alemtuzumab activity. 

3. root to pmid1: Multiple nodes exist in PMID1. The basis for nodes is a PubMed Search for Alemtuzumab or Campath restricted from 01/01/1900 to 07/31/2001 (approval date plus
60 days for publication lag). Each pmid1 node corresponds to one publication. Only one edge is drawn from root to a given PMID1 node. *Redundancy between ct and pmid1 is  handled 
by allowing ct to take precedence. A root to pmid1 edge is drawn only if a root to ct/fda/patent to pmid1 edge does not exist.*

. fda to pmid1:  FDA approval for Campath was granted in May 2001. The FDA Oncology 
Center of  Excellence published an Approval Summary paper in 2008- PMID 18305062. A single 
PMID was  extracted from the approval documents on the Drugs@FDA website. Cheson et al. 
(1996) PMID: 8652811. 

5. ct to pmid1: A  search in PubMed using criteria of alemtuzumab, publication type of clinical trial, and date restricted to 7/31/2001 or earlier (((alemtuzumab) AND "clinical trial"[Publication Type])) AND ("1900/01/01"[Date - Publication] : "2001/07/31"[Date - Publication]) 

6. pmid1 to pmid2: pmid2 refers to cited references and is derived from Elsevier data where Eric maps pmids to ScopusIDs to Cited Scopus IDs and then back to pmids

7. pmid1 to grants and pmid2 to grants: using NIH ExPORTER data [needs to be expanded on]

8. authors and institions: derived from Scopus data
 










