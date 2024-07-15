package models

import (
	"encoding/json"
)

type TLocation struct {
	Rastreador_Id 	 string      `json:"rastreador_id"`
	Latitude         json.Number `json:"latitude"`
	Longitude        json.Number `json:"longitude"`
	Velocidade       json.Number `json:"velocidade"`
	HorarioRastreador string      `json:"horario_rastreador"`
	Bateria          json.Number `json:"bateria"`
	BateriaVeiculo   json.Number `json:"bateria_veiculo"`
	Ignicao          bool        `json:"ignicao"`
	Altitude         json.Number `json:"altitude"`
	Direcao          int         `json:"direcao"`
	Odometro         json.Number `json:"odometro"`
}
