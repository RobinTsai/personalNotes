```sh
#!/bin/bash

echo -n Time count:
tput sc

count=0
while [[ true ]]; do
  if [[ $count -lt 10 ]]; then
    let count++;
    sleep 1;
    tput rc;
    tput ed;
    echo -n $count
  else exit 0;
  fi
done
