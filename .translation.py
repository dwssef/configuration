import requests
from bs4 import BeautifulSoup
import sys

args = sys.argv

language_list = ['Arabic', 'German', 'English', 'Spanish', 'French', 'Hebrew', 'Japanese', 'Dutch',
                 'Polish', 'Portuguese', 'Romanian', 'Russian', 'Turkish', "Chinese"]

first_language = args[1]
second_language = args[2]
word = args[3]


def get_response(first, second):
    headers = {'user-agent': 'some_browser'}
    try:
        response = requests.get(f'https://context.reverso.net/translation/{first.lower()}-{second.lower()}/{word}',
                                headers=headers)
        return response
    except requests.exceptions.ConnectionError:
        print('Something wrong with your internet connection')


def soup_words(lst=None):
    if lst is None:
        lst = []
    soup = BeautifulSoup(get_response(first_language, second_language).content, 'html.parser')
    words = soup.find_all('a', {'class': 'translation'})
    for i in words:
        lst.append(i.text.strip())
    return lst[1:]


def soup_examples(lst=None):
    if lst is None:
        lst = []
    soup = BeautifulSoup(get_response(first_language, second_language).content, 'html.parser')
    phrases_first_language = soup.find_all('div', {'class': 'src ltr'})
    phrases_second_language = soup.find_all('div', {'class': 'trg ltr'})
    for i in range(len(phrases_first_language)):
        try:
            lst.append(phrases_first_language[i].text.strip())
            lst.append(phrases_second_language[i].text.strip())
        except Exception:
            continue
    return lst




if second_language == 'all':
    language_list.remove(first_language.capitalize())
    for language in language_list:
        second_language = language
        lst_words = soup_words()
        lst_phrases = soup_examples()
        if len(lst_words) == 0 and len(lst_phrases) == 0:
            print(f'Sorry, unable to find {word}')
            break
        else:
            print(f'\n{second_language.capitalize()} Translations:')
            print(lst_words[0])

            print(f'\n{second_language.capitalize()} Examples:')
            print(lst_phrases[0])
            print(lst_phrases[1])


else:
    lst_words = soup_words()
    lst_phrases = soup_examples()
    if second_language.capitalize() not in language_list:
        print(f"Sorry, the program doesn't support {second_language}")
    else:
        if len(lst_words) == 0 and len(lst_phrases) == 0:
            print(f'Sorry, unable to find {word}')
        else:
            print(f'{second_language.capitalize()} Translations:')
            for index in range(5):
                print(lst_words[index])
            print(f'\n{second_language.capitalize()} Examples:')
            for index in range(0, 10, 2):
                print(lst_phrases[index])
                print(lst_phrases[index + 1], '\n')
