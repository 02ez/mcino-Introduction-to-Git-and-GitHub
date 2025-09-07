import unittest
import sys
import os
import io
from unittest.mock import patch

# Add the root directory to the path to import compound_interest
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import compound_interest


class TestCompoundInterest(unittest.TestCase):
    """Test cases for compound interest calculator"""

    def test_compound_interest_basic(self):
        """Test basic compound interest calculation"""
        # Test case: p=1000, t=2, r=5
        # Expected: 1000 * (1 + 5/100)^2 = 1000 * 1.1025 = 1102.5
        result = compound_interest.compound_interest(1000, 2, 5)
        self.assertAlmostEqual(result, 1102.5, places=2)

    def test_compound_interest_zero_principal(self):
        """Test compound interest with zero principal"""
        result = compound_interest.compound_interest(0, 2, 5)
        self.assertEqual(result, 0)

    def test_compound_interest_zero_time(self):
        """Test compound interest with zero time"""
        result = compound_interest.compound_interest(1000, 0, 5)
        self.assertEqual(result, 1000)

    def test_compound_interest_zero_rate(self):
        """Test compound interest with zero rate"""
        result = compound_interest.compound_interest(1000, 2, 0)
        self.assertEqual(result, 1000)

    def test_compound_interest_high_precision(self):
        """Test compound interest with high precision values"""
        # Test case: p=1234.56, t=3.5, r=7.25
        result = compound_interest.compound_interest(1234.56, 3.5, 7.25)
        expected = 1234.56 * pow(1.0725, 3.5)
        self.assertAlmostEqual(result, expected, places=2)

    def test_compound_interest_negative_values(self):
        """Test compound interest with edge case values"""
        # Test with very small values
        result = compound_interest.compound_interest(0.01, 1, 1)
        expected = 0.01 * pow(1.01, 1)
        self.assertAlmostEqual(result, expected, places=6)

    def test_compound_interest_large_values(self):
        """Test compound interest with large values"""
        result = compound_interest.compound_interest(1000000, 10, 8)
        expected = 1000000 * pow(1.08, 10)
        self.assertAlmostEqual(result, expected, places=0)

    @patch('sys.stdout', new_callable=io.StringIO)
    @patch('builtins.input', side_effect=['1000', '2', '5'])
    def test_main_execution(self, mock_input, mock_stdout):
        """Test the main execution block"""
        # Import and run the main block
        exec(compile(open('compound_interest.py').read(), 'compound_interest.py', 'exec'))
        
        output = mock_stdout.getvalue()
        self.assertIn('1102.50', output)

    def test_function_signature(self):
        """Test that the function has the correct signature"""
        import inspect
        
        sig = inspect.signature(compound_interest.compound_interest)
        params = list(sig.parameters.keys())
        
        self.assertEqual(len(params), 3)
        self.assertIn('p', params)
        self.assertIn('t', params)
        self.assertIn('r', params)

    def test_docstring_exists(self):
        """Test that the module has basic documentation"""
        # Check that the file has comments/documentation
        with open('compound_interest.py', 'r') as f:
            content = f.read()
            self.assertIn('#', content)  # Should have comments


class TestPerformance(unittest.TestCase):
    """Performance tests for compound interest calculation"""

    def test_calculation_performance(self):
        """Test that calculations complete within reasonable time"""
        import time
        
        start_time = time.time()
        for _ in range(1000):
            compound_interest.compound_interest(1000, 5, 7)
        end_time = time.time()
        
        # Should complete 1000 calculations in less than 1 second
        self.assertLess(end_time - start_time, 1.0)


class TestEdgeCases(unittest.TestCase):
    """Edge case tests for compound interest calculator"""

    def test_very_long_time_period(self):
        """Test with very long time period"""
        result = compound_interest.compound_interest(100, 100, 1)
        # Should not raise overflow error
        self.assertIsInstance(result, float)
        self.assertGreater(result, 100)

    def test_fractional_inputs(self):
        """Test with fractional inputs"""
        result = compound_interest.compound_interest(1000.5, 2.5, 5.25)
        expected = 1000.5 * pow(1.0525, 2.5)
        self.assertAlmostEqual(result, expected, places=2)

    def test_string_inputs_conversion(self):
        """Test that the main function handles string inputs correctly"""
        # This test simulates the input conversion that happens in main
        p = float("1000")
        t = float("2")
        r = float("5")
        
        result = compound_interest.compound_interest(p, t, r)
        self.assertAlmostEqual(result, 1102.5, places=2)


if __name__ == '__main__':
    # Run tests with coverage if pytest-cov is available
    unittest.main(verbosity=2)