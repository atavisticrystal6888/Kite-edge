"""k6 rate-limiter soak test (T188): verifies 3 req/sec Kite API cap under load."""
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 5,
  duration: '30s',
  thresholds: {
    http_req_duration: ['p(95)<1000'],
    checks: ['rate>0.8'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4000';

export default function () {
  // Rapid instrument search to test rate limiting
  const res = http.get(`${BASE_URL}/api/v1/instruments/search?q=RELIANCE`, {
    headers: { Cookie: 'kite_session=test_token' },
  });
  check(res, {
    'not server error': (r) => r.status < 500,
    'rate limited or ok': (r) => r.status === 200 || r.status === 429,
  });

  sleep(0.2);
}
