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
for i in $(ls $DIR); do
	if [ $COUNTER -eq 0 ]; then
		LABELS=$i
	else
		LABELS=$LABELS,$i
	fi
	let COUNTER=COUNTER+1
done

declare -i LABELCOUNTER=0
declare -i EVEN=0
DATASET_RESULT=( $(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $1" -X POST -F "name=dataset-$(uuidgen)" -F labels=$LABELS -L $2/v1/vision/datasets | sed 's/ /_/g') )

if [ ${DATASET_RESULT[1]} != 200 ]; then
	echo "Could not create dataset: ${DATASET_RESULT[0]}"
	exit
else
	DATASET_ID=$(echo ${DATASET_RESULT[0]} | jq '.id')
	echo "Created dataset $DATASET_ID with labels:$LABELS"
fi


for i in $(echo ${DATASET_RESULT[0]} | jq '.labelSummary.labels[] | .name, .id' | sed 's/"//g'); do
	EVEN=LABELCOUNTER%2
	if [ $EVEN -eq 0 ]; then
		LABEL=$i
	else
		ID=$i
		for j in $(ls $DIR/$LABEL); do
			EXAMPLE_RESULT=( $(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $1" -X POST -F "name=example-$(uuidgen)" -F labelId=$ID -F "data=@$DIR/$LABEL/$j" -L $2/v1/vision/datasets/$DATASET_ID/examples | sed 's/ /_/g') )
			if [ ${EXAMPLE_RESULT[1]} != 200 ]; then
				echo "FAILED:$DIR/$LABEL/$j:${EXAMPLE_RESULT[0]}"
			else
				EXAMPLE_ID=$(echo ${EXAMPLE_RESULT[0]} | jq '.id')
				echo "SUCCESS:$DIR/$LABEL/$j:$EXAMPLE_ID"
			fi
		done
	fi
	let LABELCOUNTER=LABELCOUNTER+1
done
