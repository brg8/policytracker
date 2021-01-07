# bin/bash
# Todo: Several nonces, Long requireLazy lines?

POLICY_DIR=policies
THIS_FILE_NAME=$(basename "$0")
POLICY_FILE=$POLICY_DIR/fb.html
POLICY_TMP_FILE=$POLICY_DIR/fb_temp.html
NONCE_FILE=$POLICY_DIR/nonce

if [ $(basename $(pwd)) != "tospp" ]; then
  echo "Must run this script from tospp folder"
  exit 1
fi

curl "https://www.facebook.com/policy.php" > $POLICY_FILE

tidy $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

grep nonce= $POLICY_FILE | head -n 1 | grep -Eo nonce=\".+\" > $NONCE_FILE
NONCE=$(grep -Eo \".+\" $NONCE_FILE)
sed "s/$NONCE/\"NONCE\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

sed -E "s/\"compat_iframe_token\":\"[a-zA-Z0-9_-]+\"/\"compat_iframe_token\":\"COMPAT_IFRAME_TOKEN\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE
sed -E "s/\"ajaxpipe_token\":\"[a-zA-Z0-9_-]+\"/\"ajaxpipe_token\":\"AJAXPIPE_TOKEN\"/g" $POLICY_FILE > $POLICY_TMP_FILE
cp $POLICY_TMP_FILE $POLICY_FILE

rm $POLICY_TMP_FILE
rm $NONCE_FILE

# Todo: Only commit if there is something to commit
if [ $(git branch --show-current) = "main" ]; then
  git add $POLICY_DIR/*
  git commit -m "Executed file $THIS_FILE_NAME"
  git push origin main
fi

exit 0
