const express = require('express');
const fs = require('fs');
const path = require('path');
const archiver = require('archiver');

const app = express();
const PORT = process.env.PORT || 3333;
const HOST = '0.0.0.0';

// Middleware to parse JSON requests
app.use(express.json());

// Ensure user_logs directory exists
const logsDir = path.join(__dirname, 'user_logs');
if (!fs.existsSync(logsDir)) {
    fs.mkdirSync(logsDir, { recursive: true });
}

// POST /log endpoint
app.post('/log', (req, res) => {
    try {
        const { user_id, message, created } = req.body;

        // Validate required fields
        if (!user_id || !message) {
            return res.status(400).json({
                error: 'Missing required fields',
                required: ['user_id', 'message']
            });
        }

        // Use provided created timestamp or generate current timestamp
        const timestamp = new Date().toISOString();
        const createdTime = created ? new Date(created).toISOString() : timestamp;
        
        // Format log entry with both timestamps
        const logEntry = `[${timestamp}] [created: ${createdTime}] ${message}\n`;
        
        // Create log file path
        const logFilePath = path.join(logsDir, `${user_id}.log`);
        
        // Append to log file
        fs.appendFileSync(logFilePath, logEntry);
        
        // Send success response
        res.status(200).json({
            success: true,
            message: 'Log entry added successfully',
            user_id: user_id,
            timestamp: timestamp,
            created: createdTime
        });

    } catch (error) {
        console.error('Error writing log:', error);
        res.status(500).json({
            error: 'Internal server error',
            message: error.message
        });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// Get list of available log files
app.get('/api/logs', (req, res) => {
    try {
        const files = fs.readdirSync(logsDir)
            .filter(file => file.endsWith('.log'))
            .map(file => {
                const filePath = path.join(logsDir, file);
                const stats = fs.statSync(filePath);
                const userId = file.replace('.log', '');
                
                return {
                    user_id: userId,
                    filename: file,
                    size: stats.size,
                    modified: stats.mtime.toISOString(),
                    created: stats.birthtime.toISOString()
                };
            });
        
        res.json({
            success: true,
            logs: files
        });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to read user_logs directory',
            message: error.message
        });
    }
});

// Download logs as ZIP file
app.get('/api/logs/download', (req, res) => {
    try {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const filename = `user_logs-${timestamp}.zip`;
        
        // Set response headers
        res.setHeader('Content-Type', 'application/zip');
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        
        // Create archive
        const archive = archiver('zip', {
            zlib: { level: 9 } // Maximum compression
        });
        
        // Handle archive errors
        archive.on('error', (err) => {
            console.error('Archive error:', err);
            res.status(500).json({
                error: 'Failed to create archive',
                message: err.message
            });
        });
        
        // Pipe archive to response
        archive.pipe(res);
        
        // Check if user_logs directory exists and has files
        if (!fs.existsSync(logsDir)) {
            // Create empty archive if no user_logs directory
            archive.finalize();
            return;
        }
        
        const files = fs.readdirSync(logsDir).filter(file => file.endsWith('.log'));
        
        if (files.length === 0) {
            // Create empty archive if no log files
            archive.finalize();
            return;
        }
        
        // Add each log file to archive
        files.forEach(file => {
            const filePath = path.join(logsDir, file);
            if (fs.existsSync(filePath)) {
                archive.file(filePath, { name: file });
            }
        });
        
        // Add a summary file
        const summary = {
            generated: new Date().toISOString(),
            total_files: files.length,
            files: files.map(file => {
                const filePath = path.join(logsDir, file);
                const stats = fs.statSync(filePath);
                return {
                    filename: file,
                    user_id: file.replace('.log', ''),
                    size: stats.size,
                    modified: stats.mtime.toISOString(),
                    created: stats.birthtime.toISOString()
                };
            })
        };
        
        archive.append(JSON.stringify(summary, null, 2), { name: 'summary.json' });
        
        // Finalize archive
        archive.finalize();
        
    } catch (error) {
        console.error('Error creating download:', error);
        res.status(500).json({
            error: 'Failed to create download',
            message: error.message
        });
    }
});

// Get specific log file content
app.get('/api/logs/:user_id', (req, res) => {
    try {
        const { user_id } = req.params;
        const logFilePath = path.join(logsDir, `${user_id}.log`);
        
        if (!fs.existsSync(logFilePath)) {
            return res.status(404).json({
                error: 'Log file not found',
                user_id: user_id
            });
        }
        
        const content = fs.readFileSync(logFilePath, 'utf8');
        const lines = content.split('\n').filter(line => line.trim());
        
        res.json({
            success: true,
            user_id: user_id,
            entries: lines.length,
            content: lines
        });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to read log file',
            message: error.message
        });
    }
});

// Serve static HTML viewer
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'viewer.html'));
});

// Start server
app.listen(PORT, HOST, () => {
    console.log(`Simple Log Server is running on port ${PORT}`);
    console.log(`POST to http://localhost:${PORT}/log with user_id and message`);
    console.log(`Health check: http://localhost:${PORT}/health`);
    console.log(`Log files are stored in user_logs directory`);
});

module.exports = app;
