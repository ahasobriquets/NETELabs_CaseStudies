# Count Author Output (write out publication counts, by type, for each author, for analysis)
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
from sortedcontainers import SortedDict

AUTHORS = "Output\\authors.json"
AUTH_PUBS = 'Output\\auth_publications.json'
AUTH_OUT = 'Output\\pub_counts.csv'

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
AuthFields = [
    'SID',
    'TYPE',
    'COUNT'
]
AuthOut = CSVOutput(AUTH_OUT, AuthFields)

print("Begin")

# Load Authors
Authors = SortedDict()
print("Loading Authors")
Count = 0
with fileinput.input(files=(AUTHORS), openhook=fileinput.hook_encoded("utf-8")) as f:
    for line in f:
        Count += 1
        if not (Count % 10000): print("Loaded: {}".format(Count))
        auth = json.loads(line.strip())
        Authors[auth['SID']] = {}
print("{} Authors Loaded".format(Count))

# Read Previous Results, if any
PubCount = 0
with fileinput.input(files=(AUTH_PUBS), openhook=fileinput.hook_encoded("utf-8")) as f:
    print("Processing Results")
    for line in f:
        pub = json.loads(line)
        PubCount += 1
        if not (PubCount % 100000): print("Processed {} Publications".format(PubCount))
        auth_id = pub['auth_sid']
        auth = Authors.get(auth_id, None)
        if auth is not None:
            docType = pub['docType']
            auth[docType] = auth.get(docType, 0) + 1
        else: print("Auth '{}' Not Found!".format(auth_id))
print("{} Publications Processed".format(PubCount))

for auth_id, auth in Authors.items():
    for docType, count in auth.items():
        row = {'SID': auth_id, 'TYPE': docType, 'COUNT': count}
        AuthOut.write(row)

print("Done")
