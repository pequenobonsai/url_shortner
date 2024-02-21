import { check } from 'k6';
import http from 'k6/http'
import exec from 'k6/execution';

export const options = {
  scenarios: {
    contacts: {
      executor: 'ramping-arrival-rate',
      startRate: 5,
      timeUnit: '1s',
      preAllocatedVUs: 5,
      stages: [
        { target: 5, duration: '5s' },
        { target: 10, duration: '5s' },
        { target: 15, duration: '5s' },
      ],
    }
  }
}

export default function() {
  const getRes = http.get("http://localhost:4000/urls/new");

  const formRes = getRes.submitForm({
    formSelector: "form",
    fields: {
      "url[original_raw]": `https://example.org/${exec.vu.idInTest}`,
    }
  }, undefined);

  check(formRes, {
    '200': (r) => r.status === 200,
    'redirected out of /urls/new': (r) => r.url != "http://localhost:4000/urls/new",
  })
}
