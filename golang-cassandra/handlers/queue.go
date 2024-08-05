package handlers

import (
	"log"

	"github.com/streadway/amqp"
)


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
