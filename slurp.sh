#!/bin/bash
if [ $# -le 2 ]; then
	echo "usage: slurp.sh <ACCESS_TOKEN> <URL> /path/to/dataset"
	exit 1;
fi

if [ ! -d "$3" ]; then
	echo "Directory $3 not found"
	exit 1;
fi

declare -i COUNTER=0
DIR=$3
if [ ${DIR:${#DIR}-1} = / ]; then
	DIR=${DIR%/} 
fi

OLDIFS=$IFS
IFS=$'\n'
labelarray=($(find $DIR/* -type d -maxdepth 0 | awk -F\/ '{print $NF}'))
IFS=$OLDIFS

for label in "${labelarray[@]}";
do
	if [ -z "$LABELS" ]; then
		LABELS="$label"
	else
		LABELS="$LABELS,$label"
	fi
done

declare -i LABELCOUNTER=0
declare -i EVEN=0

DATASET_RESULT=$(curl -f -s -H "Authorization: Bearer $1" -X POST -F "name=dataset-$(uuidgen)" -F "labels=$LABELS" -L $2/v1/vision/datasets)
if [ $? != 0 ]; then
	echo "Could not create dataset"
	exit
else
	DATASET_ID=$(echo $DATASET_RESULT | jq '.id')
	echo "Created dataset $DATASET_ID with labels:$LABELS"
fi

echo $DATASET_RESULT | jq '.labelSummary.labels[] | .name, .id' | sed 's/"//g' | while read i; do
	EVEN=LABELCOUNTER%2
	if [ $EVEN -eq 0 ]; then
		LABEL=$i
	else
		ID=$i
		find "$DIR/$LABEL" -type f | while read j ; do
			EXAMPLE_RESULT=$(curl -f -s -H "Authorization: Bearer $1" -X POST -F "name=example-$(uuidgen)" -F labelId=$ID -F "data=@$j" -L $2/v1/vision/datasets/$DATASET_ID/examples) 
			EXAMPLE_STATUS=$?
			if [ $EXAMPLE_STATUS != 0 ]; then
				echo "FAILED:$j:$EXAMPLE_STATUS"
			else
				EXAMPLE_ID=$(echo $EXAMPLE_RESULT | jq '.id')
				echo "SUCCESS:$j:$EXAMPLE_ID"
			fi
		done
	fi
	let LABELCOUNTER=LABELCOUNTER+1
done
