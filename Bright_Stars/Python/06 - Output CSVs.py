# Output CSVs (Base data used for analysis, importable into the SQL database
# By: Eric Livingston (e.livingston@Elsevier.com)
# Copyright © 2017 Elsevier B.V. All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:

# 1.	Redistributions of source code must retain the above copyright notice,
#   	this list of conditions and the following disclaimer.

# 2.	Redistributions in binary form must reproduce the above copyright
#   	notice, this list of conditions and the following disclaimer in the
#   	documentation and/or other materials provided with the distribution.

# Neither the name of the copyright holder nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import csv
import json
import fileinput
import ElsevierClient as Elsevier
from sortedcontainers import SortedList

N1_PUBS = "Output\\n1_publications.json"
N2_PUBS = "Output\\n2_publications.json"
AUTHORS = "Output\\authors.json"
PUB_OUT = "Output\\pub_out.csv"
PUB_SRC = "Output\\pub_src.csv"
PUB_SUBJ = "Output\\pub_subj.csv"
PUB_CITE = "Output\\pub_cites.csv"
PUB_AUTH = "Output\\pub_auth.csv"
PUB_AUTH_AFF = "Output\\pub_auth_affs.csv"
PUB_IDX = "Output\\pub_idx.csv"
PUB_KEY = "Output\\pub_key.csv"
PUB_AFFS = "Output\\pub_affs.csv"
Scopus = Elsevier.PubClient()

# Little Class that helps format output of publications
class CSVOutput:
    def __init__(s, name, fields, mode='w', dialect='unix', newline='', encoding='utf-8'):
        s.out = open(name, mode, newline=newline, encoding=encoding)
        s.writer = csv.DictWriter(s.out, fieldnames=fields, dialect=dialect, extrasaction='ignore')
        s.writer.writeheader()

    def write(s, row):
        s.writer.writerow(row)

    def flush(s):
        s.out.flush()

    def close(s):
        s.out.close()

# Main Pub CSV
PubFields = [
    'SID',
    'PMID',
    'DOI',
    'EID',
    'Date',
    'Title'
]
PubOut = CSVOutput(PUB_OUT, PubFields)

# Publication Source
SrcFields = [
    'PubSID',
    'ISSN',
    'Type',
    'Name',
    'CoverDate',
    'Volume',
    'Issue',
    'Pages'
]
SrcOut = CSVOutput(PUB_SRC, SrcFields)

# Publication Subject Areas
SubjFields = [
    'PubSID',
    'Code',
    'Abbr',
    'Name'
]
SubjOut = CSVOutput(PUB_SUBJ, SubjFields)

# Publication Index Terms
IdxTermFields = [
    'PubSID',
    'Name'
]
IdxTermOut = CSVOutput(PUB_IDX, IdxTermFields)

# Publication Author Keywords
KeyTermFields = [
    'PubSID',
    'Name'
]
KeyTermOut = CSVOutput(PUB_KEY, KeyTermFields)

# Publication Citations (Bibliography)
CiteFields = [
    'PubSID',
    'SID',
    'SourceYear',
    'SourceName',
    'SourceVolume',
    'SourceFirstPage',
    'SourceLastPage',
    'Title',
    'Text'
]
CiteOut = CSVOutput(PUB_CITE, CiteFields)

# Publication Authors
AuthFields = [
    'PubSID',
    'SID',
    'FullName',
    'LastName',
    'FirstName',
    'Initials',
    'DocCount'
]
AuthOut = CSVOutput(PUB_AUTH, AuthFields)

# Author Affiliations
AuthAffFields = [
    'AuthSID',
    'SID',
    'IsCurrent'
]
AuthAffOut = CSVOutput(PUB_AUTH_AFF, AuthAffFields)

# Publication Affiliations
AffFields = [
    'PubSID',
    'SID',
    'Name',
    'City',
    'Country',
    'URL'
]
AffOut = CSVOutput(PUB_AFFS, AffFields)

def merge(*dict_args):
    result = {}
    for dictionary in dict_args: result.update(dictionary)
    return result

def output_pub(pub):
    PubOut.write(pub)
    ref = {'PubSID': pub['SID']}
    SrcOut.write(merge(ref, pub['Source']))
    if pub['Subjects']:
        for code, data in pub['Subjects'].items(): SubjOut.write(merge(ref, {'Code': code}, data))
    if pub['IndexTerms']:
        for term in pub['IndexTerms'].keys(): IdxTermOut.write(merge(ref, {'Name': term}))
    if pub['Keywords']:
        for term in pub['Keywords']: KeyTermOut.write(merge(ref, {'Name': term}))
    if pub['Citations']:
        for cite in pub['Citations']: CiteOut.write(merge(ref, cite))
    if pub['Authors']:
        for auth in pub['Authors']:
            auth = Authors.get(auth['SID'], auth)
            AuthOut.write(merge(ref, auth))
            if auth['Affiliations']:
                auth_ref = {'AuthSID': auth['SID']}
                curr_aff = auth['CurrentAffiliation']['SID']
                for aff in auth['Affiliations'].values():
                    AuthAffOut.write(merge(auth_ref, {'IsCurrent': (aff['SID'] == curr_aff)}, aff))
    if pub['Affiliations']:
        for aff in pub['Affiliations'].values(): AffOut.write(merge(ref, aff))

# Load Authors
Authors = {}
print("Loading Authors")
Count = 0
with fileinput.input(files=(AUTHORS), openhook=fileinput.hook_encoded("utf-8")) as f:
    for line in f:
        Count += 1
        if not (Count % 1000): print("Loaded: {}".format(Count))
        auth = json.loads(line.strip())
        Authors[auth['SID']] = auth
print("{} Authors Loaded".format(Count))

# Process Core CorePubs
PubIDs = SortedList()
print("Processing Publications (N1 & N2)")
Count = 0
with fileinput.input(files=(N1_PUBS, N2_PUBS), openhook=fileinput.hook_encoded("utf-8")) as f:
    for line in f:
        Count += 1
        if not (Count % 1000): print("Processed: {}".format(Count))
        pub = json.loads(line.strip())
        if pub['SID'] not in PubIDs:
            PubIDs.add(pub['SID'])
            output_pub(pub)
print("{} Publications Processed".format(Count))

print("Done")
