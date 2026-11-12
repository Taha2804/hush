"""LLM-based generation of word records."""

from __future__ import annotations

import asyncio
import json
import os
import time
from dataclasses import dataclass
from typing import Dict, List, Optional

import httpx


@dataclass
class LLMConfig:
    provider: str = "openai"
    model: str = "gpt-4o-mini"
    temperature: float = 0.7
    max_tokens: int = 4096
    timeout: int = 90
    max_retries: int = 3
    backoff_base: float = 2.0
    rate_limit_rpm: int = 60
    concurrency: int = 4


class LLMClient:
    """Thin async client for OpenAI-compatible APIs and Ollama."""

    def __init__(self, config: LLMConfig):
        self.config = config
        self.base_url = self._resolve_base_url()
        self.api_key = os.getenv("OPENAI_API_KEY") or os.getenv("ANTHROPIC_API_KEY") or ""
        self.client = httpx.AsyncClient(timeout=config.timeout)
        self._last_call = 0.0

    def _resolve_base_url(self) -> str:
        if self.config.provider == "ollama":
            return os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
        elif self.config.provider == "anthropic":
            return "https://api.anthropic.com"
        return os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1")

    async def _rate_limit(self):
        elapsed = time.time() - self._last_call
        min_interval = 60.0 / max(1, self.config.rate_limit_rpm)
        if elapsed < min_interval:
            await asyncio.sleep(min_interval - elapsed)
        self._last_call = time.time()

    async def complete(self, prompt: str, system: str = "") -> str:
        """Call the LLM with retry and backoff."""
        await self._rate_limit()

        for attempt in range(self.config.max_retries + 1):
            try:
                if self.config.provider == "ollama":
                    return await self._call_ollama(prompt, system)
                elif self.config.provider == "anthropic":
                    return await self._call_anthropic(prompt, system)
                else:
                    return await self._call_openai(prompt, system)
            except Exception as e:
                if attempt == self.config.max_retries:
                    raise
                await asyncio.sleep(self.config.backoff_base ** attempt)

        raise RuntimeError("LLM call failed after retries")

    async def _call_openai(self, prompt: str, system: str) -> str:
        headers = {"Authorization": f"Bearer {self.api_key}", "Content-Type": "application/json"}
        body = {
            "model": self.config.model,
            "messages": ([{"role": "system", "content": system}] if system else []) + [{"role": "user", "content": prompt}],
            "temperature": self.config.temperature,
            "max_tokens": self.config.max_tokens,
        }
        resp = await self.client.post(f"{self.base_url}/chat/completions", headers=headers, json=body)
        resp.raise_for_status()
        return resp.json()["choices"][0]["message"]["content"]

    async def _call_anthropic(self, prompt: str, system: str) -> str:
        headers = {"x-api-key": self.api_key, "anthropic-version": "2023-06-01", "Content-Type": "application/json"}
        body = {
            "model": self.config.model,
            "system": system,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": self.config.temperature,
            "max_tokens": self.config.max_tokens,
        }
        resp = await self.client.post(f"{self.base_url}/v1/messages", headers=headers, json=body)
        resp.raise_for_status()
        return resp.json()["content"][0]["text"]

    async def _call_ollama(self, prompt: str, system: str) -> str:
        body = {
            "model": self.config.model,
            "prompt": (system + "\n\n" if system else "") + prompt,
            "stream": False,
            "options": {"temperature": self.config.temperature, "num_predict": self.config.max_tokens},
        }
        resp = await self.client.post(f"{self.base_url}/api/generate", json=body)
        resp.raise_for_status()
        return resp.json()["response"]


class DescriptionGenerator:
    """Generates a single-sentence neutral definition."""

    SYSTEM_PROMPT = (
        "You are writing definitions for a social deduction word game. "
        "Write ONE short sentence (8-18 words) that clearly explains what the word means. "
        "Use simple language. Do NOT use commas to list clues. Do NOT repeat the word. "
        "Do NOT write a list. Do NOT give examples. Just define it plainly."
    )

    def __init__(self, llm: LLMClient):
        self.llm = llm

    async def generate(self, word: str, category: str, subcategory: Optional[str] = None) -> str:
        context = f"Category: {category}"
        if subcategory:
            context += f", Subcategory: {subcategory}"
        prompt = (
            f"Word: {word}\n{context}\n\n"
            f"Write a ONE-SENTENCE definition (8-18 words). Example:\n"
            f"Word: Telescope\nCategory: Science & Technology\n"
            f"Definition: An instrument used to observe objects that are very far away.\n\n"
            f"Definition for '{word}':"
        )
        text = await self.llm.complete(prompt, self.SYSTEM_PROMPT)
        return text.strip().strip('"')


class HintGenerator:
    """Generates hints at three difficulty levels."""

    SYSTEM_PROMPT = (
        "You are writing hints for a social deduction game. The IMPOSTER receives these hints. "
        "Generate 6 hints per difficulty level:\n"
        "- EASY (level 3): Recognizable associations, common knowledge, direct clues.\n"
        "- MEDIUM (level 2): Indirect but meaningful relationships, less predictable.\n"
        "- HARD (level 1): Subtle associations, requires deeper understanding.\n"
        "Each hint is a SHORT PHRASE (2-6 words). No duplicates. No synonyms of the word. "
        "Return ONLY a JSON object with keys 'easy', 'medium', 'hard' each containing an array of 6 strings."
    )

    def __init__(self, llm: LLMClient):
        self.llm = llm

    async def generate(
        self,
        word: str,
        category: str,
        description: Optional[str] = None,
        existing_hints: Optional[Dict[str, List[str]]] = None,
    ) -> Dict[str, List[str]]:
        ctx = f"Word: {word}\nCategory: {category}"
        if description:
            ctx += f"\nDescription: {description}"
        if existing_hints:
            ctx += f"\nExisting hints to avoid repeating: {json.dumps(existing_hints)}"

        prompt = f"{ctx}\n\nGenerate 6 hints per level as JSON:"
        text = await self.llm.complete(prompt, self.SYSTEM_PROMPT)
        return self._parse_json(text, ["easy", "medium", "hard"])

    def _parse_json(self, text: str, required_keys: List[str]) -> Dict[str, List[str]]:
        text = text.strip()
        # Try to extract JSON block
        if "```" in text:
            import re
            m = re.search(r"```(?:json)?\n(.+?)\n```", text, re.DOTALL)
            if m:
                text = m.group(1)
        try:
            data = json.loads(text)
            result = {}
            for k in required_keys:
                v = data.get(k, [])
                if isinstance(v, list):
                    result[k] = [str(x).strip() for x in v if str(x).strip()][:6]
                else:
                    result[k] = []
            return result
        except json.JSONDecodeError:
            return {k: [] for k in required_keys}


class ImposterGenerator:
    """Generates imposter alternatives at three difficulty levels."""

    SYSTEM_PROMPT = (
        "You are generating FAKE WORDS for the Imposter in a social deduction game. "
        "Generate 3 imposter alternatives per difficulty level:\n"
        "- EASY (level 1): Same broad category, noticeably different. (e.g., word='Apple' → 'Banana')\n"
        "- MEDIUM (level 2): Shares meaningful conceptual similarities. (e.g., 'Pear')\n"
        "- HARD (level 3): Very closely related, hard to distinguish. (e.g., 'Crabapple')\n"
        "NEVER use the secret word. NEVER use hints. NEVER use synonyms. "
        "Return ONLY a JSON object with keys 'easy', 'medium', 'hard' each containing an array of 3 strings."
    )

    def __init__(self, llm: LLMClient):
        self.llm = llm

    async def generate(
        self,
        word: str,
        category: str,
        description: Optional[str] = None,
        hints: Optional[List[str]] = None,
        existing_imposters: Optional[Dict[str, List[str]]] = None,
    ) -> Dict[str, List[str]]:
        ctx = f"Secret word: {word}\nCategory: {category}"
        if description:
            ctx += f"\nDescription: {description}"
        if hints:
            ctx += f"\nHints given to imposter: {hints}"
        if existing_imposters:
            ctx += f"\nExisting imposters to avoid: {json.dumps(existing_imposters)}"

        prompt = f"{ctx}\n\nGenerate 3 imposter alternatives per level as JSON:"
        text = await self.llm.complete(prompt, self.SYSTEM_PROMPT)
        return self._parse_json(text, ["easy", "medium", "hard"])

    def _parse_json(self, text: str, required_keys: List[str]) -> Dict[str, List[str]]:
        text = text.strip()
        if "```" in text:
            import re
            m = re.search(r"```(?:json)?\n(.+?)\n```", text, re.DOTALL)
            if m:
                text = m.group(1)
        try:
            data = json.loads(text)
            result = {}
            for k in required_keys:
                v = data.get(k, [])
                if isinstance(v, list):
                    result[k] = [str(x).strip() for x in v if str(x).strip()][:3]
                else:
                    result[k] = []
            return result
        except json.JSONDecodeError:
            return {k: [] for k in required_keys}


class DifficultyClassifier:
    """Classifies word difficulty (easy/medium/hard) based on frequency/familiarity."""

    SYSTEM_PROMPT = (
        "Classify how well-known this word is for a general audience. "
        "EASY: Very common, known by almost everyone.\n"
        "MEDIUM: Moderately known, some people might not know it.\n"
        "HARD: Niche, technical, or obscure.\n"
        "Return ONLY 'easy', 'medium', or 'hard'."
    )

    def __init__(self, llm: LLMClient):
        self.llm = llm

    async def classify(self, word: str, category: str) -> str:
        prompt = f"Word: {word}\nCategory: {category}\nDifficulty:"
        text = await self.llm.complete(prompt, self.SYSTEM_PROMPT)
        text = text.strip().lower()
        if "easy" in text:
            return "easy"
        if "hard" in text:
            return "hard"
        return "medium"