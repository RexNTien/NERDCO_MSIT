# NERDCO_MSIT

10/31/2025

Rex Tien

NERD CO

University of Colorado Anschutz Medical Campus


# Description

This repository contains a MATLAB app which administers the Multi-Source Interference Task. This version of the MSIT is intended to run during intraoperative recording through a Neuropixels probe during DBS surgery.

This implementation was developed specifically to run on our hardware at CUAnschutz, which is detailed below. However, it was developed in a modular fashion, so the task-running portion should be transferrable to other setups.

This code is designed to run the MSIT as described in the config files provided by Angelique Paulk at MGH. We have attempted to stay as close to the parameters provided as possible.
 - The stimuli blocks used to run this MSIT are located in "\NERDCO_MSIT\BlockFiles\" and titled _mg106_msit_block_01.csv_, _mg106_msit_block_02.csv_, etc.

### General Task Flow:
 - The number and identity of blocks is selectable. Blocks run sequentially, waiting for experimenter and subject keyboard input before advancing to the next block.
 - Task instructions, stimuli and fixation crosses are all shown using Psychtoolbox's DrawFormattedText function
 - Stimuli are shown for 1.75 seconds, responses are recorded during the stimulus show and through the next ISI, up to 0.05 seconds before the next stimulus show
 - The ISI value in the _.csv_ configuration file determines the time that the fixation cross is shown before each trial.
 - If the subject is holding down keys when it is time to show a stimulus, the experiment pauses until the keys are released, then re-displays the ISI fixation cross for that trial.
 - Instructions for the experimenter and feedback about trial performance are shown in the MATLAB command window
 - Trial performance and timestamp information are saved in _.txt_ file logs as they occur
 - Final _.mat_ data structure is saved at the end of the run.


# Requirements/Hardware

### Basic requirements (running task only):
 - MATLAB R2022b or later (tested and fully working on R2022b)
 - Psychtoolbox 3.0.19 or later (tested and fully working with Psychtoolbox 3.0.19)
 - Experimenter-facing monitor, mouse and keyboard
 - Subject-facing monitor and mini-keyboard (with 3 keys)
 
### CU Anschutz full hardware (automatic video and audio recording, TTL sync pulses):
 - Task Computer:
	- OS Name	Microsoft Windows 10 Enterprise LTSC 
	- Version	10.0.19044 Build 19044 
	- System Type	x64-based PC
	- BaseBoard Product	PRIME Z590-P
	- Processor	11th Gen Intel(R) Core(TM) i5-11600K @ 3.90GHz, 3912 Mhz, 6 Core(s), 12 Logical Processor(s)
	- Installed Physical Memory (RAM)	32.0 GB
	- Any computer mic (we have been using a standard line-in 3.5mm lavalier mic plugged into the mic input of the task computer).
 - TTL Sync Pulse from task computer to neural recording rig:
	- PCIe parallel port card (StarTech.com 2S1P Native PCI Express Parallel Serial Combo Card with 16550 UART - PCIe 2x Serial 1x Parallel RS232 Adapter Card , TAA (PEX2S5531P))
	- 3v3 to 5v TTL booster: SN74AHCT125N SN74 Quadruple Bus Buffer Gates with 3-State Outputs IC DIP-14
	- parPulse mex file and dlls
 - Camera control laptop:
	- Ubuntu 18.04 LTSC laptop with custom python software controlling
	- Connected to task computer via ethernet cable, controlled with UDP messages
	- Synchronizes and controls 3x Teledyne FLIR BFS-U3-16S2M-CS cameras
	- Cameras send a 5v TTL sync pulse on each frame capture to the neural recording rig
 - Neural recording rig (OpenEphys)


# File System

 - The MATLAB MSIT app must be run from the outer "\NERDCO_MSIT\" directory
 - The MSIT directory must contain the following subdirectories:
	- "\NERDCO_MSIT\@MSIT\" containing the app and its methods
	- "\NERDCO_MSIT\BlockFiles\" containing the configuration files describing the stimuli and timing information
	- IF using parPulse to send TTLs from task computer: "\NERDCO_MSIT\ParallelPortFiles\" containing libraries and mex file for parPulse


# Running the app - minimal version:

1. Open MATLAB
2. Navigate to "\NERDCO_MSIT\" as the working directory
3. Type ***MSIT*** in the command window, press enter, this brings up the GUI
4. Select the "Block Configuration Files" to use. All selected blocks will be presented in order.
5. For the minimal version (just running the task): un-check "Enable Cameras", "Enable Microphone", "Enable TTLs"
6. Ensure that the "Response Keys" under "Data I/O Settings" correspond to your left right and middle response keys.
7. Enter a "Patient ID" and file save location for saving the results
8. Press "Start Task" button
9. Press 'n' key to show instructions
10. Press 'a' 's' or 'd' key to begin the block
11. Press 'n' key to advance to the next block
12. Press 'a' 's' or 'd' key to begin the next block
13. Press 'w' key at any time to quit (except when listening for subject response during stimulus display)


# Description of outputs

Outputs save to the directory specified in the "Save File Location" field of the GUI, in a subfolder named the value in the "Patient ID" field of the GUI

If the task runs to completion, 3 outputs are always generated:
### 1. *PID_yyyy-mm-dd_hhH_MMm_SSs.mat*
The main _.mat_ file output. *PID* = Patient ID, *yyyy-mm-dd_hhH_MMm_SSs* = the date and time that the start button was pressed. Contains the following variables:
 - **FinishedTrials** - [1 x 1 struct] containing the information for all completed tirals. Contains fields:
	- **BlockXX** where **XX** is the Block number - [1 x 1 struct] containing the results from Block **XX**. Contains fields:
		- **NumTrialsPresented** - the number of trials completed in this block
		- **MissedTrials** - the number of missed trials (subject did not respond in time during the stimulus presentation)
		- **Accuracy** - the percentage of total trials shown where the subject gave a correct response in time
		- **Output** - [1 x 1 struct] containing the information for each trial in Block **XX**. Contains fields:
			- **StartTime** - the time (generated by Psychtoolbox ***GetSecs***) that the block began
			- **Trials** - [1 x nTrials struct array] containing the information for each trial. Each element contains fields:
				- **Trial** - the trial index
				- **Condition** - the task condition for the presented stimulus
				- **Conflict** - the type of conflict for the presented stimulus
				- **Stimulation** - whether electrical stimulation was administered (note: not used currently)
				- **Stimuli** - the MSIT number stimuli shown on this trial
				- **Correct** - the correct response for the presented stimulus
				- **ISI** - the time in seconds that the fixation cross was shown before the current stimulus was displayed
				- **ResponseKey** - the response given by the subject during the stimulus display (1, 2, or 3), (-1 if no response recorded)
				- **ResponseAccuracy** - whether the subject's response was correct (1) or incorrect (0), (-1 if no response recorded)
				- **ResponseUncertainty** - timing uncertainty in the keypress recorded time, as provided by Psychtoolbox KbCheck, (-1 if no response recorded)
				- **ReactionTime** - the time in seconds between when the stimulus was shown and when the keypress was recorded, (-1 if no response recorded)
 - **TaskSettings** - [1 x 1 struct] containing the important task settings, mostly set in the GUI
 - **TTLlog** - [1 x 1 struct] containing a log of important timestamps. Contains the following fields:
	- **NextrowNum** - an internal variable for building the TTLlog table
	- **TTLLength** - the duration in seconds of the TTL pulse
	- **StartTime** - the time (generated by Psychtoolbox ***GetSecs***) that the TTL log was initialized.
	- **TTLtable** - [nTTLs x 9 table] containing timestamps of important events, as well as TTL pulse information. Each table row contains the following fields:
		- **Event** - String describing the event that occurred.
		- **TTLTime** - timestamp of the event, (generated with Psychtoolbox ***GetSecs***, ***Screen('flip')*** or similar). This is the timestamp that should be used to align events post-hoc
		- **TimeStamp** - datetime timestamp of the event (note it is less accurate than TTLTime)
		- **TimeFromStart** - estimated time, in seconds, from the start of the TTLlog (note it is less accurate than TTLTime).
		- **BlockNum** - the block number during which the event occurred. (0 if during setup)
		- **TrialNum** - the trial number during which the event occurred. (0 if during setup)
		- **TTLEnabled** - whether the TTL voltage pulse generating device was enabled during this run
		- **GoodForAlignment** - whether this TTL should be used for alignment with neural data. Note, only TTLs that utilize ***GetSecs*** then immediately send a voltage pulse qualify as "good for alignment" (other TTLs, such as those which send at some unknown time after the ***Screen('flip')*** timestamp, are less accurate and should not be used for alignment)
		- **TTLActuallySent** - whether a voltage pulse was actually sent by the device. Can be false if two pulses are sent in too-fast succession. In that case the neural recording system would not record a pulse.
 - **AppProperties** - [1 x 1 struct], a record of the internal app variables
 - **AppSettings** - [1 x 1 struct], a record of the values of all of the fields in the GUI

### 2. *PID_yyyy-mm-dd_hhH_MMm_SSs_Trial_log.txt*
*PID* = Patient ID, *yyyy-mm-dd_hhH_MMm_SSs* = the date and time that the start button was pressed.
 - Space delimited, contains the same information as in **FinsihedTrials.BlockXX.Output.Trials** above, but is written live so that no data can be lost.
### 3. *PID_yyyy-mm-dd_hhH_MMm_SSs_TTL_log.txt*
*PID* = Patient ID, *yyyy-mm-dd_hhH_MMm_SSs* = the date and time that the start button was pressed.
 - Space delimited, contains the same information as in **TTLlog.TTLtable** above, but is written live so that no data can be lost.

### 4. Optional Files
If the "Enable Audio" checkbox was selected, audio files will also be generated for each block with the following naming scheme:
 - _PID_yyyy-mm-dd_hhH_MMm_SSs_BlockXX.wav_
	- *PID* = Patient ID, *yyyy-mm-dd_hhH_MMm_SSs* = the date and time that the start button was pressed, **XX** is the number of the block.
	- A separate .wav file is generated for each block.
 
If the "Enable Cameras" checkbox was selected, our system also saves a video file for each FLIR camera for each block, on the camera control laptop.
	

# Description of GUI

### Block Configuration Files
Which blocks to run and which _.csv_ config files to use
 - Check boxes allow you to choose which blocks to run. Must select at least one. Do not have to select sequential or first block (i.e. can select just Blocks Two and Four)
 - Edit fields in the center show which configuration file is used for each block.
 - "Choose File" buttons allow you to change which configuration file is used for each block.

### Display Settings
 - "Intro Text Size" - Font size used for displaying initial instructions and between-block instructions
 - "Stumulus Text Size" - Font size used for displaying the numbers of the MSIT stimuli and the fixation cross
 - "Response Time (s)" - Time that the MSIT stimuli are displayed for. It's also the time limit for subject to respond (subject must respond while numbers are visible).
 - "Do short block demo?" - When checked, this changes the _.csv_ files to "short" versions, which just have the first 4 trials of each block. Useful for training subjects and testing.
 - "Show task on screen" - Allows user to select which screen task is displayed on.

### Data I/O Settings
 - "Enable Cameras" - Enables automatic video recording. Currently requires our separate camera laptop connected via ethernet cable.
 - "Enable Microphone" - Enables automatic audio recording.
 - "Microphone" - Allows user to select which microphone to use for automatic audio recording.
 - "Enable TTLs" - Enables sending voltage pulses on key task events. Currently requires parallel port card and parPulse mex file and libraries.
 - "TTL Length (ms)" - Length of the TTL voltage pulse, in milliseconds.
 - "Parallel card address" - Hardware address of the parallel port card. Found in Windows in [System Information] - [Hardware Resources] - [I/O] - Generally the first address next to "PCIe to Multi Mode Parallel Port (LPT3)"
	- If this is wrong, and TTL is enabled, Windows will hard crash when you start the task.
 - "Response Key 1(left)" - The key that subject will press corresponding to "1", or the left-most key.
 - "Response Key 2(middle)" - The key that subject will press corresponding to "2", or the middle key.
 - "Response Key 3(right)" - The key that subject will press corresponding to "3", or the right-most key.
 - "Quit Key" - The key that experimenter can press to end the experiment early.
 - "Advance Block Key" - The key that the experimenter must press to start the first block or advance to the next block.
 
### File Settings
 - "Patient ID" - Unique identifier for the patient, becomes the prefix of the output files
 - "Save File Location" - The directory that output data files will be saved in. Can be changed with "Change File Location" button.
 
### Start Task
 - Starts the actual task running.
 

# Description of App/Functions/Methods

### MSIT.mlapp
 - MATLAB app providing GUI controls for running the MSIT task, runs setup functions and starts the MSIT_Main.m function to run the task

Note: Uses try-catch when calling MSIT_Main to try to save as much data as possible in the case of an error.

### Setup_MSIT.m
_Setup_MSIT(app, Process)_

Runs when app is started, when file locations change, and at start of ***MSIT_Main***. Performs the following functions based on the value of **Process**:
 - 'initialize' - Checks directory, sets default values, sets app properties, populates block file fields
 - 'OutputFileLoc' - Changes the output directory
 - 'BlockXFileButton' - Changes the block _.csv_ configuration file for Block X
 - 'inputs_outputs' - locks in keypress settings and output data structures and file settings
 
### Display_Controls.m
_Display_Controls(app, Process)_

Runs when app is started, at the start of ***MSIT_Main*** and at the end. Performs the following functions based on the value of **Process**:
 - 'find_screens' - Identifies available screens that task can be displayed on
 - 'initialize' - Opens and prepares the Psychtoolbox display
 - 'close' - Closes and clears the Psychtoolbox display

### Audio_Controls.m
_Audio_Controls(app, Process)_

Runs when app is started, when "Enable Audio" checkbox changes, at the start of ***MSIT_Main*** and at the end. Performs the following functions based on the value of **Process**:
 - 'setup' - Initializes Psych Sound, finds available microphones, populates drop-down menu
 - 'start' - Starts audio capture
 - 'stop' - Stops audio capture and saves .wav file

Note: if "Enable Audio" is un-checked, 'start' and 'stop' do nothing.

### Camera_Controls.m
_Camera_Controls(app, Process)_

Runs when app is started, when "Enable Audio" checkbox changes, at the start of ***MSIT_Main*** and at the end. Performs the following functions based on the value of **Process**:
 - 'start' - Starts video capture, with a short pause for alignment
 - 'stop' - Stops video capture, with a short pause for alignment

Note: if "Enable Cameras" is un-checked, 'start' and 'stop' do nothing.

Note: Different udp protocols depending on the MATLAB version. versions later than R2022b may not work correctly.

### Setup_Parallel_TTL.m
_Setup_Parallel_TTL(app, Process)_

Runs when app is started, when "Enable TTL" checkbox changes, and at the start of ***MSIT_Main***. Performs the following functions based on the value of **Process**:
 - 'toggle' - Enables the GUI fields and sets values.
 - 'initialize' - Opens connection with parallel port card, sends 5 initial TTL pulses in a train.

### MSIT_Main.m
_MSIT_Main(app)_

Runs when the "Start Task" button is pressed. Does the following:
 1. Performs setup, taking the values from the GUI to establish outputs (***Setup_MSIT***), sets some app properties
 2. Initializes the TTL (***Setup_Parallel_TTL***)
 3. Determines the blocks to run and their config files
 4. Initializes the Psychtoolbox display window (***Display_Controls***)
 5. Runs the blocks sequentially. For each block:
	1. Get block ID, wait for experimenter "advance" input (***MSIT_Wait_And_Advance_Or_Cancel***)
	2. Starts the audio (***Audio_Controls***)
	3. Starts the video (***Camera_Controls***)
	4. Creates the trials structure (***Build_Trial_Struct***)
	5. Writes instructions and waits for subject input to begin block (***MSIT_Show_Text***, ***MSIT_Wait_And_Advance_Or_Cancel***)
	6. Runs the trials of the block sequentially. For each trial:
		1. Display a trial (***MSIT_Run_Trial***)
		2. Store trial outcome in **FinishedTrials**
		3. Print trial outcome to live trial log
	7. Show block end text (***MSIT_Show_Text***)
	8. Stops the video (***Camera_Controls***)
	9. Stops the audio (***Audio_Controls***)
 6. Saves the outputs and closes everything (***Save_All***, ***Display_Controls***)

### MSIT_Wait_And_Advance_Or_Cancel.m
_MSIT_Wait_And_Advance_Or_Cancel(app, StartTime, WaitTime, Process)_

Called from ***MSIT_Main*** and ***MSIT_Run_Trial***. Performs the following functions based on the value of **Process**:
 - 'justwait' - Simply waits until current time is **WaitTime** after **StartTime**
 - 'escape' - Waits until current time is **WaitTime** after **StartTime**, while checking for exit command to quit
 - 'advance' - Waits indefinitely, while checking for exit command to quit, or block advance key to advance
 - 'blockstart' - Waits indefinitely, while checking for exit command to quit, or any of the 3 response keys to advance

### Build_Trial_Struct.m
_Build_Trial_Struct(app)_

Called from ***MSIT_Main*** at the start of each block
 - Reads in the trials information from the _.csv_ block configuration file and creates the trials structure with trial info and outcome fields.

### MSIT_Show_Text.m
_ShowTime = MSIT_Show_Text(app, text, isMain)_

Used to show instruction text on the Psychtoolbox display, fixation cross and stimuli
 - **text** - the text to display
 - **isMain** - 1 when showing fixation cross or stimulus, 0 when showing instructions
 - Returns the estimated timestamp that the text appeared on the screen, as provided by ***Screen('flip')***
 
### MSIT_Run_Trial.m
_MSIT_Run_Trial(app)]_

Called from ***MSIT_Main***, runs a single trial
 1. If it's the first trial of a block, shows the fixation cross, check for exit key (***MSIT_Wait_And_Advance_Or_Cancel***)
 2. Checks if keys are being held down before showing stimulus. If they are, show error message, and then show the fixation cross ISI again. This part loops until no keys are left down (***MSIT_Show_Text***, ***MSIT_Wait_And_Advance_Or_Cancel***)
 3. Displays the stimulus, checks for subject response and logs it (***MSIT_Wait_And_Get_Response***)
 4. Draws fixation cross for the next trial, continue to check for subject response and log it (***MSIT_Wait_And_Get_Response***)
 - If a response is given during 3 or 4, changes keyboard checking to just check for escape key (***MSIT_Wait_And_Advance_Or_Cancel***)
 - If it's the last trial of a block, waits out the last ISI again after stimulus presentation

### MSIT_Wait_And_Get_Response.m
_MSIT_Wait_And_Get_Response(app, StartTime, WaitTime)]_

Called from ***MSIT_Run_Trial***, listens for and saves subject response during stimulus display:
 1. Only checks response keys, for speed
 2. Checks if any response key is down
 3. Determines and stores which key was pressed, time of press, timing uncertainty, response accuracy, and reaction time

Note: Separate function from the other keyboard listening function in order to make it as fast as possible.

### Send_Log_TTL.m
_Send_Log_TTL(app, TTLTime, EventTxt, GoodAlign, WaitAfter)_

Sends and logs a TTL for important task events. Called from many different functions, immediately after important events.
 1. Sends the voltage pulse TTL as rapidly as possible if "TTL Enabled" was checked in the GUI
 2. Stores event information in the TTLlog (app data and live log)
 3. Waits a small amount of time if **WaitAfter** is true, to avoid the possibility of sending TTLs too close together, causing an error

Note: This function still logs events even if the voltage pulse TTL was not enabled or if a pulse was not sent due to too-rapid interfacing with the parallel card.

### Save_All.m
_Save_All(app)_

Builds data structures and saves the main _.mat_ output file
 1. Attempts to re-create **app** object without the problematic fields that make MATLAB unable to save it
 2. Separate and save data in the _.mat_ file