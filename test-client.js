const axios = require('axios');

const SERVER_URL = 'http://localhost:3000';

// Test data
const testLogs = [
    { user_id: 'alice', message: 'User logged in' },
    { user_id: 'bob', message: 'Started new session', created: '2025-07-13T08:00:00.000Z' },
    { user_id: 'alice', message: 'Performed search query: nodejs tutorial' },
    { user_id: 'charlie', message: 'First time user registration', created: '2025-07-13T09:30:00.000Z' },
    { user_id: 'bob', message: 'Updated profile information' },
    { user_id: 'alice', message: 'Logged out', created: '2025-07-13T10:15:00.000Z' },
    { user_id: 'dave', message: 'Historical log entry', created: '2025-07-12T14:20:00.000Z' }
];

async function testLogServer() {
    console.log('🚀 Starting Simple Log Server Test Client\n');

    try {
        // First, check if server is running
        console.log('📡 Checking server health...');
        const healthResponse = await axios.get(`${SERVER_URL}/health`);
        console.log('✅ Server is healthy:', healthResponse.data);
        console.log();

        // Send test log entries
        console.log('📝 Sending test log entries...\n');
        
        for (const logData of testLogs) {
            try {
                const response = await axios.post(`${SERVER_URL}/log`, logData);
                console.log(`✅ Log sent for user "${logData.user_id}": ${logData.message}`);
                if (logData.created) {
                    console.log(`   Created time: ${logData.created}`);
                }
                console.log(`   Response: ${response.data.message} at ${response.data.timestamp}`);
                console.log(`   Created in log: ${response.data.created}\n`);
                
                // Small delay between requests
                await new Promise(resolve => setTimeout(resolve, 100));
                
            } catch (error) {
                console.error(`❌ Failed to send log for user "${logData.user_id}":`, error.response?.data || error.message);
            }
        }

        console.log('🎉 Test completed! Check the logs folder for generated log files.');

    } catch (error) {
        if (error.code === 'ECONNREFUSED') {
            console.error('❌ Cannot connect to server. Make sure the server is running on port 3000.');
            console.log('💡 Start the server with: npm start');
        } else {
            console.error('❌ Test failed:', error.message);
        }
    }
}

// Test error handling
async function testErrorHandling() {
    console.log('\n🧪 Testing error handling...\n');

    const errorTests = [
        { description: 'Missing user_id', data: { message: 'test message' } },
        { description: 'Missing message', data: { user_id: 'testuser' } },
        { description: 'Empty request', data: {} }
    ];

    for (const test of errorTests) {
        try {
            await axios.post(`${SERVER_URL}/log`, test.data);
            console.log(`❌ Expected error for: ${test.description}`);
        } catch (error) {
            if (error.response?.status === 400) {
                console.log(`✅ Correctly handled error for: ${test.description}`);
                console.log(`   Error: ${error.response.data.error}\n`);
            } else {
                console.log(`❌ Unexpected error for: ${test.description}`, error.message);
            }
        }
    }
}

// Run tests
async function runAllTests() {
    await testLogServer();
    await testErrorHandling();
    
    console.log('\n📁 Log files should be created in the "logs" folder:');
    console.log('   - alice.log');
    console.log('   - bob.log');
    console.log('   - charlie.log');
    console.log('\n💡 You can also test manually using curl or Postman:');
    console.log(`   curl -X POST ${SERVER_URL}/log -H "Content-Type: application/json" -d '{"user_id":"test","message":"Hello World"}'`);
}

if (require.main === module) {
    runAllTests();
}

module.exports = { testLogServer, testErrorHandling };
