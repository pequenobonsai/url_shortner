import { check } from 'k6';
import { parseHTML } from 'k6/html'
import http from 'k6/http'

export const options = {
  scenarios: {
    contacts: {
      executor: 'ramping-arrival-rate',
      startRate: 25,
      timeUnit: '1s',
      preAllocatedVUs: 5,
      stages: [
        { target: 25, duration: '5s' },
        { target: 50, duration: '5s' },
        { target: 100, duration: '5s' },
      ],
    }
  }
}

const shortUrlSelector = "body > main > div > div.mt-14 > dl > div:nth-child(2) > dd > div > a"
const longUrlSelector = "body > main > div > div.mt-14 > dl > div:nth-child(1) > dd > div > a"

export function setup() {
  let res = http.get("http://localhost:4000/urls/new");
  res = res.submitForm({
    formSelector: "form",
    fields: {
      "url[original_raw]": "https://example.org",
    }
  }, undefined, { redirects: 1 });

  const doc = parseHTML(res.body);

  const shortUrl = doc.find(shortUrlSelector).attr('href');
  const longUrl = doc.find(longUrlSelector).attr('href');

  return { shortUrl, longUrl }
}

export default function(data) {
  const res = http.get(data.shortUrl, { redirects: 0 });

  check(res, {
    'is status 302': (r) => r.status === 302,
    'redirects to long url': (r) => r.headers["Location"] == data.longUrl
  })
}
