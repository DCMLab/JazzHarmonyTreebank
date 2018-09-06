# iReal Pro corpus

This repo contains the iRealPro chord sequences including tree annotations.

## Structure of the repo

| directory | content |
| - | - |
| iRb_v1-0 | the original data as downloaded from [there](http://musiccog.ohio-state.edu/home/index.php/iRb_Jazz_Corpus). |
| iRb_thru | original data as expanded by the humdrum `thru` command, using `expand_abbreviated_formats.jl`. |
| iReal_csv | expanded data converted to csv |
| iReal_trees | csv file and png picture of tree annotation |

## The code files

| file | purpose |
| - | - |
| `compile_tree_annotations.jl`| implements the function `compile_tree_annotations()` that returns the annotated trees and their chord sequences |
| `expand_abbreviated_formats.jl` | command line tool for converting original data into expanded data using the humdrum `thru` command |

## How to make and plot a tree analysis

1. Choose a song from the `iReal_csv` folder
1. Open the csv file in a spreadsheet application
1. Make your tree analysis
1. Export the analysis as csv
1. Move your analysis into the `iReal_trees` folder
1. Run this script from the Julia REPL:

```julia
using TikzQTrees
plot_jazz_tree(csv_file_name)
```
