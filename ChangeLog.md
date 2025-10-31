MSIT changes 10/31/2025
 - Further testing and bugfixes
 - Further documentation
 - Reset app defaults

MSIT changes 10/30/2025
 - Wrote README.md file
 - Removed ProcessNum section from Send_Log_TTL.m
 - Fixed several bugs in TTL sending and Audio
 - Fixed names of GridLayouts / Labels so they save correctly
 - Fixed MicrophoneHandle reading 

MSIT changes 10/29/2025
 - Added ReactionTime in trial struct field and calculation
 - Added check for keys being held down before advancing to show stimulus
 - Shortened TTL pulse duration
 - Added try-catch architecture in TTL log to catch error of colliding TTL sends
 - Changed log messages for TTL log to simplify the code and get rid of number codes
 - Added a field in the TTL log to identify when a TTL was actually sent or was missed because of collision
 - Removed kb checking for final trial ISI
 - Added microphone handle as an app property to aid in starting / stopping / saving audio
 - Added AudioControls.m to control the audio instead of writing it in straight
 - Changed CameraControls, AudioControls, ParallelTTLSetup, Setup_MSIT to use a string input instead of number for additional clarity
 - Changed function names for clarity
  - MSIT_TTLlog.m -> Send_Log_TTL.m
  - BuildTrialStruct.m -> Build_Trial_Struct.m
  - CameraControls.m -> Camera_Controls.m
  - FindAvailableScreens.m -> Find_Available_Screens.m
  - AudioControls.m -> Audio_Controls.m
  - MSIT_Run.m -> MSIT_Run_Trial.m
  - MSIT_StartUp.m -> MSIT_Main.m
  - ParallelTTLsetup.m -> Setup_Parallel_TTL.m
  - SetupParameters.m -> Setup_MSIT.m
  - ShowText.m -> Show_Text.m
  - Run_Fixation.m -> Show_Fixation.m
  - SaveAll.m -> Save_All.m
 - Changed Camera and Audio controls to include their setup functions, removed SetupAudio.m
 - Created Display_Controls.m which encompasses Find_Available_Screens.m and Initialize_PTB.m
 - Changed Setup_MSIT to include all file picking functions and setup the output files
 - Added display of current block and trial numbers, and performance.
 - separated MSIT_Wait_And_Get_Response.m and MSIT_Wait_And_Advance_Or_Cancel.m to speed up response loggging
 - Got rid of Show_Fixation because it's redundant with Show_Text, since Fixation is just text

MSIT changes 10/20/2025

 - Spruced up the GUI
 - Added audio recording items in GUI
 - Added microphone choice functionality
 - Added start / stop audio recording in MSIT_StartUp
 - Fixed ScreenUsedNum.Items bug when only 1 screen (expected a cell array)
 - Added many comments

MSIT changes 7/21/2025 - Rex from Equipment room on cart

 - Hooked up mini keyboard, seems good
 - removed key cap from fourth key of mini keyboard
 - Fixed camera controls non-2022 case 2 to have ip address so it can do end pause and stop
 - Changed exit key back to 'w' from 'esc' so that minikeyboard can't exit you
 - Added live logging of TTLs and Task in txt files
 - Added some reminders next to the start button


MSIT changes 7/21/2025 - Rex from build room

 - Added button for "Do short block demo?" this will run the short blocks (4 trials each) to show the subject what the actual task will be like.
 - Changed instructions to directly match what was provided
 - Increased default font size
 - Made default 2 blocks
 - Made it so patient id folder is created to save in, not just in PatientData.


MSIT changes 7/18/2025 - Rex from home

Major conceptual changes:
 - Changed so that MSIT_TTLlog sends the TTL and records info in the table, all in one function, so we don't have to do separate parPulse and then log.
 - Changed so that TTL log table is created even if TTL is not enabled, so that times still get logged without having to actually send a TTL
 - Added lots of comments
 - Removed anything related to stim, triggers, hex values
 - Overhauled fixation showing and response checking
 - Replaced "MSITapp" with "app" everywhere for ease of use
 - Added functionality for blocks 3 and 4
 - Changed saving so that it just saves everything in one big happy .mat file
 - Made blocks more continuous by not shutting down and restarting PTB every time
 - Moved PTB variables / settings to TaskSettings from TrialStruct

GUI
 - Added field and label for "Response Time (s)" - replacing "maxTime" in the code
 - Added field and label for "TTL Length (ms)" - the length of the TTL. Just in case Denman's system can't register a 1ms pulse.
 - Set Block One and Block Two to enabled by default
 - Fixed font colors being too light to see
 - Added Blocks 3 and 4
 - Changed title
 - Added default prefix for patient ID

MSIT.mlapp
 - Changed the function definition of MSIT_TTLlog, removed TriggerCode
 - Changed the function definition of ParallelTTLsetup, removed TriggerCode, TTLnum
 - Added MSIT_TTLlog(app,0); to the startupFcn so that TTLtable always gets created
 - Changed so that Enable Cameras is checked by default
 - Changed so that EnableTTLs is checked by default
 - ParallelTTLsetup runs on startupFcn now
 - Got rid of PatientID Callback Fcn, now it runs at the top of MSIT_StartUp, to capture the patient ID and datetime right when you press start. This lets you run multiple times without closing, because a new save file name is created each time you press start.
 - Added ExitFlag
 - Added TrialStruct as an app property to reduce separate sends/returns and to facilitate saving in case of a crash

SetupParameters.m
 - Added default values for the save location and blocks
 - Added vector MSITapp.TaskSettings.BlocksToDo to hold which blocks are being done
 - Moved the TTLlog creation to here so it always happens, and MSIT_TTLlog is faster
 - Changed the TTLtable definition - removed HexNum and added TTLTime and IsRealTTL
 - Pre-populates Block One and Block Two files

PickingFile.m
 - Streamlined to programmatically assign things to blocks

SetPatientID.m
 - Added seconds to the timestamp in PatientID

MSIT_TTLlog.m
 - Changed the function definition, removed TriggerCode, added TTLTime, TrialNum
 - Changed up the EventTexts to reflect the different events
 - Added parPulse call so that this function now sends a TTL and then logs it
 - Changed the way the next row of the table is created - just using a cell array because it's faster
 - Added trial number to the table

ParallelTTLsetup.m
 - Changed the function definition, removed TriggerCode, TTLnum
 - Remove MSIT_TTLlog call from case 0, since now it gets called in startupFcn
 - Added functionality in UseTTL to be able to turn off the TTL after you've turned it on
 - Added TTL Length field to this functionality
 - Case 2 now optionally initializes the parallel card, then sends and logs 5 TTLs
 - Got rid of case 3, now to send a TTL just call MSIT_TTLlog directly

MSIT_StartUp.m
 - Removed Trigger parameters and triggercode
 - Removed creation of MSITapp.FinishedTrials.Tiggers
 - Changed escape key to 'esc' instead of 'w', so subject doesn't have access to it
 - Uncommented 'HideCursor()' after opening the window
 - Added keymatchVector getting
 - Changed currentTrial to MSITapp.TaskSettings.currentTrial
 - Removed the try catch from MSIT_Run in favor of ExitFlag
 - Made fixation showing more timely
 - Changed how FinishedTrials saves - it gets populated, and trial info added as the task goes now.
 - PTB doesn't shut down between every block now
 
 PredrawStimuli.m
 - RENAMED TO "Initialize_PTB.m" to clear up confusion
 - got rid of all the image texture related stuff
 
 MSIT_Run.m
 - Changed the function definition, to add keymatchVector (a faster way to detect valid key press than 'find')
 - Put Fixation show code directly in there
 - Put escape key polling during fixation, and real-time wait
 - Put Response code directly in there
 - Changed keyboard key checking to be faster, so the TTL is closer to the keypress
 - Changed Escape key behavior, now instead of throwing an error to exit, it just flips a flag, then everything can be saved before exiting
 - Made fixation timing more timely by always showing the next fixation right on time
 
Run_Fixation.m
 - Changed a lot, now it just shows the fixation cross quickly
 
ResponseCue.m
 - REPLACED THIS FUNCTION WITH ONE CALLED 'Wait_And_Check_Response.m'
 - Changed a lot
 - Made it faster and snappier with keyboard checking
 - Changed Escape key behavior, now instead of throwing an error to exit, it just flips a flag, then everything can be saved before exiting
 - Now has two modes: just checking for escape key, or doing full checking and logging
 
SendTrigger.m
 - Removed completely
 
ADDED NEW FUNCTION: SaveAll.m
 - Tries to save as much as possible from the entire app contents

ADDED NEW FUNCTION: ShowText.m
 - Just streamlines showing some text on the screen

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

MSIT changes 4/16/2025 - Rex - Build Room

MSIT.mlapp
1. Added default Parallel card address (4FE8) - but check on cart computer before running!
2. Made Parallel card address field editable
3. Added properties: "udpObj" and "UDPnull"

ParallelTTLSetup.m
1. Made Parallel card address field populate only if it is blank when the checkbox is clicked
2. In [case 2], put code at the end to send a rapid train of 5 TTLs to indicate the start

MSIT_TTLlog.m
1. Changed the first message in TTLlog from 'Task Started' to 'TTL Enabled'
2. Added "case 11" Eventtxt = "Start TTL train"

CameraControls.m
1. As far as I could tell, camera UDP object never gets created. Added the camera UDP creation code from PRT task in [case 1]

MSIT_StartUp.m
1. Changed output filename generation to automatically create 2 digit number after "Block"
2. Removed comment line 59 (% Setting up TTL and Cameras) since it already happened
3. Changed start text instructions to be more like those provided in STIMULI
