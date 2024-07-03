import http from "k6/http";
import { sleep, check } from "k6";
import { Rate, Counter } from "k6/metrics";
import exec from "k6/execution";

export let options = {
  stages: [
    // { duration: "30s", target: 100 },
    // { duration: "30s", target: 500 },
    // { duration: "1m", target: 1000 },
    // { duration: "1m", target: 1500 },
    // { duration: "1m", target: 2000 },
    { duration: "1m", target: 25000 },
    { duration: "10s", target: 0 },
  ],
  thresholds: {
    http_req_duration: ["p(95)<700"],
    "checks{status:201}": ["rate>0.90"],
  },
};

const successTimeRate = new Rate("success_time_rate");
const successRate = new Rate("success_rate");
// const vuCounter = new Counter("vu_counter");

function getRandomFloat(min, max) {
  return (Math.random() * (max - min) + min).toFixed(2);
}

function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

export default function () {
  let payload = {
    latitude: getRandomFloat(-90, 90),
    longitude: getRandomFloat(-180, 180),
    velocidade: getRandomFloat(0, 200),
    horario_rastreador: new Date().toISOString(),
    bateria: getRandomFloat(0, 100),
    bateria_veiculo: getRandomFloat(0, 15),
    ignicao: Math.random() < 0.5,
    altitude: getRandomFloat(0, 8848),
    direcao: getRandomInt(0, 360),
    odometro: getRandomFloat(0, 999999.9),
  };

  let res = http.post("http://localhost:80/location", JSON.stringify(payload), {
    headers: {
      "Content-Type": "application/json",
    },
  });

  const resultTime = check(res, {
    "response time is below 500ms": (r) => r.timings.duration < 500,
  });

  const resultRate = check(res, {
    "status is 201": (r) => r.status === 201,
  });

  successRate.add(resultRate);
  successTimeRate.add(resultTime);

  // if (!resultRate || res.timings.duration > 1000) {
  //   console.log(
  //     `First error or slow response recorded with VUs: ${exec.instance.vusActive}`
  //   );
  //   vuCounter.add(exec.instance.vusActive);
  //   exec.test.abort();
  // }

  sleep(1);
}
