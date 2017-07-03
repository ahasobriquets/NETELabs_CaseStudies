'''
VJ Davey
June 30 2017

Usage:
    xml_parse_test.py -f [xml_file]

        -> '-f' specifies that you want to pass a file
        -> 'xml_file' is the PubMed XML file desired to be parsed and converted to a CSV file

This script will be used to parse XML. The XML is currently
going to be passed as a command line argument. It will then
generate a CSV file which is designed as follows:
    1) The CSV file will contain several columns related to PubMed information
    2) Currently outputs as columns:
        a) The Pubmed ID (PMID)
        b) The NLM Unique ID
        c) The Publication Date


7/3 : Code has been updated to handle being passed an XML file which contains a series of smaller XML files
inside of it
'''
from lxml import etree # Used to parse the XML data
import sys # Used to parse the input argument(s)
import csv # Used to output information to a csv file

# Collect the XML file as an argument passed to the program as an input argument
xml_arg = None
if '-f' not in sys.argv:
    raise ValueError('No XML file attached!')
else:
    xml_arg = sys.argv[(sys.argv).index('-f')+1]
    if str(xml_arg)[-4:] == ".xml": #safety check that this is an XML file
        print "XML file: %s taken." % (str(xml_arg))
    else:
        raise ValueError('You did not pass an XML file!')
# Open and parse the XML file with lxml
xml = etree.parse(xml_arg)

# Safety check that this is a proper PubMed XML file for safety's sake. (Might have to be changed if my logic is wrong here)
if len(xml.xpath('//PubmedArticleSet'))==0:
    raise ValueError('Passed XML file not a Pubmed Article Set XML file!')

#Open a CSV file to write to
with open('pub_med_test.csv', 'wb') as csvfile:
    pubmed_writer = csv.writer(csvfile, delimiter = ',')
    # Header information, particularly number of 'Keyword_*' columns produced, will need to likely be adjusted in a future update to accomodate for whatever the largest keyword list is (if all the articles have varying length lists...)
    # Currently, capping off at 80, since thats the most keywords in the list for the test XML file...
    header = ['PMID', 'Year', 'Article_Title', 'Journal_Title', 'Publication_Type'] + ["Keyword_%d"%(i+1) for i in range(0,80)]
    pubmed_writer.writerow(header)

    # We intend to make records for every article in the XML file
    for article in xml.iter("PubmedArticle"):
        # Create a subset of the XML for each article
        sub_xml = etree.ElementTree(article)

        # For each type of article publication, we will create a new row of information (e.g. Journal Article, Multicenter Study, etc.)
        for publication_type_tag_index in range(0,len(sub_xml.xpath('//PublicationTypeList/PublicationType'))):
            # Pull all the desired information
            pmid = sub_xml.xpath('//MedlineCitation/PMID')[0].text
            try:
                year = sub_xml.xpath('//PubDate/Year')[0].text
            except IndexError: #when no PubDate/Year is available
                year = "NA"
            journal_title = sub_xml.xpath('//Journal/Title')[0].text
            article_title = sub_xml.xpath('//ArticleTitle')[0].text
            publication_type = sub_xml.xpath('//PublicationTypeList/PublicationType')[publication_type_tag_index].text
            # Create NA filler info for keywords lists tht dont reach the 80 keyword cap
            keyword_list = ["" for i in range(0,80)]
            keyword_pull = sub_xml.xpath('//KeywordList/Keyword')
            for keyword_index in range(0,len(keyword_pull)):
                keyword_list[keyword_index] = keyword_pull[keyword_index].text

            # Just printing the information to the console to make sure the user is aware of what is going in
            print "Pulled XML Data for PMID: %s. \n\tTitle: %s\n\tJournal: %s \n\tPublished in: %s\n\tPublication Type: %s\
            " % (pmid, article_title, journal_title, year,publication_type)

            # Write the desired information off to the CSV file
            data = [pmid,year,article_title,journal_title, publication_type] + keyword_list
            data = [item.encode('utf-8') for item in data] # Make sure data is unicode safe (utf-8). Encode every string in the data list before writing to CSV
            pubmed_writer.writerow(data)

# Let the user know that the new CSV file has been created
print "New file pub_med_test.csv created."
