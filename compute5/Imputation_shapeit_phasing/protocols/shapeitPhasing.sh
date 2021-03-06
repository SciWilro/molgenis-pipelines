#MOLGENIS nodes=1 cores=8 mem=2G

#foreach project,chr

#Parameter mapping
#string shapeitBin
#string m
#string studyData
#string studyDataType
#string shapeitThreads
#string chr
#string additonalShapeitParam
#string PhaseOutputFolder
#string stage
#string shapeitversion
#string PhaseOutputFolderTemp


tmpOutput="${PhaseOutputFolderTemp}/~chr${chr}"
finalOutput="${PhaseOutputFolder}/chr${chr}"



if [ "${stage}" != "" ]
then
	${stage} shapeit/${shapeitversion}
fi



echo "m: ${m}";
echo "studyData: ${studyData}"
echo "studyDataType: ${studyDataType}"
echo "shapeitThreads: ${shapeitThreads}"
echo "chr: ${chr}"
echo "additonalShapeitParam: ${additonalShapeitParam}"
echo "PhaseOutputFolder: ${PhaseOutputFolder}"
echo "PhaseOutputFolderTemp: ${PhaseOutputFolderTemp}"
echo "tmpOutput: ${tmpOutput}"

mkdir -p ${PhaseOutputFolder}
mkdir -p ${PhaseOutputFolderTemp}

if [ $studyDataType == "PED" ]; then
	inputVarName="--input-ped"
elif [ $studyDataType == "BED" ]; then
	inputVarName="--input-bed"
elif [ $studyDataType == "GEN" ]; then
	inputVarName="--input-gen"
else
  	echo "The variable studyDataType provided in the worksheet does not match any of the following values: PED, BED or GEN"
  	echo "Analysis can not be continued. Exiting now!"
  	exit 1
fi

startTime=$(date +%s)

alloutputsexist \
	"${PhaseOutputFolder}/chr${chr}.haps" \
	"${PhaseOutputFolder}/chr${chr}.sample"

getFile $m
inputs $m

# $studyData can be multiple files. Here we will check each file and do a getFile, if needed, for each file
for studyDataFile in $studyData
do
	echo "Study data file detected: ${studyDataFile}"
	getFile $studyDataFile
	inputs $studyDataFile
done



if $shapeitBin \
	$inputVarName $studyData \
	--input-map $m \
	--output-max $tmpOutput \
	--thread $shapeitThreads \
	--output-log ${tmpOutput}.log \
	${additonalShapeitParam}
then
	#Command successful
	echo "returnCode ShapeIt2: $?"
	
	echo -e "\nCopying temp files to final files\n\n"

	for tempFile in ${tmpOutput}* ; do
		finalFile=`echo $tempFile | sed -e "s/~//g"`
		finalFile=${PhaseOutputFolder}/$(basename $finalFile)
		echo "Copying temp file: ${tempFile} to ${finalFile}"
		cp $tempFile $finalFile
		putFile $finalFile
	done
	
else 
	#Command failed
	echo "returncode ShapeIt2: $?"
	
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
	
fi


endTime=$(date +%s)


#Source: http://stackoverflow.com/questions/12199631/convert-seconds-to-hours-minutes-seconds-in-bash

num=$(($endTime-$startTime))
min=0
hour=0
day=0
if ((num>59));then
    sec=$(($num%60))
    num=$(($num/60))
    if ((num>59));then
        min=$(($num%60))
        num=$(($num/60))
        if ((num>23));then
            hour=$(($num%24))
            day=$(($num/24))
        else
            hour=${num}
        fi
    else
        min=${num}
    fi
else
    sec=${num}
fi
echo "Running time: ${day} days ${hour} hours ${min} mins ${sec} secs"



