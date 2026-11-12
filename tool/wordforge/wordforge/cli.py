"""Command-line interface for WordForge."""

from __future__ import annotations

import asyncio
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List

import click

from wordforge.database.models import (
    Hint,
    ImposterWord,
    PackMeta,
    RecordStatus,
    WordDifficulty,
    WordPack,
    WordRecord,
)
from wordforge.database.repository import WordForgeDB
from wordforge.generators.description_generator import (
    DescriptionGenerator,
    HintGenerator,
    ImposterGenerator,
    DifficultyClassifier,
    LLMClient,
    LLMConfig,
)
from wordforge.pipeline.export_pipeline import FlutterExporter, HushbugIntegrator, SupabaseExporter
from wordforge.pipeline.validation_pipeline import ValidationPipeline
from wordforge.validators.category_validator import CategoryValidator


CONFIG_DIR = Path(__file__).parent.parent / "config"


def load_categories() -> List[Dict]:
    with open(CONFIG_DIR / "categories.json") as f:
        return json.load(f)


def load_settings() -> Dict:
    with open(CONFIG_DIR / "settings.json") as f:
        return json.load(f)


# Predefined candidate words for missing categories
MISSING_CATEGORY_CANDIDATES = {
    "brands_products": [
        "Coca-Cola", "Nike", "Apple", "Samsung", "Toyota", "Amazon", "Google", "Microsoft",
        "McDonald's", "Starbucks", "Disney", "Netflix", "Spotify", "Uber", "Airbnb",
        "Tesla", "BMW", "Mercedes", "Honda", "Ford", "Volkswagen", "Sony", "LG",
        "Panasonic", "Canon", "Nikon", "GoPro", "Dyson", "Keurig", "Nespresso",
        "Levi's", "Adidas", "Puma", "Under Armour", "The North Face", "Patagonia",
        "Rolex", "Omega", "Seiko", "Casio", "Timex", "Fossil", "Swatch",
        "Lego", "Hasbro", "Mattel", "Funko", "Hot Wheels", "Barbie", "Nerf",
        "PlayStation", "Xbox", "Nintendo", "Steam", "Epic Games", "Valve", "Blizzard",
        "Intel", "AMD", "NVIDIA", "ASUS", "MSI", "Gigabyte", "Razer", "Logitech",
        "Bose", "Sennheiser", "JBL", "Beats", "Shure", "Audio-Technica", "Sony",
        "Canon", "Epson", "HP", "Dell", "Lenovo", "Acer", "MSI", "Razer",
        "Instagram", "TikTok", "WhatsApp", "Telegram", "Discord", "Slack", "Zoom",
        "Twitter", "Facebook", "LinkedIn", "Reddit", "Pinterest", "Snapchat",
        "Visa", "Mastercard", "PayPal", "Stripe", "Square", "Revolut", "Wise",
        "IKEA", "Zara", "H&M", "Uniqlo", "Gap", "Old Navy", "American Eagle",
    ],
    "internet_social": [
        "Hashtag", "Meme", "Viral", "Influencer", "Streamer", "Troll", "DM",
        "Subreddit", "Upvote", "Downvote", "Thread", "Reply", "Retweet", "Quote Tweet",
        "Story", "Reel", "Live", "Filter", "Sticker", "Emoji", "GIF",
        "Verified", "Follower", "Following", "Bio", "Handle", "Tag", "Mention",
        "Notification", "Feed", "Timeline", "Algorithm", "Shadowban", "Engagement",
        "Clickbait", "Doomscroll", "FOMO", "YOLO", "TL;DR", "ELI5", "AMA",
        "OP", "OC", "Repost", "Crosspost", "Flair", "Mod", "Admin", "Ban",
        "VPN", "Cookie", "Cache", "Browser", "Incognito", "Bookmark", "Extension",
        "Adblock", "Tracker", "Pixel", "Analytics", "SEO", "CTR", "Impression",
        "API", "Endpoint", "Webhook", "OAuth", "Token", "JWT", "CORS",
        "Cloud", "Serverless", "CDN", "Edge", "Latency", "Bandwidth", "Throughput",
        "GitHub", "GitLab", "Bitbucket", "CI/CD", "Pipeline", "Deploy", "Rollback",
        "Docker", "Kubernetes", "Container", "Microservice", "Lambda", "Function",
        "Database", "SQL", "NoSQL", "Redis", "MongoDB", "PostgreSQL", "MySQL",
        "Frontend", "Backend", "Fullstack", "React", "Vue", "Svelte", "Next.js",
        "TypeScript", "JavaScript", "Python", "Rust", "Go", "Node", "Deno",
    ],
    "business_finance": [
        "Stock", "Bond", "ETF", "Dividend", "Portfolio", "Asset", "Liability", "Equity",
        "Revenue", "Profit", "Loss", "Margin", "EBITDA", "ROI", "ROE", "EPS",
        "IPO", "SPAC", "Merger", "Acquisition", "Takeover", "Valuation", "Cap Table",
        "Venture Capital", "Angel Investor", "Series A", "Unicorn", "Decacorn", "Exit",
        "Startup", "Scaleup", "SME", "Enterprise", "Corporation", "LLC", "Partnership",
        "CEO", "CFO", "COO", "CTO", "CMO", "Board", "Shareholder", "Stakeholder",
        "Budget", "Forecast", "Audit", "Compliance", "Regulation", "KYC", "AML",
        "Invoice", "Receipt", "Payment", "Transaction", "Ledger", "Accounting",
        "Tax", "Deduction", "Credit", "Debit", "Interest", "Principal", "Compound",
        "Inflation", "Deflation", "Recession", "Depression", "Bull Market", "Bear Market",
        "Volatility", "Liquidity", "Solvency", "Leverage", "Hedge", "Derivative",
        "Option", "Future", "Swap", "Forward", "Strike", "Expiry", "Premium",
        "Insurance", "Premium", "Deductible", "Claim", "Policy", "Underwriting",
        "Mortgage", "Loan", "Credit Score", "Collateral", "Default", "Foreclosure",
        "Crypto", "Bitcoin", "Ethereum", "Blockchain", "Smart Contract", "DeFi",
        "NFT", "Token", "Wallet", "Exchange", "Mining", "Staking", "Yield",
        "Salary", "Bonus", "Commission", "Equity", "Vesting", "Cliff", "ESOP",
        "401k", "IRA", "Pension", "Retirement", "Compound Interest", "Diversification",
    ],
    "after_dark": [
        "Cocktail", "Martini", "Wine", "Champagne", "Whiskey", "Vodka", "Gin", "Tequila",
        "Bar", "Club", "Lounge", "Speakeasy", "Rooftop", "Dancefloor", "DJ", "Bouncer",
        "Flirt", "Date", "Tinder", "Bumble", "Hinge", "Match", "Swipe", "Ghosting",
        "Hookup", "One-night stand", "FWB", "Situationship", "Boyfriend", "Girlfriend",
        "Anniversary", "Valentine", "Anniversary", "Proposal", "Engagement", "Wedding",
        "Honeymoon", "Anniversary", "Divorce", "Alimony", "Prenup", "Separation",
        "Lingerie", "Perfume", "Cologne", "Massage", "Spa", "Jacuzzi", "Sauna",
        "Bachelorette", "Bachelor", "Strip club", "Burlesque", "Cabaret", "Drag",
        "Wine tasting", "Brewery", "Distillery", "Mixology", "Sommelier", "Bartender",
        "Shot", "Chaser", "Happy hour", "Last call", "Closing time", "Afterparty",
        "Netflix and chill", "Cuddle", "Kiss", "Make out", "Sleepover", "Morning after",
        "Blind date", "Speed dating", "Matchmaker", "Wingman", "Pickup line", "Rejection",
        "Crush", "Infatuation", "Love", "Lust", "Passion", "Romance", "Intimacy",
        "Anniversary gift", "Flowers", "Chocolate", "Jewelry", "Ring", "Promise",
        "Couples therapy", "Counseling", "Communication", "Trust", "Jealousy", "Cheating",
        "Open relationship", "Polyamory", "Swinging", "Threesome", "Fantasy", "Roleplay",
    ],
}


async def generate_missing_packs(
    categories: List[str],
    target_per_category: int,
    output_dir: str,
    use_llm: bool = False,
):
    """Generate word packs for missing categories."""
    settings = load_settings()
    gen_config = settings.get("generation", {})

    llm_config = LLMConfig(
        provider=gen_config.get("provider", "openai"),
        model=gen_config.get("model", "gpt-4o-mini"),
        temperature=gen_config.get("temperature", 0.7),
        max_tokens=gen_config.get("max_tokens", 4096),
        timeout=gen_config.get("timeout_seconds", 90),
        max_retries=gen_config.get("max_retries", 3),
        backoff_base=gen_config.get("backoff_base_seconds", 2.0),
        rate_limit_rpm=gen_config.get("rate_limit_rpm", 60),
        concurrency=gen_config.get("concurrency", 4),
    )

    llm = LLMClient(llm_config) if use_llm else None
    db = WordForgeDB(f"{output_dir}/wordforge.db")

    for cat_id in categories:
        cat_info = next((c for c in load_categories() if c["id"] == cat_id), None)
        if not cat_info:
            print(f"Unknown category: {cat_id}")
            continue

        candidates = MISSING_CATEGORY_CANDIDATES.get(cat_id, [])
        if not candidates:
            print(f"No candidates defined for {cat_id}")
            continue

        print(f"\n=== Generating {cat_id} ({cat_info['name']}) ===")
        print(f"Target: {target_per_category} words, Candidates: {len(candidates)}")

        # Try to load checkpoint
        checkpoint = db.load_checkpoint(cat_id)
        existing_records = checkpoint if checkpoint else []
        existing_words = {r.word for r in existing_records}
        remaining = [w for w in candidates if w not in existing_words]

        if existing_records:
            print(f"Resuming from checkpoint: {len(existing_records)} done, {len(remaining)} remaining")

        records = list(existing_records)

        for i, word in enumerate(remaining):
            if len(records) >= target_per_category:
                break

            if llm:
                # Use LLM generation
                subcat = None  # Could be inferred
                desc_gen = DescriptionGenerator(llm)
                hint_gen = HintGenerator(llm)
                imp_gen = ImposterGenerator(llm)
                diff_cls = DifficultyClassifier(llm)

                description = await desc_gen.generate(word, cat_info["name"], subcat)
                diff_str = await diff_cls.classify(word, cat_info["name"])
                difficulty = WordDifficulty(diff_str)

                hints_data = await hint_gen.generate(word, cat_info["name"], description)
                hints = []
                for level, label in [(3, "easy"), (2, "medium"), (1, "hard")]:
                    for text in hints_data.get(label, [])[: gen_config.get("hints_per_difficulty", 6)]:
                        hints.append(Hint(text=text, level=level))

                hints_list = [h.text for h in hints]
                imps_data = await imp_gen.generate(word, cat_info["name"], description, hints_list)
                imposters = []
                for level, label in [(1, "easy"), (2, "medium"), (3, "hard")]:
                    for text in imps_data.get(label, [])[: gen_config.get("imposter_alternatives_per_difficulty", 3)]:
                        imposters.append(ImposterWord(text=text, level=level))
            else:
                # Template-based generation for offline mode
                description = f"A well-known {cat_info['description'].lower()}"
                difficulty = WordDifficulty.MEDIUM

                # Simple template hints
                base = word.lower()
                hints = [
                    Hint(text=f"Popular {base}", level=3),
                    Hint(text=f"Famous {base}", level=3),
                    Hint(text=f"Known for {base}", level=3),
                    Hint(text=f"Leading {base}", level=3),
                    Hint(text=f"Top {base} brand", level=3),
                    Hint(text=f"Recognized {base}", level=3),
                    Hint(text=f"Market leader in {base}", level=2),
                    Hint(text=f"Iconic {base} name", level=2),
                    Hint(text=f"Household name: {base}", level=2),
                    Hint(text=f"Global {base} presence", level=2),
                    Hint(text=f"Industry giant {base}", level=2),
                    Hint(text=f"Premium {base} label", level=2),
                    Hint(text=f"Trademark {base} style", level=1),
                    Hint(text=f"Signature {base} quality", level=1),
                    Hint(text=f"Benchmark {base} standard", level=1),
                    Hint(text=f"Synonymous with {base}", level=1),
                    Hint(text=f"Defining {base} era", level=1),
                    Hint(text=f"Legacy {base} influence", level=1),
                ]

                imposters = [
                    ImposterWord(text=f"Generic {base}", level=1),
                    ImposterWord(text=f"Competitor {base}", level=1),
                    ImposterWord(text=f"Alternative {base}", level=1),
                    ImposterWord(text=f"Rival {base}", level=2),
                    ImposterWord(text=f"Similar {base}", level=2),
                    ImposterWord(text=f"Comparable {base}", level=2),
                    ImposterWord(text=f"Lookalike {base}", level=3),
                    ImposterWord(text=f"Knockoff {base}", level=3),
                    ImposterWord(text=f"Imitation {base}", level=3),
                ]

            word_id = f"wf:{cat_id}:{word.lower().replace(' ', '-')}"
            record = WordRecord(
                id=word_id,
                word=word,
                category=cat_id,
                subcategory=subcat,
                difficulty=difficulty,
                tags=[],
                is_adult=cat_info.get("is_adult", False),
                hints=hints,
                imposters=imposters,
                description=description,
                source="wordforge",
                status=RecordStatus.GENERATED,
            )
            records.append(record)

            if len(records) % 10 == 0:
                db.save_checkpoint(cat_id, records)
                print(f"  Checkpoint: {len(records)}/{target_per_category}")

        # Save final
        db.save_checkpoint(cat_id, records)

        # Build pack
        diff_counts = {"easy": 0, "medium": 0, "hard": 0}
        for r in records:
            diff_counts[r.difficulty.value] += 1

        meta = PackMeta(
            id=cat_id,
            name=cat_info["name"],
            description=f"Generated WordForge pack for {cat_info['name']}",
            icon=cat_info.get("icon", "category"),
            is_adult=cat_info.get("is_adult", False),
            count=len(records),
            difficulty=diff_counts,
            schema_version=3,
            content_version="1.0.0",
            generated_at=datetime.utcnow().isoformat() + "Z",
            source="wordforge",
        )

        pack = WordPack(meta=meta, words=records[:target_per_category])

        # Validate
        validator = ValidationPipeline()
        report = validator.run(pack)
        print(f"  Validation: {report['passed']} passed, {report['failed']} failed, {report['warnings']} warnings")

        if report["failed"] > 0:
            for issue in report["issues"][:5]:
                print(f"    - {issue['word']}: {issue['message']}")

        # Export
        exporter = FlutterExporter(output_dir + "/offline_packs")
        result = exporter.export_pack(pack)
        print(f"  Exported to: {result['output_path']}")

    print("\n=== All packs generated ===")


@click.group()
def cli():
    """Hushbug WordForge - Automated word pack generation and validation."""
    pass


@cli.command()
@click.option("--categories", "-c", multiple=True, help="Categories to generate")
@click.option("--target", "-t", default=100, help="Words per category")
@click.option("--output", "-o", default="output", help="Output directory")
@click.option("--use-llm", is_flag=True, help="Use LLM for generation (requires API key)")
def generate(categories, target, output, use_llm):
    """Generate word packs for specified categories."""
    if not categories:
        categories = ["brands_products", "internet_social", "business_finance", "after_dark"]
    asyncio.run(generate_missing_packs(list(categories), target, output, use_llm))


@cli.command()
@click.option("--pack-dir", default="output/offline_packs", help="Pack directory")
def validate(pack_dir):
    """Validate all packs in a directory."""
    validator = ValidationPipeline()
    exporter = FlutterExporter(pack_dir)

    for f in Path(pack_dir).glob("*.json"):
        if f.name == "index.json":
            continue
        print(f"\nValidating {f.name}...")
        with open(f) as fp:
            data = json.load(fp)
        is_adult = data.get("is_adult", False)
        pack = WordPack(
            meta=PackMeta(
                id=data["id"],
                name=data["name"],
                version=data.get("version", 2),
                schema_version=data.get("schema_version", 3),
                is_adult=is_adult,
                content_version=data.get("content_version", "1.0.0"),
                generated_at=data.get("generated_at"),
            ),
            words=[WordRecord.from_pack_json(data["id"], w, adult=is_adult) for w in data.get("words", [])],
        )
        report = validator.run(pack)
        print(f"  {report['passed']}/{report['total_words']} passed, {report['failed']} failed, {report['warnings']} warnings")


@cli.command()
@click.option("--hushbug-path", required=True, help="Path to Hushbug Flutter project")
@click.option("--pack-dir", default="output/offline_packs", help="Pack directory")
@click.option("--dry-run/--no-dry-run", default=True, help="Dry run mode")
def integrate(hushbug_path, pack_dir, dry_run):
    """Integrate generated packs into Hushbug Flutter project."""
    integrator = HushbugIntegrator(hushbug_path)
    if not integrator.validate_target():
        print("ERROR: Not a valid Hushbug project")
        return

    packs = []
    for f in Path(pack_dir).glob("*.json"):
        if f.name == "index.json":
            continue
        with open(f) as fp:
            data = json.load(fp)
        is_adult = data.get("is_adult", False)
        packs.append(WordPack(
            meta=PackMeta(
                id=data["id"], name=data["name"],
                version=data.get("version", 2),
                schema_version=data.get("schema_version", 3),
                is_adult=is_adult,
                content_version=data.get("content_version", "1.0.0"),
                generated_at=data.get("generated_at"),
            ),
            words=[WordRecord.from_pack_json(data["id"], w, adult=is_adult) for w in data.get("words", [])],
        ))

    result = integrator.integrate(packs, dry_run=dry_run)
    if result["success"]:
        print("Integration successful!")
        print(f"  Backed up: {result['backed_up']}")
        for p in result["packs"]:
            print(f"  {p['pack_id']}: {p.get('written', p.get('would_write', False))}")
    else:
        print(f"ERROR: {result['error']}")


@cli.command()
@click.option("--pack-dir", default="output/offline_packs", help="Pack directory")
@click.option("--dry-run/--no-dry-run", default=True, help="Dry run mode")
def supabase_export(pack_dir, dry_run):
    """Export packs to Supabase word_bank table."""
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_KEY")
    if not url or not key:
        print("ERROR: SUPABASE_URL and SUPABASE_SERVICE_KEY must be set")
        return

    packs = []
    for f in Path(pack_dir).glob("*.json"):
        if f.name == "index.json":
            continue
        with open(f) as fp:
            data = json.load(fp)
        is_adult = data.get("is_adult", False)
        packs.append(WordPack(
            meta=PackMeta(
                id=data["id"], name=data["name"],
                version=data.get("version", 2),
                schema_version=data.get("schema_version", 3),
                is_adult=is_adult,
                content_version=data.get("content_version", "1.0.0"),
                generated_at=data.get("generated_at"),
            ),
            words=[WordRecord.from_pack_json(data["id"], w, adult=is_adult) for w in data.get("words", [])],
        ))

    exporter = SupabaseExporter(url, key)
    result = exporter.export_all(packs, dry_run=dry_run)
    print(f"Exported {result['total_records']} records in {result['batches']} batches")
    for i, r in enumerate(result["results"]):
        print(f"  Batch {i+1}: {r}")


@cli.command()
def list_categories():
    """List all configured categories."""
    for c in load_categories():
        adult = " [ADULT]" if c.get("is_adult") else ""
        print(f"  {c['id']}: {c['name']}{adult}")


if __name__ == "__main__":
    cli()