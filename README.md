# Simple Log Server

A simple Node.js log server that creates user-specific log files and appends messages with timestamps.

## Features

- REST API endpoint `POST /log` for logging messages
- Creates individual log files for each user (`<user_id>.log`)
- Automatically appends timestamp to each log entry
- JSON request/response format
- Error handling and validation
- Health check endpoint
- **Web-based log viewer** for browsing and viewing log files
- API endpoints for accessing log data programmatically

## Installation

1. Install dependencies:
```bash
npm install
```

## Usage

### Starting the Server

```bash
npm start
```

The server will start on port 3000 (or the port specified in the PORT environment variable).

### Log Viewer

Open your browser and go to `http://localhost:3000` to access the web-based log viewer. The viewer provides:

- **Real-time log browsing**: See all available log files at a glance
- **Interactive interface**: Click on any log file to view its contents
- **Formatted display**: Timestamps and messages are clearly formatted
- **Auto-refresh**: The viewer automatically updates every 10 seconds
- **Responsive design**: Works on both desktop and mobile devices
- **Download functionality**: Download all logs as a ZIP file with one click

### API Endpoints

#### POST /log
Logs a message for a specific user.

**Request:**
```json
{
  "user_id": "alice",
  "message": "User performed some action",
  "created": "2025-07-13T08:00:00.000Z"
}
```

**Fields:**
- `user_id` (required): The user identifier
- `message` (required): The log message
- `created` (optional): Custom timestamp for when the event occurred. If not provided, current timestamp is used.

**Response:**
```json
{
  "success": true,
  "message": "Log entry added successfully",
  "user_id": "alice",
  "timestamp": "2025-07-13T10:30:45.123Z",
  "created": "2025-07-13T08:00:00.000Z"
}
```

#### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "OK",
  "timestamp": "2025-07-13T10:30:45.123Z",
  "uptime": 123.456
}
```

#### GET /
Serves the web-based log viewer interface.

#### GET /api/logs
Returns a list of all available log files.

**Response:**
```json
{
  "success": true,
  "logs": [
    {
      "user_id": "alice",
      "filename": "alice.log",
      "size": 1024,
      "modified": "2025-07-13T10:30:45.123Z",
      "created": "2025-07-13T08:00:00.000Z"
    }
  ]
}
```

#### GET /api/logs/:user_id
Returns the content of a specific user's log file.

**Response:**
```json
{
  "success": true,
  "user_id": "alice",
  "entries": 3,
  "content": [
    "[2025-07-13T10:30:45.123Z] [created: 2025-07-13T08:00:00.000Z] User logged in",
    "[2025-07-13T10:32:15.456Z] [created: 2025-07-13T10:32:15.456Z] Performed action"
  ]
}
```

#### GET /api/logs/download
Downloads all log files as a ZIP archive.

**Response:**
- Content-Type: `application/zip`
- Content-Disposition: `attachment; filename="logs-{timestamp}.zip"`
- Contains all `.log` files from the logs directory
- Includes a `summary.json` file with metadata about all log files

### Testing

Run the test client to see the server in action:

```bash
npm test
```

The test client will:
- Check server health
- Send multiple log entries for different users
- Test error handling
- Show you where the log files are created

### Manual Testing

You can also test manually using curl:

```bash
curl -X POST http://localhost:3000/log \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test","message":"Hello World"}'
```

With custom created timestamp:
```bash
curl -X POST http://localhost:3000/log \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test","message":"Historical event","created":"2025-07-12T14:20:00.000Z"}'
```

Download logs as ZIP:
```bash
curl -X GET http://localhost:3000/api/logs/download -o logs.zip
```

## Log Files

Log files are created in the `logs/` directory with the format:
- `alice.log`
- `bob.log`
- etc.

Each log entry includes both the server timestamp and the created timestamp:
```
[2025-07-13T10:30:45.123Z] [created: 2025-07-13T10:30:45.123Z] User logged in
[2025-07-13T10:32:15.456Z] [created: 2025-07-13T08:00:00.000Z] Historical event
```

The first timestamp is when the server processed the request, and the second is the `created` field (or the same timestamp if no `created` field was provided).

## Project Structure

```
SimpleLogServer/
├── package.json          # Dependencies and scripts
├── server.js             # Main server file
├── test-client.js        # Test client
├── viewer.html           # Web-based log viewer
├── logs/                 # Directory for log files
└── README.md            # This file
```

## Error Handling

The server validates requests and returns appropriate error codes:
- `400 Bad Request` - Missing required fields (user_id, message)
- `500 Internal Server Error` - Server-side errors

## Dependencies

- **express**: Web framework for Node.js
- **axios**: HTTP client for testing
- **archiver**: Library for creating ZIP archives
