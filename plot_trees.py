#%%
import json

with open('tree-annotation.json', 'r') as f:
    tunes = json.load(f)

# %%
from treebank_library import plot_qtree, latex_escape

img = None
for tune in tunes:
    if 'tree' in tune:
        img = plot_qtree(latex_escape(tune['tree']), resolution=200, print_log=False)
        display(tune['title'])
        display(img)

#%%
len([t for t in tunes if 'tree' in t])