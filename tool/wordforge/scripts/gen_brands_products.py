#!/usr/bin/env python3
"""Generate the brands_products word pack for Hushbug WordForge.

Creates ~120 high-quality brand/product words with template-based generation
(no LLM needed). Outputs JSON matching the Flutter v2 pack format.
"""

from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any

from wordforge.database.models import (
    Hint,
    ImposterWord,
    PackMeta,
    RecordStatus,
    WordDifficulty,
    WordPack,
    WordRecord,
)
from wordforge.pipeline.export_pipeline import FlutterExporter
from wordforge.pipeline.validation_pipeline import ValidationPipeline
from wordforge.validators.text_utils import leaks_imposter, normalize

BRAND_DATA = [    # Technology (17 words)
    {
        "word": "Apple",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "A premium consumer electronics company known for iPhone and Mac computers.",
        "tags": ["tech", "consumer-electronics", "smartphones", "computers"],
    },
    {
        "word": "Microsoft",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "A global software corporation famous for Windows and Office productivity suite.",
        "tags": ["tech", "software", "operating-systems", "cloud"],
    },
    {
        "word": "Google",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "An internet search and advertising giant that also makes Android and cloud services.",
        "tags": ["tech", "search", "advertising", "android"],
    },
    {
        "word": "Amazon",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "An e-commerce and cloud computing company that started as an online bookstore.",
        "tags": ["tech", "ecommerce", "cloud", "logistics"],
    },
    {
        "word": "Meta",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "The parent company of Facebook Instagram and WhatsApp focused on social connection.",
        "tags": ["tech", "social-media", "vr", "metaverse"],
    },
    {
        "word": "Tesla",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "An electric vehicle and clean energy company led by Elon Musk.",
        "tags": ["tech", "automotive", "electric-vehicles", "energy"],
    },
    {
        "word": "Netflix",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "A streaming service that pioneered on-demand video entertainment worldwide.",
        "tags": ["tech", "streaming", "entertainment", "media"],
    },
    {
        "word": "Spotify",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "A music streaming platform with millions of songs and podcasts.",
        "tags": ["tech", "music", "streaming", "audio"],
    },
    {
        "word": "Uber",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "A ride-hailing app that connects passengers with drivers globally.",
        "tags": ["tech", "ride-sharing", "transport", "gig-economy"],
    },
    {
        "word": "Airbnb",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "A marketplace for short-term home rentals and travel experiences.",
        "tags": ["tech", "travel", "hospitality", "sharing-economy"],
    },
    {
        "word": "NVIDIA",
        "subcategory": "Technology",
        "difficulty": "hard",
        "description": "A semiconductor company that designs graphics processing units for gaming and AI.",
        "tags": ["tech", "semiconductors", "gpus", "ai"],
    },
    {
        "word": "AMD",
        "subcategory": "Technology",
        "difficulty": "hard",
        "description": "A chipmaker competing in processors and graphics cards for computers.",
        "tags": ["tech", "semiconductors", "processors", "gpus"],
    },
    {
        "word": "Intel",
        "subcategory": "Technology",
        "difficulty": "medium",
        "description": "A semiconductor giant that makes processors for most personal computers.",
        "tags": ["tech", "semiconductors", "processors", "x86"],
    },
    {
        "word": "Samsung",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "A Korean conglomerate making phones appliances and memory chips.",
        "tags": ["tech", "smartphones", "displays", "memory"],
    },
    {
        "word": "Sony",
        "subcategory": "Technology",
        "difficulty": "easy",
        "description": "A Japanese electronics and entertainment company with PlayStation consoles.",
        "tags": ["tech", "gaming", "electronics", "entertainment"],
    },
    {
        "word": "LG",
        "subcategory": "Technology",
        "difficulty": "medium",
        "description": "A Korean electronics brand known for displays and home appliances.",
        "tags": ["tech", "displays", "appliances", "korean"],
    },
    {
        "word": "GoPro",
        "subcategory": "Technology",
        "difficulty": "medium",
        "description": "An action camera brand for extreme sports and adventure recording.",
        "tags": ["tech", "action-cameras", "sports", "video"],
    },

    # Food & Beverage (16 words)
    {
        "word": "Coca-Cola",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "The world's most recognized carbonated soft drink brand since 1886.",
        "tags": ["beverage", "soft-drink", "soda", "global"],
    },
    {
        "word": "Pepsi",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "A major cola competitor to Coca-Cola with a sweeter taste profile.",
        "tags": ["beverage", "soft-drink", "cola", "rival"],
    },
    {
        "word": "Starbucks",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "A global coffeehouse chain known for customized espresso beverages.",
        "tags": ["beverage", "coffee", "cafe", "chain"],
    },
    {
        "word": "McDonald's",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "The largest fast-food restaurant chain serving burgers and fries worldwide.",
        "tags": ["food", "fast-food", "burgers", "franchise"],
    },
    {
        "word": "KFC",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "A fast-food chain specializing in fried chicken with secret herbs.",
        "tags": ["food", "fast-food", "chicken", "franchise"],
    },
    {
        "word": "Burger King",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "A burger chain known for flame-grilled Whopper sandwiches.",
        "tags": ["food", "fast-food", "burgers", "flame-grilled"],
    },
    {
        "word": "Subway",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "A sandwich franchise where subs are made fresh in front of you.",
        "tags": ["food", "fast-food", "sandwiches", "franchise"],
    },
    {
        "word": "Domino's",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "A pizza delivery chain promising thirty-minute delivery guarantee.",
        "tags": ["food", "pizza", "delivery", "chain"],
    },
    {
        "word": "Oreo",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "A chocolate sandwich cookie with creme filling from Nabisco.",
        "tags": ["food", "cookies", "snacks", "chocolate"],
    },
    {
        "word": "KitKat",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "A chocolate-covered wafer bar with a snap-break design.",
        "tags": ["food", "chocolate", "wafer", "snack"],
    },
    {
        "word": "M&M's",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "Colorful button-shaped chocolates that melt in your mouth not hands.",
        "tags": ["food", "chocolate", "candy", "colorful"],
    },
    {
        "word": "Snickers",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "A chocolate bar with nougat caramel and peanuts satisfying hunger.",
        "tags": ["food", "chocolate", "candy-bar", "peanuts"],
    },
    {
        "word": "Pringles",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "Stackable potato crisps in a distinctive cylindrical can.",
        "tags": ["food", "chips", "potato", "can"],
    },
    {
        "word": "Lay's",
        "subcategory": "Food & Beverage",
        "difficulty": "easy",
        "description": "A potato chip brand with countless flavor varieties globally.",
        "tags": ["food", "chips", "potato", "flavors"],
    },
    {
        "word": "Ben & Jerry's",
        "subcategory": "Food & Beverage",
        "difficulty": "medium",
        "description": "A premium ice cream brand with creative chunk-filled flavors.",
        "tags": ["food", "ice-cream", "premium", "chunks"],
    },
    {
        "word": "Häagen-Dazs",
        "subcategory": "Food & Beverage",
        "difficulty": "medium",
        "description": "A super-premium ice cream brand with dense rich texture.",
        "tags": ["food", "ice-cream", "super-premium", "dense"],
    },

    # Fashion & Apparel (16 words)
    {
        "word": "Nike",
        "subcategory": "Fashion",
        "difficulty": "easy",
        "description": "A sportswear giant with swoosh logo and Just Do It slogan.",
        "tags": ["fashion", "sportswear", "sneakers", "athletic"],
    },
    {
        "word": "Adidas",
        "subcategory": "Fashion",
        "difficulty": "easy",
        "description": "A German sportswear brand with three-stripe logo and Boost foam.",
        "tags": ["fashion", "sportswear", "sneakers", "german"],
    },
    {
        "word": "Puma",
        "subcategory": "Fashion",
        "difficulty": "easy",
        "description": "A German athletic brand with leaping cat logo and Suede classics.",
        "tags": ["fashion", "sportswear", "sneakers", "german"],
    },
    {
        "word": "Under Armour",
        "subcategory": "Fashion",
        "difficulty": "medium",
        "description": "An American performance apparel brand known for compression gear.",
        "tags": ["fashion", "sportswear", "performance", "compression"],
    },
    {
        "word": "New Balance",
        "subcategory": "Fashion",
        "difficulty": "medium",
        "description": "A Boston-based sneaker brand with numbered models and made-in-USA lines.",
        "tags": ["fashion", "sneakers", "running", "made-in-usa"],
    },
    {
        "word": "Reebok",
        "subcategory": "Fashion",
        "difficulty": "medium",
        "description": "A fitness brand with CrossFit heritage and classic leather sneakers.",
        "tags": ["fashion", "sportswear", "fitness", "crossfit"],
    },
    {
        "word": "Asics",
        "subcategory": "Fashion",
        "difficulty": "hard",
        "description": "A Japanese running shoe brand with Gel cushioning technology.",
        "tags": ["fashion", "running", "gel", "japanese"],
    },
    {
        "word": "Saucony",
        "subcategory": "Fashion",
        "difficulty": "hard",
        "description": "An American running shoe brand with Endorphin speed models.",
        "tags": ["fashion", "running", "endorphin", "american"],
    },
    {
        "word": "Hoka",
        "subcategory": "Fashion",
        "difficulty": "hard",
        "description": "A maximalist running shoe brand with oversized midsoles.",
        "tags": ["fashion", "running", "maximalist", "cushioning"],
    },
    {
        "word": "On Running",
        "subcategory": "Fashion",
        "difficulty": "hard",
        "description": "A Swiss running brand with CloudTec cushioning pods.",
        "tags": ["fashion", "running", "swiss", "cloudtec"],
    },
    {
        "word": "Levi's",
        "subcategory": "Fashion",
        "difficulty": "easy",
        "description": "The original blue jeans brand with red tab since 1873.",
        "tags": ["fashion", "denim", "jeans", "heritage"],
    },
    {
        "word": "Wrangler",
        "subcategory": "Fashion",
        "difficulty": "medium",
        "description": "A Western-style denim brand owned by Kontoor Brands.",
        "tags": ["fashion", "denim", "western", "workwear"],
    },
    {
        "word": "Calvin Klein",
        "subcategory": "Fashion",
        "difficulty": "medium",
        "description": "An American minimalist fashion house known for underwear and jeans.",
        "tags": ["fashion", "underwear", "jeans", "minimalist"],
    },
    {
        "word": "Ralph Lauren",
        "subcategory": "Fashion",
        "difficulty": "medium",
        "description": "An American luxury brand with polo player logo and preppy aesthetic.",
        "tags": ["fashion", "luxury", "polo", "preppy"],
    },
    {
        "word": "Gap",
        "subcategory": "Fashion",
        "difficulty": "easy",
        "description": "A basic casual wear retailer with logo hoodies and denim.",
        "tags": ["fashion", "casual", "basics", "american"],
    },
    {
        "word": "Uniqlo",
        "subcategory": "Fashion",
        "difficulty": "easy",
        "description": "A Japanese basics brand with Heattech and AIRism technology.",
        "tags": ["fashion", "basics", "japanese", "heattech"],
    },

    # Automotive (13 words)
    {
        "word": "Toyota",
        "subcategory": "Automotive",
        "difficulty": "easy",
        "description": "A Japanese automaker known for reliability and hybrid Prius.",
        "tags": ["automotive", "japanese", "reliable", "hybrid"],
    },
    {
        "word": "Honda",
        "subcategory": "Automotive",
        "difficulty": "easy",
        "description": "A Japanese brand with Civic Accord and motorcycle heritage.",
        "tags": ["automotive", "japanese", "civic", "motorcycles"],
    },
    {
        "word": "Ford",
        "subcategory": "Automotive",
        "difficulty": "easy",
        "description": "An American auto pioneer with F-Series trucks and Mustang.",
        "tags": ["automotive", "american", "trucks", "mustang"],
    },
    {
        "word": "Chevrolet",
        "subcategory": "Automotive",
        "difficulty": "easy",
        "description": "An American GM brand with Silverado and Corvette sports car.",
        "tags": ["automotive", "american", "silverado", "corvette"],
    },
    {
        "word": "BMW",
        "subcategory": "Automotive",
        "difficulty": "easy",
        "description": "A German luxury brand with kidney grille and Ultimate Driving Machine.",
        "tags": ["automotive", "german", "luxury", "performance"],
    },
    {
        "word": "Mercedes-Benz",
        "subcategory": "Automotive",
        "difficulty": "easy",
        "description": "A German luxury brand with three-pointed star and S-Class.",
        "tags": ["automotive", "german", "luxury", "s-class"],
    },
    {
        "word": "Audi",
        "subcategory": "Automotive",
        "difficulty": "easy",
        "description": "A German brand with four rings and Quattro all-wheel drive.",
        "tags": ["automotive", "german", "quattro", "rings"],
    },
    {
        "word": "Volkswagen",
        "subcategory": "Automotive",
        "difficulty": "easy",
        "description": "A German people's car brand with Beetle and Golf icons.",
        "tags": ["automotive", "german", "beetle", "golf"],
    },
    {
        "word": "Porsche",
        "subcategory": "Automotive",
        "difficulty": "medium",
        "description": "A German sports car maker with 911 rear-engine legend.",
        "tags": ["automotive", "german", "sports-car", "911"],
    },
    {
        "word": "Ferrari",
        "subcategory": "Automotive",
        "difficulty": "medium",
        "description": "An Italian supercar brand with prancing horse and Rosso Corsa.",
        "tags": ["automotive", "italian", "supercar", "racing"],
    },
    {
        "word": "Lamborghini",
        "subcategory": "Automotive",
        "difficulty": "medium",
        "description": "An Italian exotic car brand with scissor doors and V12.",
        "tags": ["automotive", "italian", "exotic", "v12"],
    },
    {
        "word": "Rivian",
        "subcategory": "Automotive",
        "difficulty": "hard",
        "description": "An American electric truck startup with R1T and R1S.",
        "tags": ["automotive", "electric", "truck", "startup"],
    },
    {
        "word": "Lucid",
        "subcategory": "Automotive",
        "difficulty": "hard",
        "description": "An American luxury EV with Air sedan and Gravity SUV.",
        "tags": ["automotive", "electric", "luxury", "air"],
    },

    # Entertainment (14 words)
    {
        "word": "Disney",
        "subcategory": "Entertainment",
        "difficulty": "easy",
        "description": "A media empire with Mickey Mouse Marvel Star Wars and theme parks.",
        "tags": ["entertainment", "media", "theme-parks", "animation"],
    },
    {
        "word": "Warner Bros",
        "subcategory": "Entertainment",
        "difficulty": "medium",
        "description": "A Hollywood studio with DC Comics Harry Potter and Looney Tunes.",
        "tags": ["entertainment", "studio", "dc-comics", "harry-potter"],
    },
    {
        "word": "Universal",
        "subcategory": "Entertainment",
        "difficulty": "medium",
        "description": "A film studio and theme park with Minions and Jurassic Park.",
        "tags": ["entertainment", "studio", "theme-park", "minions"],
    },
    {
        "word": "Paramount",
        "subcategory": "Entertainment",
        "difficulty": "hard",
        "description": "A historic studio with mountain logo and Mission Impossible.",
        "tags": ["entertainment", "studio", "mission-impossible", "mountain"],
    },
    {
        "word": "Sony Pictures",
        "subcategory": "Entertainment",
        "difficulty": "hard",
        "description": "A film studio with Spider-Man and Ghostbusters franchises.",
        "tags": ["entertainment", "studio", "spider-man", "sony"],
    },
    {
        "word": "Marvel",
        "subcategory": "Entertainment",
        "difficulty": "easy",
        "description": "A comic universe with Avengers X-Men and Cinematic Universe.",
        "tags": ["entertainment", "comics", "mcu", "superheroes"],
    },
    {
        "word": "DC Comics",
        "subcategory": "Entertainment",
        "difficulty": "easy",
        "description": "A comic publisher with Superman Batman Wonder Woman and Justice League.",
        "tags": ["entertainment", "comics", "superheroes", "justice-league"],
    },
    {
        "word": "Pixar",
        "subcategory": "Entertainment",
        "difficulty": "easy",
        "description": "An animation studio with Toy Story Finding Nemo and lamps.",
        "tags": ["entertainment", "animation", "toy-story", "disney"],
    },
    {
        "word": "DreamWorks",
        "subcategory": "Entertainment",
        "difficulty": "medium",
        "description": "An animation studio with Shrek Kung Fu Panda and Trolls.",
        "tags": ["entertainment", "animation", "shrek", "kung-fu-panda"],
    },
    {
        "word": "Illumination",
        "subcategory": "Entertainment",
        "difficulty": "medium",
        "description": "An animation studio with Minions Despicable Me and Mario.",
        "tags": ["entertainment", "animation", "minions", "despicable-me"],
    },
    {
        "word": "Nintendo",
        "subcategory": "Entertainment",
        "difficulty": "easy",
        "description": "A Japanese gaming giant with Mario Zelda Pokemon and Switch.",
        "tags": ["entertainment", "gaming", "nintendo", "mario"],
    },
    {
        "word": "PlayStation",
        "subcategory": "Entertainment",
        "difficulty": "easy",
        "description": "A Sony gaming brand with DualSense controller and exclusives.",
        "tags": ["entertainment", "gaming", "playstation", "sony"],
    },
    {
        "word": "Xbox",
        "subcategory": "Entertainment",
        "difficulty": "easy",
        "description": "A Microsoft gaming brand with Game Pass and Halo series.",
        "tags": ["entertainment", "gaming", "xbox", "microsoft"],
    },
    {
        "word": "Steam",
        "subcategory": "Entertainment",
        "difficulty": "easy",
        "description": "A Valve digital game store with Summer Sale and Workshop.",
        "tags": ["entertainment", "gaming", "pc", "valve"],
    },

    # Home & Kitchen (10 words)
    {
        "word": "IKEA",
        "subcategory": "Home",
        "difficulty": "easy",
        "description": "A Swedish flat-pack furniture giant with meatballs and maze stores.",
        "tags": ["home", "furniture", "swedish", "flat-pack"],
    },
    {
        "word": "Dyson",
        "subcategory": "Home",
        "difficulty": "medium",
        "description": "A British vacuum and hair tool brand with cyclone tech.",
        "tags": ["home", "vacuum", "hair-tools", "cyclone"],
    },
    {
        "word": "KitchenAid",
        "subcategory": "Home",
        "difficulty": "medium",
        "description": "An iconic stand mixer brand in countless colors.",
        "tags": ["home", "kitchen", "stand-mixer", "iconic"],
    },
    {
        "word": "Instant Pot",
        "subcategory": "Home",
        "difficulty": "medium",
        "description": "A multi-cooker that pressure cooks slow cooks and yogurts.",
        "tags": ["home", "kitchen", "multi-cooker", "pressure-cooker"],
    },
    {
        "word": "Ninja",
        "subcategory": "Home",
        "difficulty": "hard",
        "description": "A kitchen appliance brand with blenders and air fryers.",
        "tags": ["home", "kitchen", "blenders", "air-fryer"],
    },
    {
        "word": "Vitamix",
        "subcategory": "Home",
        "difficulty": "hard",
        "description": "A commercial-grade blender that pulverizes anything.",
        "tags": ["home", "blender", "commercial-grade", "powerful"],
    },
    {
        "word": "Le Creuset",
        "subcategory": "Home",
        "difficulty": "hard",
        "description": "A French enameled cast iron cookware in vibrant colors.",
        "tags": ["home", "cookware", "french", "cast-iron"],
    },
    {
        "word": "Tefal",
        "subcategory": "Home",
        "difficulty": "medium",
        "description": "A non-stick cookware pioneer with Thermo-Spot indicator.",
        "tags": ["home", "cookware", "non-stick", "thermo-spot"],
    },
    {
        "word": "Weber",
        "subcategory": "Home",
        "difficulty": "medium",
        "description": "A kettle grill brand that defined backyard barbecue.",
        "tags": ["home", "grill", "barbecue", "kettle"],
    },
    {
        "word": "Traeger",
        "subcategory": "Home",
        "difficulty": "hard",
        "description": "A wood-pellet grill with WiFi temperature control.",
        "tags": ["home", "grill", "pellet", "wifi"],
    },

    # Sports (9 words)
    {
        "word": "Wilson",
        "subcategory": "Sports",
        "difficulty": "medium",
        "description": "A sporting goods brand with tennis rackets and NFL footballs.",
        "tags": ["sports", "tennis", "football", "nfl"],
    },
    {
        "word": "Spalding",
        "subcategory": "Sports",
        "difficulty": "medium",
        "description": "A basketball brand with official NBA game ball heritage.",
        "tags": ["sports", "basketball", "nba", "official-ball"],
    },
    {
        "word": "Rawlings",
        "subcategory": "Sports",
        "difficulty": "hard",
        "description": "A baseball glove brand with Heart of the Hide leather.",
        "tags": ["sports", "baseball", "gloves", "heart-of-hide"],
    },
    {
        "word": "Easton",
        "subcategory": "Sports",
        "difficulty": "hard",
        "description": "A bat and hockey equipment brand for diamond and ice.",
        "tags": ["sports", "baseball", "hockey", "bats"],
    },
    {
        "word": "Bauer",
        "subcategory": "Sports",
        "difficulty": "hard",
        "description": "A hockey equipment brand with Vapor and Supreme lines.",
        "tags": ["sports", "hockey", "vapor", "supreme"],
    },
    {
        "word": "CCM",
        "subcategory": "Sports",
        "difficulty": "hard",
        "description": "A hockey brand with Jetspeed and Ribcor stick families.",
        "tags": ["sports", "hockey", "jetspeed", "ribcor"],
    },
    {
        "word": "Titleist",
        "subcategory": "Sports",
        "difficulty": "medium",
        "description": "A golf brand with Pro V1 ball and Scotty Cameron putters.",
        "tags": ["sports", "golf", "pro-v1", "scotty-cameron"],
    },
    {
        "word": "Callaway",
        "subcategory": "Sports",
        "difficulty": "medium",
        "description": "A golf brand with Epic drivers and Chrome Soft balls.",
        "tags": ["sports", "golf", "epic", "chrome-soft"],
    },
    {
        "word": "TaylorMade",
        "subcategory": "Sports",
        "difficulty": "medium",
        "description": "A golf brand with SIM drivers and Spider putters.",
        "tags": ["sports", "golf", "sim", "spider"],
    },

    # Beauty & Personal Care (12 words)
    {
        "word": "L'Oréal",
        "subcategory": "Beauty",
        "difficulty": "medium",
        "description": "A French cosmetics giant with Because You're Worth It.",
        "tags": ["beauty", "cosmetics", "french", "worth-it"],
    },
    {
        "word": "Estée Lauder",
        "subcategory": "Beauty",
        "difficulty": "medium",
        "description": "A luxury beauty brand with Advanced Night Repair serum.",
        "tags": ["beauty", "luxury", "skincare", "night-repair"],
    },
    {
        "word": "MAC",
        "subcategory": "Beauty",
        "difficulty": "medium",
        "description": "A professional makeup brand with bullet lipsticks and studios.",
        "tags": ["beauty", "makeup", "professional", "lipstick"],
    },
    {
        "word": "Maybelline",
        "subcategory": "Beauty",
        "difficulty": "easy",
        "description": "A drugstore makeup brand with Great Lash mascara pink-green.",
        "tags": ["beauty", "makeup", "drugstore", "mascara"],
    },
    {
        "word": "Lancôme",
        "subcategory": "Beauty",
        "difficulty": "medium",
        "description": "A French luxury brand with Hypnôse mascara and La Vie Est Belle.",
        "tags": ["beauty", "luxury", "french", "mascara"],
    },
    {
        "word": "Dior Beauty",
        "subcategory": "Beauty",
        "difficulty": "hard",
        "description": "A couture beauty line with Addict lipstick and Sauvage fragrance.",
        "tags": ["beauty", "couture", "lipstick", "sauvage"],
    },
    {
        "word": "Chanel Beauty",
        "subcategory": "Beauty",
        "difficulty": "hard",
        "description": "A luxury beauty with Rouge Coco and Les Beiges foundation.",
        "tags": ["beauty", "luxury", "foundation", "rouge-coco"],
    },
    {
        "word": "YSL Beauty",
        "subcategory": "Beauty",
        "difficulty": "hard",
        "description": "A fashion-house beauty with Touche Éclat and Libre perfume.",
        "tags": ["beauty", "fashion", "touche-eclat", "libre"],
    },
    {
        "word": "Fenty Beauty",
        "subcategory": "Beauty",
        "difficulty": "medium",
        "description": "A Rihanna brand with 50 foundation shades and Gloss Bomb.",
        "tags": ["beauty", "inclusive", "foundation", "gloss-bomb"],
    },
    {
        "word": "Rare Beauty",
        "subcategory": "Beauty",
        "difficulty": "medium",
        "description": "A Selena Gomez brand with liquid blush and mental health mission.",
        "tags": ["beauty", "celebrity", "blush", "mental-health"],
    },
    {
        "word": "Glossier",
        "subcategory": "Beauty",
        "difficulty": "medium",
        "description": "A direct-to-consumer brand with Boy Brow and skin-first ethos.",
        "tags": ["beauty", "dtc", "skin-first", "boy-brow"],
    },
    {
        "word": "The Ordinary",
        "subcategory": "Beauty",
        "difficulty": "medium",
        "description": "A clinical skincare brand with affordable acids and serums.",
        "tags": ["beauty", "skincare", "clinical", "affordable"],
    },

    # Finance (13 words)
    {
        "word": "Visa",
        "subcategory": "Finance",
        "difficulty": "easy",
        "description": "A global payments network with blue-gold logo and everywhere acceptance.",
        "tags": ["finance", "payments", "credit-card", "network"],
    },
    {
        "word": "Mastercard",
        "subcategory": "Finance",
        "difficulty": "easy",
        "description": "A payments network with interlocking circles and Priceless campaign.",
        "tags": ["finance", "payments", "credit-card", "priceless"],
    },
    {
        "word": "American Express",
        "subcategory": "Finance",
        "difficulty": "medium",
        "description": "A premium card network with Centurion logo and Membership Rewards.",
        "tags": ["finance", "credit-card", "premium", "centurion"],
    },
    {
        "word": "PayPal",
        "subcategory": "Finance",
        "difficulty": "easy",
        "description": "An online payments platform with buyer protection and Venmo.",
        "tags": ["finance", "payments", "online", "venmo"],
    },
    {
        "word": "Stripe",
        "subcategory": "Finance",
        "difficulty": "hard",
        "description": "A developer-first payments API for internet businesses.",
        "tags": ["finance", "payments", "api", "developers"],
    },
    {
        "word": "Square",
        "subcategory": "Finance",
        "difficulty": "medium",
        "description": "A Block financial services with white card reader and Cash App.",
        "tags": ["finance", "payments", "pos", "cash-app"],
    },
    {
        "word": "Revolut",
        "subcategory": "Finance",
        "difficulty": "medium",
        "description": "A fintech app with multi-currency accounts and crypto trading.",
        "tags": ["finance", "fintech", "multi-currency", "crypto"],
    },
    {
        "word": "Wise",
        "subcategory": "Finance",
        "difficulty": "hard",
        "description": "A low-cost international transfer service with real exchange rates.",
        "tags": ["finance", "transfers", "international", "exchange-rate"],
    },
    {
        "word": "Robinhood",
        "subcategory": "Finance",
        "difficulty": "medium",
        "description": "A commission-free trading app with fractional shares and crypto.",
        "tags": ["finance", "trading", "commission-free", "fractional"],
    },
    {
        "word": "Coinbase",
        "subcategory": "Finance",
        "difficulty": "medium",
        "description": "A cryptocurrency exchange with wallet and Earn learning rewards.",
        "tags": ["finance", "crypto", "exchange", "wallet"],
    },
    {
        "word": "Binance",
        "subcategory": "Finance",
        "difficulty": "hard",
        "description": "The world's largest crypto exchange with BNB token and Smart Chain.",
        "tags": ["finance", "crypto", "exchange", "bnb"],
    },
    {
        "word": "BlackRock",
        "subcategory": "Finance",
        "difficulty": "hard",
        "description": "The world's largest asset manager with iShares ETFs.",
        "tags": ["finance", "asset-management", "etfs", "ishares"],
    },
    {
        "word": "Vanguard",
        "subcategory": "Finance",
        "difficulty": "hard",
        "description": "A client-owned fund company with low-cost index funds.",
        "tags": ["finance", "funds", "index-funds", "client-owned"],
    },
]

BRAND_GROUPS = {
    "Technology": ["Apple", "Microsoft", "Google", "Amazon", "Meta", "Tesla", "Netflix", "Spotify", "Uber", "Airbnb", "NVIDIA", "AMD", "Intel", "Samsung", "Sony", "LG", "GoPro"],
    "Food & Beverage": ["Coca-Cola", "Pepsi", "Starbucks", "McDonald's", "KFC", "Burger King", "Subway", "Domino's", "Oreo", "KitKat", "M&M's", "Snickers", "Pringles", "Lay's", "Ben & Jerry's", "Häagen-Dazs"],
    "Fashion": ["Nike", "Adidas", "Puma", "Under Armour", "New Balance", "Reebok", "Asics", "Saucony", "Hoka", "On Running", "Levi's", "Wrangler", "Calvin Klein", "Ralph Lauren", "Gap", "Uniqlo"],
    "Automotive": ["Toyota", "Honda", "Ford", "Chevrolet", "BMW", "Mercedes-Benz", "Audi", "Volkswagen", "Porsche", "Ferrari", "Lamborghini", "Rivian", "Lucid"],
    "Entertainment": ["Disney", "Warner Bros", "Universal", "Paramount", "Sony Pictures", "Marvel", "DC Comics", "Pixar", "DreamWorks", "Illumination", "Nintendo", "PlayStation", "Xbox", "Steam"],
    "Home": ["IKEA", "Dyson", "KitchenAid", "Instant Pot", "Ninja", "Vitamix", "Le Creuset", "Tefal", "Weber", "Traeger"],
    "Sports": ["Wilson", "Spalding", "Rawlings", "Easton", "Bauer", "CCM", "Titleist", "Callaway", "TaylorMade"],
    "Beauty": ["L'Oréal", "Estée Lauder", "MAC", "Maybelline", "Lancôme", "Dior Beauty", "Chanel Beauty", "YSL Beauty", "Fenty Beauty", "Rare Beauty", "Glossier", "The Ordinary"],
    "Finance": ["Visa", "Mastercard", "American Express", "PayPal", "Stripe", "Square", "Revolut", "Wise", "Robinhood", "Coinbase", "Binance", "BlackRock", "Vanguard"],
}

# Load attrs_map from the generated JSON file
with open(Path(__file__).parent / "attrs_map.json", "r", encoding="utf-8") as f:
    ATTRS_MAP = json.load(f)


def generate_hints_for_level(word: str, subcategory: str, level: int, attrs: Dict[str, str] = None) -> List[str]:
    """Generate 6 hints for a specific difficulty level.

    Level 3 (easy): Direct, obvious hints that clearly point to the brand.
    Level 2 (medium): Indirect hints requiring some knowledge.
    Level 1 (hard): Subtle hints that only experts/fans would recognize.
    """
    word_lower = word.lower()
    if attrs is None:
        attrs = ATTRS_MAP.get(word, {})

    import re

    # Pre-process attrs to strip brand name from problematic fields
    def strip_brand(text: str) -> str:
        if not text:
            return text
        t = text
        # Case-insensitive replacement of brand name
        t = re.sub(re.escape(f"{word} and "), "", t, flags=re.IGNORECASE)
        t = re.sub(re.escape(f"{word} & "), "", t, flags=re.IGNORECASE)
        t = re.sub(re.escape(word), "", t, flags=re.IGNORECASE)
        t = re.sub(r'\s+', ' ', t).strip()
        t = t.strip('-:.,;').strip()
        return t

    # Also strip other brand names from rivals/acquisition to avoid imposter conflicts
    def strip_other_brands(text: str) -> str:
        if not text:
            return text
        t = text
        # Strip all known brand names (case-insensitive)
        all_brands = []
        for brands in BRAND_GROUPS.values():
            all_brands.extend(brands)
        for brand in all_brands:
            t = re.sub(re.escape(brand), "", t, flags=re.IGNORECASE)
        # Clean up artifacts
        t = re.sub(r'\b(and|&)\s*$', '', t)  # trailing "and" or "&"
        t = re.sub(r'^\s*(and|&)\s*', '', t)  # leading "and" or "&"
        t = re.sub(r'\s+', ' ', t).strip()
        t = t.strip('-:.,;').strip()
        if not t or len(t) < 3:
            return 'other brands'
        return t

    known_for = attrs.get('known_for', 'popular products')
    known_for = strip_brand(known_for)
    if not known_for or len(known_for) < 3:
        known_for = 'popular products'

    key_product = attrs.get('key_product', 'flagship product')
    key_product = strip_brand(key_product)
    if not key_product or len(key_product) < 3:
        key_product = 'flagship product'

    logo = attrs.get('logo', 'a distinctive symbol')
    logo = strip_brand(logo)
    if not logo or len(logo) < 3:
        logo = 'a distinctive symbol'

    slogan = attrs.get('slogan', 'memorable tagline')
    slogan = strip_brand(slogan)
    if not slogan or len(slogan) < 3:
        slogan = 'memorable tagline'

    rivals = attrs.get('rivals', 'other major brands')
    rivals = strip_other_brands(rivals)
    if not rivals or len(rivals) < 3:
        rivals = 'other major brands'

    acquisition = attrs.get('acquisition', 'notable companies')
    acquisition = strip_other_brands(acquisition)
    if not acquisition or len(acquisition) < 3:
        acquisition = 'notable companies'

    hq = attrs.get('hq', 'a major city')
    hq = strip_brand(hq)
    if not hq or len(hq) < 3:
        hq = 'a major city'

    hints = []

    if level == 3:  # Easy - direct but WITHOUT the word itself
        # Use diverse templates with DIFFERENT attributes to avoid near-duplicates
        hints = [
            f"This {subcategory.lower()} company produces {known_for}",
            f"Renowned for {known_for}",
            f"Founded in {attrs.get('founded', 'the 1900s')} and headquartered in {hq}",
            f"Their logo features {logo}",
            f"Slogan: {slogan}",
            f"Competes with {rivals}",
        ]
    elif level == 2:  # Medium - indirect
        hints = [
            f"Their logo features {logo}",
            f"Known for {known_for}",
            f"Founded in {attrs.get('founded', 'the 20th century')}",
            f"Headquartered in {hq}",
            f"Their slogan: {slogan}",
            f"Competes with {rivals}",
        ]
    else:  # level == 1, Hard - subtle
        hints = [
            f"The {attrs.get('origin', 'global')} brand behind {key_product}",
            f"Stock ticker: {attrs.get('ticker', 'NYSE listed')}",
            f"Acquired {acquisition}",
            f"CEO: {attrs.get('ceo', 'industry leader')}",
            f"Revenue exceeds {attrs.get('revenue', 'billions annually')}",
            f"Pioneered {attrs.get('innovation', 'industry standards')}",
        ]

    # Filter to ensure no hint contains the secret word (case-insensitive)
    filtered = [h for h in hints if word_lower not in h.lower()]

    # If we don't have enough hints, add generic fallbacks
    if len(filtered) < 6:
        fallbacks = [
            f"A {subcategory.lower()} brand you might recognize",
            f"Popular in the {subcategory.lower()} market",
            f"Known for its distinctive approach to {subcategory.lower()}",
            f"A {attrs.get('origin', 'global')} company in {subcategory.lower()}",
            f"Founded in the {attrs.get('founded', '20th century')}",
            f"Based in {attrs.get('hq', 'a major city')}",
        ]
        for fb in fallbacks:
            if len(filtered) >= 6:
                break
            if word_lower not in fb.lower() and fb not in filtered:
                filtered.append(fb)

    return filtered[:6]


def generate_all_hints(word: str, subcategory: str) -> List[Hint]:
    """Generate 6 hints for each of the 3 difficulty levels (18 total)."""
    all_hints = []
    attrs = ATTRS_MAP.get(word, {})
    for level in [3, 2, 1]:  # easy, medium, hard
        hints = generate_hints_for_level(word, subcategory, level, attrs)
        for h in hints:
            all_hints.append(Hint(text=h, level=level))
    return all_hints


def generate_imposters_for_level(word: str, subcategory: str, level: int, hint_texts: List[str] = None, used: set = None, description: str = "") -> List[str]:
    """Generate 3 imposters for a specific difficulty level.

    Level 1 (easy): Same category, different subcategory - broad alternatives.
    Level 2 (medium): Same subcategory - similar brands.
    Level 3 (hard): Very close competitors - easily confused brands.

    Imposters are filtered to ensure they never appear in any hint text or
    description, and are unique across all difficulty tiers.
    """
    word_lower = word.lower()
    if hint_texts is None:
        hint_texts = []
    if used is None:
        used = set()

    same_subcategory = [b for b in BRAND_GROUPS.get(subcategory, []) if b.lower() != word_lower]
    same_category = []
    for cat, brands in BRAND_GROUPS.items():
        if cat != subcategory:
            same_category.extend(brands)

    imposters = []

    def is_safe(brand: str) -> bool:
        b = brand.lower()
        if b == word_lower:
            return False
        if b in used:
            return False
        # Check if imposter leaks via hint text
        from wordforge.validators.text_utils import leaks_imposter, normalize
        for h in hint_texts:
            if normalize(h) == normalize(brand):
                return False
            if leaks_imposter(word, brand, h):
                return False
        # Check description if provided
        if description:
            if normalize(description) == normalize(brand):
                return False
            if leaks_imposter(word, brand, description):
                return False
        return True

    if level == 1:  # Easy - broad, different subcategory
        for brand in same_category:
            if is_safe(brand):
                imposters.append(brand)
                used.add(brand.lower())
                if len(imposters) >= 3:
                    break

    elif level == 2:  # Medium - same subcategory
        for brand in same_subcategory:
            if is_safe(brand):
                imposters.append(brand)
                used.add(brand.lower())
                if len(imposters) >= 3:
                    break

    else:  # level == 3, Hard - very close competitors
        for brand in same_subcategory:
            if is_safe(brand):
                imposters.append(brand)
                used.add(brand.lower())
                if len(imposters) >= 3:
                    break

    # Pad if needed with generic terms
    generic_pads = {
        "Technology": ["TechCorp", "InnovateInc", "DigitalCo", "SysTech", "NetWorks"],
        "Food & Beverage": ["FoodCo", "DrinkBrand", "TasteInc", "FlavorCorp", "SnackCo"],
        "Fashion": ["StyleBrand", "WearCo", "ThreadInc", "LookBrand", "FitWear"],
        "Automotive": ["AutoMaker", "MotorCo", "DriveInc", "CarBrand", "WheelCo"],
        "Entertainment": ["MediaCorp", "ShowBiz", "FunInc", "PlayCo", "StarBrand"],
        "Home": ["HomeCo", "LivingInc", "HouseBrand", "NestCo", "DwellInc"],
        "Sports": ["SportCo", "GameInc", "PlayBrand", "FitCorp", "ActiveWear"],
        "Beauty": ["BeautyCo", "GlamInc", "LookBrand", "GlowCo", "ChicInc"],
        "Finance": ["FinCo", "MoneyInc", "BankBrand", "CashCorp", "WealthInc"],
    }
    pads = generic_pads.get(subcategory, ["BrandA", "BrandB", "BrandC"])
    for pad in pads:
        if len(imposters) >= 3:
            break
        if is_safe(pad):
            imposters.append(pad)
            used.add(pad.lower())

    return imposters[:3]


def generate_all_imposters(word: str, subcategory: str, hint_texts: List[str], description: str = "") -> List[ImposterWord]:
    """Generate 3 imposters for each of the 3 difficulty levels (9 total)."""
    all_imposters = []
    used = set()
    for level in [1, 2, 3]:  # easy, medium, hard
        imposters = generate_imposters_for_level(word, subcategory, level, hint_texts, used, description)
        for imp in imposters:
            all_imposters.append(ImposterWord(text=imp, level=level))
    return all_imposters


def create_word_records() -> List[WordRecord]:
    """Create WordRecord objects for all brands."""
    records = []
    for i, brand in enumerate(BRAND_DATA):
        word = brand["word"]
        subcategory = brand["subcategory"]
        difficulty = WordDifficulty(brand["difficulty"])

        # Generate hints for ALL three levels (18 total)
        hints = generate_all_hints(word, subcategory)

        # Generate imposters for ALL three levels (9 total)
        hint_texts = [h.text for h in hints]
        imposters = generate_all_imposters(word, subcategory, hint_texts, brand["description"])

        record = WordRecord(
            id=f"offline:brands_products:{word.lower().replace(' ', '-').replace('&', 'and').replace('\'', '').replace('.', '')}",
            word=word,
            category="brands_products",
            subcategory=subcategory,
            difficulty=difficulty,
            tags=brand["tags"],
            is_adult=False,
            hints=hints,
            imposters=imposters,
            description=brand["description"],
            source="offline",
            status=RecordStatus.GENERATED,
        )
        records.append(record)

    return records


def main():
    """Main entry point to generate and validate the brands_products pack."""
    print("Generating brands_products word pack...")
    print(f"Total brands: {len(BRAND_DATA)}")

    # Count by difficulty
    diff_counts = {"easy": 0, "medium": 0, "hard": 0}
    for b in BRAND_DATA:
        diff_counts[b["difficulty"]] += 1
    print(f"Difficulty distribution: {diff_counts}")

    # Count by subcategory
    sub_counts = {}
    for b in BRAND_DATA:
        sub = b["subcategory"]
        sub_counts[sub] = sub_counts.get(sub, 0) + 1
    print(f"Subcategory distribution: {sub_counts}")

    # Create records
    records = create_word_records()
    print(f"Created {len(records)} WordRecord objects")

    # Create pack
    meta = PackMeta(
        id="brands_products",
        name="Brands & Products",
        description="Famous brands and products across technology, food, fashion, automotive, entertainment, home, sports, beauty, and finance.",
        icon="branding_watermark",
        is_adult=False,
        count=len(records),
        difficulty=diff_counts,
        version=2,
        schema_version=3,
        content_version="1.0.0",
        generated_at=datetime.utcnow().isoformat() + "Z",
        source="wordforge",
    )

    pack = WordPack(meta=meta, words=records)

    # Run validation
    print("\nRunning validation...")
    pipeline = ValidationPipeline(min_words_per_pack=60)
    result = pipeline.run(pack)

    print(f"Total words: {result['total_words']}")
    print(f"Passed: {result['passed']}")
    print(f"Failed: {result['failed']}")
    print(f"Warnings: {result['warnings']}")

    if result['issues']:
        print("\nValidation Issues:")
        for issue in result['issues']:
            print(f"  [{issue['category']}] {issue['word']}: {issue['message']}")

    # Export if clean
    if result['is_clean']:
        print("\nPack is clean! Exporting...")
        exporter = FlutterExporter(output_dir=Path(__file__).parent.parent.parent / "assets" / "packs")
        exporter.export_pack(pack)
        print("Export complete!")
    else:
        print("\nPack has errors - not exporting")

    # Also write to offline_packs for reference
    offline_dir = Path(__file__).parent.parent / "output" / "offline_packs"
    offline_dir.mkdir(parents=True, exist_ok=True)
    offline_path = offline_dir / "brands_products.json"
    with open(offline_path, "w", encoding="utf-8") as f:
        json.dump(pack.as_json(), f, ensure_ascii=False, indent=2)
    print(f"Also written to {offline_path}")


if __name__ == "__main__":
    main()