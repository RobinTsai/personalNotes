```sh
#!/bin/bash

echo "1. Use set -x"
for i in {1..5}
do
  set -x  # 启动调试
  echo $i
  set +x  # 关闭调试
done
echo "Script executed"

echo -e "\n2. Use '_DEBUG=on ./shellFile' to run\n"

function DEBUG() {
  [ "$_DEBUG" == "on" ] && $@ || :
}

for i in {5..10}
do
  DEBUG echo $i
done

echo "3. use shebang '#!/bin/bash -xv'"
