# Elsevier Scopus Client module
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
import time
import jsonpickle
import urllib.request
import urllib.parse
import urllib.error
import multiprocessing.dummy as multiprocessing
from munch import *
from sortedcontainers import SortedSet

# Replace the string below with your Scopus API key
# Scopus API keys are freely-obtainable at https://dev.Elsevier.com
APIKey = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
# The debug setting will generate a log of queries and errors by the client
Debug = True
# The client is capable of multithreaded, parallel queries to break up a search for speed
# However, testing has been unreliable so far as the server can randomly disconnect
# So, for now, keep max thread count to 1 in order to serialize it all
MaxThreadCount = 1
# Similarly, in theory some searches can return up to 200 records at once. This sets a global
# Maximum on search results per submission. 25 Seems to be the most stable over time
MaxSearchCount = 25
# Each unique search through the API can currently only return a maximum of 5,000 records. This is a
# bug, and needs to be sorted out. It's a lecacy limitation on the older search technology used by
# Scopus. While the technology has been upgraded, this legacy limitation remains for now
MaxReturnCount = 5000
# The API is throttled at 60 queries in 60 seconds. This client implements a locking throttle that
# will keep track of overall search rate across all threads, and pause each new search long enough for
# the rate to drop below 60 queries in the last 60 seconds. This allows for sustained speeds of
# one query per second, or allows a single query to have burst traffic of a higher rate for shorter
# times.
ThrottleSeconds = 60
ThrottleLimit = 60

# Document publication type codes (for use in counts, etc.)
DocTypes = {
    'ar': 'Article',
    'ip': 'Article in Press',
    'ab': 'Abstract Report',
    'bk': 'Book',
    'ch': 'Book Chapter',
    'bz': 'Business Article',
    'cp': 'Conference Paper',
    'cr': 'Conference Review',
    'ed': 'Editorial',
    'er': 'Erratum',
    'le': 'Letter',
    'no': 'Note',
    'pr': 'Press Release',
    'rp': 'Report',
    're': 'Review',
    'sh': 'Short Survey'
}

class QueryThrottle:
    def __init__(s):
        s.Lock = multiprocessing.Lock()
        s.Queries = []

    def queue(s):
        now = time.time()
        threshold = now - ThrottleSeconds
        while s.Queries and (s.Queries[0] < threshold): del s.Queries[0]
        return s.Queries

    def ready(s):
        with s.Lock:
            while len(s.queue()) >= ThrottleLimit:
                Log.write("Throttling...")
                time.sleep(0.1)
            s.Queries.append(time.time())
        return True

Throttle = QueryThrottle()

class DebugLogger:
    def __init__(s):
        s.debug_file = open('Scopus Search Result.txt', 'wb') if Debug else None
        if s.debug_file:
            s.Lock = multiprocessing.Lock()

    def reset(s):
        if s.debug_file:
            s.debug_file.seek(0)
            s.debug_file.truncate()
            s.debug_file.flush()

    def write(s, data):
        if s.debug_file:
            with s.Lock:
                if not isinstance(data, str): data = jsonpickle.encode(data, warn=True, unpicklable=False)
                s.debug_file.write((data + '\n').encode('UTF-8'))
                s.debug_file.flush()

Log = DebugLogger()

# These classes read scopus return records and create more uniform classes based on them
# Scopus return records can optionally contain fields or not, depending on if a value is in them.
# These classes create a standard structure with fixed fields, indicating None when no data is present.

# Publication Source
class PubSource:
    def __init__(s, src):
        s.Type = src.get('prism:aggregationType', None)
        s.Name = src.get('prism:publicationName', None)
        s.CoverDate = src.get('prism:coverDisplayDate', src.get('prism:coverDate', None))
        s.ISBN = src.get('prism:isbn', None)
        s.ISSN = src.get('prism:issn', None)
        s.eISSN = src.get('prism:eIssn', None)
        s.Volume = src.get('prism:volume', None)
        s.Issue = src.get('prism:issueIdentifier', None)
        s.IssueName = src.get('prism:issueName', None)
        s.Edition = src.get('prism:edition', None)
        s.ArticleNumber = src.get('article-number', None)
        s.StartPage = src.get('prism:startingPage', None)
        s.EndPage = src.get('prism:endingPage', None)
        s.Pages = src.get('prism:pageRange', None)
        if not s.Pages:
            if s.StartPage and s.EndPage: s.Pages = s.StartPage + '-' + s.EndPage

# Publication Citation record
class Citation:
    def __init__(s, ref):
        s.Text = ref.get('ref-fulltext', None)
        ref = ref['ref-info']
        id = ref['refd-itemidlist']['itemid']
        if id['@idtype'] == 'SGR':
            s.SID = id['$']
        else:
            print("Unknown ID type: {}".format(id['@idtype']))
        s.Title = ref.get('ref-title', {}).get('ref-titletext', None)
        s.SourceName = ref.get('ref-sourcetitle', None)
        s.SourceText = ref.get('ref-text', None)
        volume = ref.get('ref-volisspag', {})
        s.SourceVolume = volume.get('voliss', {}).get('@volume', None)
        s.SourceFirstPage = volume.get('pagerange', {}).get('@first', None)
        s.SourceLastPage = volume.get('pagerange', {}).get('@last', None)
        s.SourceYear = ref.get('ref-publicationyear', {}).get('@first', None)
        s.Authors = []
        authors = ref.get('ref-authors', {}).get('author', None)
        if authors:
            if not isinstance(authors, list): authors = [authors]
            for auth in authors:
                s.Authors.append(Munch({
                    'FullName': auth.get('ce:indexed-name', None),
                    'LastName': auth.get('ce:surname', None),
                    'Initials': auth.get('ce:initials', None)
                }))

# Affiliation record. Affiliation data can be delivered in several formats, depending on the search
# API used. This class tries to determine which is being sent, and creates a standard object
class Affiliation:
    def __init__(s, aff, include_raw=False):
        s.load(aff)
        if include_raw: s.Raw = aff

    def load(s, aff):
        if 'scopus-id' in aff:
            s.load_mini(aff)  # Indicates this is a "mini" record with less data
        else:
            s.load_profile(aff)  # Full affiliation record

    def load_mini(s, aff):
        s.SID = aff['scopus-id']
        s.Name = aff.get('affiliation-name', aff.get('affilname', None))
        s.City = aff.get('affiliation-city', None)
        s.Country = aff.get('affiliation-country', None)
        s.URL = aff.get('affiliation-url', None)

    def load_profile(s, aff):
        s.Parents = []
        profile = {}
        try:
            if 'ip-doc' in aff:  # This is one way aff info might be returned
                profile = aff['ip-doc']
                s.SID = aff['@affiliation-id']
                s.Type = profile.get('@type', None)
                if '@parent' in aff:
                    parent = {'SID': aff['@parent'], 'Name': profile.get('parent-preferred-name', {}).get('$', None)}
                    s.Parents.append(Munch(parent))
            elif 'institution-profile' in aff:  # This is an alternative (more complete) record type
                core = aff['coredata']
                profile = aff['institution-profile']
                s.SID = core['dc:identifier'].split(':')[1]
                s.EID = core.get('eid', None)
                s.Type = profile.get('org-type', None)
                supers = profile.get('super-orgs', {}).get('super-org', None)
                if supers:
                    if not isinstance(supers, list): supers = [supers]
                    for super in supers:
                        s.Parents.append(Munch({
                            'SID': super['$'],
                            'Type': super['@rel-type']
                        }))
                s.AltNames = []
                for variant in aff.get('name-variants', {}).get('name-variant', []):
                    s.AltNames.append(variant['name-variant'])
                s.AltAffs = []
                for entry in aff.get('certainty-scores', {}).get('certainty-score', []):
                    s.AltAffs.append({'Score': entry['score'], 'SID': entry['org-id']})
            if profile:
                # Common Fields
                s.Name = profile.get('preferred-name', {}).get('$', None)
                s.Domain = profile.get('org-domain', None)
                s.URL = profile.get('org-URL', None)
                addr = profile.get('address', None)
                if addr:
                    s.Street = addr.get('address-part', None)
                    s.City = addr.get('city', None)
                    s.State = addr.get('state', None)
                    s.PostCode = addr.get('postal-code', None)
                    s.Country = addr.get('country', None)
                    s.CountryCode = addr.get('@country', None)
            else:
                s.SID = aff['@id']
        except:
            print("Unprocessed Aff: '{}'".format(aff))
            raise

# Author record. Like Affiliations, the actual record structure returned and information contained
# Will differ, depending on the search API being used and record type being returned. This class
# Tries to detect which record is being used and create a fixed class structure from them
class Author:
    def __init__(s, auth, include_raw=False):
        s.Subjects = None
        s.Affiliations = None
        s.CurrentAffiliation = None
        s.Publications = None
        if '@auid' in auth:  # Author sub-record of Publication Retrieval API results
            core = auth
            profile = auth
            name = auth.get('preferred-name', {})
            s.SID = auth['@auid']
            s.FullName = auth.get('ce:indexed-name', None)
            affs = auth.get('affiliation')
            if affs:
                s.Affiliations = {}
                if not isinstance(affs, list): affs = [affs]
                for aff in affs:
                    aff['scopus-id'] = aff['@id']
                    aff = Affiliation(aff)
                    s.Affiliations[aff.SID] = aff
                    if not s.CurrentAffiliation: s.CurrentAffiliation = aff
        elif 'authid' in auth:  # Author info embedded in Scopus Search API results
            core = auth
            profile = auth
            name = auth['preferred-name'] if 'preferred-name' in auth else auth
            s.SID = auth['authid']
            s.FullName = auth.get('authname', None)
            subject_areas = {}
            if 'subject-area' in auth:
                if not isinstance(auth['subject-area'], list): auth['subject-area'] = [auth['subject-area']]
                for sa in auth['subject-area']:
                    subject_areas[sa['@code']] = {'Abbr': sa['@abbrev'], 'Name': sa['$'], 'Freq': None}
            if subject_areas: s.Subjects = Munch(subject_areas)
            aff = auth.get('affiliation-current', None)
            if aff:
                aff['scopus-id'] = aff['affiliation-id']
                aff = Affiliation(aff)
                s.Affiliations = {aff.SID: aff}
                s.CurrentAffiliation = aff
            affs = auth.get('afid', [])
            if affs:
                if not isinstance(affs, list): affs = [affs]
                if not s.Affiliations: s.Affiliations = {}
                for aff in affs:
                    aff_id = format(aff['$'])
                    if aff_id and (aff_id not in s.Affiliations):
                        aff['scopus-id'] = aff_id
                        aff = Affiliation(aff)
                        s.Affiliations[aff.SID] = aff
                        if not s.CurrentAffiliation: s.CurrentAffiliation = aff
        elif 'coredata' in auth:  # Response from Retrieve Author API
            core = auth['coredata']
            profile = auth.get('author-profile', {})
            name = profile.get('preferred-name', {})
            s.SID = core['dc:identifier'].split(':')[1]
            s.FullName = name.get('indexed-name', None)
            subject_areas = {}
            auth_areas = auth.get('subject-areas', {})
            if auth_areas:
                for sa in auth_areas.get('subject-area', []):
                    subject_areas[sa['@code']] = {'Abbr': sa['@abbrev'], 'Name': sa['$'], 'Freq': None}
            for class_type in profile.get('classificationgroup', {}).values():
                if class_type['@type'] == 'ASJC':
                    types = class_type.get('classification', [])
                    if not isinstance(types, list): types = [types]
                    for sa in types:
                        if sa['$'] in subject_areas: subject_areas[sa['$']]['Freq'] = sa['@frequency']
            if subject_areas: s.Subjects = Munch(subject_areas)
            cur_affils = profile.get('affiliation-current', {}).get('affiliation', None)
            if cur_affils:
                if not isinstance(cur_affils, list): cur_affils = [cur_affils]
                if not s.Affiliations: s.Affiliations = {}
                for affil in cur_affils:
                    aff = Affiliation(affil)
                    if aff.SID:
                        s.Affiliations[aff.SID] = aff
                        if s.CurrentAffiliation is None: s.CurrentAffiliation = aff
            aff_history = profile.get('affiliation-history', {}).get('affiliation', [])
            if not isinstance(aff_history, list): aff_history = [aff_history]
            if aff_history:
                if not s.Affiliations: s.Affiliations = {}
                for aff in aff_history:
                    aff_id = aff['@affiliation-id']
                    if aff_id and (aff_id not in s.Affiliations):
                        aff = Affiliation(aff)
                        s.Affiliations[aff.SID] = aff
                        if not s.CurrentAffiliation: s.CurrentAffiliation = aff
            prev_ids = core.get('historical-identifier', [])
            if prev_ids: s.PrevIDs = [i['$'].split(':')[1] for i in prev_ids]
        # Common Fields
        s.EID = core.get('eid', None)
        s.ORCID = core.get('orcid', None)
        s.DocCount = core.get('document-count', None)
        s.CoAuthCount = core.get('coauthor-count', None)
        s.CitedByCount = core.get('cited-by-count', None)
        s.CitationCount = core.get('citation-count', None)
        s.HIndex = core.get('h-index', None)
        s.FirstName = name.get('given-name', name.get('ce:given-name', None))
        s.LastName = name.get('surname', name.get('ce:surname', None))
        s.Initials = name.get('initials', name.get('ce:initials', None))
        if 'name-variant' in profile:
            names = profile['name-variant']
            if not isinstance(names, list): names = [names]
            s.AltNames = [Munch({
                'LastName': n.get('surname', None),
                'FirstName': n.get('given-name', None),
                'Initials': n.get('initials', None),
                'FullName': n.get('indexed-name', None)
            }) for n in names]
        if include_raw: s.Raw = auth

    def get_pubs(s, year=None, view='COMPLETE', start=0, count=None, sort='-coverDate', doctypes=None, include_abs=False, include_raw=False):
        params = [year, view, start, count, sort, doctypes, include_abs, include_raw]
        s.Publications = None
        if (not getattr(s, 'PubParams', False)) or (params != s.PubParams):
            Scopus = PubClient()
            s.PubParams = params  # Store params so we don't request the same thing twice
            s.Publications = Scopus.find_author_pubs(s.SID, year=year, view=view, start=start, count=count, sort=sort, doctypes=doctypes, include_abs=include_abs, include_raw=include_raw)
        return s.Publications

    def get_log(s):  # This allows scripts accessing this client to reset the debug Log
        return Log

# Publication record. As with Authors, publication records may be in several formats, depending on the
# API being used and record being returned.
# The Publication class is a base class that has fields shared with Science Direct publications as well
class Publication:
    def __init__(s, pub, include_abs=False, include_raw=False):
        s.SID = None  # Set in child object
        if 'coredata' in pub:  # One way the publication record might be returned
            core = pub['coredata']
            keywords = pub.get('authkeywords', {})
            if keywords:
                keywords = keywords.get('author-keyword', [])
                s.Keywords = [k['$'] for k in keywords] if keywords else None
            else:
                s.Keywords = None
            s.Links = Munch({link['@rel']: link['@href'] for link in core.get('link', [])})
        else:  # An alternative format that might be returned
            core = pub
            keywords = core.get('authkeywords', "")
            s.Keywords = [k.strip() for k in keywords.split('|')] if keywords else None
            s.Links = Munch({link['@ref']: link['@href'] for link in core.get('link', [])})
        s.EID = core.get('eid', None)
        s.PMID = core.get('pubmed-id', None)
        s.DOI = core.get('prism:doi', None)
        s.PII = core.get('pii', None)
        s.Title = core.get('dc:title', None)
        s.Date = None  # Set in Child Object
        s.Source = PubSource(core)
        s.Authors = None
        s.Affiliations = None
        s.Citations = None
        s.CitedPubs = None
        s.IndexTerms = None
        abstract = core.get('dc:description', None)
        s.Abstract = abstract.strip() if include_abs and (abstract is not None) else None
        if include_raw: s.Raw = pub

    def get_cited_pubs(s, view='FULL', include_abs=True, include_raw=False, exclude=None):
        params = [view, include_abs, include_raw]
        if (not getattr(s, 'CitedParams', False)) or (params != s.CitedParams):
            s.CitedParams = params
            s.CitedPubs = {}
            citations = list(c.SID for c in getattr(s, 'Citations', []))
            if exclude:
                if isinstance(exclude, SortedSet):
                    citations = SortedSet(citations) - exclude
                    exclude = None
                elif isinstance(exclude, set):
                    citations = set(citations) - exclude
                    exclude = None
            if citations:
                Scopus = PubClient()
                for cite_id in citations:
                    if (not exclude) or (cite_id not in exclude):
                        pub = Scopus.get_publication(cite_id, include_abs=include_abs, include_raw=include_raw)
                        if pub and (pub.SID not in s.CitedPubs): s.CitedPubs[pub.SID] = pub
        return s.CitedPubs

    def get_log(s):  # This allows scripts accessing this client to reset the debug Log
        return Log

# Scopus Publication record (as opposed to Science Direct record) This builds upon the generic
# Publication base class, above.
class ScopusPublication(Publication):
    def __init__(s, pub, include_abs=False, include_raw=False):
        super(ScopusPublication, s).__init__(pub, include_abs=include_abs, include_raw=include_raw)
        if 'coredata' in pub:  # One way the data could be returned
            core = pub['coredata']
            authors = pub.get('authors', {})
            if authors: authors = authors.get('author', [])
            auth_id_label = '@auid'
            item = pub.get('item', None)
            if item:
                tail = item.get('bibrecord', {}).get('tail', None)
                if tail:
                    references = tail.get('bibliography', {}).get('reference', [])
                    if not isinstance(references, list): references = [references]
                    s.Citations = []
                    for ref in references:
                        s.Citations.append(Citation(ref))
            if 'idxterms' in pub:
                terms = pub['idxterms']
                if terms:
                    mainterms = pub['idxterms'].get('mainterm', [])
                    if mainterms:
                        if not isinstance(mainterms, list): mainterms = [mainterms]
                        s.IndexTerms = {}
                        for term in mainterms:
                            if not isinstance(term, dict): term = {'$': term, '@weight': 1}
                            s.IndexTerms[term['$']] = Munch({'Weight': term.get('@weight', 1)})
        else:  # An alternative way the data could be returned
            core = pub
            authors = pub.get('author', [])
            auth_id_label = 'authid'
        dc_id = core.get('dc:identifier', None)
        s.SID = dc_id.split(':')[1] if dc_id else None
        s.SrcID = core.get('source-id', None)
        s.ORCID = core.get('orcid', None)
        s.SubType = core.get('subtype', None)
        s.SubTypeDesc = core.get('subtypeDescription', None)
        s.Date = core.get('prism:coverDate', None)
        s.CitedByCount = core.get('citedby-count', None)
        s.Message = core.get('message', None)
        s.FunderName = core.get('fund-sponsor', None)
        subject_areas = {}
        areas = pub.get('subject-areas', {})
        if areas:
            for sa in areas.get('subject-area', []):
                subject_areas[sa['@code']] = {'Abbr': sa['@abbrev'], 'Name': sa['$']}
        s.Subjects = Munch(subject_areas)
        affs = pub.get('affiliation', [])
        if not isinstance(affs, list): affs = [affs]
        if affs:
            s.Affiliations = {}
            for aff in affs:
                aff_id = aff.get('afid', aff.get('@id', None))
                if aff_id and (aff_id not in s.Affiliations):
                    aff['scopus-id'] = aff_id
                    aff = Affiliation(aff)
                    s.Affiliations[aff.SID] = aff
        author_ids = []
        if authors:
            s.Authors = []
            for auth in authors:
                auth_id = format(auth[auth_id_label])
                if auth_id not in author_ids:
                    author_ids.append(auth_id)
                    s.Authors.append(Author(auth))

# Core API-calling client that accesses the requested API URL and retrieves data.
# Designed to support a multithreaded context
class APIClient:
    def __init__(s, url, headers, query, start=None, count=None, pid=None):
        s.url = url
        s.headers = headers
        s.query = query
        s.start = start
        s.count = count
        s.pid = pid  # Parent ID if being called from a pool

    def submit(s, start=None, count=None):
        result = None
        if start is not None: s.start = start
        if count is not None: s.count = count
        if (s.start is not None) and (s.count is not None):  # Sanity check; need both
            query = s.url + s.query.format(s.start, s.count)
            process = multiprocessing.current_process()  # Track which MP process we're in for logging
            if Throttle.ready():  # Check global throttle, wait until ready if rate is exceeded
                Log.write([  # Log query data if Debug is True
                    "S:{}".format(time.strftime("%I:%M:%S")),  # Submission Time
                    "Q:{}".format(len(Throttle.queue())),  # Query Submitted
                    "P:{}".format(s.pid),  # MP Process ID
                    "T:{}".format(process.ident), query  # MP Thread ID (under Process)
                ])
                try:
                    req = urllib.request.Request(url=query, headers=s.headers)
                    f = urllib.request.urlopen(req)
                    buffer = f.read().decode("utf-8")
                    data = json.loads(buffer)
                    Log.write(data)
                    result = Munch({  # Munch just creates a simple object so attributes can be accessed using dot notation
                        'Meta': Munch({
                            'Query': query,
                            'SearchTerms': "",
                            'TotalResults': 0,
                            'StartIndex': 0,
                            'ItemCount': 0
                        }),
                        'Items': []
                    })
                    if 'search-results' in data:  # Basic Scopus Search
                        meta = data['search-results']
                        result.Meta.SearchTerms = meta['opensearch:Query']['@searchTerms']
                        result.Meta.TotalResults = int(meta['opensearch:totalResults'])
                        result.Meta.StartIndex = int(meta['opensearch:startIndex'])
                        result.Meta.ItemCount = int(meta['opensearch:itemsPerPage'])
                        if result.Meta.ItemCount: result.Items = meta['entry']
                    elif 'abstracts-retrieval-response' in data:  # Abstract Retrieval API
                        result.Meta.TotalResults = 1
                        result.Meta.ItemCount = 1
                        result.Items = [data['abstracts-retrieval-response']]
                    elif 'author-retrieval-response' in data:  # Author Retrieval API
                        authors = data['author-retrieval-response']
                        if not isinstance(authors, list): authors = [authors]
                        result.Meta.TotalResults = len(authors)
                        result.Meta.ItemCount = result.Meta.TotalResults
                        result.Items = authors
                    elif 'affiliation-retrieval-response' in data:  # Affiliation Retrieval API
                        result.Meta.TotalResults = 1
                        result.Meta.ItemCount = 1
                        result.Items = [data['affiliation-retrieval-response']]
                    else: Log.write({'Query': query, 'Result': data})  # Unknown API return!
                except urllib.error.HTTPError as e:  # Log HTTP Error (e.g. Timeout) and continue
                    Log.write(e)
                except Exception as e:  # Raise other types of errors as more serious
                    Log.write(e)
                    raise
        return result

# Search results contain the data returned by Scopus, keep track of the metadata (# found, etc)
# And are aggregatable, so multiple searches can be collected into one. This supports MP
class SearchResult:
    def __init__(s, results=None):
        s.Meta = []
        s.Items = []
        s.StartIndex = 0
        s.TotalResults = 0
        s.ItemCount = 0
        s.Remaining = 0
        if results: s.add_results(results)

    def add_results(s, data):
        if not isinstance(data.Meta, list): metadata = [data.Meta]
        else: metadata = data.Meta
        for meta in metadata:
            s.Meta.append(meta)
            s.TotalResults = meta.TotalResults
            s.StartIndex = min(s.StartIndex, meta.StartIndex)
            s.ItemCount += meta.ItemCount
        s.Remaining = s.TotalResults - s.ItemCount
        s.Items.extend(data.Items)

# Elsevier Publication (Scopus) client
class PubClient:
    def __init__(s):
        s.url = "http://api.elsevier.com/content"
        s.headers = {
            'accept': 'application/json',
            'x-els-apikey': APIKey
        }

    # MP Pool client function to kick off an API search
    def submit_job(s, job):
        api = APIClient(s.url, s.headers, job['qry'], pid=job['pid'])
        data = api.submit(job['beg'], job['num'])
        return SearchResult(data)

    # Query submission - created a pool of MP threads that can kick off simultaneous searches,
    # splitting the query into blocks using the Start and Count parameters, allowing for
    # parallel processing of large queries (though this has been shown unreliable so far)
    def submit(s, search, count=None, max_count=25):
        if count is None: count = MaxReturnCount
        count = min(count, MaxReturnCount)
        pid = int((time.perf_counter() % 1) * 100000)
        # First, execute a single starting search
        results = SearchResult(APIClient(s.url, s.headers, search, 0, max_count, pid=pid).submit())
        # If anything is left to retrieve, split remainder into parallel MP threads/searches
        if results.Remaining:
            start = results.ItemCount
            count -= start
            count = min(count, results.Remaining)
            jobs = []
            while count > 0:
                this_batch = min(count, max_count)
                jobs.append({
                    'qry': search,
                    'beg': start,
                    'num': this_batch,
                    'pid': pid
                })
                count -= this_batch
                start += this_batch
            # Create an MP Pool of clients, and allocate search jobs
            with multiprocessing.Pool(min(len(jobs), MaxThreadCount)) as job_pool:
                pool_results = job_pool.map(s.submit_job, jobs)
            # This will contain the aggregated results from all job threads/searches, but they will
            # come back in arbitrary order. First have to sort them
            pool_results.sort(key=lambda r: r.StartIndex)
            for result in pool_results:
                results.add_results(result)  # Aggregate thread results into a master Result record
            if results.Remaining:  # Search didn't get everything it needed to - must have been an error
                Log.write("Error Encountered in Search: {}".format(search))
                Log.write(results)
                results = None
        return results

    # Basic Scopus search for publications.
    def search_scopus(s, query, count=None, view='COMPLETE', sort='-coverDate', include_abs=False, include_raw=False):
        max_count = 25 if view in ['COMPLETE', 'COMPONENT'] else MaxSearchCount
        query = urllib.parse.quote(query)
        search = "/search/scopus?view={}&sort={}".format(view, sort) + "&start={}&count={}&query=" + query
        pubs = []
        result = s.submit(search=search, count=count, max_count=max_count)
        if result:
            for raw_pub in result.Items:
                if 'error' not in raw_pub:
                    pubs.append(ScopusPublication(raw_pub, include_abs=include_abs, include_raw=include_raw))
        return pubs

    # Retrieve a specific list of publications, by ID (specifying ID type)
    def find_scopus_pubs(s, ids, id_type="doi", view='COMPLETE', start=0, count=None, sort='-coverDate', doctypes=None, include_abs=False, include_raw=False):
        if not isinstance(ids, list): ids = [ids]
        id_search = id_type + "({})"
        query = " or ".join([id_search.format(id) for id in ids])
        if doctypes:  # Use something like doctypes=['ar', 'cp'] to limit
            if isinstance(doctypes, str): doctypes = [doctypes]
            query += " and doctype({})".format(" or ".join([t for t in doctypes]))
        if count: count = min(len(ids), count)
        return s.search_scopus(query, count=count, view=view, sort=sort, include_abs=include_abs, include_raw=include_raw)

    # Retrieve all Pubications affiliated with a certain Author ID
    def find_author_pubs(s, auth_id, year=None, view='COMPLETE', start=0, count=None, sort='-coverDate', doctypes=None, include_abs=False, include_raw=False):
        query = "au-id({})".format(auth_id)
        if year: query += " and pubyear aft {}".format(year)
        if doctypes:  # Use something like doctypes=['ar', 'cp'] to limit
            if isinstance(doctypes, str): doctypes = [doctypes]
            query += " and ({})".format(" or ".join(["doctype({})".format(t) for t in doctypes]))
        return s.search_scopus(query, count=count, view=view, sort=sort, include_abs=include_abs, include_raw=include_raw)

    # Search for a specific author by name, and optionally including affiliations
    def search_author(s, first, last, affiliations=None, include_raw=False):
        if affiliations:
            affs = ["affil({})".format(a) for a in affiliations if (('(' not in a) and (')' not in a))]
            query = "(authfirst({}) and authlast({})) and ({})".format(first, last, " or ".join(affs))
        else:
            query = "authfirst({}) and authlast({})".format(first, last)
        query = urllib.parse.quote(query.replace(' ', '+'), safe='/+')
        search = "/search/author?query=" + query
        authors = []
        data = s.submit(search=search, max_count=200)
        for raw_auth in data.Items:
            raw_auth['scopus-id'] = raw_auth['dc:identifier'].split(':')[1]
            authors.append(Author(raw_auth, include_raw=include_raw))
        return authors

    # Retrieve a specific author record by Scopus ID
    def get_author(s, scopus_id, view='ENHANCED', include_raw=False):
        search = "/author/author_id/{}?view={}".format(scopus_id, view)
        authors = []
        result = s.submit(search=search)
        if result.ItemCount:
            if 'alias' in result.Items[0]:
                new_id = result.Items[0]['alias']['prism:url'].split(':')[2]
                return s.get_author(new_id, view=view, include_raw=include_raw)
            else:
                for raw_auth in result.Items:
                    author = Author(raw_auth, include_raw=include_raw)
                    authors.append(author)
        return authors

    # Retrieve a specific Affiliation record by Scopus ID
    def get_affiliation(s, scopus_id, view='STANDARD', include_raw=False):
        search = "/affiliation/affiliation_id/{}?view={}".format(scopus_id, view)
        aff = None
        result = s.submit(search=search)
        if result.ItemCount: aff = Affiliation(result.Items[0], include_raw=include_raw)
        return aff

    # Retrieve a specific Publicaton record by Scopus ID
    def get_publication(s, scopus_id, view='FULL', include_abs=True, include_raw=False):
        search = "/abstract/scopus_id/{}?view={}".format(scopus_id, view)
        pub = None
        result = s.submit(search=search)
        if result.ItemCount: pub = ScopusPublication(result.Items[0], include_abs=include_abs, include_raw=include_raw)
        return pub
