#!/bin/sh

# Test the HTTP response code of all absolute paths in a given list. Works for webpages, files etc. 
# Specify your parent domain in the $SITE variable below
# 
# Usage: 
# 
#   bash testUrls.sh myUrlsList.txt
# 
# myUrslList.txt contents (currently accepts absolute URLs only):
# 
#   /some/path/
#   /another/path
#   etc
# 
# Results will be logged in myUrlsList-results.csv in this format:
# /some/page,200
# /my/best/file.pdf,302 etc

# @TODO
#  - Unencoded spaces in URLs can throw false positives, like 'example.com/ some/path' as
#    everything after the space is treated as a second argument in the shell


SITE='https://example.com'
INPUT=$1
RESULTS=$1'-results.csv'

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
        

        # If the response isn't a 200 code (catches everything)
        # if [[ $(echo $RESPONSE) != '' ]] && [[ $(echo $RESPONSE) != 200 ]]; then
        
        # If the response isn't a 400/500 error, or empty...
        if [[ $(echo $RESPONSE) != 40* ]] && [[ $(echo $RESPONSE) != 50* ]] && [[ $(echo $RESPONSE) != '' ]]; then
        
            # Check if it's more than 3 numbers long - redirects return both codes e.g. '302 200'
            if [[ $(echo $RESPONSE | wc -m) -gt 3 ]]; then
                FINAL_RESPONSE=$(echo $RESPONSE | cut -d ' ' -f 2)
            else 
                FINAL_RESPONSE=$RESPONSE
            fi
            echo -e $FULLPATH','$FINAL_RESPONSE >> $RESULTS
        fi
    done < $INPUT
fi
echo 'URLs tested, live URLs logged in '$RESULTS
