import requests
import json
import sys
import tomli

if len(sys.argv) == 2:
    search_text = sys.argv[1]
else:
    print("need a search object")
    sys.exit()

try:
    with open(".env", "rb") as f:
        toml_dict = tomli.load(f)
        if toml_dict:
            user = toml_dict["hy_user"]
            token = toml_dict["hy_token"]
        else:
            print("The .env file are empty")
except FileNotFoundError:
    print("The .env file does not exist.")
    sys.exit()

headers = {"Authorization": f"Bearer {token}"}

endp = f"https://api.hypothes.is/api/search?limit=200&user={user}&any={search_text}"

res = requests.get(endp, headers=headers)
r = res.json()

dic = {}
for i in range(len(r['rows'])):
    dic["text"] = r['rows'][i]['text']
    dic["title"] = r['rows'][i]['document']['title'][0]
    dic["exact"] = r['rows'][i]['target'][0]['selector'][2]['exact']
    dic["links"] = r['rows'][i]['links']['incontext']
    print(json.dumps(dic, ensure_ascii=False, indent=4))
