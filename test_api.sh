#!/bin/bash

# Test script for the Ruby Books API
# This script demonstrates all CRUD operations

BASE_URL="http://localhost:8000"

echo "================================"
echo "Ruby Books API - Test Script"
echo "================================"
echo ""

# Health Check
echo "1️⃣  Health Check"
echo "GET $BASE_URL/health"
curl -s $BASE_URL/health | jq .
echo -e "\n"

# Get all books
echo "2️⃣  Get All Books"
echo "GET $BASE_URL/books"
curl -s $BASE_URL/books | jq .
echo -e "\n"

# Get specific book
echo "3️⃣  Get Book by ID (ID: 1)"
echo "GET $BASE_URL/books/1"
curl -s $BASE_URL/books/1 | jq .
echo -e "\n"

# Create a new book
echo "4️⃣  Create New Book"
echo "POST $BASE_URL/books"
NEW_BOOK=$(curl -s -X POST $BASE_URL/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Hobbit",
    "author": "J.R.R. Tolkien",
    "isbn": "9780547928227",
    "published_year": 1937
  }')
echo $NEW_BOOK | jq .
BOOK_ID=$(echo $NEW_BOOK | jq -r '.book.id')
echo -e "\n"

# Update the book
echo "5️⃣  Update Book (ID: $BOOK_ID)"
echo "PUT $BASE_URL/books/$BOOK_ID"
curl -s -X PUT $BASE_URL/books/$BOOK_ID \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Hobbit (Special Edition)",
    "author": "J.R.R. Tolkien",
    "isbn": "9780547928227",
    "published_year": 1937
  }' | jq .
echo -e "\n"

# Get updated book
echo "6️⃣  Verify Update (ID: $BOOK_ID)"
echo "GET $BASE_URL/books/$BOOK_ID"
curl -s $BASE_URL/books/$BOOK_ID | jq .
echo -e "\n"

# Delete the book
echo "7️⃣  Delete Book (ID: $BOOK_ID)"
echo "DELETE $BASE_URL/books/$BOOK_ID"
curl -s -X DELETE $BASE_URL/books/$BOOK_ID | jq .
echo -e "\n"

# Verify deletion
echo "8️⃣  Verify Deletion (ID: $BOOK_ID)"
echo "GET $BASE_URL/books/$BOOK_ID"
curl -s $BASE_URL/books/$BOOK_ID | jq .
echo -e "\n"

echo "================================"
echo "✅ Test script completed!"
echo "================================"
