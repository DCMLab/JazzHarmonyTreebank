# Jazz Harmony Treebank

This repository contains the **Jazz Harmony Treebank**, a corpus of
hierarchical harmonic analyses of jazz chord sequences selected from the
iRealPro corpus published on [zenodo](https://zenodo.org/record/3546040#.XyhT40mxV26) by Shanahan et al.

![](images/summertime.png?raw=true)

## Attribution 
If you use this data in any way, please cite the the following paper:

D. Harasim, C. Finkensiep, P. Ericson, T. J. O'Donnell, and M. Rohrmeier (2020). The Jazz Harmony Treebank. In *Proceedings of the 21th International Society for Music Information Retrieval Conference*. Montréal, Canada.

## Data format description

The treebank is available in the file `treebank.json`, structured as a
JSON with the following fields:

 * `title`: The title of the tune
 * `chords`: The list of chord symbols. The length of this list is the same
   as the lists of `measures` and `beats`. Chord symbols are strings composed of 
   * A root note (an uppercase letter from A to G with optional accidential `#` or `b`.
   * A basic chord form. For minor chords a lowercase `m`, for augmented chords a `+`, for half and fully diminished chords a `%` and `o`, respectively, and for
     suspended chords a `sus`. Major chords are denoted without a symbols for its basic chord form.
   * An optional `6`, `7` or `^7` indicating an added sixth, minor, or
     major seventh, respectively.
 * `measures`: A monotonically increasing list of integers that indicates the
    measures of the tune. Measures which appear more than once indicate
    that they comprise more than one chord symbol.
 * `beats`: A list of beats with chord onsets. There is always a
    `1` item for each measure, denoting the chord played on the measure's
    downbeat. Additional entries are integers that indicate the beats on which
    subsequent chords within the same measure start. For example in common time, 
    a measure with two chords on the beats 1 and 3 corresponds to the `beats` list `[1,3]`.
 * `turnaround`: An integer that indicates which chord in the sequence is
   the final tonic chord of the tune. If the number is `0`, then it is the
   final chord of the `chords` list. A positive value of
   `2` indicates that the third last chord is the tonic, while the last two
   chords constitute a turnaround to bring the tune back to the beginning
   for repeated choruses. A negative number of `-1` indicates that the tune
   should be repeated and end on the first chord from the beginning of the
   `chords` list to end with an appropriate tonic.
 * `trees` : A list of all the tree analyses for a tune. If this element
   exists, it contains at least one tree analysis. Each analysis is a JSON
   object consisting of of two elements: `open_constituent_tree` and 
   `complete_constituent_tree`. Both contain harmonic tree analyses of the
   full harmonic sequence, as ended at the chord indicated by the
   `turnaround` annotation. The difference between the two trees is further described
   in the correponding paper (see above). In short, the `open_constituent_tree` contains 
   phrase analyses additional to the harmonic reference of the `complete_constituent_tree`.
   Both trees are JSON objects recursively defined as having a `label`
  (which is a chord taken from the `chords` list), and a list `children` of
  either zero or two subtrees, which are themselves trees.
 * `comments`: A string containing comments from the annotation
   procedure, for example noting alternate chord sequences from other
   sources, fixed transcription errors, ambiguities, chord roles, etc.
 * `composers`: A string with the name(s) of the composer(s) of the tune,
   as recorded in the iRealPro corpus.
 * `year`: An integer representation of the year (CE) in which the tune was
   composed according to the iRealPro corpus.
 * `meter`: A JSON object containing two integers, `numerator` and
   `denominator` indicating the meter of the tune.
 * `key`: The key of the tune, as annotated in the iRealPro corpus. This
   is an uppercase (for major keys) or lowercase (for minor keys) letter
   between a-g, possibly followed by a `-` to indicate a lowering
   accidental. 

## Utility library

We include a basic set of utility functions for interacting with the
dataset in `jht_utilities.py`. In particular, it contains the following
functions:

 * `qtree_to_dict`: Convert a tree in [qtree](https://www.ctan.org/pkg/tikz-qtree) string form
   to a Python dict in the format of the treebank.
   For example, convert `[.A B [.C D E]]` into
   `{'label': 'A', 'children': [{'label': 'B', 'children': []}, {'label': 'C', 'children': [{'label': 'D', 'children': []}, {'label': 'E', 'children': []}]}]}`.

 * `dict_to_qtree`: Convert a tree in treebank format
   into a qtree string.

 * `plot_qtree` and `plot_dict`: Use `pdflatex` and `tikz` to generate a
   pleasant visualisations of a single tree. In addition to the
   tree, this function takes also a filename to which the tree should be written, 
   and optionally whether or not some basic escaping of LaTeX symbols should be applied to 
   the node labels.

 * For the following, we assume the tree to be in dict form, as given for example
   by loading the treebank using `json.load`.
 
 * `contains_open_constituents`: Traverse the tree to look
   for nodes marked as open constituents (see the paper cited above for details).

 * `unfold_open_constituents` Traverse the tree from the root to the leafs and transform it to
   obtain the pure harmonic reference structure. This function removes all open
   constituents.
 
 * `leaf_labels` Obtain the trees leaf labels as a string. 
   For instance `[B, D, E]` in the above example.

## Dataset statistics

Below are general summary statistics about the dataset as described in the corresponding paper:

> The first plot shows that the analyzed pieces is chosen relatively independently from the year
of composition.  The second plot shows the bias for short pieces in
this subset.  The [fourth] _(the third plot was omitted from the paper)_ plot shows that the length of turnarounds, if
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

## References

The iRealPro dataset that this research builds on was created by the user 
community of the [iRealPro app](https://irealpro.com/) and first presented scientifically in

Daniel Shanahan, Yuri Broze, and Richard Rodgers (2012). A Diachronic Analysis
of Harmonic Schemata in Jazz. In _Proceedings of the  12th  International
Conference on Music Perception and Cognition and the 8th Triennial
Conference of the European Society for the Cognitive Sciences of Music_,
pages 909–917.


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
