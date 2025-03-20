import {
  Counter,
  Histogram,
  collectDefaultMetrics,
  register,
} from "prom-client"

collectDefaultMetrics()

export const apiRequestCounter = new Counter({
  name: "api_requests_total",
  help: "Total number of API requests",
  labelNames: ["method", "path", "status"],
})

export const apiRequestHist = new Histogram({
  name: "api_requests_duration_ms",
  help: "Histogram of the duration of all API requests in ms",
  labelNames: ["method", "path"],
  buckets: [1, 5, 10, 50, 100, 500, 1000, 5000, 10000],
})

export { register }
