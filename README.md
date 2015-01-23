# Monolith

```bash
# Initial setup
# Fill out .env based on .env.sample (Pusher key/auth endpoint is optional)
bin/setup

# Start the development server
bin/server
```

### Routes

* `/` —is a menu where a user can select a fair to display
* `/#/screensaver` —is a 'screensaver'
* `/#/:fair_id/map` —Fair map/activity feed
* `/#/:fair_id/leaderboard` —Rotating leaderboard of Trending Exhibitors, Trending Artists, Most Followed Exhibitors
