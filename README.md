# Monolith

```bash
# Initial setup
gem install foreman
# Fill out .env based on .env.sample (Pusher key/auth endpoint is optional)

npm install

# Start the development server
make s

# Run the specs
make test
```

### Routes

* `/` —is a menu where a user can select a fair to display
* `/#/screensaver` —is a 'screensaver'
* `/#/:fair_id/map` —Fair map/activity feed
* `/#/:fair_id/leaderboard` —Rotating leaderboard of Trending Exhibitors, Trending Artists, Most Followed Exhibitors
