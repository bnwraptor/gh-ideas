# gh-ideas

A database of Reddit business ideas collected from various subreddits.

## How it works

- Reddit threads are fetched as JSON and stored in `/data/`
- Each thread is also converted to a markdown summary in `/ideas/`
- View the ideas at: https://bnwraptor.github.io/gh-ideas

## Adding new ideas

Run the fetch script:
```bash
./fetch_idea.sh <subreddit> <thread_id>
```

Example:
```bash
./fetch_idea.sh Entrepreneur 1rwrhuf
```

## License

MIT
