#!/usr/bin/env python3
"""Smoke-test Sells Point admin API endpoints used by the 2.14 rebase app.

Usage:
  python3 scripts/smoke_admin_api.py
  python3 scripts/smoke_admin_api.py --base https://admin.sellspoint.in/api/
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request

DEFAULT_BASE = "https://admin.sellspoint.in/api/"

PUBLIC_GET = [
    "get-system-settings",
    "get-languages?language_code=en",
    "get-categories",
    "get-slider",
    "get-featured-section",
    "get-popular-categories",
    "faq",
    "questions/Refferal",
    "questions/Wallet",
    "blogs",
    # 2.14 — requires admin migrate + deploy
    "get-home-screen",
    "get-reels",
]

AUTH_GET = [
    "refferal-history",
    "transaction-history",
]

PATH_PARAM_GET = [
    "check-reffercode/TESTCODE",
]

# Missing on live admin until 2.14 deploy + migrate (not a regression)
EXPECTED_MISSING_UNTIL_ADMIN_DEPLOY = {
    "get-home-screen",
    "get-reels",
    "get-popular-categories",
}


def probe(base: str, path: str) -> tuple[int | str, str]:
    url = base.rstrip("/") + "/" + path.lstrip("/")
    req = urllib.request.Request(
        url,
        headers={"Accept": "application/json", "Content-Language": "en"},
        method="GET",
    )
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            return resp.status, body
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        return e.code, body
    except Exception as e:  # noqa: BLE001
        return "ERR", str(e)[:200]


def summarize(status: int | str, body: str) -> str:
    try:
        data = json.loads(body)
        if isinstance(data, dict):
            err = data.get("error")
            msg = data.get("message")
            if err is False:
                return f"OK — {msg}"[:80]
            if err is True:
                return f"API error — {msg}"[:80]
        if "could not be found" in body:
            return "404 route missing (admin not migrated?)"
        if "Unauthenticated" in body:
            return "401 auth required (route exists)"
    except json.JSONDecodeError:
        pass
    return body.replace("\n", " ")[:80]


def is_pass(path: str, status: int | str, body: str) -> bool:
    if path in AUTH_GET and status == 401:
        return True
    if path.startswith("check-reffercode/") and status == 200:
        return True
    if status != 200:
        return False
    try:
        data = json.loads(body)
        if isinstance(data, dict) and data.get("error") is False:
            return True
    except json.JSONDecodeError:
        pass
    return False


def main() -> int:
    parser = argparse.ArgumentParser(description="Admin API smoke test")
    parser.add_argument("--base", default=DEFAULT_BASE, help="API base URL")
    args = parser.parse_args()

    print(f"Admin API smoke — {args.base}\n")

    failed = 0
    for label, paths in [
        ("Public / guest", PUBLIC_GET),
        ("Auth-gated (no JWT)", AUTH_GET),
        ("Path-param", PATH_PARAM_GET),
    ]:
        print(label + ":")
        for path in paths:
            status, body = probe(args.base, path)
            note = summarize(status, body)
            ok = is_pass(path, status, body)
            route = path.split("?")[0]
            if not ok and route in EXPECTED_MISSING_UNTIL_ADMIN_DEPLOY:
                mark = "SKIP"
            else:
                mark = "PASS" if ok else "WARN"
                if not ok:
                    failed += 1
            print(f"  [{mark}] {path:35} HTTP {status} — {note}")
        print()

    print("Notes:")
    print("  - get-home-screen / get-reels need admin 2.14 migrate + deploy")
    print("  - check-reffercode uses path param: check-reffercode/{code}")
    print("  - Wallet/referral history need logged-in JWT")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
