#!/bin/bash
# Fetch a Reddit thread and save it to the ideas database

if [ $# -lt 2 ]; then
    echo "Usage: $0 <subreddit> <thread_id> [title]"
    echo "Example: $0 Entrepreneur 1rwrhuf"
    exit 1
fi

SUBREDDIT="$1"
THREAD_ID="$2"
TITLE="${3:-}"

DATA_DIR="data"
IDEAS_DIR="ideas"

# Fetch the JSON data
URL="https://www.reddit.com/r/$SUBREDDIT/comments/$THREAD_ID/.json"
echo "Fetching: $URL"

RESPONSE=$(curl -s -H "User-Agent: gh-ideas/1.0" "$URL")
echo "$RESPONSE" > "$DATA_DIR/${SUBREDDIT}_${THREAD_ID}.json"

# Extract title if not provided
if [ -z "$TITLE" ]; then
    TITLE=$(echo "$RESPONSE" | jq -r '.[0].data.children[0].data.title' 2>/dev/null)
    # Sanitize title for filename
    FILENAME=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-' | head -c 50)
else
    FILENAME=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-' | head -c 50)
fi

# Extract the post content
POST_CONTENT=$(echo "$RESPONSE" | jq -r '.[0].data.children[0].data.selftext' 2>/dev/null)
POST_AUTHOR=$(echo "$RESPONSE" | jq -r '.[0].data.children[0].data.author' 2>/dev/null)
POST_SCORE=$(echo "$RESPONSE" | jq -r '.[0].data.children[0].data.score' 2>/dev/null)
CREATED_UTC=$(echo "$RESPONSE" | jq -r '.[0].data.children[0].data.created_utc' 2>/dev/null)
PERMAURL=$(echo "$RESPONSE" | jq -r '.[0].data.children[0].data.permalink' 2>/dev/null)

# Convert timestamp
DATE=$(date -d "@$CREATED_UTC" "+%Y-%m-%d" 2>/dev/null || echo "unknown")

# Get top comments (limit to 10)
COMMENTS=$(echo "$RESPONSE" | jq -r '.[1].data.children[:10][] | "### u/\(.data.author) (score: \(.data.score))\n\(.data.body)\n\n---" ' 2>/dev/null)

# Create markdown file
cat > "$IDEAS_DIR/${SUBREDDIT}_${THREAD_ID}.md" << EOF
# $TITLE

**Subreddit:** r/$SUBREDDIT  
**Author:** u/$POST_AUTHOR  
**Score:** $POST_SCORE  
**Date:** $DATE  
**Source:** https://reddit.com$PERMAURL

---

## Post

$POST_CONTENT

---

## Top Comments

$COMMENTS

---

*Fetched from Reddit - [View original](https://reddit.com$PERMAURL)*
EOF

echo "✓ Saved JSON to: $DATA_DIR/${SUBREDDIT}_${THREAD_ID}.json"
echo "✓ Saved markdown to: $IDEAS_DIR/${SUBREDDIT}_${THREAD_ID}.md"
