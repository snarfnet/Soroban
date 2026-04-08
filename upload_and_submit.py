#!/usr/bin/env python3
import jwt, time, json, urllib.request, hashlib, os

KEY_ID = "JYA5G4738Z"
ISSUER_ID = "2be0734f-943a-4d61-9dc9-5d9045c46fec"
with open("/Users/user/.appstoreconnect/private_keys/AuthKey_JYA5G4738Z.p8", "r") as f:
    PRIVATE_KEY = f.read()

APP_ID = "6761827077"
VERSION_ID = "65dae2e7-e63e-4774-b243-7077762ad42c"
EN_LOC_ID = "d73c90a5-b9ea-47e1-b2bc-f31211a026a4"

def get_token():
    now = int(time.time())
    return jwt.encode({"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}, PRIVATE_KEY, algorithm="ES256", headers={"kid": KEY_ID})

def api_get(path):
    req = urllib.request.Request("https://api.appstoreconnect.apple.com" + path,
        headers={"Authorization": "Bearer " + get_token()})
    return json.loads(urllib.request.urlopen(req).read())

def api_post(path, body):
    req = urllib.request.Request("https://api.appstoreconnect.apple.com" + path,
        data=json.dumps(body).encode("utf-8"),
        headers={"Authorization": "Bearer " + get_token(), "Content-Type": "application/json"}, method="POST")
    return json.loads(urllib.request.urlopen(req).read())

def api_patch(path, body):
    req = urllib.request.Request("https://api.appstoreconnect.apple.com" + path,
        data=json.dumps(body).encode("utf-8"),
        headers={"Authorization": "Bearer " + get_token(), "Content-Type": "application/json"}, method="PATCH")
    return json.loads(urllib.request.urlopen(req).read())

def upload_screenshot(loc_id, display_type, filepath):
    filename = os.path.basename(filepath)
    with open(filepath, "rb") as f:
        data = f.read()

    # Get or create screenshot set
    sets = api_get("/v1/appStoreVersionLocalizations/" + loc_id + "/appScreenshotSets")
    set_id = None
    for s in sets["data"]:
        if s["attributes"]["screenshotDisplayType"] == display_type:
            set_id = s["id"]
    if not set_id:
        result = api_post("/v1/appScreenshotSets", {
            "data": {
                "type": "appScreenshotSets",
                "attributes": {"screenshotDisplayType": display_type},
                "relationships": {"appStoreVersionLocalization": {"data": {"type": "appStoreVersionLocalizations", "id": loc_id}}}
            }
        })
        set_id = result["data"]["id"]

    # Reserve
    result = api_post("/v1/appScreenshots", {
        "data": {
            "type": "appScreenshots",
            "attributes": {"fileName": filename, "fileSize": len(data)},
            "relationships": {"appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}}
        }
    })
    ss_id = result["data"]["id"]
    ops = result["data"]["attributes"]["uploadOperations"]

    # Upload chunks
    for op in ops:
        chunk = data[op["offset"]:op["offset"]+op["length"]]
        headers = {h["name"]: h["value"] for h in op["requestHeaders"]}
        urllib.request.urlopen(urllib.request.Request(op["url"], data=chunk, headers=headers, method=op["method"]))

    # Commit
    api_patch("/v1/appScreenshots/" + ss_id, {
        "data": {"type": "appScreenshots", "id": ss_id, "attributes": {
            "uploaded": True, "sourceFileChecksum": hashlib.md5(data).hexdigest()
        }}
    })
    print("  Uploaded: " + filename)

# Get Japanese loc ID
ja_locs = api_get("/v1/appStoreVersions/" + VERSION_ID + "/appStoreVersionLocalizations")
JA_LOC_ID = None
for loc in ja_locs["data"]:
    if loc["attributes"]["locale"] == "ja":
        JA_LOC_ID = loc["id"]
print("JA Loc: " + str(JA_LOC_ID))

ss_dir = "/Users/user/Soroban/screenshots"

# Upload screenshots for EN
print("Uploading EN 6.7 inch screenshots...")
for f in ["01_main.png", "02_clear.png", "03_values.png"]:
    upload_screenshot(EN_LOC_ID, "APP_IPHONE_67", os.path.join(ss_dir, f))

print("Uploading EN 6.5 inch screenshots...")
for f in ["65_01_main.png", "65_02_clear.png", "65_03_values.png"]:
    upload_screenshot(EN_LOC_ID, "APP_IPHONE_65", os.path.join(ss_dir, f))

# Upload same for JA
if JA_LOC_ID:
    print("Uploading JA 6.7 inch screenshots...")
    for f in ["01_main.png", "02_clear.png", "03_values.png"]:
        upload_screenshot(JA_LOC_ID, "APP_IPHONE_67", os.path.join(ss_dir, f))
    print("Uploading JA 6.5 inch screenshots...")
    for f in ["65_01_main.png", "65_02_clear.png", "65_03_values.png"]:
        upload_screenshot(JA_LOC_ID, "APP_IPHONE_65", os.path.join(ss_dir, f))

# Wait for build
print("\nWaiting for build to be processed...")
for attempt in range(10):
    time.sleep(10)
    builds = api_get("/v1/builds?filter[app]=" + APP_ID + "&sort=-uploadedDate&limit=1")
    if builds["data"]:
        b = builds["data"][0]
        state = b["attributes"]["processingState"]
        print("  Build: " + b["id"] + " - " + state)
        if state == "VALID":
            BUILD_ID = b["id"]
            break
    else:
        print("  No builds yet...")
else:
    print("Build not ready, trying to proceed anyway...")
    BUILD_ID = None

# Link build
if BUILD_ID:
    try:
        api_patch("/v1/appStoreVersions/" + VERSION_ID + "/relationships/build", {
            "data": {"type": "builds", "id": BUILD_ID}
        })
        print("Build linked!")
    except Exception as e:
        print("Build link: " + str(e))

# Submit for review
try:
    result = api_post("/v1/reviewSubmissions", {
        "data": {"type": "reviewSubmissions", "relationships": {
            "app": {"data": {"type": "apps", "id": APP_ID}}
        }}
    })
    sub_id = result["data"]["id"]
    print("Submission created: " + sub_id)

    api_post("/v1/reviewSubmissionItems", {
        "data": {"type": "reviewSubmissionItems", "relationships": {
            "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": sub_id}},
            "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}
        }}
    })
    print("Version added to submission")

    api_patch("/v1/reviewSubmissions/" + sub_id, {
        "data": {"type": "reviewSubmissions", "id": sub_id, "attributes": {"submitted": True}}
    })
    print("SUBMITTED FOR REVIEW!")
except Exception as e:
    print("Submit error: " + str(e))

print("\nDone!")
