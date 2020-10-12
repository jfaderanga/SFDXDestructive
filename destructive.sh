#!/bin/sh

# arguments you pass from command line
TARGET_ENV=$1
SOURCE_PATH=$2

# you can select any class that has @isTest annotation
# even DataFactory will work
API_VERSION=48.0
TEST_RUN=TestDataUtil

echo "staring delete deploy.."
rm -rf deploySh/deployDelete/destructivePackage &>/dev/null
mkdir -p deploySh/deployDelete/destructivePackage &>/dev/null

echo "converting to sfdx format"
sfdx force:source:convert -p ${SOURCE_PATH} -d deploySh/deployDelete/destructivePackage

# copy package.xml to desctructiveChanges.xml
cp deploySh/deployDelete/destructivePackage/package.xml deploySh/deployDelete/destructivePackage/destructiveChanges.xml

# we remove the package that contains members and replace it with plain version only
rm -rf deploySh/deployDelete/destructivePackage/package.xml
find deploySh/deployDelete/destructivePackage/* -type d -exec rm -rf '{}' \;

# generate an empty (containing only the api version tag) package.xml
cat <<EOT > deploySh/deployDelete/destructivePackage/package.xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
  <version>${API_VERSION}</version>
</Package>
EOT

# deploying to the target org
echo "deploying a destructive change to ${TARGET_ENV}"
sfdx force:mdapi:deploy -d deploySh/deployDelete/destructivePackage -u ${TARGET_ENV} -l RunSpecifiedTests -r ${TEST_RUN} -w -1

if [ $? -eq 0 ]; then
    # green color
    echo -e "\e[32mSuccess!"
else
    # red color
    echo -e "\e[31mError"
fi
