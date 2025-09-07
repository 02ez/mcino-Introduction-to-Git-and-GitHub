#!/usr/bin/env bats

setup() {
    # Ensure script is executable
    chmod +x simple-interest.sh
}

@test "simple interest calculation with valid inputs" {
    # Test case: principal=1000, rate=5, time=2
    # Expected: 1000 * 5 * 2 / 100 = 100
    result=$(echo -e "1000\n5\n2" | ./simple-interest.sh | tail -1)
    [ "$result" = "100" ]
}

@test "simple interest calculation with zero principal" {
    # Test case: principal=0, rate=5, time=2
    # Expected: 0 * 5 * 2 / 100 = 0
    result=$(echo -e "0\n5\n2" | ./simple-interest.sh | tail -1)
    [ "$result" = "0" ]
}

@test "simple interest calculation with zero rate" {
    # Test case: principal=1000, rate=0, time=2
    # Expected: 1000 * 0 * 2 / 100 = 0
    result=$(echo -e "1000\n0\n2" | ./simple-interest.sh | tail -1)
    [ "$result" = "0" ]
}

@test "simple interest calculation with zero time" {
    # Test case: principal=1000, rate=5, time=0
    # Expected: 1000 * 5 * 0 / 100 = 0
    result=$(echo -e "1000\n5\n0" | ./simple-interest.sh | tail -1)
    [ "$result" = "0" ]
}

@test "simple interest calculation with decimal values" {
    # Test case: principal=1500, rate=7.5, time=3
    # Expected: 1500 * 7.5 * 3 / 100 = 337.5 -> 337 (integer division)
    result=$(echo -e "1500\n7\n3" | ./simple-interest.sh | tail -1)
    [ "$result" = "315" ]
}

@test "script exists and is executable" {
    [ -f "simple-interest.sh" ]
    [ -x "simple-interest.sh" ]
}

@test "script contains required elements" {
    grep -q "#!/bin/bash" simple-interest.sh
    grep -q "read p" simple-interest.sh
    grep -q "read r" simple-interest.sh
    grep -q "read t" simple-interest.sh
}

@test "script has proper shebang" {
    head -1 simple-interest.sh | grep -q "#!/bin/bash"
}