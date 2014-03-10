# Monolith

```bash
# Initial setup
npm install
touch .env
printf 'CLIENT_ID=<YOUR_CLIENT_ID>\nCLIENT_SECRET=<YOUR_CLIENT_SECRET>' >> .env

# Start the development server
make s

# Run the specs
make test
```

### Routes

* `/` —is a 'screensaver'
* `/#/map` —Fair map/activity feed
* `/#/leaderboard` —Rotating leaderboard of Trending Exhibitors, Trending Artists, Most Followed Exhibitors
