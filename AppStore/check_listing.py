"""Checks AppStore/LISTING.md against App Store Connect field limits."""
import re, sys, pathlib
text = pathlib.Path(__file__).with_name("LISTING.md").read_text()
def section(title):
    m = re.search(r"^### " + re.escape(title) + r".*?\n\n(.*?)(?=\n### |\n## |\Z)", text, re.S | re.M)
    return m.group(1).strip()
limits = {"Promotional Text": 170, "Description": 4000, "Keywords": 100, "What's New in This Version": 4000}
ok = True
for name, limit in limits.items():
    n = len(section(name))
    print(f"{name:30} {n:5} / {limit}")
    ok &= n <= limit
sub = re.search(r"\*\*Subtitle \(30\):\*\* (.+)", text).group(1).strip()
print(f"{'Subtitle':30} {len(sub):5} / 30"); ok &= len(sub) <= 30
sys.exit(0 if ok else 1)
