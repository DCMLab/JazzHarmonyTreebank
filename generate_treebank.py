import os
import json
from treebank_library import qtree_to_dict

with open('tree-annotation.json', 'r') as f:
    tunes = json.load(f)

for t in tunes:
    t['measures'] = list(map(int, t['measures'].split()))
    t['beats'] = list(map(int, t['beats'].split()))
    t['chords'] = t['chords'].split()
    (num, denom) = t['meter'].split('/')
    t['meter'] = {'numerator': int(num), 'denominator': int(denom)}
    if 'tree' in t:
        t['tree'] = qtree_to_dict(t['tree'])

if not os.path.exists("public"):
    os.mkdir("public")
with open("public/treebank.json", 'w') as f:
    json.dump(tunes, f, indent=2)