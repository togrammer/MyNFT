import json
import random
import os

output_dir = "nft_metadata"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

image_cid = "QmZw3cApCvZ3mmUp1KT3bwYPpvB8MPzv9nhb52DbUfWVYY"

clothes_options = [("Jacket", 45), ("Suit", 25), ("Military", 10), ("Empty", 20)]
hair_options = [("Fade", 30), ("Mohawk", 25), ("Box", 35), ("Empty", 10)]
boots_options = [("Nike", 40), ("Adidas", 20), ("New Balance", 10), ("Empty", 30)]

def choose_attribute(options):
    rand = random.uniform(0, 100)
    cumulative = 0
    for item, chance in options:
        cumulative += chance
        if rand <= cumulative:
            return item
    return "Empty"

for token_id in range(100):
    clothes = choose_attribute(clothes_options)
    hair = choose_attribute(hair_options)
    boots = choose_attribute(boots_options)
    
    metadata = {
        "name": f"MyNFT #{token_id}",
        "description": "This is a unique NFT from MyNFT collection.",
        "image": f"ipfs://{image_cid}",
        "attributes": [
            {"trait_type": "Clothes", "value": clothes},
            {"trait_type": "Hair", "value": hair},
            {"trait_type": "Boots", "value": boots}
        ]
    }

    json_file_path = os.path.join(output_dir, f"{token_id}.json")
    with open(json_file_path, "w") as json_file:
        json.dump(metadata, json_file, indent=4)

print(f"Metadata for 100 NFTs has been generated in the {output_dir} directory.")