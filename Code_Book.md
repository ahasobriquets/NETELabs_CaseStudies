#  Code Book

## A cure informatics network (Williams et al. 2015), with modifications introduced by this collaborative effort, is being constructed for each of the case studies.

1. The data are modeled as a network of nodes connected by edges
2. Allowed node types are
  * root
  * ct (clinical trial in NCT database with NCT ID as uid or clinical trial(s) not in NCT database- designated as alemtuzumab_ct
  * fda
  * pmid1
  * pmid2
  * grant
  * institution (may not be needed)
  * author (may not be needed)

3. The term root is reserved for the drug in question, e.g, alemtuzumab, a humanized anti-CD52 monoclonal antibody,  also known as Campath, CamPath-1 H, and Lemtrada. 

4. Data are stored in a four column format where source and target contain unique identifiers for nodes and stype and ntype refer to node types for source and target respectively. An example is provided below and does not necessarily represent real data for the alemtuzumab (Campath) network.

| source | stype | target | ttype |
|  :---   | :--- | :--- | :--- |
| Campath | root | NCT11265 | ct |
| Campath | root | 8652811  | pmid1 |

5. When searching for related publications in PubMed, a 60 day allowance is made for 'publication lag', i.e. month of NDA/BLA approcal plus 2 months. For example, alemtuzumab was approved in May 2001, Pubmed searches are then performed fron 1900/01/01 to 2001/07/31.

Required files (substitute specific drug or biological names for drug as appropriate, e.g. alemtuzumab_fda)
  * drug/biological_fda: copy of NDA/BLA approval
  * drug/biological_ct_pmid1.csv (contains pmids derived PubMed searches for "clinical trial"[Publication Type]
  * drug/biological_fda_pmid1.csv (contains cited references in FDA Approval Summary publication plus pmids for any references that were scraped from the NDA/BLA approval
  * drug/biological_patent_pmid1.csv (contains cited references in patent(s) relevant to the drug/biological)
  * drug/biological_pmid1.csv (contains all stage 1 pmids- the union of pmids from ct, patents, and fda)

## Workflow Description

1.  Manual search of drug/biological_fda in drugs@fda http://www.accessdata.fda.gov/scripts/cder/daf/
2.  Manual search of EspaceNet and Google Patents for relevant patents
3.  Pubmed search for time restricted (NDA/BLA + 2 months) "clinical trial"[Publication Type]
4.  Extract cited references from fda approval summary publications if they exist, else rely on scraping documents from 1.
5.  Pubmed search for time restricted (NDA/BLA + 2 months) for drug name as keyword (ingredient or trade name)
6.  Construct edge list
| source | stype | target | ttype |
|  :---   | :--- | :--- | :--- |
| drug/biol | root | fda_identifier | fda |
| drug/bio | root | ct_identifier | ct
| drug/bio | root | patent_no | pt |
| fda_identifier | fda| pmid | pmid1 |
| ct_identifier | ct | pmid | pmid1 |
| patent_no | pt | pmid | pmid1 |
|pmid | pmid1 | pmid | pmid2 |
| pmid | pmid1 | grant_identifier | grant |
| pmid | pmid2 | grant_identifier | grant |








