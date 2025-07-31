#!/bin/bash

# Config
IMAGE_NAME="php-apache-8.3-fpm"
DOCKERHUB_USER="ashishagarwal1980"
REPO_NAME="$DOCKERHUB_USER/$IMAGE_NAME"
VERSION_FILE="version.txt"

# Read current version or default to 1980 if file missing
if [[ -f $VERSION_FILE ]]; then
  CURRENT_VERSION=$(cat $VERSION_FILE)
else
  CURRENT_VERSION=1980
fi

# Increment version (assumes numeric version)
NEW_VERSION=$((CURRENT_VERSION + 1))

echo "Building version: $NEW_VERSION"

# Build image with new version tag
docker build -t ${IMAGE_NAME}:${NEW_VERSION} .

# Tag image for Docker Hub
docker tag ${IMAGE_NAME}:${NEW_VERSION} ${REPO_NAME}:${NEW_VERSION}

# Push to Docker Hub
docker push ${REPO_NAME}:${NEW_VERSION}

# Update version file
echo $NEW_VERSION > $VERSION_FILE

echo "Image ${REPO_NAME}:${NEW_VERSION} built and pushed successfully!"
