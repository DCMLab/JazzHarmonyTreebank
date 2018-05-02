# iReal Pro corpus

This repo contains the iRealPro chord sequences including tree annotations and useful scripts.

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
| `Trees.jl` | tree data structures |
| `jazz_tree_tools.jl` | functions for converting csv annotations into trees |
| `plot_tree.jl` | command line tool for converting csv annotations into trees |
| `compiled_tree_data.jl` | command line tool for compiling tree annotations into one file of bracket terms |
| `expand_abbreviated_formats.jl` | command line tool for converting original data into expanded data using the humdrum `thru` command |

## How to make and plot a tree analysis

1. Choose a song from the `iReal_csv` folder
1. Open the csv file in a spreadsheet application
1. Make your tree analysis
1. Export the analysis as csv
1. Move your analysis into the `iReal_trees` folder
1. From this folder run `julia ../plot_tree.jl my_analysis.csv`
