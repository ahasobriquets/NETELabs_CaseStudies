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


6/30 : I'm assuming in the future, its probably going to be a smarter idea to pass a list which contains
the addresses of the xml files. Then, loop through that list, parse each xml file for the pertinent
information and pump it into the CSV file. For now though, I am primarily concerned with simply converting the XML to CSV.
'''

import lxml # Used to parse the XML data
from lxml import etree
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
# Open the XML file
xml_file = open(xml_arg, 'r')
# Use lxml to parse the XML file
xml = etree.parse(xml_file)
xml_file.close()

# Check that the XML file has been accepted by lxml
#print etree.tostring(root)

# Safety check that this is a proper PubMed XML file for safety's sake. (Might have to be changed if my logic is wrong here)
# We can also add additional checks for other things as needed.
if len(xml.xpath('//PubmedArticle'))==0:
    raise ValueError('Passed XML file not a Pub Med XML file!')

# Pull possibly important information. -- Edit here in the future for whatever columns we want to get information on
pmid = xml.xpath('//PMID')[0].text
year = xml.xpath('//PubDate/Year')[0].text
title = xml.xpath('//Journal/Title')[0].text
publication_type = xml.xpath('//PublicationTypeList/PublicationType')[0].text
keyword_list = xml.xpath('//KeywordList/Keyword')
keyword_list = [keyword.text for keyword in keyword_list]
print keyword_list

# Just printing the information to the console to make sure the user is aware of what is going in
print "Pulled XML Data for PMID: %s. \n\tTitle: %s. \n\tPublished in: %s\n\tPublication Type: %s\
" % (pmid, title,year,publication_type)
print "\tKeywords are:"
for keyword in keyword_list:
    print"\t%s"%(keyword)

# Open a CSV file for writing -- This will need
with open('pub_med_test.csv', 'wb') as csvfile:
    pubmed_writer = csv.writer(csvfile, delimiter = ',')
    # Header information, particularly number of 'Keyword_*' columns produced, will need to likely be adjusted in a future update to accomodate for whatever the largest keyword list is (if all the articles have varying length lists...)
    header = ['PMID', 'Year', 'Title', 'Publication_Type'] + ["Keyword_%d"%(i+1) for i in range(0,len(keyword_list))]
    data = [pmid,year,title,publication_type] + keyword_list
    # Write the desired data to the CSV file
    pubmed_writer.writerow(header)
    pubmed_writer.writerow(data)

# Let the user know that the new CSV file has been created
print "New file pub_med_test.csv created."
