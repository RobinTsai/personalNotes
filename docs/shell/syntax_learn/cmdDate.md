```sh
#!/bin/bash

echo -e "\e[1;42mdate\e[0m Output now"

echo -e "\ndate"
date

echo -e "\nUTC: "
date +%s

echo -e "\nWeekday:"
date --date "Jan 20 2001" +%A

echo -e "\nFormat out:"
date "+%d %B %Y"

echo -e "\nSet local date time:(need sudo)"
date -s "16 December 2015 08:56:22" 2>/dev/null

echo -e "\nSee 'date --help'"
