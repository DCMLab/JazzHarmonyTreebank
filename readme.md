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
   * For minor chords a lowercase `m`, for augmented chords a `+`, and for
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

QTree string from JSON tree and vice versa

open -> complete constituent trees

yield function

tree-map

depth-first tree traversal

plot-tree (requires PDF-LaTeX)

## Corpus statistics

![](plots.png?raw=true)

## Tree figures

## Research

The treebank was initially published at ISMIR 2020, and if you use it for
your research, please reference the paper presenting it:

"The Jazz Harmony Treebank" by _D. Harasim, C. Finkensiep, P. Ericson, T. J. O'Donnell, and M. Rohrmeier_ in the _Proceedings of the 20th International Society for Music Information Retrieval Conference_ (2020)

The iRealPro dataset that this research builds on was first presented in

_Daniel Shanahan, Yuri Broze, and Richard Rodgers_. "A Diachronic Analysis
of Harmonic Schemata in Jazz." In Proceedings  of the  12th  International
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
