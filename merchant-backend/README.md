# Merchant Backend - JSON Server

Backend mock API untuk Merchant Product Management App menggunakan JSON Server.

## Prerequisites

- Node.js (v14 atau lebih tinggi)
- npm atau yarn

## Installation

```bash
npm install
```

## Running the Server

```bash
npm start
```

atau

```bash
npm run dev
```

Server akan berjalan di http://localhost:3000

## API Endpoints

### Products

#### Get All Products (Paginated)
```
GET /products?_page=1&_limit=20
```

#### Get Product by ID
```
GET /products/{id}
```

#### Create Product
```
POST /products
Content-Type: application/json

{
  "name": "Product Name",
  "description": "Product description",
  "price": 99.99,
  "stock": 10,
  "imageUrl": "https://example.com/image.jpg",
  "createdAt": "2026-01-01T10:00:00.000Z",
  "updatedAt": "2026-01-01T10:00:00.000Z"
}
```

#### Update Product
```
PUT /products/{id}
Content-Type: application/json

{
  "name": "Updated Name",
  "description": "Updated description",
  "price": 149.99,
  "stock": 15,
  "imageUrl": "https://example.com/image.jpg",
  "updatedAt": "2026-01-05T10:00:00.000Z"
}
```

## Database

Data disimpan dalam file `db.json`. Server akan otomatis memperbarui file ini ketika ada perubahan data melalui API.

## Testing

Anda dapat menguji API menggunakan:
- curl
- Postman
- Browser (untuk GET requests)

Contoh:
```bash
curl http://localhost:3000/products
```
