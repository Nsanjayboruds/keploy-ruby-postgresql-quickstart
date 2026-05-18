require 'sinatra'
require 'sinatra/json'
require 'pg'
require 'json'

# Database configuration
DB_CONFIG = {
  host: ENV['DB_HOST'] || 'localhost',
  port: ENV['DB_PORT'] || 5432,
  dbname: ENV['DB_NAME'] || 'booksdb',
  user: ENV['DB_USER'] || 'postgres',
  password: ENV['DB_PASSWORD'] || 'postgres'
}

# Database connection helper
def db_connection
  PG.connect(DB_CONFIG)
rescue PG::Error => e
  halt 500, json({ error: "Database connection failed: #{e.message}" })
end

# Configure Sinatra
set :port, ENV['PORT'] || 8000
set :bind, '0.0.0.0'

# Health check endpoint
get '/health' do
  begin
    conn = db_connection
    conn.exec('SELECT 1')
    conn.close
    json({ status: 'healthy', service: 'Ruby Books API' })
  rescue PG::Error => e
    halt 500, json({ status: 'unhealthy', error: 'Database connection failed' })
  end
end

# Get all books
get '/books' do
  content_type :json
  
  begin
    conn = db_connection
    result = conn.exec('SELECT * FROM books ORDER BY id')
    books = result.map do |row|
      {
        id: row['id'].to_i,
        title: row['title'],
        author: row['author'],
        isbn: row['isbn'],
        published_year: row['published_year'].to_i
      }
    end
    json({ books: books, count: books.length })
  ensure
    conn.close if conn
  end
end

# Get a specific book by ID
get '/books/:id' do
  content_type :json
  book_id = params['id']
  
  # Validate ID is a positive integer
  if book_id !~ /^\d+$/ || book_id.to_i <= 0
    halt 400, json({ error: 'Book ID must be a positive integer' })
  end
  
  begin
    conn = db_connection
    result = conn.exec_params('SELECT * FROM books WHERE id = $1', [book_id])
    
    if result.ntuples.zero?
      halt 404, json({ error: 'Book not found' })
    end
    
    row = result[0]
    book = {
      id: row['id'].to_i,
      title: row['title'],
      author: row['author'],
      isbn: row['isbn'],
      published_year: row['published_year'].to_i
    }
    
    json(book)
  ensure
    conn.close if conn
  end
end

# Create a new book
post '/books' do
  content_type :json
  
  begin
    request_body = JSON.parse(request.body.read)
  rescue JSON::ParserError
    halt 400, json({ error: 'Invalid JSON format' })
  end
  
  title = request_body['title']
  author = request_body['author']
  isbn = request_body['isbn']
  published_year = request_body['published_year']
  
  # Validation
  if !title || title.strip.empty?
    halt 400, json({ error: 'Title is required' })
  end
  
  if !author || author.strip.empty?
    halt 400, json({ error: 'Author is required' })
  end
  
  if isbn && isbn.length > 13
    halt 400, json({ error: 'ISBN must be 13 characters or less' })
  end
  
  if published_year && (published_year !~ /^\d+$/ || published_year.to_i < 0)
    halt 400, json({ error: 'Published year must be a non-negative integer' })
  end
  
  begin
    conn = db_connection
    result = conn.exec_params(
      'INSERT INTO books (title, author, isbn, published_year) VALUES ($1, $2, $3, $4) RETURNING *',
      [title, author, isbn, published_year]
    )
    
    row = result[0]
    new_book = {
      id: row['id'].to_i,
      title: row['title'],
      author: row['author'],
      isbn: row['isbn'],
      published_year: row['published_year'].to_i
    }
    
    status 201
    json({ message: 'Book created successfully', book: new_book })
  ensure
    conn.close if conn
  end
end

# Update a book
put '/books/:id' do
  content_type :json
  book_id = params['id']
  
  # Validate ID is a positive integer
  if book_id !~ /^\d+$/ || book_id.to_i <= 0
    halt 400, json({ error: 'Book ID must be a positive integer' })
  end
  
  begin
    request_body = JSON.parse(request.body.read)
  rescue JSON::ParserError
    halt 400, json({ error: 'Invalid JSON format' })
  end
  
  # Validate empty body
  if request_body.empty?
    halt 400, json({ error: 'Request body cannot be empty' })
  end
  
  title = request_body['title']
  author = request_body['author']
  isbn = request_body['isbn']
  published_year = request_body['published_year']
  
  # Validate fields if provided
  if title !== nil && title.strip.empty?
    halt 400, json({ error: 'Title cannot be empty' })
  end
  
  if author !== nil && author.strip.empty?
    halt 400, json({ error: 'Author cannot be empty' })
  end
  
  if isbn && isbn.length > 13
    halt 400, json({ error: 'ISBN must be 13 characters or less' })
  end
  
  if published_year && (published_year !~ /^\d+$/ || published_year.to_i < 0)
    halt 400, json({ error: 'Published year must be a non-negative integer' })
  end
  
  begin
    conn = db_connection
    
    # Check if book exists
    check_result = conn.exec_params('SELECT id FROM books WHERE id = $1', [book_id])
    if check_result.ntuples.zero?
      halt 404, json({ error: 'Book not found' })
    end
    
    result = conn.exec_params(
      'UPDATE books SET title = $1, author = $2, isbn = $3, published_year = $4 WHERE id = $5 RETURNING *',
      [title, author, isbn, published_year, book_id]
    )
    
    row = result[0]
    updated_book = {
      id: row['id'].to_i,
      title: row['title'],
      author: row['author'],
      isbn: row['isbn'],
      published_year: row['published_year'].to_i
    }
    
    json({ message: 'Book updated successfully', book: updated_book })
  ensure
    conn.close if conn
  end
end

# Delete a book
delete '/books/:id' do
  content_type :json
  book_id = params['id']
  
  # Validate ID is a positive integer
  if book_id !~ /^\d+$/ || book_id.to_i <= 0
    halt 400, json({ error: 'Book ID must be a positive integer' })
  end
  
  begin
    conn = db_connection
    
    # Check if book exists
    check_result = conn.exec_params('SELECT id FROM books WHERE id = $1', [book_id])
    if check_result.ntuples.zero?
      halt 404, json({ error: 'Book not found' })
    end
    
    conn.exec_params('DELETE FROM books WHERE id = $1', [book_id])
    
    json({ message: 'Book deleted successfully' })
  ensure
    conn.close if conn
  end
end

# PATCH not allowed
patch '/books/:id' do
  halt 405, json({ error: 'Method Not Allowed' })
end

# Error handlers
error 400 do
  json({ error: 'Bad Request' })
end

error 404 do
  json({ error: 'Not Found' })
end

error 405 do
  json({ error: 'Method Not Allowed' })
end

error 500 do
  json({ error: 'Internal Server Error' })
end
