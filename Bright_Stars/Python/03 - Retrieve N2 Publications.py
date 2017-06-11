# Retrieve N2 Publications (those cited by N1)
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
from sortedcontainers import SortedSet

N1_PUBS = "Output\\n1_pubs_scopus.json"
N2_PUBS = "Output\\n2_pubs_scopus.json"
Scopus = Elsevier.PubClient()

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

# Load N1 Pubs
N1_Count = 0
PubIDs = SortedSet()
N1_Pubs = {}
with fileinput.input(files=(N1_PUBS), openhook=fileinput.hook_encoded("utf-8")) as f:
    for line in f:
        N1_Count += 1
        if not (N1_Count % 1000): print("Loaded {} Publications".format(N1_Count))
        try:
            data = json.loads(line.strip())
            try:
                pub = Elsevier.ScopusPublication(data)
                if pub.SID not in PubIDs:
                    PubIDs.add(pub.SID)
                    N1_Pubs[pub.SID] = pub
            except Exception as e: print("Unable to process line {}: {} -> {}".format(N1_Count, e, data))
        except Exception as e: print("Unable to load line {}: {}".format(N1_Count, e))
print("{} N1 Publications Loaded".format(len(N1_Pubs)))

# Load Already Processed Files
try:
    with fileinput.input(files=(N2_PUBS), openhook=fileinput.hook_encoded("utf-8")) as f:
        count = 0
        for line in f:
            count += 1
            if not (count % 1000): print("Loaded {} Processed N2 Pubs".format(count))
            try:
                data = json.loads(line.strip())
                try:
                    pub = Elsevier.ScopusPublication(data)
                    if pub.SID not in PubIDs: PubIDs.add(pub.SID)
                except: print("Unable to process line {}: {} -> {}".format(count, e, data))
            except Exception as e: print("Unable to load line {}: {}".format(count, e))
    print("{} Publications Already Processed".format(len(PubIDs)))
except: pass  # File not created yet

# Output N2 Publications and Author Data
Done = True
PubOut = Output(N2_PUBS)
pub_total = len(N1_Pubs)
pub_count = 0
for pub in N1_Pubs.values():
    pub_count += 1
    cite_count = 0
    if pub.Citations:
        try:
            pub.get_cited_pubs(include_abs=False, include_raw=True, exclude=PubIDs)
            cite_total = len(pub.CitedPubs)
            print("Processing Publication {}/{} ({} N2 Pubs to Process)".format(pub_count, pub_total, cite_total))
            for cited_pub in pub.CitedPubs.values():
                if cited_pub.SID not in PubIDs:
                    cite_count += 1
                    print("Pub {} Citation {}/{}: {}".format(pub.SID, cite_count, cite_total, cited_pub.Title))
                    PubIDs.add(cited_pub.SID)
                    PubOut.write(cited_pub.Raw)
                    PubOut.flush()  # In case of errors, ensure we save what we have
                    Done = False
                else: print("Already Saved {}".format(cited_pub.SID))
            print("Publication {}: {} N2 Pubs saved".format(pub.SID, cite_count))
        except:
            print("Error retrieving cited pubs for {}. Moving on...".format(pub.SID))
            Done = False
    else: print("No citations to Process for Publication {}/{}".format(pub_count, pub_total))

PubOut.close()
print("Done: {}".format(Done))
