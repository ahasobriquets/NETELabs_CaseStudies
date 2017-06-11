# Retrieve N1 Publications
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

# Retrieves core (N1) set of initial publication from list of PubMed IDs
# The ID file in the example contains pubmed IDs in column 1, and a blank column for
# EIDs (Elsevier IDs). If the Pubmed ID is not found in Scopus, an exception for that
# Publication will be created. If manual searching in Scopus can uncover the publication, then
# The EID can be entered in that column of the ID file and this process re-run. The EID will
# take precedence over the PMID and the publication will be retrieved using EID instead.

import csv
import json
import fileinput
import ElsevierClient as Elsevier

Scopus = Elsevier.PubClient()
PMID_FILE = "n1_pub_ids.csv"
PUB_FILE = "Output\\n1_pubs_scopus.json"
EXC_FILE = "n1_pub_exc.json"
Done = True  # Will remain true unless we write out data new data (rerun until nothing new is written)

# Little Class that helps format output of publications
class Output:
    def __init__(s, name, mode='ab'):
        s.out = open(name, mode)

    def write(s, data):
        s.out.write((json.dumps(data) + '\n').encode('UTF-8'))

    def flush(s):
        s.out.flush()

    def close(s):
        s.out.close()

# Keep track of what we've already processed (only process new stuff)
TotalPubs = 0
IDMap = {
    'eid': 'eid',
    'pubmed-id': 'pmid',
    'prism:doi': 'doi'
}
LoadedIDs = {
    'eid': [],
    'pmid': [],
    'doi': []
}
try:
    with fileinput.input(files=(PUB_FILE), openhook=fileinput.hook_encoded("utf-8")) as f:
        print("Loading Already-Processed Publications...")
        for line in f:
            pub = json.loads(line.strip())
            for idtype in IDMap:
                id = pub['coredata'].get(idtype, None)
                if id: LoadedIDs[IDMap[idtype]].append(id)
            TotalPubs += 1
            if not (TotalPubs % 1000): print("Loaded {} Publications".format(TotalPubs))
except:
    pass  # File not found or other issue, just skip
print("Loaded {} Processed Publications".format(TotalPubs))

# Load PMID list and prep for Scopus
Pubs = {
    'eid': {},
    'pmid': {},
    'doi': {}
}
TotalPubs = 0
with open(PMID_FILE, newline='', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        pmid = row['pmid']
        eid = row['eid']
        if eid:  # If we have assigned an EID to the pub, it overrides the (presumably wrong) PMID
            if eid not in LoadedIDs['eid']:
                LoadedIDs['eid'].append(eid)
                Pubs['eid'][eid] = row
                TotalPubs += 1
        elif pmid:
            if pmid not in LoadedIDs['pmid']:
                LoadedIDs['pmid'].append(pmid)
                Pubs['pmid'][pmid] = row
                TotalPubs += 1
        else:
            print("No Valid ID for: {}".format(row['title']))

# Set up output file for publication data
PubOut = Output(PUB_FILE)
ExcOut = Output(EXC_FILE, mode='wb')
Processed = 0

def get_pubs(ids, id_type):
    global Processed
    global Done
    global NotFound
    id_type = id_type.upper()
    print("Fetching {} of type: {}".format(len(ids), id_type))
    try:
        for pub in Scopus.find_scopus_pubs(ids, id_type, include_abs=False, include_raw=False):
            id = getattr(pub, id_type)
            Processed += 1
            print("Processing {}/{}: {}".format(Processed, TotalPubs, pub.Title))
            try:
                ref_pub = Scopus.get_publication(pub.SID, include_abs=False, include_raw=True)
                if ref_pub:
                    ids.remove(id)
                    PubOut.write(ref_pub.Raw)
                    Done = False
                else:
                    print("Can't Retrieve Pub {}".format(pub.SID))
            except: print("Error processing Publication... moving on")
    except: print("Error processing batch. Moving on")
    if ids:
        print("{}s Not Found: {}".format(id_type.upper(), ids))
        Processed += len(ids)
    return ids

# Query Scopus in Batches of 10 at a time
print("{} Pub IDs Loaded".format(TotalPubs))
ScopusPubs = []
NotFound = []
for id_type in Pubs:
    IDs = []
    bad_ids = []
    Count = 0
    for id in Pubs[id_type]:
        Count += 1
        IDs.append(id)
        if not (Count % 10):
            bad_ids.extend(get_pubs(IDs, id_type))
            IDs = []
    if IDs: bad_ids.extend(get_pubs(IDs, id_type))
    for id in bad_ids: NotFound.append(Pubs[id_type][id])

if NotFound:
    print("Total Pub IDs Not Found: {}".format(len(NotFound)))
    ExcOut.write(NotFound)
print("Done: {}".format(Done))
