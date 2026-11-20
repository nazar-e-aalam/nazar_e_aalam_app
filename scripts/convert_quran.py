#!/usr/bin/env python3
import argparse
import copy
import json
import random
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "assets/quran"
API = "https://quranenc.com/api/v1"

LANGUAGES = {
    "hi": "hi",
    "guj": "gu",
    "ur": "ur",
    "sw": "sw",
}


def fetch(url):
    request = urllib.request.Request(
        url, headers={"User-Agent": "NazarEAalam-QuranImporter/1.0"}
    )

    for attempt in range(5):
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                return json.load(response)

        except (urllib.error.URLError, TimeoutError) as exc:
            if attempt == 4:
                raise

            delay = min(2**attempt, 16) + random.uniform(0, 0.5)
            print(f"Retrying after {delay:.1f}s: {exc}")
            time.sleep(delay)


def unwrap(obj):
    if isinstance(obj, list):
        if len(obj) != 1:
            raise ValueError("Unexpected source JSON array")
        return obj[0]
    return obj


def source_file(surah):
    # Existing naming: s001.json, s0010.json, s00100.json
    return ROOT / "en" / f"s00{surah}.json"


def list_translations():
    for lang, iso in LANGUAGES.items():
        print(f"\n===== {lang.upper()} =====")
        data = fetch(f"{API}/translations/list/{iso}")
        editions = data.get("translations", data) if isinstance(data, dict) else data

        for item in editions:
            print(
                "KEY:",
                item["key"],
                "| TITLE:",
                item.get("title"),
                "| VERSION:",
                item.get("version"),
            )


def convert_surah(lang, translation_key, surah):
    src = source_file(surah)

    original = json.loads(src.read_text(encoding="utf-8"))
    result = copy.deepcopy(original)
    obj = unwrap(result)

    pages = obj["data"]["chapter_info"]

    verses = [verse for page in pages for verse in page["page_verses"]]

    url = f"{API}/translation/sura/{translation_key}/{surah}"
    response = fetch(url)

    translations = (
        response.get("result", response) if isinstance(response, dict) else response
    )

    if not isinstance(translations, list):
        raise ValueError(f"Surah {surah}: invalid API response")

    mapping = {}

    for item in translations:
        if int(item["sura"]) != surah:
            raise ValueError(f"Surah {surah}: wrong Surah number")

        number = int(item["aya"])

        if number in mapping:
            raise ValueError(f"Surah {surah}: duplicate Ayah {number}")

        text = item["translation"]

        if not isinstance(text, str) or not text.strip():
            raise ValueError(f"Surah {surah}: empty Ayah {number}")

        mapping[number] = text

    expected = {int(v["verses_number"]) for v in verses}

    if len(expected) != len(verses):
        raise ValueError(f"Surah {surah}: duplicate source Ayah")

    if set(mapping) != expected:
        raise ValueError(
            f"Surah {surah}: missing={sorted(expected - set(mapping))}, "
            f"extra={sorted(set(mapping) - expected)}"
        )

    for verse in verses:
        number = int(verse["verses_number"])
        verse["translated_name"] = mapping[number]

    output_dir = ROOT / lang
    output_dir.mkdir(parents=True, exist_ok=True)

    destination = output_dir / src.name
    temporary = destination.with_suffix(".json.tmp")

    temporary.write_text(
        json.dumps(result, ensure_ascii=False, separators=(",", ":")), encoding="utf-8"
    )

    temporary.replace(destination)

    return surah, len(verses)


def convert(lang, translation_key):
    if lang not in LANGUAGES:
        raise ValueError(f"Unsupported language: {lang}")

    total_ayahs = 0
    completed = 0
    errors = []

    with ThreadPoolExecutor(max_workers=6) as executor:
        futures = {
            executor.submit(convert_surah, lang, translation_key, surah): surah
            for surah in range(1, 115)
        }

        for future in as_completed(futures):
            surah = futures[future]

            try:
                number, count = future.result()

                completed += 1
                total_ayahs += count

                print(f"[{completed}/114] Surah {number}: {count} Ayahs OK", flush=True)

            except Exception as exc:
                errors.append((surah, str(exc)))
                print(f"[ERROR] Surah {surah}: {exc}", flush=True)

    print("\n===== RESULT =====")
    print("Language:", lang)
    print("Completed:", completed)
    print("Total Ayahs:", total_ayahs)
    print("Errors:", len(errors))

    if errors:
        for surah, message in sorted(errors):
            print(f"Surah {surah}: {message}")
        raise RuntimeError("Conversion incomplete")

    if completed != 114 or total_ayahs != 6236:
        raise RuntimeError("Quran validation failed")

    print(f"SUCCESS: {lang} — 114 Surahs, 6236 Ayahs")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--list", action="store_true")
    parser.add_argument("--lang", choices=LANGUAGES.keys())
    parser.add_argument("--key")
    args = parser.parse_args()

    if args.list:
        list_translations()
    elif args.lang and args.key:
        convert(args.lang, args.key)
    else:
        parser.error("Use --list or --lang LANG --key TRANSLATION_KEY")


if __name__ == "__main__":
    main()
