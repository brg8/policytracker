# bin/bash
# Todo: Several nonces, Long requireLazy lines?

POLICY_DIR=policies
THIS_FILE_NAME=$(basename "$0")
POLICY_FILE=$POLICY_DIR/fb.html
POLICY_TXT_FILE=$POLICY_DIR/fb.txt
POLICY_TMP_FILE=$POLICY_DIR/fb_temp.html
NONCE_FILE=$POLICY_DIR/nonce
NONCE_REGEX=[a-zA-Z0-9_-]+

if [ $(basename $(pwd)) != "tospp" ]; then
  echo "Must run this script from tospp folder"
  exit 1
fi

curl "https://www.facebook.com/policy.php" > $POLICY_FILE

tidy -iq --literal-attributes yes --drop-empty-elements no --drop-empty-paras no --merge-divs no --merge-spans no --coerce-endtags no --escape-scripts no --fix-backslash no --fix-bad-comments no --fix-style-tags no --fix-uri no --join-styles no --merge-emphasis no --indent yes --wrap 0 --tidy-mark no --indent-attributes no $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

if false; then
# Todo: Refactor tokenization
sed -E "s/nonce=\"$NONCE_REGEX\"/nonce=\"NONCE\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

sed -E "s/\"compat_iframe_token\":\"$NONCE_REGEX\"/\"compat_iframe_token\":\"COMPAT_IFRAME_TOKEN\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

sed -E "s/\"ajaxpipe_token\":\"$NONCE_REGEX\"/\"ajaxpipe_token\":\"AJAXPIPE_TOKEN\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

WEB_SESSION_ID=$(grep -Eo bootstrapWebSession.+$ $POLICY_FILE | grep -Eo "\d+")
sed -E "s/$WEB_SESSION_ID/\"WEB_SESSION_ID\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

BIGPIPE_PAGE_ID=$(grep -Eo "bigPipe\.setPageID\(\"$NONCE_REGEX\"" $POLICY_FILE | grep -Eo "(\d|\-)+")
sed -E "s/$BIGPIPE_PAGE_ID/BIGPIPE_PAGE_ID/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

sed -E "s/name=\"jazoest\" value=\"$NONCE_REGEX\"/name=\"jazoest\" value=\"JAZOEST_VALUE\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

sed -E "s/name=\"lsd\" value=\"$NONCE_REGEX\"/name=\"lsd\" value=\"LSD_VALUE\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

sed -E "s/name=\"lgnrnd\" value=\"$NONCE_REGEX\"/name=\"lgnrnd\" value=\"LGNRND_VALUE\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE
fi

sed -E "s/amp;h=$NONCE_REGEX\"/amp;h=URL_TRACKER\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

lynx --dump $POLICY_FILE > $POLICY_TXT_FILE

rm $POLICY_TMP_FILE

# Todo: Only commit if there is something to commit
if [ $(git branch --show-current) = "main" ]; then
  git add $POLICY_DIR/*
  git commit -m "Executed file $THIS_FILE_NAME"
  git push origin main
fi

exit 0
