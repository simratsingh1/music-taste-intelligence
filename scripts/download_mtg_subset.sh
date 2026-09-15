#!/usr/bin/env bash
# Downloads the Week 1 MTG-Jamendo working subset: metadata (via a shallow
# clone of the official repo) + 2 low-quality audio tar archives (~3GB,
# ~1,100 tracks), with checksum verification. Idempotent — safe to re-run.
#
# See CURRENT_STATUS.md and scripts/download_data.md for why this subset
# (vs. GTZAN or the full 156GB low-quality set) was chosen.
set -euo pipefail

cd "$(dirname "$0")/.."  # repo root

REPO_DIR="data/raw/mtg-jamendo-dataset"
AUDIO_DIR="data/raw/audio-low"
ARCHIVES=("00" "01")  # bump this list to pull more tracks later

if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning MTG-Jamendo metadata + download tooling..."
    git clone --depth 1 https://github.com/MTG/mtg-jamendo-dataset.git "$REPO_DIR"
else
    echo "Metadata repo already present at $REPO_DIR, skipping clone."
fi

TARS_MANIFEST="$(pwd)/$REPO_DIR/data/download/raw_30s_audio-low_sha256_tars.txt"

mkdir -p "$AUDIO_DIR"
cd "$AUDIO_DIR"

for i in "${ARCHIVES[@]}"; do
    f="raw_30s_audio-low-$i.tar"
    if [ -d "$i" ]; then
        echo "$f already extracted (found ./$i), skipping."
        continue
    fi

    if [ ! -f "$f" ]; then
        echo "Downloading $f..."
        curl -sS -o "$f" "https://cdn.freesound.org/mtg-jamendo/raw_30s/audio-low/$f"
    fi

    expected=$(grep -F " $f" "$TARS_MANIFEST" | awk '{print $1}')
    actual=$(shasum -a 256 "$f" | awk '{print $1}')
    if [ "$expected" != "$actual" ]; then
        echo "CHECKSUM MISMATCH for $f (expected $expected, got $actual) — removing, re-run script." >&2
        rm -f "$f"
        exit 1
    fi
    echo "$f checksum OK"

    tar -xf "$f"
    rm "$f"  # drop the tar once extracted to save space
done

echo "Done. Tracks on disk: $(find . -name '*.mp3' | wc -l | tr -d ' ')"
