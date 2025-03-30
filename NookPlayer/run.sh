#!/bin/bash

# Check for Swift
if ! command -v swift &> /dev/null; then
    echo "Swift could not be found. Please install Swift."
    exit 1
fi

# Build and run the application
echo "Building and running NookPlayer..."
swift run

