```sh
#!/bin/bash

echo -e "\e[1;42mstty\e[0m Hide, such as password input"
echo -e "Enter password:"
stty -echo        # Set hidden
read password     # Read the input and save into this variable
stty echo         # Set no hidden
echo
echo "What you input is $password"
