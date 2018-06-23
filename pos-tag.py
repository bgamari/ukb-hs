#!/usr/bin/env python

import os
import sys
import nltk
from nltk.stem import WordNetLemmatizer
import json

data_dir = os.environ.get('POS_TAG_DATA_DIR')
if data_dir:
    nltk.data.path = [data_dir] + nltk.data.path

lemmatizer = WordNetLemmatizer()

while not sys.stdin.closed:
    line = sys.stdin.readline()
    if line == '':
        continue
    req = json.loads(line)
    text = nltk.word_tokenize(req['text'])
    tags = [ (lemmatizer.lemmatize(term), pos)
             for (term, pos) in nltk.pos_tag(text) ]
    json.dump(tags, sys.stdout)
    sys.stdout.write('\n')
    sys.stdout.flush()
