#!/bin/zsh

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
  echo "SwiftLint is not installed. Installing via Homebrew..."
  brew install swiftlint
fi

echo "Setting up SwiftLint in the project..."

# Create run script phase file - you'll need to manually add this to your Xcode project
cat > swiftlint_build_phase.txt << EOL
if which swiftlint > /dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
  echo "or install via brew: brew install swiftlint"
fi
EOL

echo "✅ Script created! Now follow these steps to add SwiftLint to your project:"
echo ""
echo "1. Open your Xcode project"
echo "2. Select your project in the Project Navigator"
echo "3. Select your target"
echo "4. Go to the 'Build Phases' tab"
echo "5. Click the '+' button at the top left of the build phases section"
echo "6. Select 'New Run Script Phase'"
echo "7. Rename the phase to 'Run SwiftLint'"
echo "8. Copy and paste the script from the swiftlint_build_phase.txt file into the script field"
echo "9. Make sure the 'Run script only when installing' checkbox is NOT checked"
echo "10. Drag the run script phase to be right after 'Target Dependencies' phase"
echo ""
echo "Once added, SwiftLint will run every time you build your project."
