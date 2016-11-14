from bs4 import BeautifulSoup as bs
import csv
import string
import os

def pull_poll_info(result):
    poll_name = [x.string for x in result.children][0]
    result2 = result.next_sibling.find('tbody')
    number = string.replace(result.next_sibling.next_sibling.text,'respondents','').strip()
    demographics = []
    # First get demographics
    for demo in  result2.find_all('td', {'class' : 'exit-poll__cell exit-poll__cell--answer'}):
        demo_char =  [x for x in  demo.children][1].string
        demo_val =  [x for x in  demo.children][-1].text
        poll_res = []
        for candidate in demo.next_siblings:
             poll_res.append(candidate.string)
        demographics.append([poll_name, number, demo_char, demo_val] + poll_res)
    return demographics
    
for fn in os.listdir('htmldata/'):
    if fn.endswith(".htm"):
        with open("htmldata/" + fn, 'rb') as f:
            soup = bs(f, 'html.parser')
            with open('output/%s.csv' % fn[:-4], 'wb') as outf:
                writer = csv.writer(outf)
                writer.writerow(['state', 'poll_type', 'sample_size', 'demographic', 'percentage', 'clinton', 'trump', 'other1','other2','other3'])
                for poll in soup.body.find_all('header', {'class' : 'exit-poll__header'}):
                    output = pull_poll_info(poll)
                    for line in output:
                        writer.writerow([fn[:-4]]+ line)
        

