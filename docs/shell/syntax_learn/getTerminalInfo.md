```sh
#!/bin/bash

echo -e "\e[1;42mtput\e[0m Operation terminal"
echo "Get info"
tput cols         # width
tput lines        # height
tput longname     # terminal name

echo "Set"
tput cup 10 10  # Set cursor position
tput setb 0      # Set background color, value 0~7
tput setf 7      # Set foreground color
tput bold        # Set bold
tput smul        # Set underline start
echo "Now, see the color"
tput rmul        # Set underline end

echo "this will be deleted"
# tput ed          # Delete from the cursor to the line end
