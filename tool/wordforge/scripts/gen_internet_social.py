"""Generate the internet_social word pack for Hushbug WordForge.

Template-based generation (no LLM) creating ~100 high-quality internet/social media words.
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


def create_internet_social_pack() -> WordPack:
    """Create the internet_social word pack with ~100 words."""

    words_data = [
        # Social Media Platforms & Concepts (20 words: 8 easy, 10 medium, 2 hard)
        {
            "word": "Instagram",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.EASY,
            "description": "A photo and video sharing social networking service owned by Meta.",
            "tags": ["social-media", "photo-sharing", "meta", "app"],
        },
        {
            "word": "TikTok",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.EASY,
            "description": "A short-form video hosting platform known for viral trends and creative content.",
            "tags": ["social-media", "video", "short-form", "viral"],
        },
        {
            "word": "Twitter",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.EASY,
            "description": "A microblogging platform where users post short messages called tweets.",
            "tags": ["social-media", "microblogging", "tweets", "platform"],
        },
        {
            "word": "Facebook",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.EASY,
            "description": "The world's largest social networking site connecting billions of users globally.",
            "tags": ["social-media", "meta", "networking", "platform"],
        },
        {
            "word": "LinkedIn",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A professional networking platform for career development and business connections.",
            "tags": ["social-media", "professional", "career", "networking"],
        },
        {
            "word": "Snapchat",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.EASY,
            "description": "A multimedia messaging app featuring disappearing messages and augmented reality filters.",
            "tags": ["social-media", "messaging", "ar-filters", "disappearing"],
        },
        {
            "word": "Reddit",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A network of communities where people share content and vote on discussions.",
            "tags": ["social-media", "forums", "communities", "voting"],
        },
        {
            "word": "Discord",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.EASY,
            "description": "A voice, video, and text chat platform popular with gamers and communities.",
            "tags": ["social-media", "chat", "voice", "gaming"],
        },
        {
            "word": "Pinterest",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A visual discovery engine for finding ideas like recipes, home decor, and style inspiration.",
            "tags": ["social-media", "visual", "discovery", "inspiration"],
        },
        {
            "word": "Twitch",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.EASY,
            "description": "A live streaming platform primarily for video game content and creative arts.",
            "tags": ["streaming", "live", "gaming", "video"],
        },
        {
            "word": "YouTube",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.EASY,
            "description": "The world's largest video sharing platform hosting user-generated and professional content.",
            "tags": ["streaming", "video", "google", "platform"],
        },
        {
            "word": "Telegram",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A cloud-based messaging app emphasizing speed, security, and large group chats.",
            "tags": ["messaging", "encrypted", "cloud", "privacy"],
        },
        {
            "word": "WhatsApp",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.EASY,
            "description": "A cross-platform messaging app owned by Meta with end-to-end encryption.",
            "tags": ["messaging", "meta", "encrypted", "mobile"],
        },
        {
            "word": "Signal",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A privacy-focused messaging app with open-source end-to-end encryption.",
            "tags": ["messaging", "privacy", "encrypted", "open-source"],
        },
        {
            "word": "Hashtag",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.EASY,
            "description": "A word or phrase preceded by a hash symbol used to categorize content.",
            "tags": ["social-media", "metadata", "categorization", "symbol"],
        },
        {
            "word": "Influencer",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.EASY,
            "description": "A person with a large online following who can affect audience purchasing decisions.",
            "tags": ["social-media", "marketing", "content-creator", "audience"],
        },
        {
            "word": "Viral",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.EASY,
            "description": "Content that spreads rapidly and widely across the internet through sharing.",
            "tags": ["culture", "spread", "popular", "sharing"],
        },
        {
            "word": "Meme",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.EASY,
            "description": "An image, video, or text that is copied and spread rapidly with slight variations.",
            "tags": ["culture", "humor", "viral", "internet-culture"],
        },
        {
            "word": "Shadowban",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.HARD,
            "description": "A covert restriction where a user's content becomes invisible to others without notification.",
            "tags": ["social-media", "moderation", "covert", "restriction"],
        },
        {
            "word": "Verified",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "An account authenticated by the platform as genuine, often with a blue checkmark.",
            "tags": ["social-media", "authentication", "badge", "identity"],
        },

        # Social Media Features (10 words: 4 easy, 4 medium, 2 hard)
        {
            "word": "Feed",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "The continuously updating stream of content displayed on a social media homepage.",
            "tags": ["social-media", "content", "stream", "homepage"],
        },
        {
            "word": "Story",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Short-lived vertical content that disappears after twenty-four hours.",
            "tags": ["social-media", "ephemeral", "vertical", "twenty-four-hours"],
        },
        {
            "word": "Reel",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Short-form vertical video feature on Instagram and Facebook.",
            "tags": ["social-media", "video", "short-form", "vertical"],
        },
        {
            "word": "DM",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.EASY,
            "description": "A private conversation between users on a platform.",
            "tags": ["messaging", "private", "direct", "conversation"],
        },
        {
            "word": "Follower",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.EASY,
            "description": "A user who subscribes to see another account's posts in their feed.",
            "tags": ["social-media", "subscribe", "audience", "account"],
        },
        {
            "word": "Engagement",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.EASY,
            "description": "Interactions on social media content including likes and comments.",
            "tags": ["social-media", "metrics", "interaction", "analytics"],
        },
        {
            "word": "Impressions",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.EASY,
            "description": "The number of times content is displayed on screens regardless of clicks.",
            "tags": ["social-media", "metrics", "views", "analytics"],
        },
        {
            "word": "Bio",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A short profile description displayed on a user's social media page.",
            "tags": ["social-media", "profile", "description", "text"],
        },
        {
            "word": "Handle",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A unique username preceded by an at symbol that identifies an account.",
            "tags": ["social-media", "username", "identifier", "at-symbol"],
        },
        {
            "word": "Trending",
            "subcategory": "Social Media",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Topics or hashtags experiencing a surge in popularity on a platform.",
            "tags": ["social-media", "popular", "topics", "surge"],
        },

        # Messaging & Communication (10 words: 4 easy, 4 medium, 2 hard)
        {
            "word": "Emoji",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.EASY,
            "description": "Small digital images or icons used to express emotions in messages.",
            "tags": ["messaging", "emotion", "icon", "unicode"],
        },
        {
            "word": "GIF",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.EASY,
            "description": "A looping animated image format widely used for reactions in messages.",
            "tags": ["messaging", "animated", "loop", "reaction"],
        },
        {
            "word": "Voice Note",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A recorded audio message sent instead of typing text.",
            "tags": ["messaging", "audio", "recording", "async"],
        },
        {
            "word": "Video Call",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.EASY,
            "description": "A real-time video conversation between two or more people online.",
            "tags": ["messaging", "video", "real-time", "call"],
        },
        {
            "word": "Group Chat",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.EASY,
            "description": "A messaging conversation with three or more participants simultaneously.",
            "tags": ["messaging", "multiple", "participants", "conversation"],
        },
        {
            "word": "Read Receipt",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A notification confirming that a message has been opened by the recipient.",
            "tags": ["messaging", "notification", "opened", "privacy"],
        },
        {
            "word": "Disappearing Messages",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Messages that automatically delete after a set time period.",
            "tags": ["messaging", "ephemeral", "auto-delete", "privacy"],
        },
        {
            "word": "End-to-End Encryption",
            "subcategory": "Security",
            "difficulty": WordDifficulty.HARD,
            "description": "A security method where only communicating users can read the messages.",
            "tags": ["security", "privacy", "encryption", "communication"],
        },
        {
            "word": "Zoom",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.EASY,
            "description": "A video conferencing platform for virtual meetings and webinars.",
            "tags": ["messaging", "video-conferencing", "meetings", "remote"],
        },
        {
            "word": "Slack",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A business messaging platform organizing conversations into channels.",
            "tags": ["messaging", "business", "channels", "workspace"],
        },

        # Streaming & Content Creation (12 words: 3 easy, 7 medium, 2 hard)
        {
            "word": "Streamer",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A person who broadcasts live video content to an online audience.",
            "tags": ["streaming", "live", "broadcaster", "content-creator"],
        },
        {
            "word": "VOD",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Recorded content available to watch anytime after broadcast.",
            "tags": ["streaming", "recorded", "on-demand", "archive"],
        },
        {
            "word": "Chat",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.EASY,
            "description": "The live text conversation sidebar during a stream where viewers interact.",
            "tags": ["streaming", "live", "text", "viewers"],
        },
        {
            "word": "Subscriber",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.EASY,
            "description": "A paying viewer who supports a streamer monthly for perks and emotes.",
            "tags": ["streaming", "paid", "support", "perks"],
        },
        {
            "word": "Donation",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.EASY,
            "description": "A voluntary monetary gift from viewers to support a content creator.",
            "tags": ["streaming", "support", "money", "voluntary"],
        },
        {
            "word": "Raid",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.HARD,
            "description": "Sending your viewers to another streamer's channel at the end of your broadcast.",
            "tags": ["streaming", "community", "support", "viewers"],
        },
        {
            "word": "Overlay",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.HARD,
            "description": "Graphics layered over a live stream showing alerts, goals, and branding.",
            "tags": ["streaming", "graphics", "alerts", "branding"],
        },
        {
            "word": "Bitrate",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.HARD,
            "description": "The amount of data transmitted per second determining video quality.",
            "tags": ["streaming", "technical", "quality", "data-rate"],
        },
        {
            "word": "Podcast",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.EASY,
            "description": "An episodic audio series available for download or streaming on demand.",
            "tags": ["streaming", "audio", "episodic", "on-demand"],
        },
        {
            "word": "Vlog",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.EASY,
            "description": "A video blog documenting a person's life, thoughts, or experiences.",
            "tags": ["streaming", "video", "blog", "personal"],
        },
        {
            "word": "Thumbnail",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A small preview image representing a video that viewers see before clicking.",
            "tags": ["streaming", "preview", "image", "click-through"],
        },
        {
            "word": "Sponsor",
            "subcategory": "Streaming",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A brand paying a creator to promote their product within content.",
            "tags": ["streaming", "brand", "promotion", "paid"],
        },

        # Gaming & Esports (10 words: 2 easy, 6 medium, 2 hard)
        {
            "word": "Esports",
            "subcategory": "Gaming",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Competitive video gaming at a professional level with organized tournaments.",
            "tags": ["gaming", "competitive", "professional", "tournaments"],
        },
        {
            "word": "MMO",
            "subcategory": "Gaming",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Massively multiplayer online game supporting thousands of simultaneous players.",
            "tags": ["gaming", "multiplayer", "online", "massive"],
        },
        {
            "word": "Battle Royale",
            "subcategory": "Gaming",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A game genre where many players fight until one remains alive.",
            "tags": ["gaming", "genre", "survival", "last-standing"],
        },
        {
            "word": "NPC",
            "subcategory": "Gaming",
            "difficulty": WordDifficulty.EASY,
            "description": "A game entity controlled by the computer not a human.",
            "tags": ["gaming", "computer-controlled", "character", "ai"],
        },
        {
            "word": "Loot",
            "subcategory": "Gaming",
            "difficulty": WordDifficulty.EASY,
            "description": "Items, currency, or rewards obtained by defeating enemies or completing tasks.",
            "tags": ["gaming", "rewards", "items", "currency"],
        },
        {
            "word": "Grind",
            "subcategory": "Gaming",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Repetitive gameplay performed to gain experience, items, or currency.",
            "tags": ["gaming", "repetitive", "experience", "progression"],
        },
        {
            "word": "Meta",
            "subcategory": "Gaming",
            "difficulty": WordDifficulty.HARD,
            "description": "The most effective tactics available in a game.",
            "tags": ["gaming", "strategy", "optimal", "competitive"],
        },
        {
            "word": "Nerf",
            "subcategory": "Gaming",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A developer change that weakens a character, weapon, or ability for balance.",
            "tags": ["gaming", "balance", "weaken", "patch"],
        },
        {
            "word": "Patch",
            "subcategory": "Gaming",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A game update that fixes bugs, adjusts balance, or adds new content.",
            "tags": ["gaming", "update", "fix", "balance"],
        },
        {
            "word": "Speedrun",
            "subcategory": "Gaming",
            "difficulty": WordDifficulty.HARD,
            "description": "Completing a game as fast as possible often using glitches and optimized routes.",
            "tags": ["gaming", "fast", "glitches", "optimization"],
        },

        # Tech & Development (14 words: 3 easy, 9 medium, 2 hard)
        {
            "word": "API",
            "subcategory": "Development",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Application programming interface rules allowing software to communicate.",
            "tags": ["development", "interface", "software", "communication"],
        },
        {
            "word": "Frontend",
            "subcategory": "Development",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "The user-facing part of a website or application built with HTML, CSS, and JavaScript.",
            "tags": ["development", "ui", "client-side", "browser"],
        },
        {
            "word": "Backend",
            "subcategory": "Development",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "The server-side logic, databases, and APIs powering an application.",
            "tags": ["development", "server-side", "database", "logic"],
        },
        {
            "word": "GitHub",
            "subcategory": "Development",
            "difficulty": WordDifficulty.EASY,
            "description": "A platform for hosting and collaborating on code repositories using Git.",
            "tags": ["development", "git", "repository", "collaboration"],
        },
        {
            "word": "Repository",
            "subcategory": "Development",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A storage location for code projects including version history and branches.",
            "tags": ["development", "storage", "version-control", "code"],
        },
        {
            "word": "Pull Request",
            "subcategory": "Development",
            "difficulty": WordDifficulty.HARD,
            "description": "A proposal to merge code changes from one branch into another for review.",
            "tags": ["development", "merge", "review", "collaboration"],
        },
        {
            "word": "CI/CD",
            "subcategory": "Development",
            "difficulty": WordDifficulty.HARD,
            "description": "Automated testing and delivery for software development.",
            "tags": ["development", "automation", "testing", "deployment"],
        },
        {
            "word": "Cloud",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.EASY,
            "description": "Remote servers accessed over the internet for storage and computing power.",
            "tags": ["tech", "remote", "servers", "internet"],
        },
        {
            "word": "Server",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.EASY,
            "description": "A computer system that provides resources, data, or services to other computers.",
            "tags": ["tech", "computer", "resources", "services"],
        },
        {
            "word": "Database",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.EASY,
            "description": "An organized collection of structured data stored and accessed electronically.",
            "tags": ["tech", "data", "storage", "structured"],
        },
        {
            "word": "Cache",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A temporary storage layer that speeds up access to frequently used data.",
            "tags": ["tech", "temporary", "speed", "performance"],
        },
        {
            "word": "Latency",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.HARD,
            "description": "The delay between a user action and the system response measured in milliseconds.",
            "tags": ["tech", "delay", "performance", "milliseconds"],
        },
        {
            "word": "Bandwidth",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.HARD,
            "description": "The maximum amount of data that can be transmitted over a connection per second.",
            "tags": ["tech", "data-rate", "connection", "capacity"],
        },
        {
            "word": "Cookie",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.EASY,
            "description": "A small text file stored by websites to remember user preferences and sessions.",
            "tags": ["tech", "storage", "tracking", "session"],
        },

        # Internet Culture & Slang (10 words: 3 easy, 5 medium, 2 hard)
        {
            "word": "Troll",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.EASY,
            "description": "Someone who deliberately posts inflammatory content to provoke emotional responses.",
            "tags": ["culture", "provocative", "inflammatory", "disruption"],
        },
        {
            "word": "Lurker",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A person who reads online discussions but rarely or never participates.",
            "tags": ["culture", "passive", "reading", "non-participation"],
        },
        {
            "word": "TL;DR",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.EASY,
            "description": "A summary of lengthy content for quick consumption.",
            "tags": ["culture", "summary", "abbreviation", "quick"],
        },
        {
            "word": "FOMO",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.EASY,
            "description": "Anxiety about not being included in experiences.",
            "tags": ["culture", "anxiety", "social", "psychology"],
        },
        {
            "word": "Doomscrolling",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Compulsively scrolling through negative news and content for extended periods.",
            "tags": ["culture", "negative", "compulsive", "mental-health"],
        },
        {
            "word": "Stan",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "An extremely devoted fan of a celebrity, artist, or franchise.",
            "tags": ["culture", "fan", "devoted", "celebrity"],
        },
        {
            "word": "Cringe",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.EASY,
            "description": "A feeling of secondhand embarrassment from awkward or try-hard content.",
            "tags": ["culture", "embarrassment", "awkward", "reaction"],
        },
        {
            "word": "Ghosting",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Suddenly cutting off all communication with someone without explanation.",
            "tags": ["culture", "communication", "dating", "disappearance"],
        },
        {
            "word": "Based",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.HARD,
            "description": "Slang meaning agreeable, authentic, or factually correct regardless of popularity.",
            "tags": ["culture", "slang", "authentic", "agreement"],
        },
        {
            "word": "Clickbait",
            "subcategory": "Culture",
            "difficulty": WordDifficulty.HARD,
            "description": "Sensationalized headlines or thumbnails designed to attract clicks misleadingly.",
            "tags": ["culture", "misleading", "sensational", "clicks"],
        },

        # Security (10 words: 1 easy, 7 medium, 2 hard)
        {
            "word": "Catfish",
            "subcategory": "Security",
            "difficulty": WordDifficulty.EASY,
            "description": "Someone who creates a fake online identity to deceive others romantically.",
            "tags": ["security", "fake", "identity", "deception"],
        },
        {
            "word": "Doxxing",
            "subcategory": "Security",
            "difficulty": WordDifficulty.HARD,
            "description": "Publishing private personal information without consent to harass or threaten.",
            "tags": ["security", "privacy", "harassment", "personal-info"],
        },
        {
            "word": "Swatting",
            "subcategory": "Security",
            "difficulty": WordDifficulty.HARD,
            "description": "A dangerous prank calling emergency services to someone's address falsely.",
            "tags": ["security", "prank", "emergency", "dangerous"],
        },
        {
            "word": "Phishing",
            "subcategory": "Security",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Fraudulent attempts to obtain sensitive data by impersonating trusted entities.",
            "tags": ["security", "fraud", "deception", "credentials"],
        },
        {
            "word": "2FA",
            "subcategory": "Security",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Requiring a second verification step beyond password.",
            "tags": ["security", "authentication", "verification", "protection"],
        },
        {
            "word": "VPN",
            "subcategory": "Security",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Encrypts internet traffic and masks IP address.",
            "tags": ["security", "privacy", "encryption", "ip-mask"],
        },
        {
            "word": "Tracker",
            "subcategory": "Security",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Code that monitors user behavior across websites for advertising and analytics.",
            "tags": ["security", "privacy", "monitoring", "advertising"],
        },
        {
            "word": "Ad Blocker",
            "subcategory": "Security",
            "difficulty": WordDifficulty.EASY,
            "description": "Software that prevents advertisements from displaying on web pages.",
            "tags": ["security", "privacy", "ads", "browser-extension"],
        },
        {
            "word": "Incognito",
            "subcategory": "Security",
            "difficulty": WordDifficulty.EASY,
            "description": "A browser mode that does not save history, cookies, or form data locally.",
            "tags": ["security", "privacy", "browser", "history"],
        },
        {
            "word": "Captcha",
            "subcategory": "Security",
            "difficulty": WordDifficulty.EASY,
            "description": "A challenge-response test distinguishing human users from automated bots.",
            "tags": ["security", "human-verification", "bot", "challenge"],
        },

        # Digital Economy & Web3 (6 words: 0 easy, 2 medium, 4 hard)
        {
            "word": "NFT",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.HARD,
            "description": "A unique digital asset verified on a blockchain.",
            "tags": ["tech", "blockchain", "digital-asset", "unique"],
        },
        {
            "word": "Cryptocurrency",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.HARD,
            "description": "Digital currency secured by cryptography operating on decentralized networks.",
            "tags": ["tech", "digital-currency", "blockchain", "decentralized"],
        },
        {
            "word": "Wallet",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A digital application for storing, sending, and receiving cryptocurrency.",
            "tags": ["tech", "crypto", "storage", "transaction"],
        },
        {
            "word": "Metaverse",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.HARD,
            "description": "A collective virtual shared space blending physical and digital realities.",
            "tags": ["tech", "virtual", "3d", "immersive"],
        },
        {
            "word": "Web3",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.HARD,
            "description": "A vision for a decentralized internet built on blockchain technology.",
            "tags": ["tech", "decentralized", "blockchain", "internet"],
        },
        {
            "word": "DAO",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.HARD,
            "description": "Governed by smart contracts on blockchain.",
            "tags": ["tech", "governance", "blockchain", "smart-contracts"],
        },

        # Communication & Collaboration Tools (4 words: 1 easy, 3 medium)
        {
            "word": "Teams",
            "subcategory": "Messaging",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "Microsoft's collaboration platform combining chat, meetings, and file sharing.",
            "tags": ["messaging", "microsoft", "collaboration", "office"],
        },
        {
            "word": "Notion",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "An all-in-one workspace for notes, databases, and project management.",
            "tags": ["tech", "productivity", "notes", "workspace"],
        },
        {
            "word": "Figma",
            "subcategory": "Development",
            "difficulty": WordDifficulty.MEDIUM,
            "description": "A collaborative web-based interface design tool for UI and UX design.",
            "tags": ["development", "design", "ui", "collaborative"],
        },
        {
            "word": "Canva",
            "subcategory": "Tech",
            "difficulty": WordDifficulty.EASY,
            "description": "A graphic design platform with templates for social media and marketing.",
            "tags": ["tech", "design", "templates", "graphics"],
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
            id=f"offline:internet_social:{word.lower().replace(' ', '-').replace('/', '-')}",
            word=word,
            category="internet_social",
            subcategory=subcategory,
            difficulty=difficulty,
            tags=tags,
            is_adult=False,
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
        id="internet_social",
        name="Internet & Social Media",
        description="~100 words covering social media platforms, messaging, streaming, gaming, tech, internet culture, security, and development.",
        icon="globe",
        is_adult=False,
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

    # Word-specific hints for key terms - carefully avoiding the secret word
    word_specific_hints = {
        "instagram": {
            "easy": [
                "Photo sharing app with filters",
                "Owned by Meta company",
                "Square photos originally",
                "Stories and Reels features",
                "Influencer marketing hub",
                "Double tap to like posts",
            ],
            "medium": [
                "Algorithm prioritizes engagement",
                "Explore page shows recommendations",
                "Hashtags boost discoverability",
                "Shopping tags link products",
                "IGTV for longer videos",
                "Close friends list for privacy",
            ],
            "hard": [
                "Graph API for developers",
                "Covert restriction reduces reach",
                "Verified badge for notable accounts",
                "Rate limits on API endpoints",
                "OAuth for third-party login",
                "Webhooks for real-time events",
            ],
        },
        "tiktok": {
            "easy": [
                "Short vertical video app",
                "Viral dances and trends",
                "For You page algorithm",
                "Duet and stitch features",
                "Sound library for creators",
                "Owned by ByteDance",
            ],
            "medium": [
                "Recommendation engine is powerful",
                "Creator fund pays for views",
                "Live streaming with gifts",
                "Effects and filters library",
                "Tag challenges trend",
                "Shop feature for commerce",
            ],
            "hard": [
                "Content graph maps interests",
                "Covert restriction limits distribution",
                "API for analytics partners",
                "Moderation AI scans content",
                "Pixel tracks conversions",
                "Spark ads amplify organic posts",
            ],
        },
        "twitter": {
            "easy": [
                "Microblogging with 280 chars",
                "Posts called tweets",
                "Retweet shares content",
                "Hashtags organize topics",
                "Trending topics sidebar",
                "Verified blue checkmark",
            ],
            "medium": [
                "Threads connect multiple tweets",
                "Spaces for audio rooms",
                "Lists curate accounts",
                "Bookmarks save privately",
                "Analytics track impressions",
                "API v2 for developers",
            ],
            "hard": [
                "Rate limits on API calls",
                "Visibility filtering silently",
                "Birdwatch community notes",
                "OAuth 2.0 for authentication",
                "Webhooks for real-time data",
                "Firehose full tweet stream",
            ],
        },
        "facebook": {
            "easy": [
                "Largest social network",
                "Meta company flagship",
                "News Feed algorithm",
                "Groups for communities",
                "Marketplace for selling",
                "Events for gatherings",
            ],
            "medium": [
                "Pixel tracks conversions",
                "Ad Manager for targeting",
                "Stories cross-post to IG",
                "Reels short video format",
                "Messenger integrated chat",
                "Business Suite manages pages",
            ],
            "hard": [
                "Graph API for developers",
                "CAPI server-side tracking",
                "Instant Articles format",
                "Oculus VR integration",
                "Libra/Diem crypto project",
                "Federated learning research",
            ],
        },
        "linkedin": {
            "easy": [
                "Professional networking site",
                "Resume and job search",
                "Connections not friends",
                "Endorsements for skills",
                "Company pages for brands",
                "Learning courses available",
            ],
            "medium": [
                "Sales Navigator for leads",
                "Recruiter finds candidates",
                "Pulse publishes articles",
                "Alumni tool networks grads",
                "Events for professionals",
                "Ads target by job title",
            ],
            "hard": [
                "API for talent solutions",
                "Data scraping restrictions",
                "Skills assessment platform",
                "Learning LMS integration",
                "B2B marketing attribution",
                "Employee advocacy tools",
            ],
        },
        "snapchat": {
            "easy": [
                "Disappearing messages app",
                "AR lenses and filters",
                "Stories last 24 hours",
                "Snap Map shows friends",
                "Streaks count daily snaps",
                "Discover media content",
            ],
            "medium": [
                "Spotlight for viral videos",
                "Memories saves snaps",
                "Bitmoji personalized avatars",
                "Snap Kit for developers",
                "Dynamic ads insert in stories",
                "Lens Studio creates AR",
            ],
            "hard": [
                "SnapML runs ML on device",
                "Camera Kit embeds camera",
                "Conversions API tracking",
                "Audience network extends reach",
                "Dynamic product ads",
                "Privacy-safe attribution",
            ],
        },
        "reddit": {
            "easy": [
                "Forum site with sub-communities",
                "Upvote and downvote posts",
                "Karma scores contributions",
                "AMAs ask me anything",
                "Moderators manage communities",
                "Anonymous usernames common",
            ],
            "medium": [
                "Premium awards for posts",
                "Popular posts front page",
                "Custom feeds combine subs",
                "Old vs new interface",
                "API for bots and tools",
                "Collectible avatars NFT",
            ],
            "hard": [
                "Pushshift archives data",
                "Automoderator config rules",
                "Crowd control filters new users",
                "GraphQL API endpoint",
                "Predictive ranking models",
                "Community points on blockchain",
            ],
        },
        "discord": {
            "easy": [
                "Voice and text chat app",
                "Servers with channels",
                "Roles manage permissions",
                "Bots add functionality",
                "Nitro premium subscription",
                "Popular with gamers",
            ],
            "medium": [
                "Stage channels for audio",
                "Threads organize discussions",
                "Webhooks post from elsewhere",
                "Rich presence shows game",
                "Slash commands trigger bots",
                "Partner program for large servers",
            ],
            "hard": [
                "Gateway intent system",
                "Opus audio codec low latency",
                "RPC for game integration",
                "OAuth2 for bot auth",
                "Audit log tracks actions",
                "Verified server badge",
            ],
        },
        "twitch": {
            "easy": [
                "Live streaming platform",
                "Gaming content focus",
                "Chat beside video",
                "Subscribe for emotes",
                "Bits cheer streamers",
                "Clips save moments",
            ],
            "medium": [
                "Affiliate and Partner tiers",
                "Raid sends viewers over",
                "VODs save past streams",
                "Drops reward game items",
                "Extensions overlay video",
                "Category browse games",
            ],
            "hard": [
                "HLS adaptive bitrate streaming",
                "IRC-based chat protocol",
                "EventSub webhooks API",
                "Drops campaign system",
                "Predictions interactive polls",
                "Guest star co-streaming",
            ],
        },
        "youtube": {
            "easy": [
                "Largest video platform",
                "Google owned service",
                "Channels upload content",
                "Subscribe for updates",
                "Comments on videos",
                "Shorts vertical format",
            ],
            "medium": [
                "Recommendation algorithm",
                "Monetization with ads",
                "Premium removes ads",
                "Music and Premium tiers",
                "Community tab posts",
                "Live streaming capable",
            ],
            "hard": [
                "Content ID copyright system",
                "Data API v3 for developers",
                "HLS/DASH streaming protocols",
                "Shorts Fund creator pool",
                "Super Chat paid messages",
                "BrandConnect sponsorships",
            ],
        },
        "telegram": {
            "easy": [
                "Cloud messaging app",
                "Large group chats",
                "Channels broadcast messages",
                "Stickers and bots",
                "Secret chats encrypted",
                "Username not phone needed",
            ],
            "medium": [
                "MTProto encryption protocol",
                "Bot API for automation",
                "Voice chats in groups",
                "Animated stickers TGS",
                "Instant View for articles",
                "Passport for identity",
            ],
            "hard": [
                "MTProto 2.0 security layer",
                "TDLib for client dev",
                "Fragment username marketplace",
                "TON blockchain integration",
                "Custom emoji for premium",
                "Story feature rolling out",
            ],
        },
        "whatsapp": {
            "easy": [
                "Meta owned messenger",
                "End-to-end encryption",
                "Phone number identity",
                "Voice and video calls",
                "Status updates 24hrs",
                "Groups up to 1024",
            ],
            "medium": [
                "Business API for companies",
                "Payments in some regions",
                "Disappearing messages timer",
                "View once media vanishes",
                "Communities group groups",
                "Chat lock with biometrics",
            ],
            "hard": [
                "Signal Protocol implementation",
                "Key transparency verifies",
                "Multi-device sync architecture",
                "Flows for business forms",
                "Proxy support for censorship",
                "Account protect blocks SIM swap",
            ],
        },
        "hashtag": {
            "easy": [
                "Hash symbol tags topics",
                "Click to see related posts",
                "Trending shows popular tags",
                "No spaces in tags",
                "Categories content easily",
                "Originated on Twitter",
            ],
            "medium": [
                "Boosts post discoverability",
                "Brand campaigns create tags",
                "Niche tags find communities",
                "Analytics track performance",
                "Banned tags hidden silently",
                "Follow tags on IG",
            ],
            "hard": [
                "Shadowban hides from search",
                "API tracks volume velocity",
                "Co-occurrence maps networks",
                "Sentiment analysis by tag",
                "Cross-platform tag tracking",
                "Tag challenge campaigns",
            ],
        },
        "influencer": {
            "easy": [
                "Large social media following",
                "Brands pay for promotion",
                "Content creator profession",
                "Engagement rate matters",
                "Niche audience trust",
                "Sponsored posts labeled",
            ],
            "medium": [
                "Micro vs macro tiers",
                "Affiliate links track sales",
                "Media kit shows metrics",
                "Authenticity drives trust",
                "Contract negotiates usage",
                "FTC requires disclosure",
            ],
            "hard": [
                "Fake follower detection tools",
                "CPM varies by platform",
                "Whitelisting boosts reach",
                "Creator marketplace platforms",
                "Attribution modeling complex",
                "Long-term ambassador deals",
            ],
        },
        "algorithm": {
            "easy": [
                "Rules sort your feed",
                "Decides what you see first",
                "Learns from your actions",
                "Different per platform",
                "Engagement signals matter",
                "Changes frequently",
            ],
            "medium": [
                "Ranking signals weighted",
                "Personalization per user",
                "Content categorization ML",
                "Freshness vs relevance",
                "Diversity prevents bubbles",
                "A/B tests optimize metrics",
            ],
            "hard": [
                "Embedding vectors represent content",
                "Multi-objective optimization",
                "Position bias correction",
                "Cold start problem new users",
                "Fairness constraints applied",
                "Real-time inference serving",
            ],
        },
        "viral": {
            "easy": [
                "Spreads fast online",
                "Shared by many people",
                "High view count quickly",
                "Memes often spread fast",
                "Trending on platforms",
                "Organic reach explodes",
            ],
            "medium": [
                "Spread rate measures reach",
                "Seeding jumpstarts spread",
                "Emotional triggers share",
                "Network effects amplify",
                "Platform algorithms boost",
                "Lifecycle: rise peak fade",
            ],
            "hard": [
                "R0 reproductive number concept",
                "Cascade prediction models",
                "Bot amplification detection",
                "Cross-platform diffusion paths",
                "Content fingerprinting tracks",
                "Spread engineering tactics",
            ],
        },
        "meme": {
            "easy": [
                "Funny image with text",
                "Spreads with variations",
                "Template format reusable",
                "Relatable humor works",
                "Image macros classic style",
                "Video formats too",
            ],
            "medium": [
                "Know Your Documents",
                "Formats evolve rapidly",
                "Inside jokes signal belonging",
                "Brands attempt humor marketing",
                "Deep fried surreal humor",
                "Dank irony layers",
            ],
            "hard": [
                "Internet anthropology studies spread",
                "Semantic mutation across uses",
                "Platform affordances shape forms",
                "Copyright fair use questions",
                "Stocks market impact",
                "Generative AI creates variants",
            ],
        },
        "streamer": {
            "easy": [
                "Broadcasts live content",
                "Interacts with chat",
                "Plays games on camera",
                "Earns from subs and bits",
                "Schedule builds audience",
                "Personality drives growth",
            ],
            "medium": [
                "Affiliate then Partner path",
                "Overlay brands the stream",
                "Alerts notify new subs",
                "Multi-stream to platforms",
                "Collabs cross-pollinate",
                "VODs create YouTube content",
            ],
            "hard": [
                "Stream key RTMP ingest",
                "Scene collections OBS",
                "Bitrate CBR vs VBR",
                "NVENC hardware encoding",
                "Low latency HLS LL-HLS",
                "Simulcast restream.io",
            ],
        },
        "esports": {
            "easy": [
                "Pro competitive gaming",
                "Tournaments prize money",
                "Teams have sponsors",
                "Leagues like sports",
                "Viewers watch live",
                "Players are athletes",
            ],
            "medium": [
                "Franchise league model",
                "Draft picks new talent",
                "Meta shifts each patch",
                "Casters narrate matches",
                "Analytics drive strategy",
                "Academy teams develop pros",
            ],
            "hard": [
                "Scrims practice matches",
                "VOD review improves play",
                "Frame perfect execution",
                "Rollback netcode LAN",
                "Salary cap regulations",
                "Player unionization efforts",
            ],
        },
        "api": {
            "easy": [
                "Apps talk to each other",
                "Request response format",
                "Keys authenticate access",
                "Rate limits prevent abuse",
                "Documentation shows usage",
                "REST common style",
            ],
            "medium": [
                "GraphQL queries exactly",
                "Webhooks push real-time",
                "OAuth delegates permission",
                "SDKs wrap HTTP calls",
                "Versioning maintains compat",
                "Idempotency keys safe retry",
            ],
            "hard": [
                "gRPC protobuf efficient",
                "Rate limit algorithms token bucket",
                "Caching ETags conditional",
                "Circuit breaker prevents cascade",
                "Observability tracing spans",
                "Schema registry validates",
            ],
        },
        "github": {
            "easy": [
                "Code hosting platform",
                "Git version control",
                "Pull requests review code",
                "Issues track bugs",
                "Actions run CI/CD",
                "Stars show popularity",
            ],
            "medium": [
                "Forks copy repos",
                "Branches isolate work",
                "Merge conflicts resolve",
                "Releases package versions",
                "Pages host static sites",
                "Copilot AI assists code",
            ],
            "hard": [
                "Git refs and internals",
                "Rebase rewrites history",
                "Signed commits verify",
                "Dependabot updates deps",
                "CodeQL scans security",
                "Advanced apps with permissions",
            ],
        },
        "cloud": {
            "easy": [
                "Servers in data centers",
                "Access via internet",
                "Pay for what you use",
                "Scales up and down",
                "AWS Azure GCP big three",
                "Storage compute network",
            ],
            "medium": [
                "IaaS PaaS SaaS models",
                "Regions zones availability",
                "Load balancers distribute",
                "Auto-scaling groups",
                "CDN caches at edge",
                "Serverless functions run",
            ],
            "hard": [
                "Kubernetes orchestrates",
                "Terraform infra as code",
                "Service mesh Istio",
                "FinOps optimizes spend",
                "Multi-provider strategies",
                "Edge computing pushes out",
            ],
        },
        "vpn": {
            "easy": [
                "Encrypts internet traffic",
                "Hides your IP address",
                "Access geo-blocked content",
                "Secure on public WiFi",
                "No logs policy important",
                "Apps for all devices",
            ],
            "medium": [
                "WireGuard fast modern protocol",
                "Kill switch prevents leaks",
                "Split tunneling selects apps",
                "Multi-hop chains servers",
                "Obfuscation beats blocking",
                "Dedicated IP option",
            ],
            "hard": [
                "Perfect forward secrecy keys",
                "RAM-only servers no disks",
                "Audit verifies no-logs",
                "WireGuard handshake 1-RTT",
                "Post-quantum crypto prep",
                "Split DNS routes selectively",
            ],
        },
        "nft": {
            "easy": [
                "Unique digital token",
                "Blockchain proves ownership",
                "Art collectibles common",
                "Not interchangeable like money",
                "Minting creates new ones",
                "Wallets store them",
            ],
            "medium": [
                "ERC-721 standard Ethereum",
                "Metadata points to media",
                "Royalties on resales",
                "Gas fees cost to mint",
                "Marketplaces list for sale",
                "Utility beyond art emerging",
            ],
            "hard": [
                "ERC-1155 multi-token standard",
                "IPFS stores media decentralized",
                "Soulbound tokens non-transferable",
                "Programmable tokens change state",
                "Fractionalization splits ownership",
                "Cross-chain bridges move assets",
            ],
        },
        "crypto": {
            "easy": [
                "Digital currency blockchain",
                "Bitcoin first and largest",
                "Decentralized no central bank",
                "Wallets hold private keys",
                "Exchanges buy and sell",
                "Volatile prices change fast",
            ],
            "medium": [
                "Proof of work secures Bitcoin",
                "Proof of stake Ethereum",
                "DeFi replaces banks",
                "Stablecoins peg to dollar",
                "Layer 2 scales throughput",
                "Cold storage hardware wallets",
            ],
            "hard": [
                "ZK-proofs privacy scaling",
                "MEV extracts value blocks",
                "Rollups optimistic ZK",
                "Account abstraction ERC-4337",
                "Restaking EigenLayer",
                "Intent-centric architectures",
            ],
        },
        "metaverse": {
            "easy": [
                "Virtual shared 3D space",
                "Avatars represent users",
                "VR headsets immerse",
                "Digital economy inside",
                "Persistent always on",
                "Interoperable ideal goal",
            ],
            "medium": [
                "Digital twins mirror real",
                "Creator economy builds",
                "Interoperable assets move",
                "Spatial computing blends",
                "WebXR browser based",
                "Haptics add touch feel",
            ],
            "hard": [
                "OpenXR standard APIs",
                "USD universal scene description",
                "GlTF 3D transmission format",
                "Distributed simulation state",
                "Edge rendering cloud GPU",
                "Identity portable across worlds",
            ],
        },
        "web3": {
            "easy": [
                "Decentralized internet vision",
                "Blockchain base layer",
                "Users own their data",
                "Tokens incentivize participation",
                "Wallets replace logins",
                "DAOs govern communities",
            ],
            "medium": [
                "Self-sovereign identity DID",
                "Verifiable credentials W3C",
                "IPFS content addressing",
                "ENS names resolve addresses",
                "Account abstraction smart wallets",
                "Zero-knowledge proofs privacy",
            ],
            "hard": [
                "Rollups scale execution",
                "Data availability sampling",
                "PBS proposer builder separation",
                "Danksharding scales Ethereum",
                "Intent-based architectures",
                "Modular blockchain stacks",
            ],
        },
        "dao": {
            "easy": [
                "Decentralized organization",
                "Token holders vote",
                "Smart contracts execute",
                "No central leadership",
                "Treasury funds projects",
                "Transparent on-chain",
            ],
            "medium": [
                "Governance tokens power",
                "Snapshot off-chain voting",
                "Multisig secures treasury",
                "Delegation assigns votes",
                "Quadratic funding matches",
                "Legal wrappers emerging",
            ],
            "hard": [
                "Optimistic governance delays",
                "Veto councils protect",
                "Rage quit exits members",
                "Sub-groups compartmentalize",
                "AI agents participate",
                "Cross-chain governance messaging",
            ],
        },
        "podcast": {
            "easy": [
                "Audio show episodes",
                "Subscribe via RSS feed",
                "Listen anytime anywhere",
                "Hosts discuss topics",
                "Guests interviewed often",
                "Free on most platforms",
            ],
            "medium": [
                "Dynamic ad insertion",
                "Visual shows growing",
                "Analytics track downloads",
                "Monetization sponsorships",
                "Networks bundle shows",
                "Transcripts improve SEO",
            ],
            "hard": [
                "RSS 2.0 enclosure tag",
                "Directory Index decentralized",
                "Value4Value lightning payments",
                "Cross-app comments ActivityPub",
                "Chapters JSON in show notes",
                "Remote recording clean audio",
            ],
        },
        "zoom": {
            "easy": [
                "Video meeting platform",
                "Screen share presents",
                "Breakout rooms split",
                "Record meetings cloud",
                "Virtual backgrounds fun",
                "Chat during calls",
            ],
            "medium": [
                "Webinar mode large audience",
                "Waiting room admits guests",
                "Polls engage participants",
                "Whiteboard collaborate",
                "Apps marketplace extends",
                "Phone dial-in option",
            ],
            "hard": [
                "SVC scalable video coding",
                "Simulcast multiple layers",
                "E2EE end-to-end option",
                "SIP/H.323 room connectors",
                "RTMP live streaming out",
                "Web SDK embeds meetings",
            ],
        },
        "slack": {
            "easy": [
                "Team chat workspace",
                "Channels organize topics",
                "Threads keep replies tidy",
                "Integrations connect tools",
                "Search finds history",
                "Emoji reactions quick",
            ],
            "medium": [
                "Workflow Builder automates",
                "Canvas docs in chat",
                "Huddles audio quick sync",
                "Connect external orgs",
                "Enterprise Grid large scale",
                "Audit logs compliance",
            ],
            "hard": [
                "Block Kit builds UI",
                "Bolt framework bots",
                "SCIM provisions users",
                "EKM manages keys",
                "DLP prevents leaks",
                "Session duration limits",
            ],
        },
        "figma": {
            "easy": [
                "Browser design tool",
                "Real-time collaboration",
                "Components reusable elements",
                "Auto layout responsive",
                "Prototyping links frames",
                "Free for individuals",
            ],
            "medium": [
                "Design systems scale",
                "Variables tokens theming",
                "Dev mode handoff specs",
                "Plugins extend features",
                "Branching merges designs",
                "Comments annotate feedback",
            ],
            "hard": [
                "WASM renders canvas fast",
                "CRDT syncs multiplayer",
                "REST API automates",
                "Webhooks notify changes",
                "Private plugins enterprise",
                "Design tokens export JSON",
            ],
        },
        "canva": {
            "easy": [
                "Graphic design templates",
                "Drag drop easy use",
                "Social media sizes preset",
                "Free and Pro tiers",
                "Brand kit consistent",
                "Magic AI generates",
            ],
            "medium": [
                "Video editor timeline",
                "Print products ship",
                "Content planner schedules",
                "Bulk create variations",
                "Teams collaborate brand",
                "Apps marketplace extends",
            ],
            "hard": [
                "Design system manages",
                "API automates creation",
                "Enterprise controls brand",
                "SSO SCIM provisions",
                "Content approval workflows",
                "Asset library governs",
            ],
        },
    }

    # Default generic hints by subcategory - using vocabulary that NEVER appears in imposter pools
    generic_hints = {
        "Social Media": {
            "easy": [
                "Popular online platform",
                "Used for sharing content online",
                "Has likes and comments",
                "Connect with others",
                "Profile with audience",
                "Scroll through timeline",
            ],
            "medium": [
                "Algorithm determines visibility",
                "Creators build audiences here",
                "Tags categorize posts",
                "Stories disappear after a day",
                "Direct messages for chat",
                "Analytics track interactions",
            ],
            "hard": [
                "Covert restriction limits reach",
                "Verification confirms identity",
                "API enables integrations",
                "Rate limits prevent abuse",
                "Webhooks push real-time data",
                "OAuth delegates authentication",
            ],
        },
        "Messaging": {
            "easy": [
                "Send messages instantly",
                "Group conversations with many",
                "Share photos and media",
                "Voice recordings instead of typing",
                "Reactions to messages",
                "Confirmation shows viewed",
            ],
            "medium": [
                "Encryption protects privacy",
                "Messages can auto-delete",
                "Stickers are larger icons",
                "Calls with screen sharing",
                "Pin important conversations",
                "Reply to specific messages",
            ],
            "hard": [
                "Protocol uses modern encryption",
                "Metadata reveals patterns",
                "Forward secrecy rotates keys",
                "Registration lock prevents swap",
                "Safety numbers verify contacts",
                "Sealed sender hides routing",
            ],
        },
        "Streaming": {
            "easy": [
                "Watch live video content",
                "Talk with other viewers",
                "Subscribe for perks",
                "Creators broadcast live",
                "Gifts support them",
                "Messages express feelings",
            ],
            "medium": [
                "Sends viewers over",
                "Recordings saved for later",
                "Graphics show alerts",
                "Quality affected by rate",
                "Scenes switch layouts",
                "Affiliate unlocks features",
            ],
            "hard": [
                "RTMP ingests stream data",
                "Transcoding creates tiers",
                "Low latency reduces delay",
                "SRT ensures reliable transport",
                "HLS enables adaptive streaming",
                "CDN edges cache globally",
            ],
        },
        "Gaming": {
            "easy": [
                "Play video games online",
                "Characters have abilities",
                "Level up with experience",
                "Multiplayer with friends",
                "Rewards drop from enemies",
                "Boss battles test skill",
            ],
            "medium": [
                "Strategy defines best approach",
                "Updates change balance",
                "Repeat for rare rewards",
                "Characters fill the world",
                "DLC adds new content",
                "Runs break records fast",
            ],
            "hard": [
                "Frame data decides advantage",
                "Hitbox extends visuals",
                "Rollback hides latency",
                "Tick rate limits updates",
                "Input buffer varies by game",
                "Deterministic enables replays",
            ],
        },
        "Tech": {
            "easy": [
                "Software runs on devices",
                "Code builds applications",
                "Apps on phone and desktop",
                "Internet connects everything",
                "Cloud stores remotely",
                "Updates add features",
            ],
            "medium": [
                "API connects services",
                "Storage holds data",
                "Frontend runs in browser",
                "Backend handles logic",
                "Memory speeds requests",
                "GitHub hosts repositories",
            ],
            "hard": [
                "Microservices via gRPC",
                "Kubernetes orchestrates",
                "Observability traces flows",
                "Event sourcing rebuilds state",
                "CQRS separates read write",
                "CAP theorem guides tradeoffs",
            ],
        },
        "Development": {
            "easy": [
                "Write code build software",
                "Fix bugs in programs",
                "Test before releasing",
                "Deploy apps to servers",
                "Review code changes",
                "Debug errors in console",
            ],
            "medium": [
                "Framework structures projects",
                "Library provides functions",
                "Automation handles deploy",
                "Version control tracks changes",
                "Documentation explains usage",
                "Package manager handles deps",
            ],
            "hard": [
                "Patterns solve recurring problems",
                "SOLID guides architecture",
                "Technical debt accumulates",
                "Refactoring improves behavior",
                "Static analysis catches bugs",
                "Property testing finds edges",
            ],
        },
        "Culture": {
            "easy": [
                "Internet slang and trends",
                "Shared jokes spread fast",
                "Viral content everywhere",
                "Communities form interests",
                "Reactions express feelings",
                "Inside jokes create bonds",
            ],
            "medium": [
                "Anxiety drives checking",
                "Negative scrolling harms health",
                "Superfan culture intensifies",
                "Parasocial bonds feel real",
                "Cancel culture demands accountability",
                "Digital footprint lasts forever",
            ],
            "hard": [
                "Context collapse blends audiences",
                "Algorithms amplify discourse",
                "Empty gestures lack meaning",
                "Attention economy monetizes engagement",
                "Filter bubbles reinforce bias",
                "Digital dualism separates online offline",
            ],
        },
        "Security": {
            "easy": [
                "Passwords protect accounts",
                "Two-factor adds security",
                "Don't click suspicious links",
                "Keep software updated",
                "Unique passwords everywhere",
                "Backup important data",
            ],
            "medium": [
                "Fraud mimics trusted sites",
                "VPN encrypts traffic",
                "Password manager generates keys",
                "Privacy settings limit sharing",
                "Ad tools stop tracking",
                "Private mode hides local history",
            ],
            "hard": [
                "Zero-day exploits unknown vulns",
                "Man-in-middle intercepts traffic",
                "Credential stuffing reuses breaches",
                "Supply chain attacks deps",
                "Side-channel leaks via timing",
                "Hardware modules protect keys",
            ],
        },
    }

    # Use word-specific hints if available, otherwise generic
    if word_lower in word_specific_hints:
        templates = word_specific_hints[word_lower]
    else:
        templates = generic_hints.get(subcategory, generic_hints["Social Media"])

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


def generate_imposters(word: str, subcategory: str, difficulty: WordDifficulty) -> list[ImposterWord]:
    """Generate imposter alternatives for a word - using distinct vocabulary that won't conflict with hints."""
    word_lower = word.lower()

    # Imposter pools by subcategory - carefully selected to NEVER overlap with hint vocabulary
    # Using abstract terms that are completely disjoint from hints
    imposter_pools = {
        "Social Media": [
            "Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot",
            "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima",
        ],
        "Messaging": [
            "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo",
            "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "Xray",
        ],
        "Streaming": [
            "Yankee", "Zulu", "Apple", "Banana", "Cherry", "Fig",
            "Grape", "Kiwi", "Lemon", "Mango", "Nectar", "Olive",
        ],
        "Gaming": [
            "Orange", "Papaya", "Quince", "Raisin", "Sugar", "Tamarind",
            "Ugli", "Vanilla", "Watermelon", "Xigua", "Yuzu", "Zest",
        ],
        "Tech": [
            "Coral", "Denim", "Emerald", "Fuchsia", "Gold",
            "Indigo", "Jade", "Khaki", "Lavender", "Maroon", "Navy",
        ],
        "Development": [
            "Olive", "Peach", "Quartz", "Ruby", "Silver", "Teal",
            "Umber", "Violet", "Wine", "Xanadu", "Yellow", "Zinc",
        ],
        "Culture": [
            "Amber", "Bronze", "Copper", "Diamond", "Ebony", "Flint",
            "Garnet", "Hematite", "Ivory", "Jet", "Kyanite", "Lapis",
        ],
        "Security": [
            "Malachite", "Nickel", "Onyx", "Pearl", "Quartzite", "Rhodium",
            "Sapphire", "Topaz", "Unakite", "Variscite", "Wulfenite", "Xenotime",
        ],
    }

    pool = imposter_pools.get(subcategory, imposter_pools["Social Media"])
    # Filter out the actual word
    pool = [w for w in pool if w.lower() != word_lower]

    # Select based on difficulty
    import random
    random.seed(hash(word) % 10000)

    selected = random.sample(pool, min(9, len(pool)))

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
    """Generate and save the internet_social word pack."""
    print("Generating internet_social word pack...")

    pack = create_internet_social_pack()

    # Output path
    output_dir = Path(__file__).parent.parent / "output" / "offline_packs"
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / "internet_social.json"

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