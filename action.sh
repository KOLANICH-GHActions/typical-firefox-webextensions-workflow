#!/usr/bin/env bash

set -e;

if [[ -z "${ACTIONS_RUNTIME_URL}" ]]; then
	echo "::error::ACTIONS_RUNTIME_URL is missing. Uploading artifacts won't work without it. See https://github.com/KOLANICH-GHActions/passthrough-restricted-actions-vars and https://github.com/KOLANICH-GHActions/node_based_cmd_action_template";
	exit 1;
fi;

if [[ -z "${ACTIONS_RUNTIME_TOKEN}" ]]; then
	echo "::error::ACTIONS_RUNTIME_TOKEN is missing. Uploading artifacts won't work without it. See https://github.com/KOLANICH-GHActions/passthrough-restricted-actions-vars and https://github.com/KOLANICH-GHActions/node_based_cmd_action_template";
	exit 1;
fi;

THIS_SCRIPT_DIR=`dirname "${BASH_SOURCE[0]}"`;
echo "This script is $THIS_SCRIPT_DIR";
THIS_SCRIPT_DIR=`realpath "${THIS_SCRIPT_DIR}"`;
echo "This script is $THIS_SCRIPT_DIR";
ACTIONS_DIR=`realpath "$THIS_SCRIPT_DIR/../../.."`;

ARTIFACT_ACTION_REPO=actions/upload-artifact;

ARTIFACT_ACTION_DIR=$ACTIONS_DIR/$ARTIFACT_ACTION_REPO/master;

artifactUploadCmd="env INPUT_IF-NO-FILES-FOUND=warn INPUT_RETENTION-DAYS=90 node $ARTIFACT_ACTION_DIR/dist/index.js";

if [ -d "$ARTIFACT_ACTION_DIR" ]; then
	:
else
	git clone --depth=1 https://github.com/$ARTIFACT_ACTION_REPO $ARTIFACT_ACTION_DIR;
fi;

echo "##[group] Checking out";
git clone --depth=1 https://github.com/$GITHUB_REPOSITORY .;
echo "##[endgroup]";

echo "##[group] Building the exts";
for mf in $(find . -name "manifest.json"); do
    d=`dirname $mf`;
    bd=`basename $d`;
    xpiname=$bd.xpi;
    7za a -tzip -mx=9 -mm=Deflate $xpiname $d/*;
    INPUT_NAME=$xpiname INPUT_PATH=$xpiname $artifactUploadCmd;
done;
echo "##[endgroup]";
