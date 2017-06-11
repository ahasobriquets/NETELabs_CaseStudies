# Retrieve All Author Pubs (download smaller records for every publication by every author)
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

import json
import fileinput
import ElsevierClient as Elsevier
from sortedcontainers import SortedList
from multiprocessing.dummy import Pool as ThreadPool

AUTHORS = "Output\\authors_scopus.json"
AUTH_PUBS = 'Output\\auth_publications.json'
# AUTH_OUT = 'Output\\auth_publications_test.json'
AUTH_OUT = AUTH_PUBS  # Set these equal for normal operations, otherwise AUTH_OUT is a test and PUBS won't be pre-processed
# PoolSize can be set to greater than 1 to implement Multiprocessing (MP) thread pools for parallel
# searches. However, this has been shows to be unreliable, generating Server disconnects for now. So,
# the safe (but slower) approach is to set threads to one, collapsing the MP approach to using a single
# thread, and thus serializing the searches.
PoolSize = 1  # Recommend to keep at 1, but other values can be experimented with
Done = True  # If anything is written out, we're not done. Can re-run until Done is True
AuthIDs = SortedList()

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

print("Begin")

# Read Previous Results, if any
if AUTH_OUT == AUTH_PUBS:
    AuthCount = 0
    PubCount = 0
    try:
        with fileinput.input(files=(AUTH_PUBS), openhook=fileinput.hook_encoded("utf-8")) as f:
            print("Processing Previous Results")
            for line in f:
                pub = json.loads(line)
                PubCount += 1
                if pub['auth_sid'] not in AuthIDs:
                    AuthCount += 1
                    if not (AuthCount % 1000): print("Loaded {} Authors".format(AuthCount))
                    AuthIDs.add(pub['auth_sid'])
        print("{} Authors Processed".format(AuthCount))
        print("{} Publications Processed".format(PubCount))
    except:
        pass

PubOut = Output(AUTH_OUT)

# Fetch Publications for a given Author ID. This can be called in parallel for multiple IDs
def fetch_pubs(auth):
    results = []
    pubs = auth.get_pubs(view='STANDARD')
    for pub in pubs:
        results.append({
            "auth_sid": auth.SID,
            "eid": pub.EID,
            "sid": pub.SID,
            "doi": pub.DOI,
            "pmid": pub.PMID,
            "title": pub.Title,
            "date": pub.Date,
            "issn": pub.Source.ISSN,
            "sourceTitle": pub.Source.Name,
            "volume": pub.Source.Volume,
            "issue": pub.Source.Issue,
            "docType": pub.SubType
        })
    print("Retrieved {} Pubs for Author {}".format(len(results), auth.FirstName, auth.LastName))
    return results

# Sets up MP job pool and allocates authors to them
def fetch_authors(auths):
    global Done
    with ThreadPool(PoolSize) as AuthorPool:
        results = AuthorPool.map(fetch_pubs, auths)
    for pubs in results:  # Aggregate Pool results and wtite it all out
        if pubs:
            Done = False
            for pub in pubs: PubOut.write(pub)
    PubOut.flush()  # Flush whatever we wrote, so subsequent errors don't leave the file incomplete

Count = 0
print("Processing Authors")
with fileinput.input(files=(AUTHORS), openhook=fileinput.hook_encoded("utf-8")) as f:
    AuthQ = []
    for line in f:
        Count += 1
        if not (Count % 100): print("Processed {} Authors".format(Count))
        data = json.loads(line)
        auth = Elsevier.Author(data)
        log = auth.get_log()
        log.reset()
        if auth.SID not in AuthIDs:
            AuthIDs.add(auth.SID)
            AuthQ.append(auth)
            if len(AuthQ) == PoolSize:  # Only send as many auths as we have Pool clients, 1 per client
                fetch_authors(AuthQ)
                AuthQ = []
                if AUTH_OUT != AUTH_PUBS: break
    if len(AuthQ): fetch_authors(AuthQ)  # Catch stragglers at the end

print("Done: {}".format(Done))
