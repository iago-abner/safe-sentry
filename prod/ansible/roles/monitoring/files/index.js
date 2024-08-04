import { sleep } from "k6";
import http from "k6/http";

export let options = {
  stages: [
    { duration: "30s", target: 1000 },
    { duration: "30s", target: 2000 },
    { duration: "30s", target: 4000 },
    { duration: "30s", target: 8000 },
    { duration: "30s", target: 16000 },
  ],
  thresholds: {
    http_req_duration: [{ threshold: "p(99)<1000", abortOnFail: true }],
  },
};

function getRandomFloat(min, max, numFixed) {
  const res = (Math.random() * (max - min) + min).toFixed(numFixed);
  return parseFloat(res);
}

function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

export default function () {
  let payload = {
    rastreador_id: getRandomInt(1, 10000),
    data: new Date().toISOString().split("T")[0],
    horario_rastreador: new Date().toISOString(),
    latitude: getRandomFloat(-90, 90, 6),
    longitude: getRandomFloat(-180, 180, 6),
    velocidade: getRandomFloat(0, 200, 1),
    bateria: getRandomFloat(0, 24, 1),
    bateria_veiculo: getRandomFloat(0, 15, 1),
    ignicao: Math.random() < 0.5,
    altitude: getRandomFloat(0, 8848, 1),
    direcao: getRandomInt(0, 360),
    odometro: getRandomFloat(0, 999999, 2),
    criado_em: new Date().toISOString(),
  };

  http.post("http://172.31.43.12:80/location", JSON.stringify(payload), {
    headers: {
      "Content-Type": "application/json",
    },
  });

  sleep(1);
}
