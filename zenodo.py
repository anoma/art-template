#! /usr/bin/env python3
# -*- coding: utf-8 -*-

# Standard library imports
import datetime as dt
import os
import pprint
import re
from typing import List, Dict
from urllib.parse import urlencode

# Related third-party imports
import pandas as pd
import requests
from bs4 import BeautifulSoup, Tag
from tabulate import tabulate


BASE_URL = "https://zenodo.org/api/"

ART_DOI =[
  "10.5281/zenodo.8268823",
  "10.5281/zenodo.8262747",
  "10.5281/zenodo.8297159",
  "10.5281/zenodo.8279842",
  "10.5281/zenodo.8262815",
  # "10.5281/zenodo.8321167",
]


class Record:
    def __init__(self, data, zenodo, base_url: str = BASE_URL) -> None:
        self.base_url = base_url
        self.data = data
        self._zenodo = zenodo

    def _row_to_version(self, row: Tag) -> Dict[str, str]:
        link = row.select("a")[0]
        linkrec = row.select("a")[0].attrs["href"]
        if not linkrec:
            raise KeyError("record not found in parsed HTML")

        texts = row.select("small")
        recmatch = re.match(r"/record/(\d*)", linkrec)
        if not recmatch:
            raise LookupError("record match not found in parsed HTML")

        recid = recmatch.group(1)

        return {
            "recid": recid,
            "name": link.text,
            "doi": texts[0].text,
            "date": texts[1].text,
            "original_version": self._zenodo.get_record(recid).original_version(),
        }

    def get_versions(self) -> list:
        url = f"{self.base_url}srecords?all_versions=1&size=100&q=conceptrecid:{self.data['conceptrecid']}"

        print(url)

        data = requests.get(url).json()

        return [Record(hit, self._zenodo) for hit in data["hits"]["hits"]]

    def get_versions_from_webpage(self) -> list:
        """Get version details from Zenodo webpage (it is not available in the REST api)"""
        res = requests.get("https://zenodo.org/record/" + self.data["conceptrecid"])
        soup = BeautifulSoup(res.text, "html.parser")
        version_rows = soup.select(".well.metadata > table.table tr")
        if len(version_rows) == 0:  # when only 1 version
            return [
                {
                    "recid": self.data["id"],
                    "name": "1",
                    "doi": self.data["doi"],
                    "date": self.data["created"],
                    "original_version": self.original_version(),
                }
            ]
        return [self._row_to_version(row) for row in version_rows if len(row.select("td")) > 1]

    def original_version(self):
        for identifier in self.data["metadata"]["related_identifiers"]:
            if identifier["relation"] == "isSupplementTo":
                return re.match(r".*/tree/(.*$)", identifier["identifier"]).group(1)
        return None
    
    def get_base_url(self):
        return self.data['base_url']

    def get_conceptdoi(self):
        return self.data['data']['conceptdoi']

    def get_conceptrecid(self):
        return self.data['data']['conceptrecid']

    def get_created(self):
        return self.data['data']['created']

    def get_doi(self):
        return self.data['data']['doi']

    def get_files(self):
        return self.data['data']['files']

    def get_id(self):
        return self.data['data']['id']

    def get_links(self):
        return self.data['data']['links']

    def get_metadata(self):
        return self.data['data']['metadata']

    def get_owners(self):
        return self.data['data']['owners']

    def get_revision(self):
        return self.data['data']['revision']

    def get_updated(self):
        return self.data['data']['updated']
    
    def get_stats(self):
        return self.data['stats']

    def get_authors(self):
        return ', '.join(list(map(lambda x: x['name'], self.data['metadata']['creators'])))
    
    def get_title(self):
        return self.data['metadata']['title']
    
    def get_date(self):
        return self.data['metadata']['publication_date']
    
    def get_doi(self):
        return self.data['doi']
        
    def get_info(self):
        # title autor date doi flat_stats
        info = {}
        info['title'] = self.get_title()
        info['authors'] = self.get_authors()
        info['date'] = self.get_date()
        info["downloads/unique"] = (self.data['stats']['version_downloads'] , self.data['stats']['version_unique_downloads'])
        info["views/unique"] = (self.data['stats']['version_views'] , self.data['stats']['version_unique_views'])
        info['doi/url'] = "[{}]({})".format(self.data['doi'], self.data['links']['html'])
        return info
        
    def __str__(self):
        return str(self.data)
    
    def __repr__(self):
        return str(self.data)
    
    def pprint(self):
        pprint.pprint(self.__repr__())

class Zenodo:
    def __init__(self, api_key: str = "", base_url: str = BASE_URL) -> None:
        self.base_url = base_url
        self._api_key = api_key
        self.re_github_repo = re.compile(r".*github.com/(.*?/.*?)[/$]")

    def search(self, search: str) -> List[Record]:
        """search Zenodo record for string `search`

        :param search: string to search
        :return: Record[] results
        """
        search = search.replace("/", " ")  # zenodo can't handle '/' in search query
        params = {"q": search}

        recs = self._get_records(params)

        if not recs:
            raise LookupError(f"No records found for search {search}")

        return recs

    def _extract_github_repo(self, identifier):
        matches = self.re_github_repo.match(identifier)

        if matches:
            return matches.group(1)

        raise LookupError(f"No records found with {identifier}")

    def find_record_by_github_repo(self, search: str):
        records = self.search(search)
        for record in records:
            if "metadata" not in record.data or "related_identifiers" not in record.data["metadata"]:
                continue

            for identifier in [identifier["identifier"] for identifier in record.data["metadata"]["related_identifiers"]]:
                repo = self._extract_github_repo(identifier)

                if repo and repo.upper() == search.upper():
                    return record

        raise LookupError(f"No records found in {search}")

    def find_record_by_doi(self, doi: str) -> Record:
        params = {"q": f"conceptdoi:{doi.replace('/', '*')}"}
        records = self._get_records(params)
        if len(records) > 0:
            return records[0]
        else:
            params = {"q": "doi:%s" % doi.replace("/", "*")}
            return self._get_records(params)[0]

    def get_record(self, recid: str) -> Record:

        url = self.base_url + "records/" + recid

        return Record(requests.get(url).json(), self)

    def _get_records(self, params: Dict[str, str]) -> List[Record]:
        url = self.base_url + "records?" + urlencode(params)

        return [Record(hit, self) for hit in requests.get(url).json()["hits"]["hits"]]


if __name__ == "__main__":
    if 'ZENODOTOKEN' in os.environ:
        ZENODOTOKEN = os.environ['ZENODOTOKEN']
    else:
        print("Warning: ZENODOTOKEN not found in environment variable. Using default token")

    zen = Zenodo(api_key = ZENODOTOKEN)


    ART_RECORD = list(map(lambda x : zen.find_record_by_doi(x), ART_DOI))

    df = pd.DataFrame(list(map(lambda x : x.get_info(), ART_RECORD)))
    df = df.reindex(columns=[
            'title',
            # 'authors',
            'views/unique',
            'downloads/unique',
            'date',
            'doi/url'
            ])
    df = df.sort_values(by=['downloads/unique'], ascending=False)
    # change column names by capitalizing the first letter
    df = df.rename(columns=lambda x: x.capitalize())

    mdTable = tabulate(df, headers='keys', tablefmt='pipe', showindex='never',
                       floatfmt='.2f', numalign='center', stralign='center')

    with open('ARTIndex.md', 'w') as f:
        f.write("# ART Index :seedling:\n\n")
        f.write("- Last update: " + dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
        f.write("- Order by downloads/unique\n\n")
        f.write(mdTable)