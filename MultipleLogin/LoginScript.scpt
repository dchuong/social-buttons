tell application "Remote Desktop"
set theComputers to the selection
repeat with x in theComputers
set thescript to "osascript -e 'tell application \"System Events\"' -e 'keystroke \"user123\"' -e 'keystroke tab' -e 'delay 0.5' -e 'keystroke \"demo@123\"' -e 'delay 0.5' -e 'keystroke return' -e 'end tell'"
set thetask to make new send unix command task with properties {name:"Multiple Login", script:thescript, showing output:false, user:"root"}
execute thetask on x
end repeat
end tell