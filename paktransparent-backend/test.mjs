/**
 * Automated End-to-End Test Suite for Pakistan Transparent Backend API
 * Uses in-memory request/response mocks to test all endpoints reliably.
 */

import { EventEmitter } from 'node:events';
import { handleRequest } from './server.mjs';

function executeRequest(method, url, data = null, token = null) {
  return new Promise((resolve, reject) => {
    // Create mock request
    const req = new EventEmitter();
    req.method = method;
    req.url = url;
    req.headers = {
      host: 'localhost:3000',
      'content-type': 'application/json',
      accept: 'application/json',
      ...(token ? { authorization: `Bearer ${token}` } : {}),
    };

    // Create mock response
    let statusCode = 200;
    const responseHeaders = {};
    let responseBody = '';

    const res = {
      setHeader(k, v) {
        responseHeaders[k.toLowerCase()] = v;
      },
      writeHead(code, headers) {
        statusCode = code;
        if (headers) {
          for (const [k, v] of Object.entries(headers)) {
            responseHeaders[k.toLowerCase()] = v;
          }
        }
      },
      write(chunk) {
        responseBody += chunk;
      },
      end(chunk) {
        if (chunk) responseBody += chunk;
        let parsedData = responseBody;
        try {
          parsedData = JSON.parse(responseBody);
        } catch {}
        resolve({ status: statusCode, headers: responseHeaders, data: parsedData });
      },
    };

    // Trigger request handling
    handleRequest(req, res).catch(reject);

    // Stream body if any
    process.nextTick(() => {
      if (data) {
        req.emit('data', JSON.stringify(data));
      }
      req.emit('end');
    });
  });
}

async function runTests() {
  console.log('🧪 Starting Pakistan Transparent API Test Suite...\n');
  let passed = 0;
  let failed = 0;

  async function test(name, fn) {
    try {
      await fn();
      console.log(`✅ PASS: ${name}`);
      passed++;
    } catch (e) {
      console.error(`❌ FAIL: ${name} ->`, e.message);
      failed++;
    }
  }

  // 1. Citizen Login
  let citizenToken = '';
  await test('Citizen Login with valid credentials', async () => {
    const res = await executeRequest('POST', '/api/auth/login', {
      email: 'citizen@paktransparent.pk',
      password: 'Citizen@123',
      role: 'citizen',
    });
    if (res.status !== 200 || !res.data.success) throw new Error(`Status ${res.status}: ${JSON.stringify(res.data)}`);
    citizenToken = res.data.data.token;
  });

  // 2. Official Login
  let officialToken = '';
  await test('Government Official Login', async () => {
    const res = await executeRequest('POST', '/api/auth/login', {
      email: 'official@paktransparent.pk',
      password: 'Official@123',
      role: 'government',
    });
    if (res.status !== 200 || !res.data.success) throw new Error(`Status ${res.status}: ${JSON.stringify(res.data)}`);
    officialToken = res.data.data.token;
  });

  // 3. User Registration
  await test('New Citizen Registration', async () => {
    const res = await executeRequest('POST', '/api/auth/register', {
      name: 'Test Citizen User',
      email: `test_${Date.now()}@paktransparent.pk`,
      password: 'TestPassword@123',
      role: 'citizen',
      district: 'Faisalabad',
      province: 'punjab',
    });
    if (res.status !== 201 || !res.data.success) throw new Error(`Status ${res.status}: ${JSON.stringify(res.data)}`);
  });

  // 4. Fetch Projects List
  await test('GET /api/projects - Returns paginated projects', async () => {
    const res = await executeRequest('GET', '/api/projects?page=1&limit=5');
    if (res.status !== 200 || !res.data.success || !Array.isArray(res.data.data)) {
      throw new Error(`Failed to fetch projects: ${JSON.stringify(res.data)}`);
    }
    if (res.data.data.length === 0) throw new Error('Expected projects array to be populated');
  });

  // 5. Create Project (Official Action)
  let createdProjectId = '';
  await test('POST /api/projects - Official sanctions new project', async () => {
    const res = await executeRequest(
      'POST',
      '/api/projects',
      {
        name: 'Automated Test Hospital Wing',
        description: 'New intensive care and emergency response unit in Quetta.',
        category: 'healthcare',
        province: 'balochistan',
        district: 'Quetta',
        budgetAllocated: 5000000000,
      },
      officialToken
    );
    if (res.status !== 201 || !res.data.success) throw new Error(`Project creation failed: ${JSON.stringify(res.data)}`);
    createdProjectId = res.data.data.id;
  });

  // 6. Get Project by ID
  await test('GET /api/projects/:id - Fetch single project', async () => {
    const res = await executeRequest('GET', `/api/projects/${createdProjectId}`);
    if (res.status !== 200 || !res.data.success || res.data.data.id !== createdProjectId) {
      throw new Error(`Failed to fetch project ${createdProjectId}`);
    }
  });

  // 7. Submit Citizen Report
  let createdReportId = '';
  await test('POST /api/reports - Citizen submits complaint', async () => {
    const res = await executeRequest(
      'POST',
      '/api/reports',
      {
        projectId: createdProjectId,
        title: 'Delay observed in Quetta hospital foundation excavation',
        description: 'Heavy machinery has not arrived on site despite deadline passing.',
        category: 'delay',
        isAnonymous: false,
      },
      citizenToken
    );
    if (res.status !== 201 || !res.data.success) throw new Error(`Report submission failed: ${JSON.stringify(res.data)}`);
    createdReportId = res.data.data.id;
  });

  // 8. Update Report Status (Government Resolution)
  await test('PATCH /api/reports/:id/status - Government official resolves complaint', async () => {
    const res = await executeRequest(
      'PATCH',
      `/api/reports/${createdReportId}/status`,
      {
        status: 'resolved',
        response: 'Heavy machinery mobilized and on-site inspection verified.',
        actionTaken: 'Contractor issued notice to expedite shift hours.',
      },
      officialToken
    );
    if (res.status !== 200 || !res.data.success || res.data.data.status !== 'resolved') {
      throw new Error(`Failed to update report status: ${JSON.stringify(res.data)}`);
    }
  });

  // 9. Audit Trail Verification
  await test('GET /api/audit - Audit trail contains logged actions', async () => {
    const res = await executeRequest('GET', '/api/audit', null, officialToken);
    if (res.status !== 200 || !res.data.success || !Array.isArray(res.data.data)) {
      throw new Error(`Failed to fetch audit records: ${JSON.stringify(res.data)}`);
    }
  });

  // 10. Web Frontend Single Page Application Serving
  await test('GET / - Serves Web Application HTML', async () => {
    const res = await executeRequest('GET', '/');
    if (res.status !== 200 || !res.headers['content-type']?.includes('text/html')) {
      throw new Error(`Failed to serve index.html: status ${res.status}`);
    }
  });

  // 11. Static CSS Assets Serving
  await test('GET /styles.css - Serves Web Application Stylesheet', async () => {
    const res = await executeRequest('GET', '/styles.css');
    if (res.status !== 200 || !res.headers['content-type']?.includes('text/css')) {
      throw new Error(`Failed to serve styles.css: status ${res.status}`);
    }
  });

  // 12. Static JavaScript Bundle Serving
  await test('GET /app.js - Serves Web Application JavaScript', async () => {
    const res = await executeRequest('GET', '/app.js');
    if (res.status !== 200 || !res.headers['content-type']?.includes('javascript')) {
      throw new Error(`Failed to serve app.js: status ${res.status}`);
    }
  });

  // 13. Macro Analytics Endpoint
  await test('GET /api/analytics - Returns Macro Transparency Metrics', async () => {
    const res = await executeRequest('GET', '/api/analytics');
    if (res.status !== 200 || !res.data.success || !res.data.data.totalBudget) {
      throw new Error(`Failed to fetch analytics: ${JSON.stringify(res.data)}`);
    }
  });

  // 14. Budget Comparison Endpoint
  await test('GET /api/budget/comparison - Returns Project Comparison Matrix', async () => {
    const res = await executeRequest('GET', '/api/budget/comparison');
    if (res.status !== 200 || !res.data.success || !Array.isArray(res.data.data)) {
      throw new Error(`Failed to fetch budget comparison: ${JSON.stringify(res.data)}`);
    }
  });

  console.log(`\n========================================`);
  console.log(`Test Results: ${passed} Passed, ${failed} Failed`);
  console.log(`========================================\n`);

  if (failed > 0) {
    process.exit(1);
  } else {
    process.exit(0);
  }
}

runTests();
