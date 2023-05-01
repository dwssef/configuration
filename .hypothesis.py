import requests
import json
import sys

if len(sys.argv) == 2:
    search_text = sys.argv[1]
else:
    print("need a search object")
    sys.exit()

user = "czy_1"
token = "6879--iHJH8waDbZ5iiJd2NufVuPcZRZjrO74Jzj8Xwyw4gw"
headers = {"Authorization": f"Bearer {token}"}

# endp = "https://api.hypothes.is/api/search?limit=200&user=czy_1&any=heap"
endp = f"https://api.hypothes.is/api/search?limit=200&user=czy_1&any={search_text}"

res = requests.get(endp, headers=headers)
# print(res.json())
r = res.json()

print(json.dumps(r))

dic = {}
for i in range(len(r['rows'])):
    dic["text"] = r['rows'][i]['text']
    dic["title"] = r['rows'][i]['document']['title'][0]
    # print(r['rows'][i]['target'][0]['selector'][2]['exact'])
    dic["exact"] = r['rows'][i]['target'][0]['selector'][2]['exact']
    dic["links"] = r['rows'][i]['links']['incontext']
    print(json.dumps(dic, indent=4))
