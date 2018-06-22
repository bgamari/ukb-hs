#!/usr/bin/env python

import sys
import nltk
from nltk.stem import WordNetLemmatizer
import json

lemmatizer = WordNetLemmatizer()

for line in sys.stdin:
    text = nltk.word_tokenize(line)
    tags = [ (lemmatizer.lemmatize(term), pos)
             for (term, pos) in nltk.pos_tag(text) ]
    json.dump(tags, sys.stdout)
    sys.stdout.write('\n')
    sys.stdout.flush()
