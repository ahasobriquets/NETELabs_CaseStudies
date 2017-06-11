# Retrieve N1 Publication Authors
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
from sortedcontainers import SortedDict

AUTH_FILE = "Output\\authors_scopus.json"
N1_PUBS = "Output\\n1_pubs_scopus.json"
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

# Load Authors
Authors = SortedDict()
AuthCount = 0
try:
    with fileinput.input(files=(AUTH_FILE), openhook=fileinput.hook_encoded("utf-8")) as f:
        for line in f:
            AuthCount += 1
            if not (AuthCount % 1000): print("Loaded {} Authors".format(AuthCount))
            data = json.loads(line)
            auth = Elsevier.Author(data)
            if auth.SID not in Authors: Authors[auth.SID] = auth
    print("{} Authors Loaded".format(len(Authors)))
except: pass

PubIDs = SortedList()
AuthOut = Output(AUTH_FILE)

# Load Core N1 Pubs
N1_Count = 0
N1_Pubs = {}
with fileinput.input(files=(N1_PUBS), openhook=fileinput.hook_encoded("utf-8")) as f:
    for line in f:
        N1_Count += 1
        if not (N1_Count % 1000): print("Loaded {} Publications".format(N1_Count))
        line = line.strip()
        try:
            data = json.loads(line)
            pub = Elsevier.ScopusPublication(data)
            if pub.SID not in PubIDs:
                PubIDs.add(pub.SID)
                N1_Pubs[pub.SID] = pub
        except Exception as e:
            print("Bad Input Line: {} ({})".format(N1_Count, e))
print("{} Core Publications Loaded".format(len(PubIDs)))

# Set up output file for Author data
N1_Total = len(N1_Pubs)
N1_Count = 0
Done = True
for n1_pub in N1_Pubs.values():
    N1_Count += 1
    print("Processing Publication {}/{}".format(N1_Count, N1_Total))
    if n1_pub.Authors:
        AuthTotal = len(n1_pub.Authors)
        AuthCount = 0
        for auth in n1_pub.Authors:  # Get publication Author
            if auth.SID not in Authors:  # Switch to retrieved Author (more data)
                AuthCount += 1
                print("Processing Author {}/{} - {}, {}".format(AuthCount, AuthTotal, auth.LastName, auth.FirstName))
                try:
                    auths = Scopus.get_author(auth.SID, include_raw=True)
                    if auths:
                        auth = auths[0]
                        if auth.SID not in Authors:  # Might be re-assigned on a redirect
                            Done = False
                            AuthOut.write(auth.Raw)
                            AuthOut.flush()  # In case of future errors, ensure we save this out
                            Authors[auth.SID] = auth
                        else: print("Already Processed {}".format(auth.LastName))
                except: print("Error retrieving author, skipping...")
            else: print("Already Processed {}".format(auth.LastName))
    else: print("No Authors listed for SID:{}".format(n1_pub.SID))
AuthOut.close()

print("Done: {}".format(Done))
