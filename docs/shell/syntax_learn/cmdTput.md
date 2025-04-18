```sh
#!/bin/bash

echo -e "\e[1;42mtput\e[0m Operation terminal"
echo "Get info"
# attention define and use variable must not add space
WIDTH="$(tput cols)"         # width
HEIGHT="$(tput lines)"        # height
TERMINAL_NAME="$(tput longname)"     # terminal name
RED="$(tput setaf 1)"
YELLOW="$(tput setab 3)"
NORMAL="$(tput sgr0)"

echo "${RED}${YELLOW}Terminal width = ${WIDTH}, height = ${HEIGHT}, name = ${TERMINAL_NAME}${NORMAL}, recover to normal"

echo "Set"
tput cup 10 10   # Set cursor position
tput setb 2      # Set background color, value 0~7
tput setab 2     # Set background color, value 0~7, using ANSI escape
tput setf 7      # Set foreground color
tput setaf 7     # Set foreground color, using ANSI escape
tput bold        # Set bold
tput smul        # Set underline start
echo "Now, see the color"
tput rmul        # Set underline end

echo "this will be deleted"

echo ""
echo -e "\e[1;42mtput sc\e[0m Save the cursor position"
echo -e "\e[1;42mtput rc\e[0m Return the cursor to the saved position"
# tput ed          # Delete from the cursor to the line end
