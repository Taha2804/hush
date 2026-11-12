"""Database layer for WordForge using SQLite."""

from __future__ import annotations

import json
import os
import sqlite3
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Dict, List, Optional

from wordforge.database.models import PackMeta, WordPack, WordRecord


class WordForgeDB:
    """SQLite database for storing generated records and generation state."""

    def __init__(self, db_path: str = "output/wordforge.db"):
        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_schema()

    def _init_schema(self):
        with self._conn() as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS word_records (
                    id TEXT PRIMARY KEY,
                    word TEXT NOT NULL,
                    category TEXT NOT NULL,
                    subcategory TEXT,
                    difficulty TEXT NOT NULL,
                    tags TEXT NOT NULL DEFAULT '[]',
                    is_adult INTEGER NOT NULL DEFAULT 0,
                    hints TEXT NOT NULL DEFAULT '[]',
                    imposters TEXT NOT NULL DEFAULT '[]',
                    description TEXT,
                    source TEXT NOT NULL,
                    status TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            conn.execute("CREATE INDEX IF NOT EXISTS idx_records_category ON word_records(category)")
            conn.execute("CREATE INDEX IF NOT EXISTS idx_records_status ON word_records(status)")
            conn.execute("CREATE INDEX IF NOT EXISTS idx_records_word ON word_records(word)")

            conn.execute("""
                CREATE TABLE IF NOT EXISTS pack_meta (
                    id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    description TEXT,
                    icon TEXT,
                    is_adult INTEGER NOT NULL DEFAULT 0,
                    count INTEGER NOT NULL DEFAULT 0,
                    difficulty TEXT NOT NULL DEFAULT '{}',
                    version INTEGER NOT NULL DEFAULT 2,
                    schema_version INTEGER NOT NULL DEFAULT 3,
                    content_version TEXT,
                    generated_at TEXT,
                    source TEXT
                )
            """)

            conn.execute("""
                CREATE TABLE IF NOT EXISTS generation_checkpoints (
                    category_id TEXT PRIMARY KEY,
                    data TEXT NOT NULL,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)

    @contextmanager
    def _conn(self):
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            conn.close()

    def save_record(self, record: WordRecord):
        with self._conn() as conn:
            conn.execute("""
                INSERT OR REPLACE INTO word_records
                (id, word, category, subcategory, difficulty, tags, is_adult,
                 hints, imposters, description, source, status, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
            """, (
                record.id,
                record.word,
                record.category,
                record.subcategory,
                record.difficulty.value,
                json.dumps(record.tags),
                1 if record.is_adult else 0,
                json.dumps([{"text": h.text, "level": h.level} for h in record.hints]),
                json.dumps([{"text": i.text, "level": i.level} for i in record.imposters]),
                record.description,
                record.source,
                record.status.value,
            ))

    def save_records(self, records: List[WordRecord]):
        with self._conn() as conn:
            for r in records:
                self.save_record(r)

    def get_record(self, record_id: str) -> Optional[WordRecord]:
        with self._conn() as conn:
            row = conn.execute("SELECT * FROM word_records WHERE id = ?", (record_id,)).fetchone()
            return self._row_to_record(row) if row else None

    def get_records_by_category(self, category: str, status: Optional[str] = None) -> List[WordRecord]:
        with self._conn() as conn:
            if status:
                rows = conn.execute(
                    "SELECT * FROM word_records WHERE category = ? AND status = ?",
                    (category, status),
                ).fetchall()
            else:
                rows = conn.execute(
                    "SELECT * FROM word_records WHERE category = ?",
                    (category,),
                ).fetchall()
            return [self._row_to_record(r) for r in rows]

    def get_all_records(self) -> List[WordRecord]:
        with self._conn() as conn:
            rows = conn.execute("SELECT * FROM word_records").fetchall()
            return [self._row_to_record(r) for r in rows]

    def update_status(self, record_id: str, status: str):
        with self._conn() as conn:
            conn.execute(
                "UPDATE word_records SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
                (status, record_id),
            )

    def save_checkpoint(self, category_id: str, records: List[WordRecord]):
        data = [r.as_pack_json() for r in records]
        with self._conn() as conn:
            conn.execute(
                "INSERT OR REPLACE INTO generation_checkpoints (category_id, data, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP)",
                (category_id, json.dumps(data)),
            )

    def load_checkpoint(self, category_id: str) -> Optional[List[WordRecord]]:
        with self._conn() as conn:
            row = conn.execute(
                "SELECT data FROM generation_checkpoints WHERE category_id = ?", (category_id,)
            ).fetchone()
            if not row:
                return None
            data = json.loads(row["data"])
            return [WordRecord.from_pack_json(category_id, w, source="wordforge") for w in data]

    def save_pack_meta(self, meta: PackMeta):
        with self._conn() as conn:
            conn.execute("""
                INSERT OR REPLACE INTO pack_meta
                (id, name, description, icon, is_adult, count, difficulty,
                 version, schema_version, content_version, generated_at, source)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                meta.id, meta.name, meta.description, meta.icon,
                1 if meta.is_adult else 0, meta.count,
                json.dumps(meta.difficulty), meta.version, meta.schema_version,
                meta.content_version, meta.generated_at, meta.source,
            ))

    def get_pack_meta(self, pack_id: str) -> Optional[PackMeta]:
        with self._conn() as conn:
            row = conn.execute("SELECT * FROM pack_meta WHERE id = ?", (pack_id,)).fetchone()
            if not row:
                return None
            return PackMeta(
                id=row["id"],
                name=row["name"],
                description=row["description"] or "",
                icon=row["icon"] or "category",
                is_adult=bool(row["is_adult"]),
                count=row["count"],
                difficulty=json.loads(row["difficulty"]),
                version=row["version"],
                schema_version=row["schema_version"],
                content_version=row["content_version"] or "1.0.0",
                generated_at=row["generated_at"],
                source=row["source"] or "",
            )

    def _row_to_record(self, row: sqlite3.Row) -> WordRecord:
        hints = [{"text": h["text"], "level": h["level"]} for h in json.loads(row["hints"])]
        imposters = [{"text": i["text"], "level": i["level"]} for i in json.loads(row["imposters"])]
        return WordRecord(
            id=row["id"],
            word=row["word"],
            category=row["category"],
            subcategory=row["subcategory"],
            difficulty=row["difficulty"],
            tags=json.loads(row["tags"]),
            is_adult=bool(row["is_adult"]),
            hints=[type("Hint", (), h) for h in hints],
            imposters=[type("ImposterWord", (), i) for i in imposters],
            description=row["description"],
            source=row["source"],
            status=row["status"],
        )