#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=03:00:00


#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string stage
#string checkStage
#string fastqcVersion
#string intermediateDir
#string peEnd1BarcodeFastQcZip
#string peEnd2BarcodeFastQcZip
#string srBarcodeFastQcZip

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "fastqcVersion: ${fastqcVersion}"
echo "intermediateDir: ${intermediateDir}"
echo "peEnd1BarcodeFastQcZip: ${peEnd1BarcodeFastQcZip}"
echo "peEnd2BarcodeFastQcZip: ${peEnd2BarcodeFastQcZip}"
echo "srBarcodeFastQcZip: ${srBarcodeFastQcZip}"

sleep 10

#If paired-end then copy 2 files, else only 1
if [ ${seqType} == "PE" ]
then
        alloutputsexist \
        "${peEnd1BarcodeFastQcZip}" \
        "${peEnd2BarcodeFastQcZip}"
        
	getFile ${peEnd1BarcodeFqGz}
	getFile ${peEnd2BarcodeFqGz}

else
        alloutputsexist \
        "${srBarcodeFastQcZip}"
        
	getFile ${srBarcodeFqGz}

fi

#Load module
${stage} fastqc/${fastqcVersion}
${checkStage}
makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then
	# end1 & end2
	fastqc ${peEnd1BarcodeFqGz} \
	${peEnd2BarcodeFqGz} \
	-o ${tmpIntermediateDir}
	
	#Get return code from last program call
	returnCode=$?

	echo -e "\nreturnCode FastQC: $returnCode\n\n"

		echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
		mv ${tmpIntermediateDir}/* ${intermediateDir}
		putFile "${peEnd1BarcodeFastQcZip}"
                putFile "${peEnd2BarcodeFastQcZip}"

else
	fastqc ${srBarcodeFqGz} \
	-o ${tmpIntermediateDir}

	echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpIntermediateDir}/* ${intermediateDir}
	putFile "${srBarcodeFastQcZip}"
fi