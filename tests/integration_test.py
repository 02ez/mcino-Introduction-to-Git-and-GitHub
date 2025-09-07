#!/usr/bin/env python3
"""
Integration tests for financial calculator scripts

This module tests the integration between different components
and validates end-to-end functionality.
"""

import subprocess
import sys
import os
import time
import tempfile
import json


class IntegrationTestRunner:
    """Integration test runner for financial calculators"""
    
    def __init__(self):
        self.test_results = []
        self.start_time = time.time()
    
    def log_test(self, test_name, passed, details=""):
        """Log test result"""
        result = {
            "test_name": test_name,
            "passed": passed,
            "details": details,
            "timestamp": time.time() - self.start_time
        }
        self.test_results.append(result)
        status = "PASS" if passed else "FAIL"
        print(f"[{status}] {test_name}: {details}")
    
    def test_shell_script_execution(self):
        """Test shell script execution with various inputs"""
        test_name = "Shell Script Execution"
        
        try:
            # Make script executable
            subprocess.run(['chmod', '+x', 'simple-interest.sh'], check=True)
            
            # Test case 1: Basic calculation
            process = subprocess.Popen(
                ['./simple-interest.sh'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            stdout, stderr = process.communicate(input="1000\n5\n2\n")
            
            if process.returncode == 0 and "100" in stdout:
                self.log_test(test_name + " - Basic", True, "Calculated 1000*5*2/100=100")
            else:
                self.log_test(test_name + " - Basic", False, f"Unexpected output: {stdout}")
                return
            
            # Test case 2: Zero values
            process = subprocess.Popen(
                ['./simple-interest.sh'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            stdout, stderr = process.communicate(input="0\n5\n2\n")
            
            if process.returncode == 0 and "0" in stdout.split('\n')[-2]:
                self.log_test(test_name + " - Zero Principal", True, "Handled zero principal correctly")
            else:
                self.log_test(test_name + " - Zero Principal", False, f"Unexpected output: {stdout}")
            
        except Exception as e:
            self.log_test(test_name, False, f"Exception: {str(e)}")
    
    def test_python_script_execution(self):
        """Test Python script execution"""
        test_name = "Python Script Execution"
        
        try:
            # Test case 1: Direct function call
            sys.path.insert(0, '.')
            import compound_interest
            
            result = compound_interest.compound_interest(1000, 2, 5)
            expected = 1102.5
            
            if abs(result - expected) < 0.01:
                self.log_test(test_name + " - Function Call", True, f"Result: {result}")
            else:
                self.log_test(test_name + " - Function Call", False, f"Expected {expected}, got {result}")
                return
            
            # Test case 2: Script execution via subprocess
            process = subprocess.Popen(
                [sys.executable, 'compound_interest.py'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            stdout, stderr = process.communicate(input="1000\n2\n5\n")
            
            if process.returncode == 0 and "1102.50" in stdout:
                self.log_test(test_name + " - Script Execution", True, "Interactive mode works")
            else:
                self.log_test(test_name + " - Script Execution", False, f"Output: {stdout}, Error: {stderr}")
            
        except Exception as e:
            self.log_test(test_name, False, f"Exception: {str(e)}")
    
    def test_cross_script_validation(self):
        """Test that both scripts produce mathematically consistent results"""
        test_name = "Cross-Script Validation"
        
        try:
            # For simple interest: SI = P * R * T / 100
            # For compound interest with 1 year: CI = P * (1 + R/100)^1 = P * (1 + R/100)
            # At 1 year, CI should be slightly higher than SI
            
            # Shell script (simple interest)
            subprocess.run(['chmod', '+x', 'simple-interest.sh'], check=True)
            process = subprocess.Popen(
                ['./simple-interest.sh'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            stdout, stderr = process.communicate(input="1000\n5\n1\n")
            si_result = float(stdout.split('\n')[-2])
            
            # Python script (compound interest)
            sys.path.insert(0, '.')
            import compound_interest
            ci_result = compound_interest.compound_interest(1000, 1, 5)
            
            # For 1 year, compound interest should be greater than or equal to simple interest
            # (CI includes principal, SI is just the interest amount)
            if ci_result >= (1000 + si_result):
                self.log_test(test_name, True, f"SI interest: {si_result}, CI total amount: {ci_result}")
            else:
                self.log_test(test_name, False, f"CI total ({ci_result}) should be >= SI principal + interest ({1000 + si_result})")
            
        except Exception as e:
            self.log_test(test_name, False, f"Exception: {str(e)}")
    
    def test_file_integrity(self):
        """Test file integrity and permissions"""
        test_name = "File Integrity"
        
        try:
            # Check required files exist
            required_files = ['simple-interest.sh', 'compound_interest.py', 'README.md', 'LICENSE']
            missing_files = []
            
            for file in required_files:
                if not os.path.exists(file):
                    missing_files.append(file)
            
            if not missing_files:
                self.log_test(test_name + " - Required Files", True, "All required files present")
            else:
                self.log_test(test_name + " - Required Files", False, f"Missing: {missing_files}")
            
            # Check shell script has shebang
            with open('simple-interest.sh', 'r') as f:
                first_line = f.readline().strip()
                if first_line.startswith('#!/bin/bash'):
                    self.log_test(test_name + " - Shell Shebang", True, "Correct shebang")
                else:
                    self.log_test(test_name + " - Shell Shebang", False, f"Wrong shebang: {first_line}")
            
            # Check Python script syntax
            with open('compound_interest.py', 'r') as f:
                content = f.read()
                try:
                    compile(content, 'compound_interest.py', 'exec')
                    self.log_test(test_name + " - Python Syntax", True, "Valid Python syntax")
                except SyntaxError as e:
                    self.log_test(test_name + " - Python Syntax", False, f"Syntax error: {e}")
            
        except Exception as e:
            self.log_test(test_name, False, f"Exception: {str(e)}")
    
    def test_performance_benchmarks(self):
        """Test performance benchmarks"""
        test_name = "Performance Benchmarks"
        
        try:
            # Test Python script performance
            import time
            import compound_interest
            
            start_time = time.time()
            for _ in range(1000):
                compound_interest.compound_interest(1000, 5, 7)
            python_time = time.time() - start_time
            
            if python_time < 1.0:  # Should complete 1000 calculations in under 1 second
                self.log_test(test_name + " - Python Performance", True, f"1000 calculations in {python_time:.3f}s")
            else:
                self.log_test(test_name + " - Python Performance", False, f"Too slow: {python_time:.3f}s")
            
            # Test shell script performance (fewer iterations due to subprocess overhead)
            subprocess.run(['chmod', '+x', 'simple-interest.sh'], check=True)
            start_time = time.time()
            for _ in range(10):
                process = subprocess.run(
                    ['./simple-interest.sh'],
                    input="1000\n5\n2\n",
                    text=True,
                    capture_output=True
                )
            shell_time = time.time() - start_time
            
            if shell_time < 5.0:  # Should complete 10 calculations in under 5 seconds
                self.log_test(test_name + " - Shell Performance", True, f"10 calculations in {shell_time:.3f}s")
            else:
                self.log_test(test_name + " - Shell Performance", False, f"Too slow: {shell_time:.3f}s")
            
        except Exception as e:
            self.log_test(test_name, False, f"Exception: {str(e)}")
    
    def run_all_tests(self):
        """Run all integration tests"""
        print("=== Financial Calculator Integration Tests ===")
        print(f"Starting at: {time.ctime()}")
        print()
        
        self.test_file_integrity()
        self.test_shell_script_execution()
        self.test_python_script_execution()
        self.test_cross_script_validation()
        self.test_performance_benchmarks()
        
        # Summary
        print()
        print("=== Test Summary ===")
        total_tests = len(self.test_results)
        passed_tests = len([t for t in self.test_results if t['passed']])
        failed_tests = total_tests - passed_tests
        
        print(f"Total Tests: {total_tests}")
        print(f"Passed: {passed_tests}")
        print(f"Failed: {failed_tests}")
        print(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%")
        
        # Save detailed results
        with open('integration_test_results.json', 'w') as f:
            json.dump({
                'summary': {
                    'total': total_tests,
                    'passed': passed_tests,
                    'failed': failed_tests,
                    'success_rate': (passed_tests/total_tests)*100
                },
                'tests': self.test_results
            }, f, indent=2)
        
        print(f"Detailed results saved to: integration_test_results.json")
        
        # Exit with appropriate code
        if failed_tests > 0:
            print(f"\n❌ Integration tests failed: {failed_tests} failures")
            sys.exit(1)
        else:
            print(f"\n✅ All integration tests passed!")
            sys.exit(0)


if __name__ == '__main__':
    # Change to script directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(os.path.dirname(script_dir))  # Go to repository root
    
    runner = IntegrationTestRunner()
    runner.run_all_tests()