import http from "k6/http";

export let options = {
  stages: [
    { duration: "50s", target: 2000 },
    { duration: "1m", target: 4000 },
    { duration: "1m", target: 6000 },
    { duration: "1m", target: 8000 },
    { duration: "1m", target: 10000 },
    { duration: "10s", target: 0 },
  ],
  thresholds: {
    http_req_duration: [{ threshold: "p(95)<1000", abortOnFail: true }],
  },
};

function getRandomFloat(min, max) {
  const res = (Math.random() * (max - min) + min).toFixed(2);
  return res;
}

function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

export default function () {
  const payload = {
    rastreador_id: getRandomInt(1, 10000),
    data: new Date().toISOString().split("T")[0],
    horario_rastreador: new Date().toISOString(),
    latitude: getRandomFloat(-90, 90),
    longitude: getRandomFloat(-180, 180),
    velocidade: getRandomFloat(0, 200),
    bateria: getRandomFloat(0, 24),
    bateria_veiculo: getRandomFloat(0, 15),
    ignicao: Math.random() < 0.5,
    altitude: getRandomFloat(0, 8848),
    direcao: getRandomInt(0, 360),
    odometro: getRandomFloat(0, 999999.9),
    criado_em: new Date().toISOString(),
  };

  http.post("http://localhost:80/location", JSON.stringify(payload), {
    headers: {
      "Content-Type": "application/json",
    },
  });
}
