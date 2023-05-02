#!/bin/bash
# Get lorem ipsum string from https://en.ipsum.com
# Uses curl to fetch json and jq to parse json
#

if ! command -v curl &> /dev/null; then
	echo "Required program \"curl\" could not be found."
    	exit 1
fi

if ! command -v jq &> /dev/null; then
	echo "Required program \"jq\" could not be found."
	exit 1
fi

usage() { echo "Usage: $0 [-a <1-10>] [-w <paras|words|bytes|lists>]" 1>&2; exit 1; }

while getopts ":a:w:" o; do
    case "${o}" in
        a)
            a=${OPTARG}
	    re='^[0-9]+$'
	    if ! [[ $a =~ $re ]] || [ $a -eq "0" ] || [ $a -gt "10" ]; then
		    echo "Error: must be a number between 1 - 10."
		    usage
	    fi
            ;;
        w)
            w=${OPTARG}
	    re='^(para|word|byte|list)s$'
	    if ! [[ $w =~ $re ]]; then
		    echo "Error: invalid argument."
		    usage
	    fi
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

TEMPFILE="/tmp/loremipsum.json"
AMOUNT=${a:=4}
WHAT=${w:=paras}
FORMAT="json"
HOST="https://en.lipsum.com"
PATHNAME="/feed/$FORMAT"
COMMAND="Generate+Lorem+Ipsum"

if [ $FORMAT == "json" ]; then
	RESPONSE=$( curl -s -H "Keep-Alive: 60" -H "Connection: keep-alive" -H "Referer: $HOST" \
		-H "Content-Type: application/x-www-form-urlencoded" -d "amount=$AMOUNT&what=$WHAT&start=yes&generate=$COMMAND" \
		-X POST $HOST$PATHNAME | sed -Er s/\'/\"/g > $TEMPFILE )

	LIPSUM=$( cat $TEMPFILE | jq -r '.feed.lipsum' )
	echo -e "$LIPSUM"
	GENERATED=$( cat $TEMPFILE | jq -r '.feed.generated' )
	echo
	echo $GENERATED
	CREDITLINK=$( cat $TEMPFILE | jq -r '.feed.creditlink' )
	CREDITNAME=$( cat $TEMPFILE | jq -r '.feed.creditname' )
	echo "Credits: $CREDITLINK $CREDITNAME"
fi
