#!/usr/bin/env python3
"""Generate after_dark word pack for Hushbug WordForge.

Template-based generation (no LLM) creating ~80 high-quality adult (18+) words.
This pack covers dating apps, modern dating, nightlife, drinks, intimacy, sexual health, and social dynamics.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).parent.parent))

from wordforge.database.models import (
    WordDifficulty,
    WordPack,
    WordRecord,
    PackMeta,
    Hint,
    ImposterWord,
)


def create_after_dark_pack() -> WordPack:
    """Create the after_dark word pack with ~80 adult words."""

    words_data = [
        # Dating Apps
        {
            "word": "Tinder",
            "subcategory": "Dating Apps",
            "difficulty": WordDifficulty.EASY,
            "description": "A popular location-based dating app using swipe mechanics to match users.",
            "tags": ["dating-app", "swipe", "match", "mobile"],
        },
        {
            "word": "Bumble",
            "subcategory": "Dating Apps",
            "difficulty": WordDifficulty.EASY,
            "description": "A dating app where women must initiate conversation after a match.",
            "tags": ["dating-app", "women-first", "feminist", "match"],
        },
        {
            "word": "Hinge",
            "subcategory": "Dating Apps",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A dating app designed to be deleted, focusing on prompts and detailed profiles.",
            "tags": ["dating-app", "prompts", "relationships", "serious"],
        },
        {
            "word": "Grindr",
            "subcategory": "Dating Apps",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Location-based dating service for LGBTQ community members.",
            "tags": ["dating-app", "lgbtq", "location", "geosocial"],
        },
        {
            "word": "Match",
            "subcategory": "Dating Apps",
            "difficulty": WordDifficulty.EASY,
            "description": "One of the oldest online dating services now also a major app platform.",
            "tags": ["dating-app", "online-dating", "veteran", "subscription"],
        },
        {
            "word": "Swipe Right",
            "subcategory": "Dating Apps",
            "difficulty": WordDifficulty.EASY,
            "description": "The gesture indicating interest in a potential match on swipe-based apps.",
            "tags": ["dating-app", "gesture", "interest", "swipe"],
        },
        {
            "word": "Super Like",
            "subcategory": "Dating Apps",
            "difficulty": WordDifficulty.EASY,
            "description": "A premium feature signaling strong interest before the other person swipes.",
            "tags": ["dating-app", "premium", "interest", "notification"],
        },
        {
            "word": "Catfish",
            "subcategory": "Dating Apps",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Someone using a fake identity online to deceive others romantically.",
            "tags": ["dating-app", "deception", "fake-profile", "scam"],
        },

        # Modern Dating
        {
            "word": "Ghosting",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Suddenly cutting off all communication without explanation after dating.",
            "tags": ["modern-dating", "disappearance", "communication", "rejection"],
        },
        {
            "word": "Benching",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.HARD,
            "description": "Keeping someone as a backup option while continuing to date others.",
            "tags": ["modern-dating", "backup", "stringing-along", "options"],
        },
        {
            "word": "Situationship",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A romantic relationship without clear labels or commitment expectations.",
            "tags": ["modern-dating", "undefined", "casual", "ambiguous"],
        },
        {
            "word": "Friends with Benefits",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.EASY,
            "description": "Friends who engage in sexual activity without romantic commitment.",
            "tags": ["modern-dating", "casual-sex", "friends", "no-strings"],
        },
        {
            "word": "Polyamory",
            "subcategory": "Relationships",
            "difficulty": WordDifficulty.HARD,
            "description": "Consensual non-monogamy involving multiple romantic relationships simultaneously.",
            "tags": ["relationships", "non-monogamy", "consensual", "multiple-partners"],
        },
        {
            "word": "Open Relationship",
            "subcategory": "Relationships",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A committed relationship where partners agree to see other people sexually.",
            "tags": ["relationships", "non-monogamy", "agreement", "boundaries"],
        },
        {
            "word": "Throuple",
            "subcategory": "Relationships",
            "difficulty": WordDifficulty.HARD,
            "description": "A three-person romantic relationship where all parties are involved with each other.",
            "tags": ["relationships", "three", "polyamory", "triad"],
        },

        # Nightlife & Venues
        {
            "word": "Nightclub",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.EASY,
            "description": "A venue open late with music, dancing, and alcohol service.",
            "tags": ["nightlife", "dancing", "music", "alcohol"],
        },
        {
            "word": "Bar",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.EASY,
            "description": "An establishment serving alcoholic drinks for consumption on premises.",
            "tags": ["nightlife", "drinks", "social", "alcohol"],
        },
        {
            "word": "Lounge",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.EASY,
            "description": "A stylish bar with comfortable seating, often more upscale than a typical bar.",
            "tags": ["nightlife", "upscale", "seating", "cocktails"],
        },
        {
            "word": "Speakeasy",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A hidden or unmarked bar evoking Prohibition-era clandestine drinking.",
            "tags": ["nightlife", "hidden", "prohibition", "secret"],
        },
        {
            "word": "Rooftop Bar",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.EASY,
            "description": "An outdoor bar on a building roof with city views.",
            "tags": ["nightlife", "outdoor", "views", "elevated"],
        },
        {
            "word": "Dive Bar",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A casual, often run-down bar with cheap drinks and minimal frills.",
            "tags": ["nightlife", "cheap", "casual", "unpretentious"],
        },
        {
            "word": "Gentlemen's Club",
            "subcategory": "Adult Venues",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A euphemism for a strip club featuring exotic dancers.",
            "tags": ["adult-venues", "strip-club", "dancers", "entertainment"],
        },
        {
            "word": "Burlesque",
            "subcategory": "Adult Venues",
            "difficulty": WordDifficulty.HARD,
            "description": "Theatrical variety show with striptease, comedy, and performance art.",
            "tags": ["adult-venues", "performance", "striptease", "theatrical"],
        },
        {
            "word": "Karaoke",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.EASY,
            "description": "Interactive entertainment singing along to instrumental tracks with lyrics displayed.",
            "tags": ["nightlife", "singing", "entertainment", "social"],
        },
        {
            "word": "Pub Crawl",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Visiting multiple bars in one night, typically with a group.",
            "tags": ["nightlife", "multiple-bars", "group", "drinking"],
        },

        # Drinks & Cocktails
        {
            "word": "Cocktail",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.EASY,
            "description": "A mixed drink with spirits and other ingredients served in a glass.",
            "tags": ["drinks", "mixed", "spirits", "craft"],
        },
        {
            "word": "Martini",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A classic drink of gin and vermouth garnished with an olive or lemon twist.",
            "tags": ["drinks", "classic", "gin", "vermouth"],
        },
        {
            "word": "Old Fashioned",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A whiskey drink with sugar bitters and citrus peel.",
            "tags": ["drinks", "whiskey", "classic", "bitters"],
        },
        {
            "word": "Margarita",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.EASY,
            "description": "A tequila drink with lime juice and orange liqueur often served with salt rim.",
            "tags": ["drinks", "tequila", "lime", "salt-rim"],
        },
        {
            "word": "Mojito",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.EASY,
            "description": "A rum drink with mint lime sugar and soda water.",
            "tags": ["drinks", "rum", "mint", "refreshing"],
        },
        {
            "word": "Negroni",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.HARD,
            "description": "An Italian drink of gin Campari and sweet vermouth in equal parts.",
            "tags": ["drinks", "italian", "campari", "aperitif"],
        },
        {
            "word": "Whiskey",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.EASY,
            "description": "A distilled spirit made from fermented grain mash aged in wooden barrels.",
            "tags": ["drinks", "distilled", "grain", "aged"],
        },
        {
            "word": "Wine",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.EASY,
            "description": "An alcoholic beverage made from fermented grapes.",
            "tags": ["drinks", "fermented", "grapes", "vintage"],
        },
        {
            "word": "Champagne",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Sparkling wine from French region used for celebratory occasions.",
            "tags": ["drinks", "sparkling", "france", "celebration"],
        },
        {
            "word": "Shot",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.EASY,
            "description": "A small serving of straight spirit consumed quickly.",
            "tags": ["drinks", "small", "straight", "quick"],
        },

        # Intimacy & Sexuality
        {
            "word": "Consent",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.EASY,
            "description": "Freely given informed enthusiastic agreement to sexual activity.",
            "tags": ["intimacy", "agreement", "enthusiastic", "essential"],
        },
        {
            "word": "Foreplay",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Intimate physical and emotional activity preceding sexual intercourse.",
            "tags": ["intimacy", "prelude", "arousal", "connection"],
        },
        {
            "word": "Libido",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A person's overall sexual drive or desire for sexual activity.",
            "tags": ["intimacy", "drive", "desire", "sexual"],
        },
        {
            "word": "Aphrodisiac",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.HARD,
            "description": "A substance believed to increase sexual desire or performance.",
            "tags": ["intimacy", "substance", "desire", "enhancement"],
        },
        {
            "word": "Kink",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Unconventional sexual preferences or behaviors outside vanilla norms.",
            "tags": ["intimacy", "unconventional", "preferences", "bdsm"],
        },
        {
            "word": "Fetish",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.HARD,
            "description": "A sexual fixation on a non-living object or non-genital body part.",
            "tags": ["intimacy", "fixation", "object", "psychology"],
        },
        {
            "word": "BDSM",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.HARD,
            "description": "Consensual activities involving power exchange and related practices.",
            "tags": ["intimacy", "power-exchange", "consensual", "lifestyle"],
        },
        {
            "word": "Safe Word",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A pre-agreed word to immediately stop sexual activity during intense play.",
            "tags": ["intimacy", "safety", "stop", "communication"],
        },
        {
            "word": "Aftercare",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.HARD,
            "description": "Emotional and physical care following intense sexual or BDSM activity.",
            "tags": ["intimacy", "care", "recovery", "emotional"],
        },

        # Sexual Health
        {
            "word": "Protection",
            "subcategory": "Sexual Health",
            "difficulty": WordDifficulty.EASY,
            "description": "Barrier methods like condoms preventing pregnancy and STI transmission.",
            "tags": ["sexual-health", "condom", "barrier", "prevention"],
        },
        {
            "word": "STI Testing",
            "subcategory": "Sexual Health",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Regular screening for sexually transmitted infections.",
            "tags": ["sexual-health", "screening", "health", "responsibility"],
        },
        {
            "word": "PrEP",
            "subcategory": "Sexual Health",
            "difficulty": WordDifficulty.HARD,
            "description": "Pre-exposure prophylaxis is a medication used to prevent HIV infection.",
            "tags": ["sexual-health", "hiv", "prevention", "medication"],
        },

        # Social Dynamics
        {
            "word": "Wingman",
            "subcategory": "Social Dynamics",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A friend who helps another approach potential romantic partners.",
            "tags": ["social-dynamics", "friend", "assist", "approach"],
        },
        {
            "word": "Pickup Line",
            "subcategory": "Social Dynamics",
            "difficulty": WordDifficulty.EASY,
            "description": "A rehearsed remark used to initiate conversation with romantic intent.",
            "tags": ["social-dynamics", "rehearsed", "approach", "conversation"],
        },
        {
            "word": "Flirting",
            "subcategory": "Social Dynamics",
            "difficulty": WordDifficulty.EASY,
            "description": "Playful behavior showing romantic or sexual interest.",
            "tags": ["social-dynamics", "playful", "interest", "romantic"],
        },
        {
            "word": "Eye Contact",
            "subcategory": "Social Dynamics",
            "difficulty": WordDifficulty.EASY,
            "description": "Meeting another's gaze, often signaling interest or confidence.",
            "tags": ["social-dynamics", "gaze", "signal", "confidence"],
        },
        {
            "word": "Body Language",
            "subcategory": "Social Dynamics",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Non-verbal cues revealing attraction, comfort, or discomfort.",
            "tags": ["social-dynamics", "non-verbal", "cues", "attraction"],
        },
        {
            "word": "Chemistry",
            "subcategory": "Social Dynamics",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "An intangible connection and mutual attraction between two people.",
            "tags": ["social-dynamics", "connection", "attraction", "spark"],
        },
        {
            "word": "Tension",
            "subcategory": "Social Dynamics",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Sexual or romantic anticipation between people who haven't acted on it.",
            "tags": ["social-dynamics", "anticipation", "unresolved", "attraction"],
        },

        # Additional terms to reach ~80
        {
            "word": "Date Night",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.EASY,
            "description": "A planned evening for a couple to spend quality time together romantically.",
            "tags": ["modern-dating", "planned", "couple", "romantic"],
        },
        {
            "word": "First Date",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.EASY,
            "description": "The initial meeting between two people exploring romantic potential.",
            "tags": ["modern-dating", "initial", "meeting", "potential"],
        },
        {
            "word": "Blind Date",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A date arranged by a third party where participants haven't met before.",
            "tags": ["modern-dating", "arranged", "strangers", "setup"],
        },
        {
            "word": "Speed Dating",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "An event with brief timed conversations to meet many potential partners.",
            "tags": ["modern-dating", "event", "timed", "multiple"],
        },
        {
            "word": "Matchmaker",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.HARD,
            "description": "A person who arranges introductions for potential romantic partners.",
            "tags": ["modern-dating", "arranges", "introductions", "professional"],
        },
        {
            "word": "Bottle Service",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Premium nightclub offering full containers with private seating.",
            "tags": ["nightlife", "premium", "bottles", "vip"],
        },
        {
            "word": "Guest List",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A list granting free or priority entry to an exclusive venue or event.",
            "tags": ["nightlife", "exclusive", "entry", "priority"],
        },
        {
            "word": "Cover Charge",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.EASY,
            "description": "An entry fee charged by nightclubs and some bars.",
            "tags": ["nightlife", "fee", "entry", "club"],
        },
        {
            "word": "Happy Hour",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.EASY,
            "description": "A period with discounted drinks and appetizers, typically early evening.",
            "tags": ["nightlife", "discounted", "early-evening", "drinks"],
        },
        {
            "word": "Last Call",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.EASY,
            "description": "The final opportunity to order drinks before a bar closes.",
            "tags": ["nightlife", "final", "order", "closing"],
        },
        {
            "word": "Designated Driver",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A person abstaining from alcohol to drive others home safely.",
            "tags": ["nightlife", "sober", "drive", "safety"],
        },
        {
            "word": "Hangover",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.EASY,
            "description": "Unpleasant physical effects following excessive alcohol consumption.",
            "tags": ["nightlife", "aftermath", "alcohol", "unpleasant"],
        },
        {
            "word": "Hair of the Dog",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Consuming alcohol to alleviate hangover symptoms.",
            "tags": ["nightlife", "remedy", "hangover", "alcohol"],
        },
        {
            "word": "One Night Stand",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A single sexual encounter with no expectation of further relationship.",
            "tags": ["modern-dating", "single", "encounter", "no-commitment"],
        },
        {
            "word": "Walk of Shame",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Walking home in the previous night's clothes after a casual encounter.",
            "tags": ["modern-dating", "morning-after", "clothes", "casual"],
        },
        {
            "word": "Booty Call",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A late-night summons for casual sex, often recurring.",
            "tags": ["modern-dating", "late-night", "casual-sex", "summons"],
        },
        {
            "word": "Netflix and Chill",
            "subcategory": "Modern Dating",
            "difficulty": WordDifficulty.EASY,
            "description": "A euphemism for inviting someone over for sex under the pretense of watching TV.",
            "tags": ["modern-dating", "euphemism", "invite", "casual"],
        },

        # Additional terms to reach ~80 with better difficulty distribution
        {
            "word": "Dry Humping",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Non-penetrative sexual activity with clothes on, simulating intercourse.",
            "tags": ["intimacy", "non-penetrative", "clothed", "simulation"],
        },
        {
            "word": "Edging",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.HARD,
            "description": "Delaying orgasm intentionally to intensify the eventual climax.",
            "tags": ["intimacy", "delay", "control", "intensity"],
        },
        {
            "word": "Squirting",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.HARD,
            "description": "Expulsion of fluid during female orgasm, often from Skene's glands.",
            "tags": ["intimacy", "female", "orgasm", "fluid"],
        },
        {
            "word": "Pegging",
            "subcategory": "Intimacy",
            "difficulty": WordDifficulty.HARD,
            "description": "Anal penetration of a man by a woman wearing a strap-on dildo.",
            "tags": ["intimacy", "anal", "strap-on", "role-reversal"],
        },
        {
            "word": "Cuckold",
            "subcategory": "Relationships",
            "difficulty": WordDifficulty.HARD,
            "description": "A man whose partner has sex with others, often with his knowledge and arousal.",
            "tags": ["relationships", "voyeurism", "humiliation", "power-dynamic"],
        },
        {
            "word": "Hotwife",
            "subcategory": "Relationships",
            "difficulty": WordDifficulty.HARD,
            "description": "A married woman who has sexual encounters with other men with her husband's consent.",
            "tags": ["relationships", "non-monogamy", "consent", "exhibitionism"],
        },
        {
            "word": "Unicorn",
            "subcategory": "Relationships",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A bisexual woman willing to join an existing couple for threesomes.",
            "tags": ["relationships", "bisexual", "threesome", "couple"],
        },
        {
            "word": "Fluid Bonding",
            "subcategory": "Sexual Health",
            "difficulty": WordDifficulty.HARD,
            "description": "Agreement between partners to stop using barriers after mutual testing.",
            "tags": ["sexual-health", "agreement", "barriers", "trust"],
        },
        {
            "word": "Afterparty",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.EASY,
            "description": "A gathering after a main event, often at a private home, continuing the night.",
            "tags": ["nightlife", "after-hours", "private", "continuation"],
        },
        {
            "word": "VIP Section",
            "subcategory": "Nightlife",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "An exclusive area in a club with premium service and restricted access.",
            "tags": ["nightlife", "exclusive", "premium", "restricted"],
        },
        {
            "word": "Mixologist",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A professional skilled in crafting creative and balanced cocktails.",
            "tags": ["drinks", "professional", "craft", "creative"],
        },
        {
            "word": "Aperol Spritz",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A refreshing Italian cocktail of Aperol, prosecco, and soda water.",
            "tags": ["drinks", "italian", "aperol", "refreshing"],
        },
        {
            "word": "Espresso Martini",
            "subcategory": "Drinks",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A vodka cocktail with coffee liqueur and fresh espresso, shaken until frothy.",
            "tags": ["drinks", "vodka", "coffee", "frothy"],
        },
    ]

    # Build WordRecords
    words = []
    for i, data in enumerate(words_data):
        word = data["word"]
        subcategory = data["subcategory"]
        difficulty = data["difficulty"]
        description = data["description"]
        tags = data["tags"]

        # Generate hints (6 per level: easy=level 3, medium=level 2, hard=level 1)
        hints = generate_hints(word, subcategory, difficulty)
        imposters = generate_imposters(word, subcategory, difficulty)

        record = WordRecord(
            id=f"offline:after_dark:{word.lower().replace(' ', '-').replace('/', '-')}",
            word=word,
            category="after_dark",
            subcategory=subcategory,
            difficulty=difficulty,
            tags=tags,
            is_adult=True,
            hints=hints,
            imposters=imposters,
            description=description,
            source="offline",
        )
        words.append(record)

    # Count difficulties
    diff_counts = {"easy": 0, "medium": 0, "hard": 0}
    for w in words:
        diff_counts[w.difficulty.value] += 1

    meta = PackMeta(
        id="after_dark",
        name="18+ - After Dark",
        description="~80 adult words covering dating apps, modern dating, nightlife, drinks, intimacy, sexual health, and social dynamics.",
        icon="nightlife",
        is_adult=True,
        count=len(words),
        difficulty=diff_counts,
        version=2,
        schema_version=3,
        content_version="1.0.0",
        generated_at=datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        source="template-generation",
    )

    return WordPack(meta=meta, words=words)


def generate_hints(word: str, subcategory: str, difficulty: WordDifficulty) -> list[Hint]:
    """Generate contextual hints for a word based on category and difficulty."""
    word_lower = word.lower()

    # Word-specific hints for major terms - carefully avoiding the secret word
    word_specific_hints = {
        "swipe right": {
            "easy": [
                "Gestural action to show interest",
                "Horizontal finger movement on screen",
                "Indicates positive preference",
                "Used in matching algorithms",
                "Common in dating applications",
                "Direction matters for preference",
            ],
            "medium": [
                "Algorithm interprets user choice",
                "Swipe direction affects match rate",
                "Velocity indicates enthusiasm",
                "Multi-finger gestures possible",
                "Undo feature reverses action",
                "Analytics track user behavior",
            ],
            "hard": [
                "Physics gesture recognition system",
                "Touch event handling optimization",
                "Friction coefficient for smoothness",
                "Inertia simulation on motion",
                "Haptic feedback confirms action",
                "Machine learning predicts intent",
            ],
        },
        "grindr": {
            "easy": [
                "Geosocial networking for community",
                "Location services enable connections",
                "Profile shows interests and needs",
                "Chat connects nearby users",
                "Events bring people together",
                "Verified badges increase trust",
            ],
            "medium": [
                "Algorithmic matching based on attraction",
                "Filters narrow potential partners",
                "Spots feature finds common interests",
                "Trips mode extends location",
                "Incognito hides from discovery",
                "Scan shows nearby profiles",
            ],
            "hard": [
                "Proximity algorithms optimize matching",
                "Geofencing enables event discovery",
                "GraphQL API allows integrations",
                "Real-time database synchronization",
                "Machine learning bias mitigation",
                "Scalable microservices architecture",
            ],
        },
        "tinder": {
            "easy": [
                "Swipe left or right to decide",
                "Connect with people nearby",
                "Chat before meeting up",
                "Profile shows photos and bio",
                "Free to download and use",
                "Most popular dating app",
            ],
            "medium": [
                "Algorithm suggests compatible profiles",
                "Premium tier shows who liked you",
                "Verification badge reduces fakes",
                "Passport feature changes location",
                "Boost increases profile visibility",
                "Unmatch removes connection instantly",
            ],
            "hard": [
                "ELO scoring ranks desirability",
                "Shadowban limits profile exposure",
                "API enables automation tools",
                "Data monetization concerns raised",
                "Gamification drives daily retention",
                "Network effects create strong moats",
            ],
        },
        "bumble": {
            "easy": [
                "Women message first after match",
                "Yellow and white branding",
                "Founded by Whitney Wolfe",
                "Also has BFF and Bizz modes",
                "Match expires in 24 hours",
                "Empowers women to lead",
            ],
            "medium": [
                "Time pressure encourages action",
                "Spotlight highlights your profile",
                "SuperSwipe shows strong intent",
                "Travel mode changes your city",
                "Incognito hides from non-matches",
                "Rematch reconnects expired chats",
            ],
            "hard": [
                "Feminist founding mission stated",
                "Monetization via premium features",
                "Safety photo verification required",
                "AI detects unsolicited images",
                "Market expansion beyond dating",
                "IPO valuation multi-billion",
            ],
        },
        "hinge": {
            "easy": [
                "Designed to be deleted",
                "Prompts replace generic bios",
                "Like specific parts of profiles",
                "We Met feature tracks dates",
                "Focus on serious relationships",
                "Detailed profiles encouraged",
            ],
            "medium": [
                "Algorithm learns your type",
                "Standouts shows best matches",
                "Roses signal extra interest",
                "Video prompts add personality",
                "Dealbreakers filter deal-breakers",
                "Most compatible daily suggestion",
            ],
            "hard": [
                "Gale-Shapley matching theory",
                "Nobel prize algorithm adapted",
                "Prompt responses weight heavily",
                "Churn reduction core metric",
                "Relationship science informs UX",
                "Data shows higher marriage rate",
            ],
        },
        "ghosting": {
            "easy": [
                "Disappear without saying goodbye",
                "Stop replying to messages",
                "Block or ignore completely",
                "No closure given",
                "Common in modern dating",
                "Leaves questions unanswered",
            ],
            "medium": [
                "Avoidance of difficult talk",
                "Digital ease enables vanishing",
                "Mental health impact significant",
                "Fade out slowly",
                "Occurs reciprocally sometimes",
                "Closure sought elsewhere often",
            ],
            "hard": [
                "Attachment theory explains pattern",
                "Avoidant style correlates strongly",
                "Paradox of choice fuels it",
                "Platform design incentivizes",
                "Moral injury term applied",
                "Collective trauma recognized",
            ],
        },
        "consent": {
            "easy": [
                "Freely given enthusiastic yes",
                "Ongoing not one-time check",
                "Can be withdrawn anytime",
                "Silence is not agreement",
                "Intoxication impairs ability",
                "Essential for every encounter",
            ],
            "medium": [
                "Affirmative model standard now",
                "Power dynamics affect freely given",
                "Coercion invalidates agreement",
                "Specific acts need specific yes",
                "Non-verbal cues supplement words",
                "Education reduces violations",
            ],
            "hard": [
                "Legal standards vary by jurisdiction",
                "Capacity assessment complex clinically",
                "Enthusiastic vs affirmative debate",
                "Trauma-informed framework essential",
                "Institutional betrayal compounds harm",
                "Restorative justice models emerging",
            ],
        },
        "foreplay": {
            "easy": [
                "Activity before intercourse",
                "Builds arousal and connection",
                "Kissing and touching included",
                "Communication enhances experience",
                "Takes time, don't rush it",
                "Mutual pleasure is the goal",
            ],
            "medium": [
                "Responsive desire often needs it",
                "Mismatched timing causes friction",
                "Novelty sustains long-term interest",
                "Erogenous zones vary by person",
                "Mental arousal precedes physical",
                "Scheduling can help busy couples",
            ],
            "hard": [
                "Dual control model explains variance",
                "Accelerator and brake systems",
                "Context determines response type",
                "Somatic markers guide exploration",
                "Erotic blueprints map preferences",
                "Mindfulness enhances sensation",
            ],
        },
        "kink": {
            "easy": [
                "Unconventional sexual interests",
                "Beyond vanilla activities",
                "Consensual exploration encouraged",
                "Communication is essential",
                "Safe words provide safety",
                "Judgment-free zone needed",
            ],
            "medium": [
                "Power exchange dynamics common",
                "Role-play explores fantasies",
                "Sensation play varies intensity",
                "Community has established norms",
                "Responsible practice standard",
                "Negotiation precedes every scene",
            ],
            "hard": [
                "Psychological drivers diverse",
                "Trauma processing sometimes involved",
                "Subspace altered consciousness state",
                "Aftercare regulates nervous system",
                "Edge play requires advanced skill",
                "Community accountability structures",
            ],
        },
        "fetish": {
            "easy": [
                "Fixation on object or body part",
                "Required for arousal sometimes",
                "Feet and leather common examples",
                "Not inherently harmful",
                "Partners can accommodate",
                "Different from preference",
            ],
            "medium": [
                "Classical conditioning may form",
                "Early experiences sometimes shape",
                "Integrate or compartmentalize",
                "Partner acceptance varies widely",
                "Therapy helps if distressing",
                "DSM distinguishes from disorder",
            ],
            "hard": [
                "Paraphilia clinical term used",
                "Neurobiology shows reward pathways",
                "Conditioning extinction difficult",
                "Moral incongruence causes distress",
                "Sex-positive therapy approaches",
                "Identity vs behavior distinction",
            ],
        },
        "bdsm": {
            "easy": [
                "Bondage Discipline Dominance Submission",
                "Sadism Masochism acronym",
                "Consensual power exchange",
                "Safe sane consensual motto",
                "Risk aware consensual kink",
                "Negotiation before play",
            ],
            "medium": [
                "Top bottom switch roles fluid",
                "Scene negotiated in advance",
                "Limits hard soft respected",
                "Subspace physiological response",
                "Drop follows intense scenes",
                "Community has strong norms",
            ],
            "hard": [
                "Edge play pushes boundaries",
                "CN consensual non-consent negotiated",
                "Protocol relationships highly structured",
                "24/7 dynamics total power exchange",
                "Legal consent defenses complex",
                "Academic research growing field",
            ],
        },
        "protection": {
            "easy": [
                "Condoms prevent pregnancy and STIs",
                "Use correctly every time",
                "Check expiration dates",
                "Store in cool dry place",
                "Water-based lube compatible",
                "Free at many clinics",
            ],
            "medium": [
                "Internal condoms alternative option",
                "Dental barriers for oral health",
                "PrEP plus condoms optimal",
                "Breakage rare with proper use",
                "Allergies use non-latex options",
                "Emergency contraception backup",
            ],
            "hard": [
                "Failure rates typical vs perfect use",
                "Microtears not visible to eye",
                "Spermicide nonoxynol-9 irritates",
                "Biomaterials research next generation",
                "Self-lubricating condoms developed",
                "Male contraceptive trials ongoing",
            ],
        },
        "prep": {
            "easy": [
                "Pill prevents HIV infection",
                "Taken daily for protection",
                "Highly effective when adherent",
                "Prescription required from doctor",
                "Regular kidney monitoring needed",
                "Does not prevent other STIs",
            ],
            "medium": [
                "Tenofovir emtricitabine combination",
                "On-demand dosing also approved",
                "Descovy alternative formulation",
                "Insurance often covers cost",
                "Generic versions available now",
                "Adherence correlates with efficacy",
            ],
            "hard": [
                "iPrEx trial proved efficacy",
                "Drug resistance rare with adherence",
                "Bone density monitoring long-term",
                "Renal function creatinine tracked",
                "Hepatitis B flare risk on cessation",
                "Implementation science scales access",
            ],
        },
    }

    # Generic hints by subcategory - using safe vocabulary that never overlaps with imposters
    generic_hints = {
        "Dating Apps": {
            "easy": [
                "Digital platform for meeting people",
                "Create profile with photos",
                "Connect based on preferences",
                "Chat feature built in",
                "Location-based suggestions",
                "Free download from app store",
            ],
            "medium": [
                "Algorithm curates potential connections",
                "Premium features unlock more options",
                "Verification reduces fraudulent accounts",
                "Filters narrow search criteria",
                "Activity status shows engagement",
                "Report tools maintain safety",
            ],
            "hard": [
                "Recommendation engine optimizes retention",
                "Monetization via subscription tiers",
                "Machine learning predicts compatibility",
                "A/B testing drives feature rollout",
                "Data privacy regulations apply",
                "Network effects create barriers",
            ],
        },
        "Modern Dating": {
            "easy": [
                "Romance in digital era",
                "Texting shapes early dynamics",
                "Labels often unclear",
                "Expectations vary widely",
                "Communication prevents confusion",
                "Boundaries protect wellbeing",
            ],
            "medium": [
                "Attachment styles influence behavior",
                "Love languages differ per person",
                "Undefined connections create stress",
                "Avoidance tactics harm others",
                "Options paralysis delays commitment",
                "Warning signs indicate problems",
            ],
            "hard": [
                "Anxious-avoidant cycles repeat",
                "Choice abundance paralyzes decisions",
                "Digital mediation reduces depth",
                "Market metaphors shape behavior",
                "Commodification of intimacy",
                "Structural factors constrain agency",
            ],
        },
        "Nightlife": {
            "easy": [
                "Evening social entertainment",
                "Music and dancing venues",
                "Beverages served at venues",
                "Friends gather socially",
                "Late hours typical",
                "Atmosphere encourages fun",
            ],
            "medium": [
                "Premium service includes seating",
                "Lists grant priority access",
                "Fees charged at entrance",
                "Discount periods save money",
                "Final service announced",
                "Sober driver ensures safety",
            ],
            "hard": [
                "Promoter economics drive traffic",
                "Occupancy regulated by codes",
                "Noise ordinances limit hours",
                "Licensing controls alcohol sales",
                "Security manages crowd flow",
                "Revenue optimization per guest",
            ],
        },
        "Adult Venues": {
            "easy": [
                "Adult entertainment establishments",
                "Performers dance on stage",
                "Private shows available for tips",
                "Age verification at door",
                "Cash transactions common",
                "Theatrical performances staged",
            ],
            "medium": [
                "House fees reduce take-home",
                "Rotation schedules organize sets",
                "Private rooms command premium",
                "Contractor classification debated",
                "Zoning restricts locations",
                "Labor rights increasingly recognized",
            ],
            "hard": [
                "Tip-out structures distribute earnings",
                "Employment classification litigated",
                "Safety regulations apply to stages",
                "Expression protections legally tested",
                "Licensing discretion municipal",
                "Worker organizing gains momentum",
            ],
        },
        "Drinks": {
            "easy": [
                "Alcoholic mixed beverages",
                "Savor flavors slowly",
                "Many recipes exist",
                "Pair with food well",
                "Consume responsibly always",
                "Social tradition worldwide",
            ],
            "medium": [
                "Balance sweet sour bitter strong",
                "Fresh ingredients elevate quality",
                "Technique controls dilution rate",
                "Glassware shapes aromatic profile",
                "Ice quality affects final taste",
                "Garnish completes presentation",
            ],
            "hard": [
                "Scientific techniques transform textures",
                "Fat-washing infuses lipid flavors",
                "Clarification removes suspended solids",
                "Precision infusion via sous-vide",
                "Rotary evaporation captures aromatics",
                "Phase diagrams guide formulation",
            ],
        },
        "Intimacy": {
            "easy": [
                "Physical emotional closeness shared",
                "Talk openly about desires",
                "Mutual agreement always required",
                "Explore together with care",
                "Pleasure both partners equally",
                "Respect limits every time",
            ],
            "medium": [
                "Desire fluctuates naturally over time",
                "Different drives common in couples",
                "New experiences maintain excitement",
                "Vulnerability deepens the bond",
                "Fantasy enhances shared reality",
                "Recovery time processes intensity",
            ],
            "hard": [
                "Responsive versus spontaneous drive types",
                "Erotic templates map unique preferences",
                "Body-based approaches release tension",
                "Nervous system state informs safety",
                "Self-differentiation enables true closeness",
                "Conflict repair cycles build growth",
            ],
        },
        "Sexual Health": {
            "easy": [
                "Protect yourself and partners",
                "Regular screening recommended",
                "Know your current status",
                "Barriers prevent transmission",
                "Vaccines prevent certain infections",
                "Open dialogue with partners",
            ],
            "medium": [
                "Window periods affect test accuracy",
                "Medication prevents HIV effectively",
                "Emergency treatment after exposure",
                "Undetectable means untransmittable",
                "Comprehensive panels recommended",
                "Partner notification protects community",
            ],
            "hard": [
                "Nucleic acid tests most sensitive",
                "Seroconversion timing critical clinically",
                "Resistant strains challenge treatment",
                "Vaccine development faces hurdles",
                "Microbicide research continues advancing",
                "Structural barriers limit healthcare access",
            ],
        },
        "Social Dynamics": {
            "easy": [
                "Interact with potential partners",
                "Read non-verbal signals",
                "Confidence attracts naturally",
                "Authenticity builds trust",
                "Accept rejection gracefully",
                "Enjoy meeting new people",
            ],
            "medium": [
                "Mirroring builds unconscious rapport",
                "Intimacy components theory explains",
                "Proximity increases familiarity",
                "Similarity predicts long-term fit",
                "Reciprocity fuels escalation",
                "Uncertainty heightens attraction",
            ],
            "hard": [
                "Evolutionary frameworks predict strategies",
                "Investment theory explains differences",
                "Value assessments occur unconsciously",
                "Dark traits exploit short-term",
                "Costly signals demonstrate quality",
                "Game theory models interactions",
            ],
        },
        "Relationships": {
            "easy": [
                "Commitment between partners",
                "Trust builds over time",
                "Communication resolves conflicts",
                "Shared values align lives",
                "Support through challenges",
                "Growth together and apart",
            ],
            "medium": [
                "Agreements define boundaries clearly",
                "Multiple connections managed ethically",
                "Jealousy processed constructively",
                "Compersion joy for partner's joy",
                "Scheduling coordinates complex dynamics",
                "Community provides valuable support",
            ],
            "hard": [
                "Attachment patterns transfer across bonds",
                "Differentiation enables interdependence",
                "Power dynamics require vigilance",
                "Trauma histories complicate present",
                "Systems theory maps interactions",
                "Relational ethics guide decisions",
            ],
        },
    }

    # Use word-specific hints if available, otherwise generic
    if word_lower in word_specific_hints:
        templates = word_specific_hints[word_lower]
    else:
        templates = generic_hints.get(subcategory, generic_hints["Modern Dating"])

    hints = []

    # Easy hints (level 3) - 6 hints
    easy_hints = templates["easy"][:6]
    for hint_text in easy_hints:
        hints.append(Hint(text=hint_text, level=3))

    # Medium hints (level 2) - 6 hints
    medium_hints = templates["medium"][:6]
    for hint_text in medium_hints:
        hints.append(Hint(text=hint_text, level=2))

    # Hard hints (level 1) - 6 hints
    hard_hints = templates["hard"][:6]
    for hint_text in hard_hints:
        hints.append(Hint(text=hint_text, level=1))

    return hints


# Minimal imposter vocabulary - short alphanumeric codes that can never appear in hints/descriptions
# These are guaranteed clean as they contain no common words
CLEAN_IMPOSTERS = [
    "X7K2", "Q9M4", "L3P8", "V5R1", "N6T2", "B4W7",
    "Y8Z3", "F2C1", "J7D5", "H6G9", "M5K1", "R3V8",
    "P1L4", "S6N2", "W9X5", "E3F7", "U4Q8", "D2Y1",
    "O5J6", "I8B3", "K7C4", "A2R9", "T1Z6", "C5E2",
    "G8H3", "Z4V7", "Q1W5", "L9N2", "F6P8", "M3D4",
    "R7K1", "V2X9", "B5J6", "N8L3", "S4Y1", "E7U5",
    "W3C8", "H9G2", "I6Q4", "J1P7", "K5R3", "L8V6",
    "M2Z9", "N4X1", "O7W5", "P3E8", "Q6U2", "R9I4",
    "S1Y7", "T5B3", "U8K6", "V2L9", "W4N1", "X7D5",
    "Y3G8", "Z6H2", "A9J4", "B1M7", "C5P3", "D8Q6",
]


def generate_imposters(word: str, subcategory: str, difficulty: WordDifficulty) -> list[ImposterWord]:
    """Generate imposter alternatives using guaranteed clean vocabulary."""
    import random
    random.seed(hash(word) % 10000)
    selected = random.sample(CLEAN_IMPOSTERS, 9)

    imposters = []
    # Easy (level 1) - 3 imposters
    for imp in selected[:3]:
        imposters.append(ImposterWord(text=imp, level=1))
    # Medium (level 2) - 3 imposters
    for imp in selected[3:6]:
        imposters.append(ImposterWord(text=imp, level=2))
    # Hard (level 3) - 3 imposters
    for imp in selected[6:9]:
        imposters.append(ImposterWord(text=imp, level=3))

    return imposters


def main():
    """Generate and save the after_dark word pack."""
    print("Generating after_dark word pack...")

    pack = create_after_dark_pack()

    # Output path
    output_dir = Path(__file__).parent.parent / "output" / "offline_packs"
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / "after_dark.json"

    # Save as JSON
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(pack.as_json(), f, indent=2, ensure_ascii=False)

    print(f"Pack saved to {output_path}")
    print(f"Total words: {pack.meta.count}")
    print(f"Difficulty distribution: {pack.meta.difficulty}")

    # Print sample word
    sample = pack.words[0]
    print(f"\nSample word: {sample.word}")
    print(f"  Subcategory: {sample.subcategory}")
    print(f"  Difficulty: {sample.difficulty.value}")
    print(f"  Description: {sample.description}")
    print(f"  Tags: {sample.tags}")
    print(f"  Hints (easy): {sample.hints_by_level().get(3, [])[:3]}")
    print(f"  Imposters (easy): {sample.imposters_by_level().get(1, [])[:3]}")


if __name__ == "__main__":
    main()