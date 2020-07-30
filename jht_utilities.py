import os
import tempfile
#from wand.image import Image
#import wand.display
from lark import Lark

# conversion between qtree and dict trees
# ---------------------------------------

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

def dict_to_qtree(d):
    if 'children' in d and d['children'] != []:
        return "[." + d['label'] + " " + "".join([dict_to_qtree(c) for c in d['children']]) + "] "
    else:
        return d['label'] + " "

# plotting
# --------
    
def latex_escape(string):
    return string\
    .replace('\\', '\\textbackslash')\
    .replace('&', '\&')\
    .replace('%', '\%')\
    .replace('$', '\$')\
    .replace('#', '\#')\
    .replace('_', '\_')\
    .replace('~', '\\textasciitilde')\
    .replace('^', '$^\\triangle$')

def plot_tex(tex_str, filename, print_log=False):
    latexdoc = '''
\\documentclass{standalone}
\\usepackage{tikz}
\\usepackage{tikz-qtree}
\\usepackage{amsmath}
\\begin{document}
%s
\\end{document}
'''%(tex_str)
    with tempfile.TemporaryDirectory() as d:
        texfile = d + "/main.tex"
        with open(texfile, "w") as f:
            f.write(latexdoc)
        command = 'pdflatex -output-directory=' + d + " " + texfile
        print(command)
        log = os.popen(command).read()
        if print_log:
            print(log)
        os.link(d + "/main.pdf", filename)
        
#        img = Image(filename = d + "/main.pdf", resolution=resolution)
#    return img

def plot_qtree(qtree_str, filename, print_log=False):
    tex_str = "\\begin{tikzpicture}\n\\Tree %s\n\\end{tikzpicture}"%(qtree_str)
    plot_tex(tex_str, filename, print_log=print_log)

def plot_dict(tree_dict, filename, print_log=False):
    plot_qtree(dict_to_qtree(tree_dict),filename,print_log=print_log)

# open constituents
# -----------------

def contains_open_constituents(tree):
    """Returns True iff tree contains any node marked as an open constituent."""
    if tree['label'][-1] == '*':
        return True
    else:
        return any(contains_open_constituents(c) for c in tree['children'])

def unfold_open_constituents(tree):
    """Returns the tree with all open constituents unfolded via branch exchange."""
    cs = tree['children']
    lb = tree['label']
    if len(cs) == 0:
        # leaf? just finish
        return tree
    elif cs[0]['label'][-1] == '*':
        # open constituent? exchange and recurse
        newleft = cs[0]['children'][0]
        newright = {'label': cs[1]['label'],
                    'children': [cs[0]['children'][1], cs[1]]}
        newnode = {'label': lb,
                   'children': [newleft, newright]}
        return unfold_open_constituents(newnode)
    else:
        # normal inner node? just go down
        return {'label': lb,
                'children': [unfold_open_constituents(c) for c in cs]}

# other
# -----

def leaf_labels(tree):
  if len(tree['children']) == 0:
    yield tree['label']
  else:
    for child in tree['children']:
      for label in leaf_labels(child):
        yield label
