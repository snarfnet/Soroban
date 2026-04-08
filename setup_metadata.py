#!/usr/bin/env python3
import jwt, time, json, urllib.request

KEY_ID = "JYA5G4738Z"
ISSUER_ID = "2be0734f-943a-4d61-9dc9-5d9045c46fec"

def load_key():
    with open("/Users/user/.appstoreconnect/private_keys/AuthKey_JYA5G4738Z.p8", "r") as f:
        return f.read()

PRIVATE_KEY = load_key()

def get_token():
    now = int(time.time())
    return jwt.encode({"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}, PRIVATE_KEY, algorithm="ES256", headers={"kid": KEY_ID})

def api_get(path):
    token = get_token()
    req = urllib.request.Request("https://api.appstoreconnect.apple.com" + path, headers={"Authorization": "Bearer " + token})
    return json.loads(urllib.request.urlopen(req).read())

def api_post(path, body):
    token = get_token()
    data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request("https://api.appstoreconnect.apple.com" + path, data=data,
        headers={"Authorization": "Bearer " + token, "Content-Type": "application/json"}, method="POST")
    return json.loads(urllib.request.urlopen(req).read())

def api_patch(path, body):
    token = get_token()
    data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request("https://api.appstoreconnect.apple.com" + path, data=data,
        headers={"Authorization": "Bearer " + token, "Content-Type": "application/json"}, method="PATCH")
    return json.loads(urllib.request.urlopen(req).read())

# Find app
result = api_get("/v1/apps?filter[bundleId]=com.japanesesoroban.app")
APP_ID = result["data"][0]["id"]
print("App ID: " + APP_ID)

# Get version
result2 = api_get("/v1/apps/" + APP_ID + "/appStoreVersions")
VERSION_ID = result2["data"][0]["id"]
print("Version ID: " + VERSION_ID)

# Get EN localization
result3 = api_get("/v1/appStoreVersions/" + VERSION_ID + "/appStoreVersionLocalizations")
EN_LOC_ID = result3["data"][0]["id"]
print("EN Loc: " + EN_LOC_ID)

# 1. English metadata
desc_en = """Experience the art of Japanese calculation with the most realistic soroban (abacus) simulator.

Real Soroban brings a traditional 13-rod soroban to your iPhone with stunning realism:

- REALISTIC PHYSICS
  Tilt your device and watch beads respond to gravity, just like a real soroban. The gyroscope-powered physics make every interaction feel natural and satisfying.

- AUTHENTIC SOUND
  Every bead click is crafted to sound like real wooden beads striking the reckoning bar.

- BEAUTIFUL DESIGN
  Warm wood tones, diamond-shaped beads, and traditional dot markers create an authentic soroban experience.

- DIGITAL DISPLAY
  A built-in calculator display shows the current value, perfect for learning and verification.

- SIMPLE & INTUITIVE
  Tap or slide beads to move them. No complicated menus \u2014 just a beautiful, functional soroban."""

api_patch("/v1/appStoreVersionLocalizations/" + EN_LOC_ID, {
    "data": {
        "type": "appStoreVersionLocalizations", "id": EN_LOC_ID,
        "attributes": {
            "description": desc_en,
            "keywords": "soroban,abacus,japanese,calculator,math,education,traditional,arithmetic,beads,counting",
            "promotionalText": "The most realistic Japanese soroban simulator with gyroscope gravity physics and authentic wood sounds.",
            "supportUrl": "https://snarfnet.github.io/Soroban/support.html",
            "marketingUrl": "https://snarfnet.github.io/Soroban/"
        }
    }
})
print("1. English metadata set")

# 2. Japanese localization
desc_ja = """世界一リアルなそろばんシミュレーター。

Real Sorobanは、本物のそろばんの質感を再現した13桁のそろばんアプリです。

■ リアルな物理演算
端末を傾けると珠が重力に従って動きます。ジャイロセンサーによるリアルな物理演算で、本物のそろばんのような操作感を実現。

■ 本格的なサウンド
木製の珠が梁に当たる「パチパチ」という音をリアルに再現。

■ 美しいデザイン
温かみのある木目調、菱形の珠、伝統的な定位点を忠実に再現。

■ デジタル表示
現在の値をリアルタイムで表示。学習や確認に便利です。

■ シンプル操作
珠をタップまたはスライドするだけ。"""

try:
    api_post("/v1/appStoreVersionLocalizations", {
        "data": {
            "type": "appStoreVersionLocalizations",
            "attributes": {
                "locale": "ja",
                "description": desc_ja,
                "keywords": "そろばん,算盤,計算,珠算,暗算,教育,日本,伝統,電卓,数学",
                "promotionalText": "ジャイロセンサーで重力を再現、木の珠の音も本格的。世界一リアルなそろばんアプリ。",
                "supportUrl": "https://snarfnet.github.io/Soroban/support.html",
                "marketingUrl": "https://snarfnet.github.io/Soroban/"
            },
            "relationships": {
                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}
            }
        }
    })
    print("2. Japanese localization created")
except Exception as e:
    print("2. JA: " + str(e))

# 3. Copyright
api_patch("/v1/appStoreVersions/" + VERSION_ID, {
    "data": {"type": "appStoreVersions", "id": VERSION_ID, "attributes": {"copyright": "2026 Satoshi Amasaki"}}
})
print("3. Copyright set")

# 4. App info: categories
result_info = api_get("/v1/apps/" + APP_ID + "/appInfos")
INFO_ID = result_info["data"][0]["id"]

api_patch("/v1/appInfos/" + INFO_ID, {
    "data": {
        "type": "appInfos", "id": INFO_ID,
        "relationships": {
            "primaryCategory": {"data": {"type": "appCategories", "id": "EDUCATION"}},
            "secondaryCategory": {"data": {"type": "appCategories", "id": "UTILITIES"}}
        }
    }
})
print("4. Categories set")

# 5. Content rights
api_patch("/v1/apps/" + APP_ID, {
    "data": {"type": "apps", "id": APP_ID, "attributes": {"contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT"}}
})
print("5. Content rights set")

# 6. English app info subtitle + privacy
result_info_locs = api_get("/v1/appInfos/" + INFO_ID + "/appInfoLocalizations")
for loc in result_info_locs["data"]:
    if loc["attributes"]["locale"] == "en-US":
        api_patch("/v1/appInfoLocalizations/" + loc["id"], {
            "data": {"type": "appInfoLocalizations", "id": loc["id"], "attributes": {
                "subtitle": "Realistic Japanese Abacus",
                "privacyPolicyUrl": "https://snarfnet.github.io/Soroban/privacy.html"
            }}
        })
        print("6. English subtitle + privacy set")

# 7. Japanese app info
try:
    api_post("/v1/appInfoLocalizations", {
        "data": {
            "type": "appInfoLocalizations",
            "attributes": {
                "locale": "ja",
                "name": "Real Soroban",
                "subtitle": "リアルなそろばんシミュレーター",
                "privacyPolicyUrl": "https://snarfnet.github.io/Soroban/privacy.html"
            },
            "relationships": {"appInfo": {"data": {"type": "appInfos", "id": INFO_ID}}}
        }
    })
    print("7. Japanese app info created")
except Exception as e:
    print("7. JA info: " + str(e))

# 8. Price (free)
result_pp = api_get("/v1/apps/" + APP_ID + "/appPricePoints?filter[territory]=USA&limit=1")
FREE_PP = result_pp["data"][0]["id"]

try:
    api_post("/v1/appPriceSchedules", {
        "data": {
            "type": "appPriceSchedules",
            "relationships": {
                "app": {"data": {"type": "apps", "id": APP_ID}},
                "baseTerritory": {"data": {"type": "territories", "id": "USA"}},
                "manualPrices": {"data": [{"type": "appPrices", "id": "${price1}"}]}
            }
        },
        "included": [{"type": "appPrices", "id": "${price1}", "relationships": {
            "appPricePoint": {"data": {"type": "appPricePoints", "id": FREE_PP}}
        }}]
    })
    print("8. Price set to FREE")
except Exception as e:
    print("8. Price: " + str(e))

# 9. Age rating
result_age = api_get("/v1/appInfos/" + INFO_ID + "?include=ageRatingDeclaration")
AGE_ID = None
for inc in result_age.get("included", []):
    if inc["type"] == "ageRatingDeclarations":
        AGE_ID = inc["id"]

if AGE_ID:
    try:
        api_patch("/v1/ageRatingDeclarations/" + AGE_ID, {
            "data": {"type": "ageRatingDeclarations", "id": AGE_ID, "attributes": {
                "alcoholTobaccoOrDrugUseOrReferences": "NONE", "contests": "NONE",
                "gambling": False, "gamblingSimulated": "NONE", "horrorOrFearThemes": "NONE",
                "matureOrSuggestiveThemes": "NONE", "medicalOrTreatmentInformation": "NONE",
                "profanityOrCrudeHumor": "NONE", "sexualContentGraphicAndNudity": "NONE",
                "sexualContentOrNudity": "NONE", "violenceCartoonOrFantasy": "NONE",
                "violenceRealistic": "NONE", "violenceRealisticProlongedGraphicOrSadistic": "NONE",
                "unrestrictedWebAccess": False, "ageRatingOverride": None,
                "messagingAndChat": False, "lootBox": False, "userGeneratedContent": False,
                "advertising": True, "healthOrWellnessTopics": False,
                "parentalControls": False, "ageAssurance": False, "gunsOrOtherWeapons": "NONE"
            }}
        })
        print("9. Age rating set")
    except Exception as e:
        print("9. Age: " + str(e))

# 10. Review detail
try:
    api_post("/v1/appStoreReviewDetails", {
        "data": {
            "type": "appStoreReviewDetails",
            "attributes": {
                "contactFirstName": "Satoshi", "contactLastName": "Amasaki",
                "contactEmail": "snarfnet@gmail.com", "contactPhone": "+81 80 2368 9194",
                "demoAccountRequired": False,
                "notes": "Uses CoreMotion for gravity simulation. Motion data processed locally only. No account required."
            },
            "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}}
        }
    })
    print("10. Review detail created")
except Exception as e:
    print("10. Review: " + str(e))

print("\nAll metadata setup complete!")
print("APP_ID=" + APP_ID)
print("VERSION_ID=" + VERSION_ID)
print("EN_LOC_ID=" + EN_LOC_ID)
