import os
import json
import treebank_library as tb

#with open('tree-annotation.json', 'r') as f:
#    tunes = json.load(f)

def qtree_to_treepair(s):
    t = {}
    open_tree = tb.qtree_to_dict(s)
    t['open_constituent_tree'] = open_tree
    t['complete_constituent_tree'] = tb.unfold_open_constituents(open_tree)
    return t

tunes = tb.load_treebank('tree-annotation.json')

for t in tunes:
    t['measures'] = list(map(int, t['measures'].split()))
    t['beats'] = list(map(int, t['beats'].split()))
    t['chords'] = t['chords'].split()
    (num, denom) = t['meter'].split('/')
    t['meter'] = {'numerator': int(num), 'denominator': int(denom)}
    if 'tree' in t:
        open_tree = tb.qtree_to_dict(t['tree'])
        t['open_constituent_tree'] = open_tree
        t['complete_constituent_tree'] = tb.unfold_open_constituents(open_tree)

if not os.path.exists("public"):
    os.mkdir("public")
with open("public/treebank.json", 'w') as f:
    json.dump(tunes, f, indent=2)
