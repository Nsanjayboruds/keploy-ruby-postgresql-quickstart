# Ruby Books API - Keploy Quickstart

A simple CRUD REST API built with **Ruby (Sinatra)** and **PostgreSQL** demonstrating Keploy integration for automated API testing.

## 🚀 Features

- ✅ Complete CRUD operations for books management
- ✅ PostgreSQL database integration
- ✅ Docker Compose setup (app + database)
- ✅ Keploy integration for record and replay
- ✅ RESTful API design
- ✅ JSON request/response handling
- ✅ Error handling and validation

## 📋 Prerequisites

### For Local Setup:
- Ruby 3.2 or higher
- PostgreSQL 15 or higher
- Bundler (`gem install bundler`)

### For Docker Setup:
- Docker (20.10 or higher)
- Docker Compose (v2.0 or higher)

### For Keploy:
- Keploy CLI ([Installation Guide](https://keploy.io/docs/server/installation/))
- Linux/WSL2 environment (Keploy requirement)

## 🛠️ Installation & Setup

### Option 1: Local Setup (Without Docker)

#### 1. Clone the repository and install dependencies

```bash
# Install Ruby dependencies
bundle install
```

#### 2. Set up PostgreSQL database

```bash
# Create database
createdb booksdb

# Run initialization script
psql -d booksdb -f init.sql
```

#### 3. Configure environment variables

```bash
cp .env.example .env
# Edit .env if needed for your local PostgreSQL configuration
```

#### 4. Start the application

```bash
bundle exec ruby app.rb
```

The API will be available at `http://localhost:8000`

#### 5. Verify the setup

```bash
curl http://localhost:8000/health
# Expected: {"status":"healthy","service":"Ruby Books API"}
```

---

### Option 2: Docker Compose Setup (Recommended)

#### 1. Build and start services

```bash
docker-compose up --build
```

This will:
- Start a PostgreSQL container
- Build and start the Ruby application container
- Initialize the database with sample data
- Expose the API on port 8000

#### 2. Verify the setup

```bash
curl http://localhost:8000/health
# Expected: {"status":"healthy","service":"Ruby Books API"}
```

#### 3. Stop services

```bash
docker-compose down
```

To remove volumes as well:
```bash
docker-compose down -v
```

---

## 🧪 Testing with Keploy

### Installation

If you haven't installed Keploy yet:

```bash
curl --silent --location "https://github.com/keploy/keploy/releases/latest/download/keploy_linux_amd64.tar.gz" | tar xz -C /tmp
sudo mkdir -p /usr/local/bin && sudo mv /tmp/keploy /usr/local/bin && keploy version
```

### Record Mode

Keploy will capture all API calls and database interactions:

#### For Local Setup:

```bash
keploy record -c "bundle exec ruby app.rb"
```

#### For Docker Setup:

```bash
keploy record -c "docker-compose up" --container-name "ruby-books-app"
```

### Make API Calls

Open a new terminal and make some API requests:

```bash
# Get all books
curl http://localhost:8000/books

# Get a specific book
curl http://localhost:8000/books/1

# Create a new book
curl -X POST http://localhost:8000/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Hobbit",
    "author": "J.R.R. Tolkien",
    "isbn": "9780547928227",
    "published_year": 1937
  }'

# Update a book
curl -X PUT http://localhost:8000/books/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Great Gatsby (Updated)",
    "author": "F. Scott Fitzgerald",
    "isbn": "9780743273565",
    "published_year": 1925
  }'

# Delete a book
curl -X DELETE http://localhost:8000/books/1
```

Keploy will automatically record these interactions as test cases.

### Replay Mode

Run the recorded test cases:

#### For Local Setup:

```bash
keploy test -c "bundle exec ruby app.rb" --delay 10
```

#### For Docker Setup:

```bash
keploy test -c "docker-compose up" --container-name "ruby-books-app" --delay 10
```

Keploy will replay all recorded requests and verify the responses match the recorded ones.

---

## 📖 API Endpoints

### Health Check
```
GET /health
```
Response:
```json
{
  "status": "healthy",
  "service": "Ruby Books API"
}
```

### Get All Books
```
GET /books
```
Response:
```json
{
  "books": [
    {
      "id": 1,
      "title": "The Great Gatsby",
      "author": "F. Scott Fitzgerald",
      "isbn": "9780743273565",
      "published_year": 1925
    }
  ],
  "count": 1
}
```

### Get Book by ID
```
GET /books/:id
```
Response:
```json
{
  "id": 1,
  "title": "The Great Gatsby",
  "author": "F. Scott Fitzgerald",
  "isbn": "9780743273565",
  "published_year": 1925
}
```

### Create Book
```
POST /books
Content-Type: application/json

{
  "title": "Book Title",
  "author": "Author Name",
  "isbn": "1234567890",
  "published_year": 2024
}
```
Response:
```json
{
  "message": "Book created successfully",
  "book": {
    "id": 6,
    "title": "Book Title",
    "author": "Author Name",
    "isbn": "1234567890",
    "published_year": 2024
  }
}
```

### Update Book
```
PUT /books/:id
Content-Type: application/json

{
  "title": "Updated Title",
  "author": "Updated Author",
  "isbn": "1234567890",
  "published_year": 2024
}
```
Response:
```json
{
  "message": "Book updated successfully",
  "book": {
    "id": 1,
    "title": "Updated Title",
    "author": "Updated Author",
    "isbn": "1234567890",
    "published_year": 2024
  }
}
```

### Delete Book
```
DELETE /books/:id
```
Response:
```json
{
  "message": "Book deleted successfully"
}
```

---

## 🔍 Expected Outputs

### Keploy Record Output

```
 KEPLOY RECORD MODE
───────────────────────────────────────────────
 📝 Recording API calls...
 ✅ Test case recorded: test-1
 ✅ Test case recorded: test-2
 ✅ Test case recorded: test-3
 ✅ Test case recorded: test-4
 ✅ Test case recorded: test-5
 
 Test cases saved to: ./keploy/tests
```

### Keploy Replay Output

```
 KEPLOY TEST MODE
───────────────────────────────────────────────
 🧪 Running test cases...
 
 Test Case 1: PASSED ✅
 Test Case 2: PASSED ✅
 Test Case 3: PASSED ✅
 Test Case 4: PASSED ✅
 Test Case 5: PASSED ✅
 
 ────────────────────────────────────
 Test Summary:
   Total:   5
   Passed:  5
   Failed:  0
 ────────────────────────────────────
```

---

## 🏗️ Project Structure

```
.
├── app.rb                 # Main application file
├── config.ru              # Rack configuration
├── Gemfile                # Ruby dependencies
├── Dockerfile             # Docker image configuration
├── docker-compose.yml     # Docker Compose setup
├── init.sql               # Database initialization script
├── .env.example           # Environment variables template
└── README.md              # This file
```

---

## 🐛 Troubleshooting

### Database Connection Issues

If you see database connection errors:

1. **Local setup**: Ensure PostgreSQL is running
   ```bash
   sudo service postgresql status
   sudo service postgresql start
   ```

2. **Docker setup**: Check if containers are healthy
   ```bash
   docker-compose ps
   docker-compose logs postgres
   ```

### Port Already in Use

If port 8000 is already in use:

1. Change the port in `.env` (local setup)
2. Or modify `docker-compose.yml` ports section (Docker setup)

### Keploy Issues

1. Ensure you're running on Linux/WSL2
2. Check Keploy logs for detailed error messages
3. Try increasing the delay: `--delay 15`

---

## 📚 Learn More

- [Keploy Documentation](https://keploy.io/docs/)
- [Sinatra Documentation](http://sinatrarb.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Ruby PG Gem](https://github.com/ged/ruby-pg)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## ✨ Acknowledgments

- Built with [Keploy](https://keploy.io) for automated API testing
- Uses [Sinatra](http://sinatrarb.com/) web framework
- Database: [PostgreSQL](https://www.postgresql.org/)

---

**Happy Testing! 🎉**
