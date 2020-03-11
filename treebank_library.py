import os
import tempfile
from wand.image import Image
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

def dict_to_qtree(d):
    if 'children' in d and d['children'] != []:
        return "[." + d['label'] + " " + "".join([dict_to_qtree(c) for c in d['children']]) + "] "
    else:
        return d['label'] + " "

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

def plot_qtree(qtree_str, resolution=300, print_log=False):
    latexdoc = '''
        \\documentclass{standalone}
        \\usepackage{tikz}
        \\usepackage{tikz-qtree}
        \\usepackage{amsmath}
        \\begin{document}
        \\begin{tikzpicture}
            \\Tree %s
        \\end{tikzpicture}
        \\end{document}
        '''%(qtree_str)
    with tempfile.TemporaryDirectory() as d:
        texfile = d + "/main.tex"
        with open(texfile, "w") as f:
            f.write(latexdoc)
        log = os.popen('pdflatex -output-directory=' + d + " " + texfile).read()
        if print_log:
            print(log)
        img = Image(filename = d + "/main.pdf", resolution=resolution)
    return img

def leaf_labels(tree):
  if len(tree['children']) == 0:
    yield tree['label']
  else:
    for child in tree['children']:
      for label in leaf_labels(child):
        yield label