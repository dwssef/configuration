import os
import sys
import json
import requests
from rich import print
from bs4 import BeautifulSoup as bs

class OxfordScraper:

    def __init__(self, word, url=None):
        self.url = url
        self.word = word
        if self.url is None:
            self.url =  'https://www.oxfordlearnersdictionaries.com/definition/english'
        self.container = self.return_container()
        if self.container is None:
            return None

    def parse(self):
        self.url += '/' + self.word
        header = {"User-agent": "Mozilla/5.0"}
        response = requests.get(self.url, headers=header)
        if response.ok :
            return bs(response.text, 'lxml')
        return None

    def get_link(self):
        return self.parse().find('link', rel='canonical')['href']

    def return_container(self):
        """ Return Container which has all word related entry """
        soup = self.parse()
        if soup==None:
            return None
        container = soup.find("div", id="entryContent")
        return container

    def is_correct_entry(self):
        try:
            assert self.get_head_word() == self.word.lower().strip()
        except Exception as e:
            raise WrongEntryError
        return True

    def get_head_word(self):
        return self.container.find('h1', class_="headword").text.strip()

    def get_phonetics(self, container=None):
        """ Returns array with British and American IPA pronunciation """
        phones = {}
        try:
            if not container:
                container = self.container
            british = container.find("span", class_="phonetics").findChildren('div',
                                                                              class_="phons_br")
            n_am = container.find("span", class_="phonetics").findChildren('div',
                                                                           class_="phons_n_am")
            british_audio = british[0].find("div", class_="sound")['data-src-mp3']
            british_text = british[0].get_text(strip=True)
            phones['british'] = [british_text, british_audio]
            n_am_audio = n_am[0].find("div", class_="sound")['data-src-mp3']
            n_am_text = n_am[0].get_text(strip=True)
            phones['n_am'] = [n_am_text, n_am_audio]
        except Exception as e:
            print("wrong")
        finally:
            return phones

    def part_of_speech(self):
        """ Category of word"""
        try:
            return self.container.find("div", class_="webtop").findChildren("span",
                                                                        class_="pos")[0].text
        except Exception as e:
            return ''

    def verb_forms(self):
        """ if category of word is verb, returns html Table
        :returns list :- [{pronoun, verb_form, [british_phone, n_am_phone]}]
        """
        verbs = []
        if self.part_of_speech() == 'verb':
            try:
                rows = self.container.find("table", class_="verb_forms_table")
                for row in rows:
                    verb_form = row.find("td", class_="verb_form").text  # with pronouns
                    verbs_phones = self.get_phonetics(row)
                    # print('row', verb_form, verbs_phones)
                    verbs.append([verb_form, verbs_phones])
            except Exception as e:
                print('error', e)
        return verbs

    def get_examples(self, exmple_cont):
        """ Get all examples sentences"""

        examples = []
        try:
            for ul in exmple_cont:
                res = ul.find_all('li', htag="li")
                for txt in res:
                    examples.append(txt.text)
        except Exception as e:
            return ''
        finally:
            return examples

    def get_meanings(self):
        """ Returns :- {explanation : examples(list)} """
        meaning = {}
        try:
            container = self.container
            all_meaning_container = container.find_all("ol")
            for cont in all_meaning_container:
                headers = cont.find_all("li", class_="sense")
                for header in headers:
                    explanation = header.find("span", class_="def").text
                    examples = self.get_examples(header.find_all('ul', class_="examples"))
                    meaning[explanation] = examples
        except Exception as e:
            return ''
        finally:
            return meaning

    def get_idioms(self):
        """ returns: list of Idioms """
        idioms = []
        try:
            all_idioms = self.container.find_all("span", {"class": "idm-g"})
            for idiom in all_idioms:
                def_top = idiom.find("span", class_="idm").text
                sense_or_s = idiom.find_all("ol")

                for sense in sense_or_s:
                    temp = {}
                    for li in sense.find_all('li', class_="sense"):
                        def_ = li.find("span", class_="def").text
                        examples = li.find_all("ul", class_="examples")
                        exmpls = [idm_text for e in examples for idm_text in e.find("span", class_="x")]
                        if temp.get(def_):
                            temp[def_].append(exmpls)
                        else:
                            temp[def_] = exmpls
                    idioms.append({def_top : [temp]})
        except Exception as e:
            return ''
        finally:
            return idioms

    def get_phrasals(self):
        container = self.container
        results = {}
        try:
            phrasal_verbs_list = container.find("ul", class_='pvrefs').find_all('li')

            for li in phrasal_verbs_list:
                text = li.find("span", class_="xh").text
                link = li.a['href']
                phrasal = OxfordScraper(url=link)
                results[text] = phrasal.get_meanings()
        except Exception as e :
            return ''
        finally:
            return results

    def get_all_entries(self):
        """
        returns: word, getPhonetics, partOfSpeech, verbForms, Meanings, Idioms, Phrasals
        """
        return (
                self.get_head_word(),
                self.get_phonetics(),
                self.part_of_speech(),
                self.verb_forms(),
                self.get_meanings(),
                self.get_idioms(),
                self.get_phrasals()
            )

def main(toSearch, content):
    word, phone, category, verb_forms, meanings, idioms, phrasal = content
    dkey = ["word", "phone", "category", "verb_forms", "meanings", "idioms", "phrasal"]

    if word != toSearch:
        print(word, toSearch, 'not matched')
        return False

    print("[[cyan]{}[/cyan]]".format(word))
    print("  {} [blue]UK[/blue] [white]{}[/white] [blue]US[/blue] [white]{}[/white]".format(category,phone['british'][0],phone['n_am'][0]))
    for k in meanings.keys():
        print("  [cyan]* {}[/cyan]".format(k))
        for i in meanings[k]:
            print("    - {}".format(i))

if __name__ == '__main__':
    word = sys.argv[1]
    word = word.strip().replace(' & ', '-').replace(' ', '-').lower()
    oxfd = OxfordScraper(word=word)
    main(word, oxfd.get_all_entries())
