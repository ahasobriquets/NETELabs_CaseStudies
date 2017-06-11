# Process Pubs and Authors (format into standard Objects)
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
import jsonpickle
import fileinput
import ElsevierClient as Elsevier
from sortedcontainers import SortedList

AuthIDs = SortedList()
PubIDs = SortedList()
N1_PUBS = "Output\\n1_pubs_scopus.json"
N1_OUT = "Output\\n1_publications.json"
N2_PUBS = "Output\\n2_pubs_scopus.json"
N2_OUT = "Output\\n2_publications.json"
AUTHORS = "Output\\authors_scopus.json"
AUTH_OUT = "Output\\authors.json"
Scopus = Elsevier.PubClient()

# Little Class that helps format output of publications
class Output:
    def __init__(s, name, mode='wb'):
        s.out = open(name, mode)

    def write(s, data):
        s.out.write((jsonpickle.encode(data, warn=True, unpicklable=False) + '\n').encode('UTF-8'))

    def flush(s):
        s.out.flush()

    def close(s):
        s.out.close()

# Load Core CorePubs
print("Processing Authors")
AuthOut = Output(AUTH_OUT)
Count = 0
with fileinput.input(files=(AUTHORS)) as f:
    for line in f:
        Count += 1
        if not (Count % 1000): print("Processed {} Authors".format(Count))
        data = json.loads(line.strip())
        auth = Elsevier.Author(data, include_raw=False)
        if auth.SID not in AuthIDs:
            AuthIDs.add(auth.SID)
            AuthOut.write(auth)
print("{} Authors Processed".format(Count))

# Load Core CorePubs
print("Processing N1 Pubs")
N1_Out = Output(N1_OUT)
Count = 0
with fileinput.input(files=(N1_PUBS)) as f:
    for line in f:
        Count += 1
        if not (Count % 1000): print("Processed {} N1 Publications".format(Count))
        data = json.loads(line.strip())
        pub = Elsevier.ScopusPublication(data, include_abs=True, include_raw=False)
        if pub.SID not in PubIDs:
            PubIDs.add(pub.SID)
            N1_Out.write(pub)
print("{} N1 Publications Processed".format(Count))

# Load Cited Files
print("Processing N2 Pubs")
N2_Out = Output(N2_OUT)
Count = 0
with fileinput.input(files=(N2_PUBS)) as f:
    for line in f:
        Count += 1
        if not (Count % 1000): print("Processed  {} N2 Publications".format(Count))
        data = json.loads(line.strip())
        pub = Elsevier.ScopusPublication(data, include_abs=True, include_raw=False)
        if pub.SID not in PubIDs:
            PubIDs.add(pub.SID)
            N2_Out.write(pub)
print("{} N2 Publications Processed".format(Count))

print("Done")
