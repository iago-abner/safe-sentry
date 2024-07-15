package handlers

import (
	"github.com/gocql/gocql"
)

func ConnectDB(host, keyspace, username, password string) (*gocql.Session, error) {
	cluster := gocql.NewCluster(host)
	cluster.Keyspace = keyspace
	cluster.Consistency = gocql.Quorum
	cluster.Authenticator = gocql.PasswordAuthenticator{
		Username: username,
		Password: password,
	}
	return cluster.CreateSession()
}
