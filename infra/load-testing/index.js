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
  return (Math.random() * (max - min) + min).toFixed(2);
}

function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

export default function () {
  const payload = {
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

  http.post("http://localhost:80/location", JSON.stringify(payload), {
    headers: {
      "Content-Type": "application/json",
    },
  });
}
