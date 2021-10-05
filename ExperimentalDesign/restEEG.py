## VARIABLES ##
waitTime = 60.000 # 1 min
loops = 2 # amount of eyes opene eyes closed loops

# loop over the loops
for loop in loops:
    # show instruction to participant for a certain amount of seconds
    message = visual.TextStim(window, text="open uw ogen")
    message.draw()
    window.flip()
    core.wait(waitTime)
    # show instruction to participant for a certain amount of seconds
    message = visual.TextStim(window, text="sluit uw ogen")
    message.draw()
    window.flip()
    core.wait(waitTime) 