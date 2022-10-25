#!/bin/sh

# Test the HTTP response code of all absolute paths in a given list
# Specify your parent domain in the $SITE variable below
# 
# Usage: 
# 
#   bash testUrls.sh mylist.txt
# 
# mylist.txt contents (assumes absolute URLs only): 
# 
#   /some/path/
#   /another/path
#   etc
# 
# You can optionally save the results like this; 
# 
#   bash testUrls.sh mylist.txt > report.log

# @TODO
#  - If wget encounters a permanent redirect, it returns '302 200'. Need to extract only the last hit or reattempt with curl...
#  - Unencoded spaces in URLs can throw false positives, like 'parksaustralia.gv.au/ kakadu' as 
#    everything after the space is treated as a second argument


SITE='https://parksaustralia.gov.au'
RESULTS=$1'-live.csv'

# Empty results if the file already exists
if [[ -f $RESULTS ]]; then
    echo '' > $RESULTS;
else
    touch $RESULTS
fi

# Quit if no file is provided
if [[ $# -eq 0 ]] ; then
    exit 1
else
	while read LINE; do
    
        # Check if URLs are absolute, append site domain if yes for wget
        if [[ ${LINE::1} == '/' ]]; then
            FULLPATH=${SITE}$LINE
        else
            FULLPATH=$LINE
        fi

        # We can use curl, but it requests the entire page and is very slow
        # curl -o /dev/null -I --silent --head --write-out "$LINE,%{http_code}\n" "$FULLPATH"
        
        # So let's use wget's spider mode, which only retrieves the response header in a fraction of the time
        RESPONSE=$(wget -Sq --no-check-certificate --spider $FULLPATH 2>&1 | egrep 'HTTP/1.1 ' | cut -d ' ' -f 4)
        # https://stackoverflow.com/questions/20553166/shell-syntax-error-in-expression-error-token-is-0#20553239
        if [[ $RESPONSE != 40* ]] && [[ ! $RESPONSE -eq '' ]]; then
            echo -e $FULLPATH','$RESPONSE >> $RESULTS
        fi
    done < $1
fi
echo 'URLs tested, live URLs logged in '$RESULTS
