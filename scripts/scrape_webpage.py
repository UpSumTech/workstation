#!/usr/bin/env python2.7
import urllib2
import requests
import re
import sys
import json
from itertools import chain
from itertools import ifilterfalse as filterfalse

__doc__="""Scrape the webpage for information
Usage:
    scrape_webpage.py links --url=<url> --filter=<filter>
    scrape_webpage.py (-h | --help)

Options:
    -h --help           You are looking at this option right.
    --url=<url>         The url of the web page to scrape for links.
    --filter=<filter>   The type of the links you want to get [default: all].
"""
from docopt import docopt

scrapped_links = dict(js=[],
    css=[],
    img=[],
    xml=[],
    pdf=[],
    txt=[],
    json=[],
    csv=[],
    endpoints=[],
    relative=[])

def get_html(url):
    website = requests.get(url)
    return website.text

def categorize_link(link):
    if re.match(r'.*\.css$', link, flags=re.IGNORECASE):
        scrapped_links['css'].append(link)
    elif re.match(r'.*\.js$', link, flags=re.IGNORECASE):
        scrapped_links['js'].append(link)
    elif re.match(r'.*\.(jpe?g|png|gif|bmp|tiff|svg|ico)$', link, flags=re.IGNORECASE):
        scrapped_links['img'].append(link)
    elif re.match(r'.*\.xml$', link, flags=re.IGNORECASE):
        scrapped_links['xml'].append(link)
    elif re.match(r'.*\.txt$', link, flags=re.IGNORECASE):
        scrapped_links['txt'].append(link)
    elif re.match(r'.*\.pdf$', link, flags=re.IGNORECASE):
        scrapped_links['pdf'].append(link)
    elif re.match(r'.*\.json$', link, flags=re.IGNORECASE):
        scrapped_links['json'].append(link)
    elif re.match(r'.*\.csv$', link, flags=re.IGNORECASE):
        scrapped_links['csv'].append(link)
    elif re.match(r'^https?', link, flags=re.IGNORECASE):
        scrapped_links['endpoints'].append(link)
    else:
        scrapped_links['relative'].append(link)

def get_all_links(url):
    html = get_html(url)
    return filterfalse(
        lambda x: x == "",
        chain(
            list(map(lambda m:m[0], re.findall('"((http)s?://.*?)"', html, flags=re.IGNORECASE))),
            re.findall('href="(.*?)"', html, flags=re.IGNORECASE),
            re.findall('action="(.*?)"', html, flags=re.IGNORECASE)))

def main(args=None):
    if args['links']:
        for link in get_all_links(args['--url']):
            categorize_link(link)
        if args['--filter']:
            if args['--filter'] == 'all':
                ret_val = scrapped_links
            else:
                ret_val = scrapped_links[args['--filter']]
    print(json.dumps(ret_val))

if __name__ == '__main__':
    args = docopt(__doc__, argv=sys.argv[1:])
    main(args)
