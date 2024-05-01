import unittest
import requests


class TestWeatherForecastApp(unittest.TestCase):
    def test_website_reachable(self):
        response = requests.get("http://127.0.0.1:5000/")
        self.assertEqual(response.status_code, 200, "website is down")


if __name__ == "__main__":
    unittest.main()
