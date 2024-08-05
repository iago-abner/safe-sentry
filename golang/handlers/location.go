package handlers

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"gopg/models"
	"log"
	"strings"

	"github.com/streadway/amqp"
)

var messagesBuffer []models.TLocation
var messageObjects []*amqp.Delivery

const batchSize = 100

func LocationWorker(channel *amqp.Channel, db *sql.DB) {
	msgs, err := channel.Consume(
		"location_queue",
		"",
		false,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		log.Fatalf("Failed to register a consumer: %v", err)
	}

	for msg := range msgs {
		var message models.TLocation
		err := json.Unmarshal(msg.Body, &message)
		if err != nil {
			log.Printf("Error unmarshalling message: %v", err)
			msg.Nack(false, true)
			continue
		}

		messagesBuffer = append(messagesBuffer, message)
		messageObjects = append(messageObjects, &msg)

		if len(messagesBuffer) >= batchSize {
			processMessages(db)
		}
	}
}

func processMessages(db *sql.DB) {
	if len(messagesBuffer) == 0 {
		return
	}

	valueStrings := make([]string, 0, len(messagesBuffer))
	valueArgs := make([]interface{}, 0, len(messagesBuffer)*10)

	for i, message := range messagesBuffer {
		valueStrings = append(valueStrings, fmt.Sprintf("($%d, $%d, $%d, $%d, $%d, $%d, $%d, $%d, $%d, $%d)",
			i*10+1, i*10+2, i*10+3, i*10+4, i*10+5, i*10+6, i*10+7, i*10+8, i*10+9, i*10+10))
		valueArgs = append(valueArgs, message.Latitude, message.Longitude, message.Velocidade, message.HorarioRastreador,
			message.Bateria, message.BateriaVeiculo, message.Ignicao, message.Altitude, message.Direcao, message.Odometro)
	}

	stmt := fmt.Sprintf("INSERT INTO localizacao (latitude, longitude, velocidade, horario_rastreador, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro) VALUES %s",
		strings.Join(valueStrings, ","))
	_, err := db.Exec(stmt, valueArgs...)

	if err != nil {
		log.Printf("Error executing batch insert: %v", err)
		nackMessages()
		return
	}

	ackMessages()
}

func ackMessages() {
	for _, msg := range messageObjects {
		msg.Ack(false)
	}
	messagesBuffer = nil
	messageObjects = nil
}

func nackMessages() {
	for _, msg := range messageObjects {
		msg.Nack(false, true)
	}
	messagesBuffer = nil
	messageObjects = nil
}
