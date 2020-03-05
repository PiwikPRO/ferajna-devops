package main

import (
	"net/http"
	"regexp"

	"github.com/hpcloud/tail"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func findErrorInLogs(count prometheus.Counter) {
	tailer, _ := tail.TailFile("./my.log", tail.Config{Follow: true})

	re := regexp.MustCompile("[eE]rror")

	for line := range tailer.Lines {
		if re.Match([]byte(line.Text)) {
			count.Add(1)
		}
	}

}
func main() {
	logErrorCounter := promauto.NewCounter(prometheus.CounterOpts{
		Name: "myapp_processed_ops_total",
		Help: "The total number of processed events",
	})

	go findErrorInLogs(logErrorCounter)

	http.Handle("/metrics", promhttp.Handler())
	http.ListenAndServe(":2112", nil)
}
