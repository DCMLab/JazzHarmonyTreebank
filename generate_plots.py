#!/bin/env python3
import json
import numpy as np
import matplotlib.pyplot as plt
import re
import collections
import math

# SETUP

#Globals
years = {}
lengths = {}
depths = []
turnarounds = {}
rules = []
rules_minor = []
rules_major = []

# Load the treebank
with open('public/treebank.json', 'r') as f:
    tunes = json.load(f)

# Tree utility functions
def treedepth(t):
    if(t['children'] == []):
        return 0
    else:
        return 1 + max(map(treedepth, t['children']))
    
def width_of_tree(t):
    if(t['children'] == []):
        return 1
    else:
        return sum(map(width_of_tree, t['children']))

# Key and chord utility functions
note_norm = {'A' : 9,'B' : 11,'C' : 0,'D' : 2,'E' : 4,'F' : 5,'G' : 7,'A#' : 10,'B#' : 0,'C#' : 1,'D#' : 3,'E#' : 5,'F#' : 6,'G#' : 8,'Ab' : 8,'Bb' : 10,'Cb' : 11,'Db' : 1,'Eb' : 3,'Fb' : 4,'Gb' : 6}
flats = {0 : 'C', 1 : 'Db', 2 : 'D', 3 : 'Eb', 4 : 'E',5 : 'F',6 : 'Gb',7 : 'G',8 : 'Ab',9 : 'A',10: 'Bb',11: 'B'}
sharps = {0 : 'C',1 : 'C#',2 : 'D',3 : 'D#',4 : 'E',5 : 'F',6 : 'F#',7 : 'G',8 : 'G#',9 : 'A',10: 'A#',11: 'B'}

# Normalising a chord to a specific tree
def key_normalize_chord(chord, key):
    regex = re.compile("([A-G][b#]?)([m]?)(.*)")
    
    (chord_pitch,chord_minor,chord_quality) = regex.match(chord).groups()
    (key_pitch,  key_minor,  key_quality  ) = regex.match(key).groups()
    
    chord_numeric_pitch = note_norm[chord_pitch]
    key_numeric_pitch   = note_norm[key_pitch]
    
    chord_normalized_numeric_pitch = (chord_numeric_pitch - key_numeric_pitch) % 12
    # We're using the flats for now
    return flats[chord_normalized_numeric_pitch] + chord_minor + chord_quality

def key_is_minor(key):
    regex = re.compile("([A-G][b#]?)([m]?)(.*)")
    (key_pitch,  key_minor,  key_quality  ) = regex.match(key).groups()
    return key_minor == 'm'

# The key of a tree is its rightmost leaf
def get_key(t):
    if(t['children'] == []):
        return t['label']
    else:
        return get_key((t['children'])[-1])
    
# Return all the rules used in a tree. Trees are at most binary
def get_rules(t,key):
    if(t['children'] == []):
        return []
    else:
        lefts = get_rules(t['children'][0],key)
        if len(t['children']) == 2 :
            rights = get_rules(t['children'][1],key)
            return [(key_normalize_chord(t['label'],key) , (
                                   key_normalize_chord(t['children'][0]['label'],key),
                                   key_normalize_chord(t['children'][1]['label'],key)
            ))] + lefts + rights
        else:
            return [(key_normalize_chord(t['label'],key) , (key_normalize_chord(t['children'][0]['label'],key)), key)] + lefts


# Loop over all tunes in the corpus
for t in tunes:
    # Extract histogram of tunes over years
    if (years.get(t['year']) == None):
        years[t['year']] = (1,0)
    else:
        (tot, withTree) = years[t['year']]
        years[t['year']] = (tot + 1, withTree)
    # And of the proportion of said tunes that have been analysed
    if (t.get('tree') != None):
        (tot,withTree) = years[t['year']]
        years[t['year']] = (tot, withTree + 1)
        
    # Extract a similar histogram of tunes over lengths of progressions
    # We omit tunes with over a hundred chords as none of these 42 tunes have been analysed
    if (len(t['chords']) < 100):
        if (lengths.get(len(t['chords'])) == None):
            lengths[len(t['chords'])] = (1,0)
        else:
            (tot, withTree) = lengths[len(t['chords'])]
            lengths[len(t['chords'])] = (tot + 1, withTree)
        if (t.get('tree') != None):
            (tot,withTree) = lengths[len(t['chords'])]
            lengths[len(t['chords'])] = (tot, withTree + 1)

    # Do minimal analysis on the trees
    if (t.get('tree') != None) and (len(t.get('chords')) < 40):
        # We check the depths and widths of the trees, and also record
        # In order, the tuples contain:
        # The length of the chord sequence
        # The width of the tree (which may be different thanks to turnarounds)
        # The depth of the tree divided by log(width)
        # The depth of the tree
        # The year of publication
        # The title
        # The tree itself
        tree = t['open_constituent_tree']
        depths.append((len(t.get('chords')),width_of_tree(tree),treedepth(tree)/math.log(width_of_tree(tree)),treedepth(tree),t.get('year'),t.get('title'),tree))
        # We extract all the rule applications in each tree, and make a common list, as well segregated by minor/major
        t_rules = get_rules(tree,get_key(tree))
        rules += t_rules
        if (key_is_minor(get_key(tree))):
            rules_minor += t_rules
        else:
            rules_major += t_rules

    # We also make a histogram of the turnaround lengths used        
    if (t.get('turnaround') != None):
        if(turnarounds.get(t['turnaround']) == None):
            turnarounds[t['turnaround']] = 1
        else:
            turnarounds[t['turnaround']] += 1

# We use counters to analyse the lists of rule applications
rule_counter = collections.Counter(rules)
most_common_rules = rule_counter.most_common(20)

rule_counter_minor = collections.Counter(rules_minor)
most_common_rules_minor = rule_counter_minor.most_common(20)

rule_counter_major = collections.Counter(rules_major)
most_common_rules_major = rule_counter_major.most_common(20)

#PLOTS
fig, (ax1, ax2, ax3, ax4, ax5, ax6) = plt.subplots(6,1,figsize=(8,30), gridspec_kw={'height_ratios': [1,1,1,0.7,1.5,1.5], 'hspace': 0.4})

darkgrey = '0.3'
lightgrey = '0.7'

# Plotting the coverage of tunes over years
indexyears = sorted(years.keys())
bar_width = 1

sortedyears = sorted(years.items())

totyears = ax1.bar(indexyears, list(map(lambda x: x[1][0], sortedyears)), bar_width,
color=darkgrey,
label='Total')

treeyears = ax1.bar(indexyears, list(map(lambda x: x[1][1], sortedyears)), bar_width,
color=lightgrey,
label='Analysed')


#Plotting the coverage of tunes over chord sequence lengths (omitting the 42 longest tunes)
indexlengths = sorted(lengths.keys())
bar_width = 1

sortedlengths = sorted(lengths.items())

totlengths = ax2.bar(indexlengths, list(map(lambda x: x[1][0], sortedlengths)), bar_width,
color=darkgrey,
label='Total')

treelengths = ax2.bar(indexlengths, list(map(lambda x: x[1][1], sortedlengths)), bar_width,
color=lightgrey,
label='Analysed')

# Plotting the widths and heights of analysed trees - We also draw the maximum and minimum possible depths assuming only binary rules used
ax3.plot(list(map(lambda x: x[1],depths)), list(map(lambda x: x[3], depths)), 'o', alpha=0.6, color=darkgrey)
widths_of_trees = (list(map(lambda x:x[1], depths)))
ax3_xvals = np.arange(1,40)
ax3.plot(ax3_xvals, ax3_xvals, darkgrey)
ax3.plot(ax3_xvals, list(map(math.log, ax3_xvals)), darkgrey)

# Plotting the various lengths of turnarounds used
ax4.bar(turnarounds.keys(),turnarounds.values(), bar_width, color=darkgrey)

# Showing the most common rules used
# rule_strings = list(reversed(list(map(lambda x : x[0][0] + " -> " + x[0][1][0] + " "+ x[0][1][1], most_common_rules))))
# counts = list(reversed(list(map(lambda x : x[1], most_common_rules))))
# y_pos = np.arange(len(rule_strings))
# bar_width=0.8

# ax5.barh(y_pos, counts, bar_width)

# ...in minor
rule_strings_minor = list(reversed(list(map(lambda x : x[0][0] + " -> " + x[0][1][0] + " "+ x[0][1][1], most_common_rules_minor))))
counts_minor = list(reversed(list(map(lambda x : x[1], most_common_rules_minor))))
y_pos_minor = np.arange(len(rule_strings_minor))
bar_width=0.8

ax5.barh(y_pos_minor, counts_minor, bar_width, color=darkgrey)

# ...and in major
rule_strings_major = list(reversed(list(map(lambda x : x[0][0] + " -> " + x[0][1][0] + " "+ x[0][1][1], most_common_rules_major))))
counts_major = list(reversed(list(map(lambda x : x[1], most_common_rules_major))))
y_pos_major = np.arange(len(rule_strings_major))
bar_width=0.8

ax6.barh(y_pos_major, counts_major, bar_width, color=darkgrey)


# Adding labels and titles
ax1.set_xlabel('year of composition', size='large')
ax1.set_ylabel('count', size='large')
ax1.set_title('Jazz standards by year', fontsize='x-large')
ax1.legend()

ax2.set_xlabel('chord sequence length', size='large')
ax2.set_ylabel('count', size='large')
ax2.set_title('Jazz standards by chord seq. length (> 100 chords omitted)', fontsize='x-large')
ax2.legend()

ax3.set_xlabel('chord sequence length', size='large')
ax3.set_ylabel('tree depth', size='large')
ax3.set_title('Depths of tree analyses by chord seq. length (lines show bounds)', fontsize='x-large')
# ax3.set_title('The maximum depths of tree analyses. We omit 4 tunes with width above 40\nThe lower and upper lines show the lower and upper bounds possible for depth at a specific length')

ax4.invert_xaxis()
ax4.set_xlabel('turnaround length', size='large')
ax4.set_ylabel('count', size='large')
ax4.set_title('Annotated turnaround lengths (pos. vals) & implicit tonics (neg. vals)', fontsize='x-large')

# ax5.set_yticks(y_pos)
# ax5.set_yticklabels(rule_strings)
# ax5.set_ylabel("Rules")
# ax5.set_xlabel("Count")
# ax5.set_title("Counts for the 20 most common key-normalized rules")

ax5.set_yticks(y_pos_minor)
ax5.set_yticklabels(rule_strings_minor)
# ax5.set_ylabel("Rules")
ax5.set_xlabel("count", size='large')
ax5.set_title("20 most frequent rules in minor (roots of keys normalized to C)", fontsize='x-large')

ax6.set_yticks(y_pos_major)
ax6.set_yticklabels(rule_strings_major)
# ax6.set_ylabel("Rules")
ax6.set_xlabel("count", size='large')
ax6.set_title("20 most frequent rules in major (roots of keys normalized to C)", fontsize='x-large')

plt.tight_layout()
plt.savefig("public/plots.png", bbox_inches='tight')
#plt.show()


