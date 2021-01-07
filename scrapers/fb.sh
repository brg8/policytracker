# bin/bash
# Todo: Several nonces, Long requireLazy lines?
# Todo: Run in lambda
# Todo: Trigger from cron job

POLICY_DIR=policies
THIS_FILE_NAME=$(basename "$0")
POLICY_FILE=$POLICY_DIR/fb.html
POLICY_TXT_FILE=$POLICY_DIR/fb.txt
POLICY_TMP_FILE=$POLICY_DIR/fb_temp.html
NONCE_REGEX=[a-zA-Z0-9_-]+

if [ $(basename $(pwd)) != "tospp" ]; then
  echo "Must run this script from tospp folder"
  exit 1
fi

curl "https://www.facebook.com/policy.php" > $POLICY_FILE

tidy -iq --literal-attributes yes --drop-empty-elements no --drop-empty-paras no --merge-divs no --merge-spans no --coerce-endtags no --escape-scripts no --fix-backslash no --fix-bad-comments no --fix-style-tags no --fix-uri no --join-styles no --merge-emphasis no --indent yes --wrap 0 --tidy-mark no --indent-attributes no $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

sed -E "s/amp;h=$NONCE_REGEX\"/amp;h=URL_TRACKER\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

lynx --dump $POLICY_FILE > $POLICY_TXT_FILE

rm $POLICY_TMP_FILE
rm $POLICY_FILE

# Todo: Only commit if there is something to commit
if [ $(git branch --show-current) = "main" ]; then
  if [[ -n $(git status -s) ]]; then
    git add $POLICY_DIR/*
    git commit -m "Executed file $THIS_FILE_NAME"
    git push origin main
  fi
fi

exit 0
