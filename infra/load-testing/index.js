import http from "k6/http";
import { sleep, check } from "k6";

export let options = {
  stages: [
    { duration: "10s", target: 100 },
    { duration: "10s", target: 200 },
    { duration: "10s", target: 300 },
    { duration: "10s", target: 400 },
    { duration: "10s", target: 500 },
    { duration: "10s", target: 600 },
    { duration: "10s", target: 700 },
    { duration: "10s", target: 800 },
    { duration: "10s", target: 900 },
    { duration: "10s", target: 1000 },
  ],
};

const payload = JSON.stringify({
  latitude: 37.774929,
  longitude: -122.419418,
  velocidade: 55.5,
  horario_rastreador: "2024-06-04T12:34:56Z",
  bateria: 80.5,
  bateria_veiculo: 12.6,
  ignicao: true,
  altitude: 15.3,
  direcao: 180,
  odometro: 123456.7,
});

const params = {
  headers: {
    "Content-Type": "application/json",
  },
};

export default function () {
  let res = http.post("http://localhost:80/rastreamento", payload, params);

  check(res, {
    "status is 201": (r) => r.status === 201,
  });

  sleep(1);
}
