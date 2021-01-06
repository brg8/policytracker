# bin/bash

POLICY_DIR=policies
THIS_FILE_NAME=$(basename "$0")

# echo $(basename $(pwd))
if [ $(basename $(pwd)) != "tospp" ]; then
  echo "Must run this script from tospp folder"
  exit 1
fi

curl "https://www.facebook.com/policy.php" > $POLICY_DIR/fb.html
git add $POLICY_DIR/*
git commit -m "Executed file $THIS_FILE_NAME"
exit 0
