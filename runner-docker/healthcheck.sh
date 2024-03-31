set -e

name=${1}
wait=${2##s}
wait=${wait:-3}
sec="$(ps --no-headers -C $name -o etimes)"

if [[ ! -n $name ]]
then
    printf "%s" "$name is undefined, process name expected"
    exit 1
fi

if [[ ! -n $sec ]]
then
    printf "%s" "$name process is not found"
    exit 1
fi

if [[ $sec -lt $wait ]]
then
    printf "%s" "$name process is running less then $wait seconds"
    exit 1
fi
