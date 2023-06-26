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
mkdir ./zip
cd ../repository && zip -r ../cloudformation/zip/init-source ./ -x .git/\* target/\* && cd ../cloudformation/
aws s3 mb s3://$profile_id-$project_name-codecommit
# We run sync even if the creation of the bucket failed, because it might be already created
aws s3 sync ./zip s3://$profile_id-$project_name-codecommit --profile $profile --region $region
sam deploy -t main.yml --stack-name $project_name --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --profile $profile --region $region --parameter-overrides ProjectName=$project_name
