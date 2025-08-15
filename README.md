## Higher Sales API

This project is a RESTful API in JSON format that allows for comprehensive management of product categories, products themselves, customers and their purchases, as well as generating detailed sales analysis reports. It includes additional features such as automated sending of notifications and daily summaries by email, and the execution of scheduled tasks in the background using Sidekiq. The entire API is documented with Swagger in the [swagger.yaml](/swagger/v1/swagger.yaml) file and can be explored in the development environment by accessing `/api-docs/index.html`, where the available endpoints, input/output formats, and supported operations are detailed.

### Core Domain
* Admins create Products (optionally belonging to multiple Categories).
* Clients perform Purchases. Each purchase stores the snapshot (price) of every product sold in `products_solds`.
* Aggregations & reports are built from `products_solds` to obtain: 
  * Top N products by units sold per category.
  * Top N products by total revenue per category.
* A daily Sidekiq job emails a purchases summary for the previous day to all admins.
* First purchase of a product triggers a notification email to the creator admin (cc to the rest).


### Authentication
JWT based. Obtain a token via `POST /auth/login` then send:
```
Authorization: Bearer <token>
```
Most category write operations and future protected endpoints require authentication.


### Emails
Background task management and email sending are fully integrated using Sidekiq and Action Mailer. Sidekiq handles asynchronous processing, including the scheduled execution of the DailyPurchasesReportWorker, which emails a summary of the previous day's sales. This recurring schedule is configured through the config/recurring.yml file, in conjunction with Sidekiq extensions such as sidekiq-cron, and requires Redis as the operational backend. Action Mailer (ProductMailer) implements two main communication flows: an automatic notification to the creator (and copy to other administrators) when the first purchase of a product is registered, and the daily purchase report with a breakdown of units sold and revenue generated per product.

### Tech Stack / Key Gems
* Rails 8 (API style controllers returning JSON)
* PostgreSQL (primary data store)
* Sidekiq + sidekiq-cron (background jobs & scheduling)
* JWT + bcrypt (authentication & password hashing)
* ActiveModelSerializers (JSON rendering/structure where applied)
* RSwag (Swagger/OpenAPI generation & UI)
* Kamal (deployment tooling) & Docker (containerization)
* Brakeman (security scanning), Rubocop Omakase (style), RSpec + FactoryBot (tests)
* Dotenv (development environment variables)

### Development Setup
Prerequisites: Docker (optional), PostgreSQL, Redis, Ruby (matching project), Node/Yarn only if you later add assets.

1. Install gems:
	```bash
	bundle install
	```
2. Prepare databases (Rails will read from `config/database.yml`):
	```bash
	bin/rails db:create
	bin/rails db:migrate
	```
3. Run Sidekiq (needs Redis):
	```bash
	bundle exec sidekiq -C config/sidekiq.yml
	```
4. Run the server:
	```bash
	bin/rails server
	```
5. Visit Swagger UI: http://localhost:3000/api-docs
6. Run test suite:
	```bash
	bundle exec rspec
	```

### Production (Docker) Run
Ensure you manually create the production database & run schema migrations (Rails won't auto-create in some managed environments). Typical steps:
1. Build image:
	```bash
	docker build -t ruby-sales .
	```
2. Run migrations (example):
	```bash
	docker run --rm \
	  -e HIGHER_SALES_DATABASE_HOST=host \
	  -e HIGHER_SALES_DATABASE_PORT=port \
	  -e HIGHER_SALES_DATABASE_USER=db_user \
	  -e HIGHER_SALES_DATABASE_PASSWORD=secure_password \
	  -e SECRET_KEY_BASE=secret \
	  -e REDIS_URL=redis_url \
	  ruby-sales bin/rails db:migrate
	```
3. Start app container (port 3000 exposed):
	```bash
	docker run -e HIGHER_SALES_DATABASE_HOST=host \
	  -e HIGHER_SALES_DATABASE_PORT=port \
	  -e SECRET_KEY_BASE=secret \
	  -e HIGHER_SALES_DATABASE_USER=database \
	  -e HIGHER_SALES_DATABASE_PASSWORD=secure_password \
	  -e REDIS_URL=redis_url \
	  -p 3000:3000 -i -t ruby-sales
	```

Sidekiq can be run either in the same container (Procfile / process manager) or a separate one pointing at the same code & Redis.

### Sidekiq Dashboard Security
Currently mounted at `/sidekiq` with no auth. In production, protect using basic auth or another layer (e.g., reverse proxy) before exposing publicly.

