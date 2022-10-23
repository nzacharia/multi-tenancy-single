import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    stages: [
        { duration: '20s', target: 200 },
        { duration: '20s', target: 100 },
        { duration: '20s', target: 50 },
    ],
};

const SERVICE_ENDPOINT = __ENV.SERVICE_ENDPOINT || "http://service:8080";

export default function () {
    const res = http.get(`${SERVICE_ENDPOINT}/hello`);
    check(res, { 'status was 200': (r) => r.status == 200 });
    sleep(1);
}