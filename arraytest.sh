#! /bin/bash
# testing array assignment and quoting.

declare -a arr=("one" "two" "and three" nakedFOUR)

for x in "${arr[@]}"
do
    echo "With quotes \"\$x\"" :"$x":
    echo "      no quotes \$x" :$x:
    echo "          curly braces \${x}" :${x}:
done
