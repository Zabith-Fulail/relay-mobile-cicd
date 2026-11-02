#!/usr/bin/env bash
# ==============================================================================
# Relay Mobile — Android Release Keystore & GitHub Secret Generator
# Generates a demo upload-keystore.jks, android/key.properties, and prints
# the Base64-encoded secret string for GitHub Actions.
# ==============================================================================

set -euo pipefail

KEYSTORE_PATH="android/app/upload-keystore.jks"
PROPERTIES_PATH="android/key.properties"

echo "🔐 Generating Android Release Keystore for Relay Mobile..."

if [ -f "$KEYSTORE_PATH" ]; then
  echo "ℹ️ Keystore already exists at $KEYSTORE_PATH"
else
  keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias upload \
    -storepass relaysecret123 \
    -keypass relaysecret123 \
    -dname "CN=Relay Mobile CI, OU=Mobile Engineering, O=Relay, L=Colombo, S=Western, C=LK"
fi

cat <<EOF > "$PROPERTIES_PATH"
storePassword=relaysecret123
keyPassword=relaysecret123
keyAlias=upload
storeFile=upload-keystore.jks
EOF

echo ""
echo "✅ Created $KEYSTORE_PATH and $PROPERTIES_PATH (both excluded by .gitignore)."
echo ""
echo "📋 To configure GitHub Actions Secrets (Settings -> Secrets -> Actions), add:"
echo "   • ANDROID_KEY_ALIAS       = upload"
echo "   • ANDROID_KEY_PASSWORD    = relaysecret123"
echo "   • ANDROID_STORE_PASSWORD  = relaysecret123"
echo "   • ANDROID_KEYSTORE_BASE64 = (run command below to copy to clipboard)"
echo "     base64 -i $KEYSTORE_PATH | pbcopy"

