#!/bin/bash

cd $WORK_PATH

set -e
set -u

. "env_aws.sh"

LOG_FILE="$WORK_PATH/log/gen_table_list_$(date +"%F").log"
FILE_NAME="all_tables_list.csv"
S3PATH="$S3P/Migration/"
S3TXT=$S3PATH$FILE_NAME
S3TXT1=$S3TXT"000"

SQLFILE="gen_table_list.sql"

date > $LOG_FILE

echo "1...Generate table list from system table..." >> $LOG_FILE

psql -X -f $SQLFILE --echo-all --set AUTOCOMMIT=off --set ON_ERROR_STOP=on \
	--set AWS_KEY=\'$AWS_KEY\' --set AWS_SECRET=\'$AWS_SECRET\' \
	--set S3TXT=\'$S3TXT\'
	
echo "2...Rename from $S3TXT1 to $S3TXT...." >> $LOG_FILE
aws s3 mv "$S3TXT1" "$S3TXT"

echo "3...Copy from $S3PATH to $WORK_PATH...." >> $LOG_FILE
aws s3 cp "$S3TXT" "$WORK_PATH" 

date >> $LOG_FILE

echo "...Completed..." >> $LOG_FILE