import os
import json
from lark import Lark

qtree_parser = Lark(r"""
    innernode: "[." LABEL " "* (innernode | leaf)+ "]" " "*
    LABEL: /[^ \[\]]+/
    leaf: LABEL " "*

    """, start='innernode')

def qtree_to_dict(qtree_str):
    def larktree_to_dict(tree):
        label = tree.children[0]
        assert label.type == 'LABEL'
        if tree.data == 'innernode':
            children = [larktree_to_dict(child) for child in tree.children[1:]]
        else:
            assert tree.data == 'leaf'
            children = []
        return {'label': label.value, 'children': children}
    tree = qtree_parser.parse(qtree_str)
    return larktree_to_dict(tree)

with open('tree-annotation.json', 'r') as f:
    tunes = json.load(f)

for t in tunes:
    t['measures'] = list(map(int, t['measures'].split()))
    t['beats'] = list(map(int, t['beats'].split()))
    t['chords'] = t['chords'].split()
    if 'tree' in t:
        t['tree'] = qtree_to_dict(t['tree'])

if not os.path.exists("public"):
    os.mkdir("public")
with open("public/treebank.json", 'w') as f:
    json.dump(tunes, f, indent=2)