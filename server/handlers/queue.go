package handlers

import (
	"api/models"
	"encoding/json"
	"log"

	"github.com/gocql/gocql"
	"github.com/streadway/amqp"
)


var messagesBuffer []models.TLocation
var messageObjects []*amqp.Delivery

const batchSize = 100

func ConnectQueue(rabbitmqURL string) (*amqp.Channel, error) {
	conn, err := amqp.Dial(rabbitmqURL)
	if err != nil {
		log.Printf("Error connection: %v", err)
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
		log.Printf("Error close connection: %v", err)
		channel.Close()
		conn.Close()
		return nil, err
	}

	return channel, nil
}

func LocationWorker(channel *amqp.Channel, queueName string, session *gocql.Session) {

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
		log.Printf("adicionou mensagem buffer")
		messagesBuffer = append(messagesBuffer, message)
		messageObjects = append(messageObjects, &msg)

		if len(messagesBuffer) >= batchSize {
			log.Printf("Entrou batch")
			processMessages(session)
		}
	}
}

func processMessages(session *gocql.Session) {
	if len(messagesBuffer) == 0 {
		return
	}

	batch := session.NewBatch(gocql.UnloggedBatch)
	for _, message := range messagesBuffer {
		batch.Query(`
			INSERT INTO Localizacao (rastreador_id, data, horario_rastreador, latitude, longitude, velocidade, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro, criado_em)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			message.RastreadorId,
			message.Data,
			message.HorarioRastreador,
			message.Latitude,
			message.Longitude,
			message.Velocidade,
			message.Bateria,
			message.BateriaVeiculo,
			message.Ignicao,
			message.Altitude,
			message.Direcao,
			message.Odometro,
			message.CriadoEm)
	}


	log.Printf("executing batch")
	if err := session.ExecuteBatch(batch); err != nil {
		log.Printf("Error executing batch: %v", err)
		nackMessages()
		return
	}
	log.Printf("aceite batch")
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
