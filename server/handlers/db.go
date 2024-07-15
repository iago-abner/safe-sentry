package handlers

import (
	"github.com/gocql/gocql"
)

// ConnectDB establishes a connection to Cassandra
func ConnectDB(host, keyspace string) (*gocql.Session, error) {
	cluster := gocql.NewCluster(host)
	cluster.Keyspace = keyspace
	cluster.Consistency = gocql.Quorum
	return cluster.CreateSession()
}
