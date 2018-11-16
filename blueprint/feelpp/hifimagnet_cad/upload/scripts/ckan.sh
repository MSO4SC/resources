get_ckan_data() {

    local TOKEN=$1
    local DATASET=${2:-"None"}
    local DATA=${3:-"Empty"}
    local UNTAR=${4:-"True"}

    echo "get_ckan_data: ${TOKEN} (${DATASET} : ${DATA})"
    
    # Get data from ckan
    echo "DATASET=${DATASET}" >> "${LOG_FILE}"
    echo "CATALOGUE_TOKEN=${CATALOGUE_TOKEN}" >> "${LOG_FILE}"
    echo "DATA=${DATA}" >> "${LOG_FILE}"

    ARCHIVE=${DATASET}
    ARCHIVE=$(echo "$ARCHIVE" | perl -pi -e "s|.*/||")
    isstatus=$?
    if [ "$isstatus" == 1 ]; then
	echo "Failed to process $DATASET"
	exit 1
    fi    
    echo "ARCHIVE=$ARCHIVE"  >> "${LOG_FILE}"

    OPTIONS=""
    if [ "$CATALOGUE_TOKEN" ]; then
	OPTIONS="-H \"Authorization: ${CATALOGUE_TOKEN}\""
    fi

    if [ "x$DATASET" != "x" ] && [ "$DATASET" != "None" ]; then
	curl "${OPTIONS}" "${DATASET}" -o "${ARCHIVE}" >> "${LOG_FILE}"
	isDownloaded=$?
	if [ "$isDownloaded" == 1 ]; then
	    echo "curl $OPTIONS $DATASET -o $ARCHIVE : FAILS" >> "${LOG_FILE}"
            exit 1
	fi

	if [ "$UNTAR" = "True" ]; then
	    TYPE=$(file "$ARCHIVE" | perl -pi -e "s|$ARCHIVE: ||")
	    echo "type($ARCHIVE)=$TYPE"  >> "${LOG_FILE}"

	    tar zxvf "$ARCHIVE" >> "${LOG_FILE}"
	    status=$?
	    if [ $status != "0" ]; then
		echo "tar zxvf $ARCHIVE : FAILS" >> "${LOG_FILE}"
		exit 1
	    fi
	fi

	# check if input file is present when DATA is defined
	# if [ ! -z "$DATA" ]; then
	if [ "$DATA" != "Empty" ]; then
	    if [ ! -f "$DATA" ]; then
		echo "$DATA: no such file in dataset $DATASET" >> "${LOG_FILE}"
		exit 1
	    fi
	fi
    fi	
}    

get_ckan_data $CATALOGUE_TOKEN $DATASET $DATA

#LICENSE_DATASET="http://193.144.35.207/dataset/meshgems-license"
# # set UNTAR option to false
#get_ckan_data $CATALOGUE_TOKEN $LICENSE_DATASET dlim8.key "False"
