#!/bin/bash

set -e

# Check if the lane name was provided
if [ -z "$1" ]; then
  echo "❌ Error: Please provide a Fastlane lane name (e.g., testflight_release)"
  exit 1
fi

LANE=$1

# Load environment variables from .env.fastlane
ENV_FILE="ios/.env.default"

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Error: $ENV_FILE not found. Make sure you have it!"
  exit 1
fi

echo "📦 Loading environment variables from $ENV_FILE"
export $(grep -v '^#' $ENV_FILE | xargs)

# Check if APP_STORE_API_KEY is loaded
if [ -z "$APP_STORE_API_KEY" ]; then
  echo "❌ Error: APP_STORE_API_KEY is not set. Check your .env.fastlane file."
  exit 1
fi

# Decode the API key into ios/AuthKey.p8
echo "🔐 Recreating AuthKey.p8 from base64..."
echo "$APP_STORE_API_KEY" | base64 --decode > ios/AuthKey.p8
echo "✅ AuthKey.p8 created successfully."

# Run the requested Fastlane lane
echo "🚀 Running Fastlane lane: $LANE"
cd ios

if [ -f "Gemfile" ]; then
  echo "💎 Using bundle exec fastlane (Gemfile detected)"
  bundle exec fastlane $LANE
else
  echo "🚀 Using global fastlane (no Gemfile)"
  fastlane $LANE
fi

cd ..

# Cleanup after build
echo "🧹 Cleaning up AuthKey.p8"
rm -f ios/AuthKey.p8
echo "✅ Cleanup complete!"