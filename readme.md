# Jazz Harmony Treebank

This repository contains the **Jazz Harmony Treebank**, a corpus of
hierarchical harmonic analyses of jazz chord sequences selected from the
iRealPro corpus due to Shanahan et. al.

![](images/summertime.png?raw=true)

The treebank is available in the file `treebank.json`, structured as a
JSON with the following fields:

 * `title`: The title of the piece
 * `measures`: A monotonically increasing list of integers indicating the
    measures in the piece. Some measures appear more than once, indicating
    that more than one chord appears in it.
 * `beats`: A list of the beats where the chords appear. This list will be
    the same length as the `measures` list. There is at least a
    `1` item for each measure, denoting what chord is played on the
    downbeat. Additional entries are integers that indicate on what beat
    subsequent chords within the same measure start at. In a standard 4/4
    measure with two chords, the list could contain, for example `[1,3]` to
    indicate that the second chord comes in at beat 3.
 * `chords`: The list of chords. The length of this list will be the same
   as the `measures` and `beats` lists. Chords are strings composed of 
   * a fundamental (an uppercase letter A-G optionally with a `#` or `b` to
     indicate accidentals).
   * For minor chords a lowercase `m`, for augmented chords a `+`, for half and fully diminished chords a `%` and `o`, respectively, and for
     sus chords a `sus`. Chords with no extra text here are major.
   * An optional `6`, `7` or `^7` indicating an added sixth, minor, or
     major sevenths, respectively.
 * `turnaround`: An integer that indicates which chord in the sequence is
   the true final chord of the tune. If the number is `0`, then this
   coincides with the final chord of the `chords` list. A positive value of
   `2` indicates that the third last chord is the tonic, while the last two
   chords constitute a turnaround to bring the tune back to the beginning
   for repeated choruses. A negative number of `-2` indicates that the tune
   should be repeated and end on the second chord from the beginning of the
   `chords` list to end properly.
 * `trees` : A list of all the tree analyses for the piece. If this element
   exists, it contains at least one tree analysis. Each analysis is a JSON
   object consisting of of two elements: `open_constituent_tree` and 
   `complete_constituent_tree`. Both contain harmonic tree analyses of the
   full harmonic sequence, as ended at the chord indicated by the
   `turnaround`. The difference between the two trees is further described
   in the paper, but briefly constitutes whether or not the tree is a
   strict (`complete`) dependency structure, or whether some (`open`)
  constituents have multiple subconstituents all referring to some future
  chord. The trees are JSON objects recursively defined as having a `label`
  (which is a chord taken from the `chords` list), and a list `children` of
  either zero or two subtrees, which are themselves trees.
 * `comments`: A string containing any comments from the annotation
   procedure, for example noting alternate chord sequences from other
   sources, fixed transcription errors, ambiguities chord roles etc.
 * `composers`: A string with the name(s) of the composer(s) of the tune,
   as recorded in the iRealPro corpus.
 * `year`: An integer representation of the year (CE) the tune was
 * composed, according to the iRealPro corpus.
 * `meter`: A JSON object containing two integers, `numerator` and
   `denominator` indicating the meter of the piece.
 * `key`: The key of the piece, as annotated in the iRealPro corpus. This
   is an uppercase (for major keys) or lowercase (for minor keys) letter
   between a-g, possibly followed by a `-` to indicate a lowering
   accidental. 

## Utility library

We include a very basic set of utility functions for interacting with the
dataset in `jht_utilities.py`. In particular, it contains the following
functions:

 * `qtree_to_dict`: This converts a tree on [qtree](https://www.ctan.org/pkg/tikz-qtree) string form `[.A B [.C D E]]`
   to a Python dict on the format stored in the treebank, as in
   `{'label': 'A', 'children': [{'label': 'B', 'children': []}, {'label': 'C', 'children': [{'label': 'D', 'children': []}, {'label': 'E', 'children': []}]}]}`

 * `dict_to_qtree`: This function converts a tree on the treebank format
   back into a string on the above form.

 * `plot_qtree` and `plot_dict` both use `pdflatex` and `tikz` to generate
   pleasant visualisations of a single tree, and takes, in addition to the
   tree also a filename to which the tree should be written, and optionally 
   whether or not some basic escaping of LaTeX symbols should be applied to 
   the node labels.

 * For the following, we assume the tree to be in dict form, as given e.g.
   by loading the treebank using `json.load`.
 
 * `contains_open_constituents` traverses the tree to look
   for nodes marked as open constituents (see the paper for details)

 * `unfold_open_constituents` traverses the tree and transforms it to
   recover the encoded complete dependency structure, removing any open
   constituents on the way.
 
 * `leaf_labels` recovers the string of labels of the leaves of the tree
   (`[B, D, E]`) in the above example.



## Corpus statistics

Below are some general statistics about the corpus, as described in the
paper introducing the present dataset:


> The first plot shows that the analyzed pieces is chosen relatively independently from the year
of composition.  The second plot shows the bias for short pieces in
this subset.  The third plot shows that the length of turnarounds, if
present, usually ranges between 1 and 3.

> The two last plots show separately for major and minor keys how often a
context-free grammar rule is used in the hierarchical analyses.  For these
plots, all chord sequences were transposed to C major or to C minor,
respectively.  Prolongations of the tonic, preparations of the tonic by the
fifth scale degree, and preparations of the fifth scale degree by the
second are by far the most common rules. 


![](plots.png?raw=true)

## Tree figures

TODO: In the directory `tree-plots` we have plotted each analyses as a PDF
for easy visualization.

## Research

The treebank was initially published at ISMIR 2020, and if you use it for
your research, please reference the paper presenting it:

_D. Harasim, C. Finkensiep, P. Ericson, T. J. O'Donnell, and M.
Rohrmeier_. "The Jazz Harmony Treebank." In Proceedings of the 20th
International Society for Music Information Retrieval Conference (2020)

The iRealPro dataset that this research builds on was first presented in

_Daniel Shanahan, Yuri Broze, and Richard Rodgers_. "A Diachronic Analysis
of Harmonic Schemata in Jazz." In Proceedings of the  12th  International
Conference on Music Perception and Cognition and the 8th Triennial
Conference of the European Society for the Cognitive Sciences of Music,
pages 909–917, 2012.


## Acknowledgements

This project has received funding from the European Research Council
(ERC) under the European Union's Horizon 2020 research and innovation
program under grant agreement No 760081 – PMSB. We gratefully
acknowledge the support of the Natural Sciences and Engineering
Research Council of Canada (NSERC), the Fonds de Recherche du
Québec, Société et Culture (FRQSC), and the Canada CIFAR
AI Chairs program. We thank Claude Latour for supporting this research
through the Latour Chair in Digital Musicology. The authors
additionally thank the anonymous referees for their valuable comments
and the members of the Digital and Cognitive Musicology Lab (DCML) for
fruitful discussions.

![](images/erc-logo.jpg?raw=true)
![](images/eu-flag.png?raw=true)
![](images/epfl-logo.png?raw=true)
