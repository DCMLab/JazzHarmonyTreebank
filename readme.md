# Jazz Harmony Treebank

This repo contains the iRealPro chord sequences including tree annotations.

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
 * `open_constituent_tree` and `complete_constituent_tree` both contain
   harmonic tree analyses of the full harmonic sequence, as ended at the
   chord indicated by the `turnaround`. The difference between the two
   trees is further described in the paper, but briefly constitutes whether
   or not the tree is a strict (`complete`) dependency structure, or
   whether some (`open`) constituents have multiple subconstituents all
   referring to some future chord. The trees are JSON objects recursively
   defined as having a `label` (which is a chord taken from the `chords`
   list), and a list `children` of either zero or two subtrees, which are
   themselves trees.
 * `comments`: A string containing any comments from the annotation
   procedure, for example noting alternate chord sequences from other
   sources, fixed transcription errors, ambiguities chord roles etc.
 * `composers`: A string with the name(s) of the composer(s) of the tune
 * `year`: An integer representation of the year (CE) the tune was composed
    ***(published?)***
 * `meter`: A JSON object containing two integers, `numerator` and
   `denominator` indicating the meter of the piece.
 * `key`: The key as annotated in the iRealPro corpus. (DO WE WANT TO KEEP
   THIS?). This is an uppercase (for major keys) or lowercase (for minor
     keys) letter between a-g, possibly followed by a `-` to indicate a
   lowering accidental.
 * `keys`: TODO: do we want to keep this? I don't know what it is.




## Research

The treebank was initially published at ISMIR 2020, and if you use it for
your research, please reference the paper presenting it:

"The Jazz Harmony Treebank" by _D. Harasim, C. Finkensiep, P. Ericson, M.
Rohrmeier_ in _Proceedings of the International Conference of Music
Information Retrieval 2020_, pp. x-y



## Acknowledgements

This project was conducted at the Latour Chair in Digital and Cognitive Musicology, generously funded by Mr Claude Latour.

This project has received funding from the European Research Council (ERC) under the European Union's Horizon 2020 research and innovation programme under grant agreement No 760081 – PMSB.

![](images/erc-logo.jpg?raw=true)
![](images/eu-flag.png?raw=true)
![](images/epfl-logo.png?raw=true)
