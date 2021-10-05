#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
FamRecEEG task details

Encoding stimuli: 450 words
Encoding blocks: 2
Encoding stimulus time: 2 sec
Encoding fixation time: 1 sec
Encoding total duration: min 23.5 min
Retrieval stimuli: 900 words (450 old, 450 new)
Retrival blocks: 3
Retrieval stimulus time: 2 sec
Retrieval fixation time: 1 sec
Retrieval confidence judgement time: 1.5 sec
Retrieval total duration: min 69 min
"""

from psychopy import core, clock, visual, event, sound
import csv, random
import my # import my own functions
import pip
import os
from rusocsci import buttonbox
from psychopy import prefs
prefs.general['audioLib'] = ['pyo']
from psychopy import sound

## Setup Section
win = visual.Window([800,600], fullscr=True, monitor="testMonitor", units='cm')
#win = visual.Window([800,600], fullscr=False, monitor="testMonitor")
EEG = 0
if EEG == 1:
    bb = buttonbox.Buttonbox()

# read stimuli file
trials = my.getStimulusInputFile('inputfiles/enc.csv')
wordsColumn = 0     #number = trials[trialNumber][wordColumn]
jitterColumn = 1       #name = trials[trialNumber][jitterColumn]

# turn the text strings into stimuli
textStimuli = []
for trial in trials:
    # append this stimulus to the list of prepared stimuli
    textStimuli.append(visual.TextStim(win, text=trial[wordsColumn])) 
    #imageStimuli.append(visual.ImageStim(win=window, size=[0.5,0.5], image="image/"+row[0]))
    #soundStimuli.append(visual.ImageStim(win=window, size=[0.5,0.5], image="image/"+row[0]))

#fixation cross
fixation = visual.ShapeStim(win, 
    vertices=((0, -0.3), (0, 0.3), (0,0), (-0.3,0), (0.3, 0)),
    lineWidth=2,
    closeShape=False,
    lineColor='white'
)

# open data output file
ppn = my.getString(win, "Please enter participant number:")
gender = my.getString(win, "Please enter participant gender:")
age = my.getString(win, "Please enter participant age:")
datafile = my.openDataFile(ppn + "_enc")
datafileCSV = my.openCSVFile(ppn + "_enc")
libraryfile = my.openDataFile(ppn + "_enc" + "_library")
# connect it with a csv writer
writer = csv.writer(datafile, delimiter=";")
writerCSV = csv.writer(datafileCSV, delimiter=",")
tempwriter = csv.writer(libraryfile, delimiter=";")
# create output file header
writer.writerow([
    "ppn", 
    "gender",
    "age",
    "word", 
    "jitter", 
    "pleasure_key",  
    "pleasure_rt",
    "fixationTime", 
    ])
writerCSV.writerow([
    "ppn", 
    "gender",
    "age",
    "word", 
    "Encoding_Jitter", 
    "Encoding_Response",  
    "Encoding_RT",
    "fixationTime", 
    ])
tempwriter.writerow([__file__])
for pkg in pip.get_installed_distributions():
    tempwriter.writerow([pkg.key, pkg.version])

## RestEEG
my.restEEG(win,2,2)
 
 
 
## Experiment Section
# show welcome screen
my.introScreen(win, "U krijgt straks woorden te zien op het scherm. Vindt u het woord plezierig, drukt u op het pijltje naar links, vindt u het woord onplezierig, drukt u op het pijltje naar rechts. \n\nplezierig <--\nonplezierig -->")
startTime = clock.getTime() # clock is in seconds
i=0
while i < len(trials):
    if i == 0 and EEG == 1:
        print("start practice")
        bb.sendMarker(val=99)
        core.wait(0.001)
        bb.sendMarker(val=0)
    if i == 20:
        my.blankScreen(win)
        answer = my.getCharacter(win, "Dit is het einde van het oefenblok, wilt u nog een keer oefenen? [j/n]")
        if answer[0] == "j":
            i=0
        elif answer[0] == "n" and EEG == 1:
            bb.sendMarker(val=10)
            core.wait(0.001)
            bb.sendMarker(val=0)
            core.wait(1.000)
    if i == 245:
        if EEG == 1:
            bb.sendMarker(val=90)
            core.wait(0.001)
            bb.sendMarker(val=0)
        my.blankScreen(win, wait = 60.000, text = "Pauze!")
        my.getCharacter(win, "druk op een knop om door te gaan")
        if EEG == 1:
            bb.sendMarker(val=91)
            core.wait(0.001)
            bb.sendMarker(val=0)

    trial = trials[i]
    
    # present fixation
    fixation.draw()
    win.flip()
    if EEG == 1 and i>19:
        bb.sendMarker(val=40)
        core.wait(0.001)
        bb.sendMarker(val=0)
    fixationTime = clock.getTime()
    core.wait(0.993) # note how the real time will be very close to a multiple of the refresh time
    
    # present stimulus text and wait a maximum of jitter for a response
    textStimuli[i].draw()
    win.flip()
    if EEG == 1 and i>19:
        bb.sendMarker(val=20)
        core.wait(0.001)
        bb.sendMarker(val=0)
    textTime = clock.getTime()
    key = event.waitKeys(float(trial[jitterColumn]), keyList=['left', 'right','escape'])
    if key != None:
        responseTime = clock.getTime()
        if EEG == 1 and key[0] == 'left':
            marker = 33
        elif EEG == 1 and key[0] == 'right':
            marker = 35
    else:
        responseTime = textTime
        if EEG == 1:
            marker = 38
    if EEG == 1 and i>19:
        bb.sendMarker(val=marker)
        core.wait(0.001)
        bb.sendMarker(val=0)
    while clock.getTime() < (textTime + float(trial[jitterColumn])):
        pass


    print("{}, text: {},{}, key: {}, text: {}".format( i, trial[wordsColumn],trial[jitterColumn], key, responseTime - textTime) )
    
    # write result to data file
    if key==None:
        key=[]
        key.append("")

    writer.writerow([
        ppn,
        gender,
        age,
        trial[wordsColumn], 
        trial[jitterColumn], 
        key[0],
        "{:.3f}".format(responseTime - textTime),
        "{:.3f}".format(fixationTime - startTime), 
        ])
    writerCSV.writerow([
        ppn,
        gender,
        age,
        trial[wordsColumn], 
        trial[jitterColumn], 
        key[0],
        "{:.3f}".format(responseTime - textTime),
        "{:.3f}".format(fixationTime - startTime), 
        ])
    
    if key[0]=='escape' or c[0] == 'escape' :
        break
    i = i+1
datafile.close()
datafileCSV.close()

if EEG == 1:
    bb.sendMarker(val=13)
    core.wait(0.001)
    bb.sendMarker(val=0)
    

# show goodbye screen
my.showText(win, "Einde van het eerste deel")
core.wait(1.000)

## Closing Section
win.close()
core.quit()
