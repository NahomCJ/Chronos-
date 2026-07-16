import json, os

MAIN = "http://chronos.us-east-1.elasticbeanstalk.com"
BH = "http://blockhub-env.us-east-1.elasticbeanstalk.com"

def auth_hdr():
    return [{"key": "Authorization", "value": "Bearer {{token}}"}]

def json_hdr():
    return [{"key": "Content-Type", "value": "application/json"}]

def auth_json_hdr():
    return auth_hdr() + json_hdr()

def raw_body(obj):
    return {"mode": "raw", "raw": json.dumps(obj, indent=2), "options": {"raw": {"language": "json"}}}

def get(name, path, public=False, base=BH):
    return {"name": name, "request": {"method": "GET", "header": [] if public else auth_hdr(), "url": base + path}}

def post(name, path, body, public=False, base=BH):
    return {"name": name, "request": {"method": "POST", "header": json_hdr() if public else auth_json_hdr(), "body": raw_body(body), "url": base + path}}

def delete(name, path):
    return {"name": name, "request": {"method": "DELETE", "header": auth_hdr(), "url": BH + path}}

blockhub_folder = {
    "name": "BlockHub",
    "item": [
        {
            "name": "Health",
            "item": [get("BlockHub Health", "/health", public=True)]
        },
        {
            "name": "Crypto — Market",
            "item": [
                get("Get Price — BTC", "/api/v1/crypto/price/BTC", public=True, base=MAIN),
                get("Get Price — ETH", "/api/v1/crypto/price/ETH", public=True, base=MAIN),
                get("Get Price — SOL", "/api/v1/crypto/price/SOL", public=True, base=MAIN),
                get("Get Price — UNI", "/api/v1/crypto/price/UNI", public=True, base=MAIN),
                get("Get Price — AAVE", "/api/v1/crypto/price/AAVE", public=True, base=MAIN),
                get("Get Price — LINK", "/api/v1/crypto/price/LINK", public=True, base=MAIN),
            ]
        },
        {
            "name": "Crypto — Portfolio",
            "item": [
                get("Get Crypto Dashboard", "/api/v1/crypto", base=MAIN),
                get("Get Crypto History", "/api/v1/crypto/history?page=1&limit=25", base=MAIN),
            ]
        },
        {
            "name": "Crypto — Trading",
            "item": [
                post("Buy Crypto", "/api/v1/crypto/buy", {
                    "asset": "BTC",
                    "amount_usd": 5
                }, base=MAIN),
                post("Sell Crypto", "/api/v1/crypto/sell", {
                    "asset": "BTC",
                    "amount_crypto": 0.0001
                }, base=MAIN),
            ]
        },
        {
            "name": "NFT — Browse",
            "item": [
                get("List All NFTs", "/api/v1/nft"),
                get("Get NFT by ID", "/api/v1/nft/{{nftId}}"),
                get("Get NFT History", "/api/v1/nft/{{nftId}}/history"),
                get("List Collections", "/api/v1/nft/collections"),
                get("Get Collection by ID", "/api/v1/nft/collections/{{collectionId}}"),
                {
                    "name": "Toggle NFT Favorite",
                    "request": {
                        "method": "POST",
                        "header": auth_hdr(),
                        "url": BH + "/api/v1/nft/{{nftId}}/favorite"
                    }
                }
            ]
        },
        {
            "name": "NFT — Minting",
            "item": [
                {
                    "name": "Mint NFT (upload image)",
                    "request": {
                        "method": "POST",
                        "header": auth_hdr(),
                        "body": {
                            "mode": "formdata",
                            "formdata": [
                                {"key": "image", "type": "file", "src": "", "description": "JPG/PNG/GIF/WEBP/MP4 — max 50 MB"},
                                {"key": "name", "value": "My NFT #1", "type": "text"},
                                {"key": "description", "value": "A unique digital asset", "type": "text"},
                                {"key": "collectionId", "value": "{{collectionId}}", "type": "text"},
                                {"key": "royaltyPercent", "value": "5", "type": "text"},
                                {"key": "attributes", "value": '[{"trait_type":"Rarity","value":"Rare"}]', "type": "text"},
                            ]
                        },
                        "url": BH + "/api/v1/minting/mint"
                    },
                    "event": [{
                        "listen": "test",
                        "script": {
                            "exec": [
                                "if ([200,201,202].includes(pm.response.code)) {",
                                "  var j = pm.response.json();",
                                "  if (j.jobId) { pm.collectionVariables.set('jobId', j.jobId); console.log('jobId saved: ' + j.jobId); }",
                                "}"
                            ],
                            "type": "text/javascript"
                        }
                    }]
                },
                get("Poll Mint Status", "/api/v1/minting/status/{{jobId}}"),
                post("Create NFT Collection", "/api/v1/minting/collection/create", {
                    "name": "Chronos Genesis",
                    "symbol": "CGS",
                    "description": "The first Chronos NFT collection",
                    "royaltyPercent": 5
                }),
            ]
        },
        {
            "name": "NFT — Marketplace",
            "item": [
                get("Browse Listings", "/api/v1/marketplace"),
                get("Get Listing by ID", "/api/v1/marketplace/{{listingId}}"),
                get("My Listings", "/api/v1/marketplace/my/listings"),
                get("My Purchases", "/api/v1/marketplace/my/purchases"),
                post("Create Listing", "/api/v1/marketplace/list", {
                    "nftId": "{{nftId}}",
                    "priceUsd": 250,
                    "currency": "USD"
                }),
                post("Buy NFT", "/api/v1/marketplace/buy", {
                    "listingId": "{{listingId}}",
                    "walletId": "{{walletId}}"
                }),
                delete("Cancel Listing", "/api/v1/marketplace/{{listingId}}"),
            ]
        },
        {
            "name": "NFT — Portfolio",
            "item": [
                get("My NFTs", "/api/v1/portfolio/nfts"),
                get("Portfolio Summary", "/api/v1/portfolio/summary"),
                get("Royalty Earnings", "/api/v1/portfolio/royalties"),
            ]
        },
    ]
}

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
path = os.path.join(root, "Chronos-API.postman_collection.json")

with open(path, "r", encoding="utf-8") as f:
    col = json.load(f)

# Add new variables
existing = {v["key"] for v in col["variable"]}
for key in ["nftId", "listingId", "collectionId", "jobId"]:
    if key not in existing:
        col["variable"].append({"key": key, "value": "", "type": "string"})

# Remove existing BlockHub folder if any (idempotent)
col["item"] = [folder for folder in col["item"] if folder.get("name") != "BlockHub"]

# Append fresh BlockHub folder
col["item"].append(blockhub_folder)

# Update description
col["info"]["description"] = (
    "Full Chronos API — all endpoints.\n\n"
    "Main API:  http://chronos.us-east-1.elasticbeanstalk.com\n"
    "BlockHub crypto: main API /api/v1/crypto\n"
    "BlockHub NFT:  http://blockhub-env.us-east-1.elasticbeanstalk.com\n\n"
    "STEP 1: Run Register or Login — token auto-saved to {{token}}\n"
    "STEP 2: All auth requests use {{token}} automatically\n"
    "STEP 3: BlockHub uses the same {{token}} — no separate login needed\n"
    "STEP 4: Replace {{nftId}}, {{listingId}}, {{collectionId}}, {{jobId}} from prior responses"
)

with open(path, "w", encoding="utf-8") as f:
    json.dump(col, f, indent=2, ensure_ascii=False)

bh_count = sum(len(sub.get("item", [])) for sub in blockhub_folder["item"])
print(f"Done! BlockHub folder added with {bh_count} requests.")
print(f"Total folders in collection: {len(col['item'])}")
