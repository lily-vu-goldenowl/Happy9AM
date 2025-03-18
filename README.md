# Happy9AM Event Messenger
A Ruby on Rails application that automatically sends scheduled event messages to users at 9:00 AM in their local timezone. With reliable scheduling, missed message recovery, and user-friendly APIs, Happy9AM ensures that important events like birthdays, holidays, and anniversaries are never forgotten!

## Key Features
- **Timezone-Aware Scheduling**: Ensures messages are sent at the correct local time.
- **Message Recovery**: Recovers missed messages in case of service interruptions.
- **Extensible Architecture**: Supports multiple event types (e.g., birthdays, holidays, anniversaries) using the Strategy Pattern.
- **Scalable Processing**: Uses Sidekiq for efficient background job management.


## Why Use `message_log` Table?
- **Prevent Duplicates**: Ensures each user gets only one message per event per day.
- **Recover Missed Messages**: Identifies and resends missed messages due to system failures.
- **Track Status**: Logs message success or failure for debugging and auditing.

## Preventing Duplicate Jobs with EventJobLock
One of the most critical aspects of this system is ensuring that event messages are not enqueued multiple times for the same user within a single day. This is achieved using the `EventJobLock` service, which leverages Redis to control job execution.

### Why `EventJobLock`?
- **Ensures Idempotency**: Prevents redundant job enqueues by setting a Redis key as a lock.
- **Optimized Performance**: Reduces unnecessary Sidekiq job processing, improving system efficiency.
- **Centralized Management**: Provides a clean, maintainable way to control job execution across the application.

view more at: `app/services/event_job_lock.rb`

### Flow chart
[![](https://mermaid.ink/img/pako:eNptkV1Pq0AQhv_KZK48SdtAoWA5iUnth9WoN9QbwZys7AgbPhZhMbal_90tLU1Mzl7tvPO8785k9xhJTuhhXLEygc3ib1iAPrPAV6xSbzAc3rQh-lFCvMkIHuQ7XPmCUyo-_4TYwu1-nlCUwkbktJMFHc4Bt51zOnuCRxmxrOu3MA9WpKIEXmqq6rczOj-isAhOQTnVNYvpXybjHlh0Wc9SgU-Fgo3kbNvC8mxYfmlRz6XfSXvH8uI4qsRbWAXay-HplA5fgsFayvRdFL89PX8X-Kko-96qG3EdPMr4EiGK_8267sj7YC7zMiNFvX530n9tNMsqYnzbbdXqHg4wpypngusP2R_JEFVCOYXo6SunD9ZkKsSwOGiUNUr62yJC74NlNQ2wkk2cXKqm5EzRQjD9s_lFLVnxKqWuVdWcSvT2-I2e6Rgj03AmhjsZX1u249gD3KI3tKyRbU-nruW4rjE2r03nMMBdF2GMpkfcnri2YVraND78ALOktNs?type=png)](https://mermaid.live/edit#pako:eNptkV1Pq0AQhv_KZK48SdtAoWA5iUnth9WoN9QbwZys7AgbPhZhMbal_90tLU1Mzl7tvPO8785k9xhJTuhhXLEygc3ib1iAPrPAV6xSbzAc3rQh-lFCvMkIHuQ7XPmCUyo-_4TYwu1-nlCUwkbktJMFHc4Bt51zOnuCRxmxrOu3MA9WpKIEXmqq6rczOj-isAhOQTnVNYvpXybjHlh0Wc9SgU-Fgo3kbNvC8mxYfmlRz6XfSXvH8uI4qsRbWAXay-HplA5fgsFayvRdFL89PX8X-Kko-96qG3EdPMr4EiGK_8267sj7YC7zMiNFvX530n9tNMsqYnzbbdXqHg4wpypngusP2R_JEFVCOYXo6SunD9ZkKsSwOGiUNUr62yJC74NlNQ2wkk2cXKqm5EzRQjD9s_lFLVnxKqWuVdWcSvT2-I2e6Rgj03AmhjsZX1u249gD3KI3tKyRbU-nruW4rjE2r03nMMBdF2GMpkfcnri2YVraND78ALOktNs)

## Done

- [x] User management API (create, update, delete)
- [x] Scheduled birthday messages at 9 AM in user's local timezone
- [x] Message delivery via Hookbin endpoint
- [x] Timezone-aware scheduling
- [x] Recovery system for missed messages during downtime
- [x] Prevention of duplicate messages through logging
- [x] Scalable job processing with Sidekiq
- [x] Add support for different types of messages holiday, anniversary, promotion notifications...
- [x] Unit tests with RSpec
## Future Improvements
- [ ] Setup CI/CD
- [ ] Implement message templates and customization options
- [ ] Add pagination and filtering to the API endpoints
- [ ] Implement rate limiting to prevent API abuse

## Setup Instructions

### Prerequisites
- Ruby 3.4.2
- Rails 8.0.1
- PostgreSQL
   - Why? Its simplicity makes it ideal for development and testing, reducing setup time and overhead while still fulfilling the test requirements.
   - For production or larger-scale systems requiring high concurrency, complex queries, or robust data integrity, PostgreSQL would be a better choice.
- Redis (for Sidekiq)

### Installation

Cronjob setup
```yaml
:scheduler:
  :schedule:
    birthday_event_scheduler:
      every: '1h' #Run every 1 hour to balance efficiency and accuracy.
      class: ScheduledEventJob
      args:
        - 'birthday' # Event type (can be 'birthday', 'holiday', etc.)
        - 9 # Target hour for event execution in the user's local timezone.
```


1. Clone the repository:
   ```bash
    git clone git@github.com:lily-vu-goldenowl/Happy9AM.git && cd Happy9AM
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Database setup:
   ```bash
   rails db:create db:migrate db:seed
   ```

4. Environment configuration:
   ```bash
   # Create a .env file or set in your environment
   # cp sample.env .env
   HOOKBIN_URL=your_hookbin_endpoint_url
   REDIS_URL=redis://localhost:6379/0
   ```

5. Start the services:
   ```bash
   # Start Rails server
   rails server

   # In a separate terminal, start Sidekiq
   bundle exec sidekiq -C config/sidekiq.yml

   # If you want to check it right away, you can run the command:
   bundle exec rails runner "ScheduledEventJob.perform_async('birthday', 9)"
   ```
## Running Sidekiq Tasks Manually

If you need to trigger birthday message processing manually without waiting for the cron job, use the following Rake tasks.

### 1. Schedule Birthday Jobs
This command schedules birthday messages for users, ensuring they will be processed at 9 AM local time.

```sh
rake sidekiq:schedule_birthdays
```
**Sample Output:**
```log
2025-03-14T07:23:48.394Z pid=80273 tid=1qtd INFO: Sidekiq 7.3.9 connecting to Redis with options {size: 10, pool_name: "internal", url: "redis://localhost:6379/0"}
✅ ScheduledEventJob enqueued for processing birthdays!
```

### 2. Send Birthday Messages Immediately
Use this command to send birthday messages to users who have a birthday today but haven't received a message yet.

```sh
rake sidekiq:send_event_messages
```

**Sample Output:**
```log
🎉 Sent birthday message to Johnny Price
🎉 Sent birthday message to Loyce Satterfield
```



## API Documentation

### Create User
```shell
curl --location '{API_ENDPOINT}/users' \
--header 'Content-Type: application/json' \
--data '{
           "user": {
             "first_name": "John",
             "last_name": "Doe",
             "birthday": "1990-03-14",
             "timezone": "America/New_York"
           }
         }'
```

### Update User
```shell
curl --location --request PUT '{API_ENDPOINT}/users/51' \
--header 'Content-Type: application/json' \
--data '{
           "user": {
             "first_name": "Johnny",
             "timezone": "America/Chicago"
           }
         }'
```

### Delete User
```shell
curl -X DELETE "{API_ENDPOINT}/users/123" -H "Content-Type: application/json"
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific tests
bundle exec rspec spec/jobs
bundle exec rspec spec/models
bundle exec rspec spec/requests
