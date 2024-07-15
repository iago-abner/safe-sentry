package models

import "time"

type TLocation struct {
	RastreadorId      int         `json:"rastreador_id"`
	Data 							string      `json:"data"`
	HorarioRastreador time.Time   `json:"horario_rastreador"`
	Latitude          float32 		`json:"latitude"`
	Longitude         float32 		`json:"longitude"`
	Velocidade        float32 		`json:"velocidade"`
	Bateria           float32 		`json:"bateria"`
	BateriaVeiculo    float32 		`json:"bateria_veiculo"`
	Ignicao           bool        `json:"ignicao"`
	Altitude          float32 		`json:"altitude"`
	Direcao           int         `json:"direcao"`
	Odometro          float32 		`json:"odometro"`
	CriadoEm          time.Time    `json:"criado_em"`
}

