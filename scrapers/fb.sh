#!/bin/bash
if [[ ! -z "$1" ]]; then
  exec >> $1
fi
PATH=/usr/local/bin:/usr/local/sbin:~/bin:/usr/bin:/bin:/usr/sbin:/sbin

POLICY_DIR=policies
THIS_FILE_NAME=$(basename "$0")
POLICY_FILE=$POLICY_DIR/fb.html
POLICY_TXT_FILE=$POLICY_DIR/fb.txt
POLICY_TMP_FILE=$POLICY_DIR/fb_temp.html
NONCE_REGEX=[a-zA-Z0-9_-]+

if [ $(basename $(pwd)) != "policy-tracker" ]; then
  echo "Error: Must run this script from tospp folder"
  exit 1
fi

echo "--$(date)-- Working on https://www.facebook.com/policy.php"
echo "  Fetching"
curl "https://www.facebook.com/policy.php" > $POLICY_FILE

echo "  Tidying"
tidy -iq --literal-attributes yes --show-warnings no --drop-empty-elements no --drop-empty-paras no --merge-divs no --merge-spans no --coerce-endtags no --escape-scripts no --fix-backslash no --fix-bad-comments no --fix-style-tags no --fix-uri no --join-styles no --merge-emphasis no --indent yes --wrap 0 --tidy-mark no --indent-attributes no $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

echo "  Pre-processing"
sed -E "s/amp;h=$NONCE_REGEX\"/amp;h=URL_TRACKER\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

echo "  Transforming"
lynx --dump $POLICY_FILE > $POLICY_TXT_FILE

echo "  Post-processing"
LC_ALL=C sed -E "s~file://$(pwd)/$POLICY_FILE~~g" $POLICY_TXT_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_TXT_FILE
LC_ALL=C sed -E "s~file://~~g" $POLICY_TXT_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_TXT_FILE
LC_ALL=C sed -E "s~localhost$(pwd)/$POLICY_FILE~~g" $POLICY_TXT_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_TXT_FILE

echo "  Cleaning up"
rm $POLICY_TMP_FILE
rm $POLICY_FILE

if [ $(git branch --show-current) = "main" ]; then
  if [[ -n $(git status -s) ]]; then
    echo "  Committing"
    git add $POLICY_DIR/*
    git commit -m "Executed file $THIS_FILE_NAME"
    git push origin main
  fi
fi

exit 0
