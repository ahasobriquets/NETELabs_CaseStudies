# Retrieve N2 Authors
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

# Load Authors
AuthIDs = SortedList()
AuthCount = 0
try:
    with fileinput.input(files=(AUTH_FILE), openhook=fileinput.hook_encoded("utf-8")) as f:
        for line in f:
            AuthCount += 1
            if not (AuthCount % 1000): print("Loaded {} Authors".format(AuthCount))
            data = json.loads(line)
            auth = Elsevier.Author(data)
            if auth.SID not in AuthIDs: AuthIDs.add(auth.SID)
    print("{} Authors Loaded".format(AuthCount))
except: pass

PubIDs = SortedList()
AuthOut = Output(AUTH_FILE)

# Load Core N1 Pubs
N2_Count = 0
Done = True
with fileinput.input(files=(N2_PUBS), openhook=fileinput.hook_encoded("utf-8")) as f:
    for line in f:
        N2_Count += 1
        print("Processing Publication {}".format(N2_Count))
        line = line.strip()
        try:
            data = json.loads(line)
            pub = Elsevier.ScopusPublication(data)
            if pub.SID not in PubIDs:
                PubIDs.add(pub.SID)
                if pub.Authors:
                    AuthTotal = len(pub.Authors)
                    AuthCount = 0
                    for auth in pub.Authors:  # Get publication Author
                        AuthCount += 1
                        if auth.SID not in AuthIDs:  # Switch to retrieved Author (more data)
                            print("Processing Author {}/{} - {}, {}".format(AuthCount, AuthTotal, auth.LastName, auth.FirstName))
                            try:
                                auths = Scopus.get_author(auth.SID, include_raw=True)
                                if auths:
                                    auth = auths[0]
                                    if auth.SID not in AuthIDs:  # Might be re-assigned on a redirect
                                        Done = False
                                        AuthOut.write(auth.Raw)
                                        AuthOut.flush()  # In case of future errors, ensure we save this out
                                        AuthIDs.add(auth.SID)
                                    else: print("Already Processed {}".format(auth.LastName))
                            except:
                                print("Error retrieving author, skipping...")
                                Done = False
                        else: print("Already Processed {}".format(auth.LastName))
                else: print("No Authors listed for SID:{}".format(pub.SID))
            else: print("Redundant Publication {}".format(pub.SID))
        except Exception as e:
            print("Bad Input Line: {} ({})".format(N2_Count, e))
            Done = False
print("{} Core Publications Loaded".format(len(PubIDs)))

AuthOut.close()
print("Done: {}".format(Done))
