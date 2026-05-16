"""k6 load-test script for KiteEdge API endpoints (T187)."""
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 10 },
    { duration: '1m', target: 50 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4000';

export default function () {
  // Health check
  let res = http.get(`${BASE_URL}/health`);
  check(res, { 'health 200': (r) => r.status === 200 });

  // Portfolio summary
  res = http.get(`${BASE_URL}/api/v1/portfolio/summary`, {
    headers: { Cookie: 'kite_session=test_token' },
  });
  check(res, { 'summary returns': (r) => r.status < 500 });

  sleep(1);
}
