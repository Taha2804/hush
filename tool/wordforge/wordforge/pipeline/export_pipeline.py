"""Export pipeline: produces Flutter-compatible offline packs and Supabase exports."""

from __future__ import annotations

import json
import os
import shutil
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

from wordforge.database.models import PackMeta, WordPack, WordRecord


class FlutterExporter:
    """Exports WordPacks to Flutter-compatible v2 JSON format."""

    def __init__(self, output_dir: str = "output/offline_packs", hushbug_dir: Optional[str] = None):
        self.output_dir = Path(output_dir)
        self.hushbug_dir = Path(hushbug_dir) if hushbug_dir else None
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def export_pack(self, pack: WordPack, dry_run: bool = False) -> Dict:
        """Export a single pack to JSON."""
        self.output_dir.mkdir(parents=True, exist_ok=True)
        out_file = self.output_dir / f"{pack.meta.id}.json"

        pack_json = {
            "id": pack.meta.id,
            "name": pack.meta.name,
            "version": pack.meta.version,
            "schema_version": pack.meta.schema_version,
            "is_adult": pack.meta.is_adult,
            "content_version": pack.meta.content_version,
            "generated_at": pack.meta.generated_at or datetime.utcnow().isoformat() + "Z",
            "words": [w.as_pack_json() for w in pack.words],
        }

        result = {
            "pack_id": pack.meta.id,
            "output_path": str(out_file),
            "word_count": len(pack.words),
            "dry_run": dry_run,
        }

        if not dry_run:
            with open(out_file, "w", encoding="utf-8") as f:
                json.dump(pack_json, f, ensure_ascii=False, indent=2)
            result["written"] = True
        else:
            result["would_write"] = True

        return result

    def export_all(self, packs: List[WordPack], dry_run: bool = False) -> List[Dict]:
        """Export multiple packs."""
        return [self.export_pack(p, dry_run) for p in packs]

    def generate_manifest(self, packs: List[WordPack], dry_run: bool = False) -> Dict:
        """Generate the index.json manifest matching assets/packs/index.json."""
        manifest = []
        for pack in packs:
            diff_counts = {"easy": 0, "medium": 0, "hard": 0}
            for w in pack.words:
                diff_counts[w.difficulty.value] += 1
            manifest.append({
                "id": pack.meta.id,
                "name": pack.meta.name,
                "description": pack.meta.description,
                "icon": pack.meta.icon,
                "is_adult": pack.meta.is_adult,
                "count": len(pack.words),
                "difficulty": diff_counts,
            })

        result = {"manifest": manifest, "dry_run": dry_run}
        if not dry_run:
            idx_file = self.output_dir / "index.json"
            with open(idx_file, "w", encoding="utf-8") as f:
                json.dump(manifest, f, ensure_ascii=False, indent=2)
            result["index_path"] = str(idx_file)
        return result


class HushbugIntegrator:
    """Direct integration with the Hushbug Flutter project assets.

    - Validates target project exists
    - Backs up existing packs
    - Copies new packs
    - Updates index.json
    """

    def __init__(self, hushbug_root: str):
        self.root = Path(hushbug_root)
        self.packs_dir = self.root / "assets" / "packs"
        self.backup_dir = self.root / "assets" / "packs" / ".backup"

    def validate_target(self) -> bool:
        """Check that the target is a valid Hushbug project."""
        return (
            (self.root / "pubspec.yaml").exists()
            and (self.root / "lib" / "domain" / "models" / "word_entry.dart").exists()
        )

    def backup_existing(self) -> List[str]:
        """Backup existing pack files."""
        if not self.packs_dir.exists():
            return []
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        backed_up = []
        for f in self.packs_dir.glob("*.json"):
            if f.name != "index.json":
                dst = self.backup_dir / f.name
                shutil.copy2(f, dst)
                backed_up.append(f.name)
        # Also backup index
        idx = self.packs_dir / "index.json"
        if idx.exists():
            shutil.copy2(idx, self.backup_dir / "index.json")
            backed_up.append("index.json")
        return backed_up

    def integrate(self, packs: List[WordPack], dry_run: bool = True) -> Dict:
        """Integrate packs into the Hushbug project."""
        if not self.validate_target():
            return {"success": False, "error": "Not a valid Hushbug project"}

        backed_up = self.backup_existing() if not dry_run else []

        results = []
        exporter = FlutterExporter(str(self.packs_dir))
        for pack in packs:
            result = exporter.export_pack(pack, dry_run=dry_run)
            results.append(result)

        if not dry_run:
            # Merge with existing index.json instead of replacing
            self._merge_manifest(packs)

        return {
            "success": True,
            "backed_up": backed_up,
            "packs": results,
            "dry_run": dry_run,
        }

    def _merge_manifest(self, new_packs: List[WordPack]) -> None:
        """Merge new packs into existing index.json, preserving existing entries."""
        idx_file = self.packs_dir / "index.json"

        # Load existing manifest
        existing = {}
        if idx_file.exists():
            with open(idx_file, "r", encoding="utf-8") as f:
                try:
                    existing_list = json.load(f)
                    existing = {item["id"]: item for item in existing_list}
                except json.JSONDecodeError:
                    existing = {}

        # Build new manifest entries
        for pack in new_packs:
            diff_counts = {"easy": 0, "medium": 0, "hard": 0}
            for w in pack.words:
                diff_counts[w.difficulty.value] += 1
            existing[pack.meta.id] = {
                "id": pack.meta.id,
                "name": pack.meta.name,
                "description": pack.meta.description,
                "icon": pack.meta.icon,
                "is_adult": pack.meta.is_adult,
                "count": len(pack.words),
                "difficulty": diff_counts,
            }

        # Sort by id for consistent ordering
        merged = list(existing.values())
        merged.sort(key=lambda x: x["id"])

        # Write merged manifest
        with open(idx_file, "w", encoding="utf-8") as f:
            json.dump(merged, f, ensure_ascii=False, indent=2)


class SupabaseExporter:
    """Exports to Supabase word_bank table.

    Uses batch upserts. Requires SUPABASE_URL and SUPABASE_SERVICE_KEY env vars.
    """

    def __init__(self, url: str, service_key: str, schema: str = "public", table: str = "word_bank", batch_size: int = 500):
        self.url = url.rstrip("/")
        self.key = service_key
        self.schema = schema
        self.table = table
        self.batch_size = batch_size

    def _headers(self) -> Dict[str, str]:
        return {
            "apikey": self.key,
            "Authorization": f"Bearer {self.key}",
            "Content-Type": "application/json",
            "Prefer": "return=minimal",
        }

    def upsert_batch(self, records: List[WordRecord], dry_run: bool = False) -> Dict:
        """Upsert a batch of records to word_bank."""
        rows = []
        for r in records:
            hints_json = json.dumps([{"text": h.text, "level": h.level} for h in r.hints])
            imposters_json = json.dumps([{"text": i.text, "level": i.level} for i in r.imposters])
            rows.append({
                "category": r.category,
                "word": r.word,
                "hints": [h.text for h in r.hints],
                "fakes": [i.text for i in r.imposters],
                "description": r.description or "",
            })

        if dry_run:
            return {"dry_run": True, "count": len(rows), "rows": rows[:3]}

        import httpx
        endpoint = f"{self.url}/rest/v1/{self.table}"
        headers = self._headers()
        # Use upsert with on_conflict
        resp = httpx.post(
            f"{endpoint}?on_conflict=category,word",
            headers=headers,
            json=rows,
        )
        if resp.status_code >= 400:
            return {"success": False, "error": resp.text, "status": resp.status_code}
        return {"success": True, "count": len(rows)}

    def export_all(self, packs: List[WordPack], dry_run: bool = True) -> Dict:
        """Export all packs in batches."""
        all_records = []
        for pack in packs:
            all_records.extend(pack.words)

        results = []
        for i in range(0, len(all_records), self.batch_size):
            batch = all_records[i:i + self.batch_size]
            results.append(self.upsert_batch(batch, dry_run))

        return {
            "total_records": len(all_records),
            "batches": len(results),
            "results": results,
            "dry_run": dry_run,
        }