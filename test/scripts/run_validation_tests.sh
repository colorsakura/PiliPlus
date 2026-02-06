#!/bin/bash
# Script to run video API validation tests
# This script provides a convenient way to run validation tests with various options

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TEST_TYPE="integration"
VERBOSE=false
SPECIFIC_TEST=""

# Help function
show_help() {
    echo "Usage: ./run_validation_tests.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE          Test type: 'unit' or 'integration' (default: integration)"
    echo "  -n, --name NAME          Run specific test by name"
    echo "  -v, --verbose            Enable verbose output"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./run_validation_tests.sh"
    echo "  ./run_validation_tests.sh --type unit"
    echo "  ./run_validation_tests.sh --name 'popular'"
    echo "  ./run_validation_tests.sh --type integration --name 'short' --verbose"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            TEST_TYPE="$2"
            shift 2
            ;;
        -n|--name)
            SPECIFIC_TEST="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Validate test type
if [[ "$TEST_TYPE" != "unit" && "$TEST_TYPE" != "integration" ]]; then
    echo -e "${RED}Error: Test type must be 'unit' or 'integration'${NC}"
    exit 1
fi

# Build test command
if [[ "$TEST_TYPE" == "unit" ]]; then
    TEST_FILE="test/http/video_api_validation_test.dart"
    echo -e "${BLUE}Running unit tests...${NC}"
else
    TEST_FILE="integration_test/video_api_validation_integration_test.dart"
    echo -e "${BLUE}Running integration tests...${NC}"
fi

CMD="flutter test $TEST_FILE"

# Add test name filter if specified
if [[ -n "$SPECIFIC_TEST" ]]; then
    CMD="$CMD --name \"$SPECIFIC_TEST\""
    echo -e "${YELLOW}Filtering tests matching: $SPECIFIC_TEST${NC}"
fi

# Add verbose flag if requested
if [[ "$VERBOSE" == true ]]; then
    CMD="$CMD -r expanded"
    echo -e "${YELLOW}Verbose output enabled${NC}"
fi

# Add timeout for integration tests
if [[ "$TEST_TYPE" == "integration" ]]; then
    CMD="$CMD --timeout 15m"
fi

echo ""
echo -e "${GREEN}Executing: $CMD${NC}"
echo ""

# Execute the command
eval $CMD

# Capture exit code
EXIT_CODE=$?

echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${RED}❌ Some tests failed${NC}"
fi

exit $EXIT_CODE
