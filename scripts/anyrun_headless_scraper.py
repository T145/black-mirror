#!/usr/bin/env python3
"""
Any.run Headless Scraper for Docker

Scrapes malicious domains from any.run submissions using headless Chrome.
"""

import re
import time
from datetime import datetime
from typing import Set
import argparse
import sys
import logging

try:
    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options
    from selenium.webdriver.common.by import By
    from selenium.common.exceptions import NoSuchElementException
except ImportError:
    print("Error: selenium not installed. Run: pip install selenium")
    sys.exit(1)

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class AnyRunHeadlessScraper:
    def __init__(self):
        self.driver = None
        self.base_url = 'https://app.any.run/submissions'

    # def setup_driver(self):
    #     """Setup headless Chrome driver for Docker environment."""
    #     chrome_options = Options()
    #     chrome_options.add_argument('--headless')
    #     chrome_options.add_argument('--no-sandbox')
    #     chrome_options.add_argument('--disable-dev-shm-usage')
    #     chrome_options.add_argument('--disable-gpu')
    #     chrome_options.add_argument('--window-size=1920,1080')
    #     chrome_options.add_argument('--user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')

    #     try:
    #         self.driver = webdriver.Chrome(options=chrome_options)
    #         self.driver.set_page_load_timeout(30)
    #         return True
    #     except Exception as e:
    #         logger.error(f"Failed to setup Chrome driver: {e}")
    #         return False

    def setup_driver(self):
        """Setup headless Chrome driver for Docker environment with error suppression."""
        chrome_options = Options()
        #chrome_options.add_argument('--headless')
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument('--disable-gpu')
        chrome_options.add_argument('--disable-software-rasterizer')
        chrome_options.add_argument('--disable-background-timer-throttling')
        chrome_options.add_argument('--disable-backgrounding-occluded-windows')
        chrome_options.add_argument('--disable-renderer-backgrounding')
        chrome_options.add_argument('--disable-features=TranslateUI')
        chrome_options.add_argument('--disable-ipc-flooding-protection')
        chrome_options.add_argument('--window-size=1920,1080')
        chrome_options.add_argument('--user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')

        # Suppress GPU and GCM errors
        chrome_options.add_argument('--disable-logging')
        chrome_options.add_argument('--disable-gpu-logging')
        chrome_options.add_argument('--log-level=3')
        chrome_options.add_argument('--silent')
        chrome_options.add_argument('--disable-extensions')
        chrome_options.add_argument('--disable-plugins')
        chrome_options.add_argument('--disable-web-security')
        chrome_options.add_argument('--disable-features=VizDisplayCompositor')
        chrome_options.add_argument('--disable-background-networking')
        chrome_options.add_argument('--disable-sync')
        chrome_options.add_argument('--disable-default-apps')
        chrome_options.add_argument('--disable-component-extensions-with-background-pages')

        # Disable GCM (Google Cloud Messaging) to prevent authentication errors
        chrome_options.add_argument('--disable-background-mode')
        chrome_options.add_argument('--disable-client-side-phishing-detection')
        chrome_options.add_argument('--disable-component-update')
        chrome_options.add_experimental_option('excludeSwitches', ['enable-logging'])
        chrome_options.add_experimental_option('useAutomationExtension', False)

        # Suppress console logs
        chrome_options.add_experimental_option('excludeSwitches', ['enable-automation'])
        chrome_options.add_experimental_option('useAutomationExtension', False)

        try:
            self.driver = webdriver.Chrome(options=chrome_options)
            self.driver.set_page_load_timeout(30)
            return True
        except Exception as e:
            logger.error(f"Failed to setup Chrome driver: {e}")
            return False

    def extract_domains_from_text(self, text: str) -> Set[str]:
        """Extract domains from text."""
        domains = set()

        # Extract domains from URLs
        url_pattern = r'https?://([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})'
        url_matches = re.findall(url_pattern, text, re.IGNORECASE)
        for match in url_matches:
            domain = match.split('/')[0].split(':')[0].lower()
            domains.add(domain)

        # Extract standalone domains
        domain_pattern = r'\b([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\b'
        domain_matches = re.findall(domain_pattern, text, re.IGNORECASE)

        for domain in domain_matches:
            if len(domain) < 4 or '..' in domain or re.match(r'^\d+\.\d+', domain):
                continue

            domain_lower = domain.lower()
            # Skip common legitimate domains
            skip_domains = [
                'any.run', 'app.any.run', 'microsoft.com', 'google.com', 'mozilla.org',
                'github.com', 'office.com', 'sharepoint.com', 'veeam.com', 'zoho.com'
            ]

            if domain_lower not in skip_domains and not any(x in domain_lower for x in ['microsoft', 'google', 'mozilla']):
                domains.add(domain_lower)

        return domains

    def is_current_day(self, date_str: str) -> bool:
        """Check if date is from current day."""
        current_date = datetime.now().date()
        today_str = current_date.strftime('%d %B %Y')
        return today_str in date_str

    def scrape_page(self, max_pages: int = 3) -> Set[str]:
        """Scrape malicious domains from any.run submissions."""
        if not self.setup_driver():
            return set()

        all_domains = set()

        try:
            logger.info(f"Loading {self.base_url}")
            self.driver.get(self.base_url)

            # Wait for page to load and dismiss cookie popup if present
            time.sleep(3)
            try:
                accept_btn = self.driver.find_element(By.XPATH, "//button[contains(text(), 'Accept')]")
                accept_btn.click()
                time.sleep(1)
            except NoSuchElementException:
                pass

            for page in range(max_pages):
                logger.info(f"Processing page {page + 1}")

                # Get page content
                page_source = self.driver.page_source

                # Look for current day submissions with malicious/suspicious activity
                if self.is_current_day(page_source):
                    # Extract domains from malicious/suspicious entries
                    malicious_patterns = ['Malicious activity', 'Suspicious activity']
                    for pattern in malicious_patterns:
                        if pattern in page_source:
                            # Extract domains near malicious indicators
                            pattern_start = page_source.find(pattern)
                            if pattern_start != -1:
                                # Get surrounding context (1000 chars before and after)
                                start = max(0, pattern_start - 1000)
                                end = min(len(page_source), pattern_start + 1000)
                                context = page_source[start:end]
                                domains = self.extract_domains_from_text(context)
                                all_domains.update(domains)

                # Try to go to next page
                if page < max_pages - 1:
                    try:
                        next_btn = self.driver.find_element(By.XPATH, "//button[contains(@class, 'next') or contains(text(), '>')]")
                        if next_btn.is_enabled():
                            next_btn.click()
                            time.sleep(3)
                        else:
                            break
                    except NoSuchElementException:
                        break

        except Exception as e:
            logger.error(f"Error during scraping: {e}")
        finally:
            if self.driver:
                self.driver.quit()

        return all_domains

    def save_domains(self, domains: Set[str], output_file: str):
        """Save domains to file."""
        if not domains:
            logger.warning("No domains found")
            return

        with open(output_file, 'w') as f:
            f.write(f"# Any.run malicious domains - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"# Total domains: {len(domains)}\n")
            f.write(f"# Source: {self.base_url}\n\n")

            for domain in sorted(domains):
                f.write(f"{domain}\n")

        logger.info(f"Saved {len(domains)} domains to {output_file}")

def main():
    parser = argparse.ArgumentParser(description='Scrape malicious domains from any.run')
    parser.add_argument('-o', '--output', default='anyrun_malicious_domains.txt', help='Output file')
    parser.add_argument('-p', '--pages', type=int, default=3, help='Max pages to scrape')
    args = parser.parse_args()

    scraper = AnyRunHeadlessScraper()
    domains = scraper.scrape_page(max_pages=args.pages)

    if domains:
        scraper.save_domains(domains, args.output)
        print(f"Successfully scraped {len(domains)} malicious domains!")
    else:
        print("No malicious domains found for today.")
        sys.exit(1)

if __name__ == '__main__':
    main()
