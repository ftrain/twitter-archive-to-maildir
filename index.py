import sqlite3
from mailbox import Maildir
from mailbox import MaildirMessage
import email.utils
import re
from email import encoders

from email.message import EmailMessage
from email.mime.text import MIMEText
from pprint import pprint
from tqdm import tqdm

def tweet_to_email(row):
    # pprint(row)
    from_addr = email.utils.formataddr(('Paul Ford',
                                        'ftrain@twitter'))
    to_addr = email.utils.formataddr(('Followers',
                                      'followers@twitter'))

    ft = row['full_text']
    subj = re.sub(r"\n.+", '', ft)

    # Let's go!
    m = MaildirMessage()

    # Not sure why I do this
    m.set_unixfrom('{} {}'.format('author', row['created_at']))

    m['From']=from_addr
    m['Reply-To']=from_addr
    m['To']=to_addr
    m['Subject']=subj
    m['Message-ID']='<{}@twitter>'.format(row['id'])
    if row['in_reply_to_status_id'] is not None:
        to_addr = email.utils.formataddr((row['in_reply_to_screen_name'],
                                          '{}@twitter'.format(row['in_reply_to_screen_name'])))
        m['In-Reply-To']='<{}@twitter>'.format(row['in_reply_to_status_id'])
        # print(row['in_reply_to_status_id'])
    m['Date'] = row['created_at']
    m['User-Agent'] = 'Twitter'
    m.add_header('X-Twitter-ID', row['id'])
    m.set_payload(ft.encode('utf-8'))
    return m

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

def __main__():
    md = Maildir('twitter', create=True)
    md.lock()    

    conn = sqlite3.connect('/home/ford/dev/triage/a.db')
    conn.row_factory = dict_factory    
    c = conn.cursor()

    for row in tqdm(c.execute('SELECT * FROM tweet')):
        m = tweet_to_email(row)
        md.add(m)
        md.flush()
        
    md.unlock()

__main__()
