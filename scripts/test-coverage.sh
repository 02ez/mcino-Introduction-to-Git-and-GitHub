#!/bin/bash
# Test Coverage and Quality Gate Script
# Enforces minimum test coverage and quality standards

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COVERAGE_THRESHOLD=${COVERAGE_THRESHOLD:-80}
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
REPORTS_DIR="${PROJECT_DIR}/coverage-reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo -e "${BLUE}=== Test Coverage and Quality Gate ===${NC}"
echo "Minimum Coverage Threshold: ${COVERAGE_THRESHOLD}%"
echo "Project Directory: ${PROJECT_DIR}"
echo "Reports Directory: ${REPORTS_DIR}"
echo ""

# Create reports directory
mkdir -p "${REPORTS_DIR}"

# Function to run Python tests with coverage
run_python_tests() {
    echo -e "${GREEN}Running Python tests with coverage...${NC}"
    
    # Run pytest with coverage
    python -m pytest tests/ -v \
        --cov=. \
        --cov-report=term-missing \
        --cov-report=xml:"${REPORTS_DIR}/coverage_${TIMESTAMP}.xml" \
        --cov-report=html:"${REPORTS_DIR}/htmlcov_${TIMESTAMP}" \
        --cov-report=json:"${REPORTS_DIR}/coverage_${TIMESTAMP}.json" \
        --junit-xml="${REPORTS_DIR}/pytest_results_${TIMESTAMP}.xml" \
        --cov-fail-under=${COVERAGE_THRESHOLD} || {
        
        echo -e "${RED}✗ Python test coverage below threshold (${COVERAGE_THRESHOLD}%)${NC}"
        return 1
    }
    
    echo -e "${GREEN}✓ Python tests passed with adequate coverage${NC}"
    return 0
}

# Function to run shell script tests
run_shell_tests() {
    echo -e "${GREEN}Running shell script tests...${NC}"
    
    # Check if BATS is available
    if ! command -v bats &> /dev/null; then
        echo -e "${YELLOW}BATS not found, installing...${NC}"
        git clone https://github.com/bats-core/bats-core.git /tmp/bats-core
        cd /tmp/bats-core
        sudo ./install.sh /usr/local
        cd "${PROJECT_DIR}"
    fi
    
    # Make sure shell script is executable
    chmod +x simple-interest.sh
    
    # Run BATS tests
    bats tests/test_shell.bats --tap > "${REPORTS_DIR}/bats_results_${TIMESTAMP}.tap" || {
        echo -e "${RED}✗ Shell script tests failed${NC}"
        return 1
    }
    
    echo -e "${GREEN}✓ Shell script tests passed${NC}"
    return 0
}

# Function to run integration tests
run_integration_tests() {
    echo -e "${GREEN}Running integration tests...${NC}"
    
    python tests/integration_test.py > "${REPORTS_DIR}/integration_results_${TIMESTAMP}.log" 2>&1 || {
        echo -e "${RED}✗ Integration tests failed${NC}"
        cat "${REPORTS_DIR}/integration_results_${TIMESTAMP}.log"
        return 1
    }
    
    echo -e "${GREEN}✓ Integration tests passed${NC}"
    return 0
}

# Function to check code quality
check_code_quality() {
    echo -e "${GREEN}Checking code quality...${NC}"
    
    # Check Python formatting
    if command -v black &> /dev/null; then
        black --check --diff . > "${REPORTS_DIR}/black_check_${TIMESTAMP}.log" 2>&1 || {
            echo -e "${YELLOW}⚠ Code formatting issues found (run 'black .' to fix)${NC}"
            cat "${REPORTS_DIR}/black_check_${TIMESTAMP}.log"
        }
    fi
    
    # Check import sorting
    if command -v isort &> /dev/null; then
        isort --check-only --diff . > "${REPORTS_DIR}/isort_check_${TIMESTAMP}.log" 2>&1 || {
            echo -e "${YELLOW}⚠ Import sorting issues found (run 'isort .' to fix)${NC}"
            cat "${REPORTS_DIR}/isort_check_${TIMESTAMP}.log"
        }
    fi
    
    # Run flake8 linting
    if command -v flake8 &> /dev/null; then
        flake8 . --statistics > "${REPORTS_DIR}/flake8_${TIMESTAMP}.log" 2>&1 || {
            echo -e "${YELLOW}⚠ Linting issues found${NC}"
            cat "${REPORTS_DIR}/flake8_${TIMESTAMP}.log"
        }
    fi
    
    # Check shell scripts with shellcheck
    if command -v shellcheck &> /dev/null; then
        find . -name "*.sh" -exec shellcheck {} \; > "${REPORTS_DIR}/shellcheck_${TIMESTAMP}.log" 2>&1 || {
            echo -e "${YELLOW}⚠ Shell script issues found${NC}"
            cat "${REPORTS_DIR}/shellcheck_${TIMESTAMP}.log"
        }
    fi
    
    echo -e "${GREEN}✓ Code quality checks completed${NC}"
}

# Function to generate coverage report
generate_coverage_report() {
    echo -e "${GREEN}Generating coverage report...${NC}"
    
    if [[ -f "${REPORTS_DIR}/coverage_${TIMESTAMP}.json" ]]; then
        COVERAGE_PERCENT=$(python -c "
import json
with open('${REPORTS_DIR}/coverage_${TIMESTAMP}.json') as f:
    data = json.load(f)
print(f\"{data['totals']['percent_covered']:.1f}\")
")
        
        echo ""
        echo -e "${BLUE}=== Coverage Summary ===${NC}"
        echo "Overall Coverage: ${COVERAGE_PERCENT}%"
        echo "Threshold: ${COVERAGE_THRESHOLD}%"
        
        if (( $(echo "${COVERAGE_PERCENT} >= ${COVERAGE_THRESHOLD}" | bc -l) )); then
            echo -e "${GREEN}✓ Coverage threshold met${NC}"
        else
            echo -e "${RED}✗ Coverage below threshold${NC}"
            return 1
        fi
    fi
}

# Function to run performance benchmarks
run_performance_tests() {
    echo -e "${GREEN}Running performance benchmarks...${NC}"
    
    python -c "
import time
import sys
import os
sys.path.insert(0, '.')
import compound_interest

# Benchmark compound interest calculation
start_time = time.time()
for _ in range(10000):
    result = compound_interest.compound_interest(1000, 5, 7)
end_time = time.time()

execution_time = end_time - start_time
ops_per_second = 10000 / execution_time

print(f'Performance Benchmark:')
print(f'  10,000 calculations in {execution_time:.3f} seconds')
print(f'  {ops_per_second:.0f} operations per second')

# Performance threshold: should handle at least 1000 ops/sec
if ops_per_second >= 1000:
    print('✓ Performance benchmark passed')
    exit(0)
else:
    print('✗ Performance benchmark failed')
    exit(1)
" > "${REPORTS_DIR}/performance_${TIMESTAMP}.log" 2>&1 || {
        echo -e "${RED}✗ Performance benchmarks failed${NC}"
        cat "${REPORTS_DIR}/performance_${TIMESTAMP}.log"
        return 1
    }
    
    echo -e "${GREEN}✓ Performance benchmarks passed${NC}"
    cat "${REPORTS_DIR}/performance_${TIMESTAMP}.log"
}

# Main execution
main() {
    local exit_code=0
    
    echo -e "${BLUE}Starting comprehensive test suite...${NC}"
    echo ""
    
    # Run all test suites
    run_python_tests || exit_code=1
    echo ""
    
    run_shell_tests || exit_code=1
    echo ""
    
    run_integration_tests || exit_code=1
    echo ""
    
    check_code_quality
    echo ""
    
    generate_coverage_report || exit_code=1
    echo ""
    
    run_performance_tests || exit_code=1
    echo ""
    
    # Final summary
    echo -e "${BLUE}=== Test Summary ===${NC}"
    if [[ ${exit_code} -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed! Quality gate satisfied.${NC}"
        echo ""
        echo "Reports generated in: ${REPORTS_DIR}"
        echo "Coverage reports: ${REPORTS_DIR}/htmlcov_${TIMESTAMP}/index.html"
    else
        echo -e "${RED}✗ Some tests failed. Quality gate not satisfied.${NC}"
        echo ""
        echo "Check reports in: ${REPORTS_DIR}"
    fi
    
    echo ""
    echo -e "${BLUE}=== Quality Gate Commands ===${NC}"
    echo "# Run tests with coverage:"
    echo "pytest tests/ -v --cov=. --cov-report=term-missing --cov-fail-under=${COVERAGE_THRESHOLD}"
    echo ""
    echo "# Run all quality checks:"
    echo "black --check ."
    echo "isort --check-only ."
    echo "flake8 ."
    echo "shellcheck *.sh"
    echo ""
    echo "# Generate coverage report:"
    echo "pytest tests/ --cov=. --cov-report=html"
    
    return ${exit_code}
}

# Install required packages if not available
install_requirements() {
    echo -e "${YELLOW}Checking required packages...${NC}"
    
    # Install Python packages if not available
    python -c "import pytest, coverage" 2>/dev/null || {
        echo "Installing pytest and coverage..."
        pip install pytest pytest-cov
    }
    
    # Install code quality tools if not available
    python -c "import black, isort, flake8" 2>/dev/null || {
        echo "Installing code quality tools..."
        pip install black isort flake8
    }
}

# Check if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_requirements
    main "$@"
fi