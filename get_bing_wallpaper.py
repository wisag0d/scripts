#!/bin/python
"""
This script well automatic download daily wallpaper from bing.
"""
import sys, os
import requests as res
from bs4 import BeautifulSoup as bs

WEBSITE_LINK = "https://bing.gifposter.com"
SAVE_PATH = sys.argv[1]

def main():
    """
    main jobs will be write here.
    """
    page_link = get_today_page()
    response = get_pictrue_link(f'{WEBSITE_LINK}{page_link}')
    if download_picture(response, SAVE_PATH):
        os.system("notify-send -i 'face-wink' 'Script Notify' '今日桌布下載完成'")
    else:
        os.system("notify-send -i 'dialog-error' 'Script Notify' '今日桌布下載失敗'")

def get_today_page():
    """
    check today wallpaper page.
    """
    page = res.get(WEBSITE_LINK)
    soup = bs(page.content, 'html.parser')
    return soup.select_one(".dayimg .flex a").get("href")

def get_pictrue_link(link):
    page = res.get(link)
    soup = bs(page.content, 'html.parser')
    return soup.select_one("#ogimg").get("content")

def download_picture(link, path):
    picture = res.get(link)
    if picture.headers.get('content-type') == 'image/jpeg':
        open(path, 'wb').write(picture.content)
        return bool(True)
    else:
        return bool(False)

if __name__ == "__main__":
    main()
