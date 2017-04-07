#  Alemtuzumab Code Book George Chacko 4/7/2017

A cure informatics network (Williams et al. 2015), with
modifications developed in this collaboration, is being constructed
for the anti-cancer biological, Alemtuzumab.

Reference Sources:

1. drugs@fda
2. https://www.drugbank.ca/drugs/DB00087
3. PubMed
4. Scopus
5. Google Patents

FDA approval for alemtuzumab was granted in May 2001. [BLA 103948-
alemtuzumab Campath, Lemtrada 05/07/01] from FDA Purple Book 4/7/1017

1. The data in this case study are modeled as a network of nodes
connected by edges 

2. Allowed node types are 

* review 
* root 
* ct (clinical trial in NCT database with NCT ID as uid or
clinical trial(s) not in NCT database- designated as alemtuzumab_ct
* fda 
* patent
* pmid1 
* pmid2 
* grant 
* institution (may not be needed) 
* author (may not be needed)

3. The root node is reserved for alemtuzumab, a humanized anti-CD52
monoclonal antibody, also known as Campath, CamPath-1 H, and
Lemtrada. FDA approval for Campath was granted in May 2001. In
searching for publications, clinical trials etc. a 60 day allowance
was made for 'publication lag'.

4. Data are stored in a four column format where source and target
contain unique identifiers for nodes and stype and ntype refer to node
types for source and target respectively. An example is provided below
but  does not  represent real data for the alemtuzumab network.

| source | stype | target | ttype |
|  :---   | :--- | :--- | :--- |
| Campath | root | NCT11265 | ct |
| Campath | root | 8652811  | pmid1 |

5. Directional Cascade for edges:

	 root -> patent
	 root -> ct
	 root -> fda
	 root -> pmid1
	      
	      patent -> pmid1
	      ct -> pmid1
	      fda -> pmid1
	      
		pmid1 -> pmid2
		pmid1 -> grant
		pmid1 -> institution
		
		pmid2 -> grant
		pmid2 -> institution

6. Files
    1. alemtuzumab_ct (query specs and data from NCT and PubMed Searches)
    2. alemtuzumab_ct.csv (pmid only version ready for import into R)
    3. alemtuzumab_fda (query specs and datd from drugs@fda and Pazdur review)
    4. alemtuzumab_fda.csv (pmid only version ready for import into R)
    5. alemtuzumab_patent (query specs and data from Google Patents & PubMed)
    6. alemtuzumab_patent.csv (pmid only version ready for import into R)

7. Read all csv files into R and merge with additional pmid1s from reviews
using the alemtuzumab_merge.R script










