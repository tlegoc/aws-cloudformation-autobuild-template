#!/bin/bash

helpFunction()
{
    echo ""
    echo "Usage: $0 -s project_name [-r region] [-p profile]"
    echo -e "\t-s project_name"
    echo -e "\t-r region, default value: eu-west-1"
    echo -e "\t-p profile, default value: default"
    exit 1 # Exit script after printing help
}

region=eu-west-1;
profile=default;
time=300;
while getopts "s:r:p:" opt
do
    case "$opt" in
        s ) project_name="$OPTARG" ;;
        r ) region="$OPTARG" ;;
        p ) profile="$OPTARG" ;;
        ? ) helpFunction ;;
    esac
done

if [ -z "$project_name" ]
then
    echo "Please specify a project name";
    helpFunction
fi

profile_id=`aws sts get-caller-identity --query "Account" --output text`
echo Profile id: "$profile_id"
echo Project name: "$project_name"
echo Region: "$region"

rm -rf ./zip
aws s3 rb s3://$profile_id-$project_name-codecommit --force  
aws s3 rm s3://$profile_id-$project_name-artifacts --recursive
aws s3 rm s3://$profile_id-$project_name-builds --recursive
"C:\Program Files\Amazon\AWSSAMCLI\bin\sam.cmd" delete --stack-name $project_name --profile $profile --region $region