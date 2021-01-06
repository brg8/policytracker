# bin/bash

POLICY_DIR=policies
THIS_FILE_NAME=$(basename "$0")
POLICY_FILE=$POLICY_DIR/fb.html
POLICY_TMP_FILE=$POLICY_DIR/fb_temp.html

if [ $(basename $(pwd)) != "tospp" ]; then
  echo "Must run this script from tospp folder"
  exit 1
fi

curl "https://www.facebook.com/policy.php" > $POLICY_FILE
tidy $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE
rm $POLICY_TMP_FILE

if [ $(git branch --show-current) = "main" ]; then
  git add $POLICY_DIR/*
  git commit -m "Executed file $THIS_FILE_NAME"
  git push origin main
fi

exit 0
