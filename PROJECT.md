Hey folks! This doc tries to give more light on some technical design choices and what was going through my mind to make those decisions.
It is not intended to be exhaustive so if something is not clear let me know please.

# I assumed that:

- We would have no custom short URLs for now, nor be able to edit already generated ones
- There's no deletion happening for already generated URLs
- We will not reuse already generated short URLs

But even so, I had some

# Questions:

- Should the URL be encrypted? Since it could contain sensitive info e.g. `https://username:password@...`?
- Should short urls expire?
- What would we want to consider "one visit" the IP? Browser session?
- Should we delete the "visit count" reference when a shortned url is deleted?
  - e.g. `on_delete: :delete_all` from `url_visits` -> `urls`
  - Maybe we should do a soft delete so this does not apply, since IMHO it doesn't make sense to allow reusing shortned ids
  - Or have a `deleted_shortned_urls` or something of the likes

In the end, I had to make some

# Decisions:

1. Decided to go with a base 32 representation and 7 chars for the short url
    - Mostly because we already have functions for encoding/decoding base 32 on Elixir and 32^7 gives us ~34B numbers generated which is enough for 1k years if we are handling 5 creations/s
    - Initially thought of going with 36 (gives us more possibility and uses all numbers and single case alphabet) but would have to create the encode/decoding logic which albeit not hard was not core to functionality

2. Saved URLs as a json blob so we have the most granular info and then construct what we need from there
  - Helps us to be more efficient if we want to make analytics per domain and other stuff
  - Ended up not using it that much but would refactor to use it instead of the string representation

3. Went with a dumb approach of generating the short URL from random bytes, but would make it different if had more time (see alternatives)
    - As a way to mitigate in the short term we could have some retries in case of collision when generating the short url

4. Experimented with a `EventBroker` idea that I had for a while to centralize PubSub events through the system but I am not 100% happy with it, even though it solves the problem that I had in mind for it

But when thinking through the problem/through implementation I also thought about some

# Alternatives/Ideas:

- Using hash of the url + random bytes for the short url
    - So there would be less chance of collisions and still support multiple short urls for the same URL instead of using just the hash

- Have a KGS (key generation "service") which could keep a few (e.g. 300) valid (ensured of no collisions) short ids in memory
    - And then we could "consume it" and periodically (e.g. 15s) regenerate it
    - Or refill it if it went less than some threshold
    - Downside is that it is a single point of failure

- Instead of ecto's uuid we could have used [uuid v6](https://github.com/bitwalker/uniq) or [ecto ulid](https://github.com/TheRealReal/ecto-ulid), to mitigate fragmentation (since ecto uuid is v4 which are not sortable by default)

And even more, if I had the time, would love to explore some

# Improvements:

- Metrics can be run as batch in the background, following the pattern of "colleting -> submiting"
- URLs don't change so we could use some kind of cache
- Denylist words that may appear
- Instead of being optimistic about the uniqueness of the key, either
  - Check on the database before just retrying
  - Keep a few in memory that we know are not inserted
    - And use that when generating a new URL
    - Given the contraints, of 5/s new redirects we could keep ~ 600 at any given point and refill it every 30s
- Better URL validation, maybe use a robust library that follows the RFC?
    - Sanitize url params, no javascript, check possibility of CSFR
- Pagination to the stats page
- Maybe we could create a view for the visit count by url, or, use a different datastorage since we might want to make a lot of analytics on many dimensions
    - Since postgres is not that great at counting rows at scale
- Acceptance tests, browser tests, etc
- The current implementation of the event broker is fragile, no retries, deadletters, semantics for dealing with errors, a bit confusing, could be way better
    - The consumer part of it could use some love and more thought, it was an idea that I wanted to "feel" and this miniapp was the victim haha

## Small ones

- Instead of calling it `url.original` I would call it `url.destination`
- Decided to add all business logic functions to a single module `UrlShortner.ex` given the scope of the app but would definitely split it up into different contexts in case of growth
    - e.g. `VisitTrack`, `Shortening`, etc

Last but not least,

# Nice to have things that I would do

- Install credo
- Run linters (credo, migration linters (better migrations), format)
    - On git commit and on CI?
- Performance testing
- docker-compose to help out with dev experience
- sequence diagrams on the readme (mermaidjs <3), especially about the "tracking visit" which is a bit more complicated
