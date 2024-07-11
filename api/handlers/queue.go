package handlers

import (
	"api/models"
	"database/sql"
	"encoding/json"
	"log"

	"github.com/streadway/amqp"
)



var messagesBuffer []models.TLocation
var messageObjects []*amqp.Delivery

const batchSize = 100

func ConnectQueue(rabbitmqURL string) (*amqp.Channel, error) {
	conn, err := amqp.Dial(rabbitmqURL)
	if err != nil {
		return nil, err
	}

	channel, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, err
	}

	queueName := "location_queue"
	_, err = channel.QueueDeclare(
		queueName,
		true,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		channel.Close()
		conn.Close()
		return nil, err
	}

	return channel, nil
}

func LocationWorker(channel *amqp.Channel, queueName string, db *sql.DB) {
	msgs, err := channel.Consume(
		queueName,
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

	tx, err := db.Begin()
	if err != nil {
		log.Printf("Error starting transaction: %v", err)
		nackMessages()
		return
	}

	stmt, err := tx.Prepare(`
		INSERT INTO localizacao (
			latitude, longitude, velocidade, horario_rastreador,
			bateria, bateria_veiculo, ignicao, altitude, direcao, odometro
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	`)
	if err != nil {
		log.Printf("Error preparing statement: %v", err)
		tx.Rollback()
		nackMessages()
		return
	}
	defer stmt.Close()

	for _, message := range messagesBuffer {
		_, err := stmt.Exec(
			message.Latitude, message.Longitude, message.Velocidade, message.HorarioRastreador,
			message.Bateria, message.BateriaVeiculo, message.Ignicao, message.Altitude,
			message.Direcao, message.Odometro,
		)
		if err != nil {
			log.Printf("Error executing statement: %v", err)
			tx.Rollback()
			nackMessages()
			return
		}
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Error committing transaction: %v", err)
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
