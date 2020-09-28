import os
import json
import treebank_library as tb

treefig_directory="rendered-trees"
tunes = tb.load_treebank('public'+"/" +'treebank.json')
treetunes = [x for x in tunes if x.get("trees") != None]

def hash_output_path(hsh):
  return "public/"+hash_html_path(hsh)

def hash_html_path(hsh):
  return treefig_directory+"/"+ hsh+".png"

def find_or_create_tree(t):
  qtree = tb.dict_to_qtree(t)
  hsh = hash(qtree)
  if(hsh < 0): # 2s complement
    hsh += 1<<64 # 64bit int
  hsh = hex(hsh)
  if(not os.path.exists(hash_output_path(hsh))):
    img = tb.plot_qtree(tb.latex_escape(qtree),resolution=200,print_log=False)
    with open(hash_output_path(hsh),"wb") as f:
      img.save(filename=hash_output_path(hsh))
  return hsh
      


if not os.path.exists("public/"+treefig_directory):
    os.mkdir("public/"+treefig_directory)

with open('public/tree-plots.md', 'w') as f:
  print("# Trees of the Jazz Harmony Treebank ", file=f)
  for tune in treetunes:
    print("## " + tune['title'],file=f)
    i = 0
    for t in tune['trees']:
      if(i > 0):
        print("### Alternate tree "+str(i),file=f)
      ohsh = find_or_create_tree(t['open_constituent_tree'])
      chsh = find_or_create_tree(t['complete_constituent_tree'])
      if(ohsh != chsh):
        print("#### Open constituent version",file=f)
        print("![](" + hash_html_path(ohsh)+")\n\n",file=f)
        print("#### Complete constituent version",file=f)
        print("![](" + hash_html_path(chsh)+")\n\n",file=f)
      else:
        print("![](" + hash_html_path(ohsh)+")\n\n",file=f)
      i+=1
     
