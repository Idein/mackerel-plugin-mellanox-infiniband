package main

import (
	"bufio"
	"flag"
	mp "github.com/mackerelio/go-mackerel-plugin"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
)

type InfinibandPlugin struct {
	Prefix string
}

func (p InfinibandPlugin) GraphDefinition() map[string](mp.Graphs) {
	return map[string]mp.Graphs{
		"*.*": {
			Label: "Mellanox Infiniband TX/RX",
			Unit:  "bytes/sec",
			Metrics: []mp.Metrics{
				{Name: "*", Label: "%1 port%2 - %3", Diff: true, Scale: 4},
			},
		},
	}
}

func (p InfinibandPlugin) FetchMetrics() (map[string]float64, error) {
	stat := map[string]float64{}
	ports, err := filepath.Glob("/sys/class/infiniband/*/ports/*")
	if err != nil {
		return nil, err
	}
	for _, port := range ports {
		g := regexp.MustCompile(`^/sys/class/infiniband/(mlx\d_\d)/ports/(\d+)$`).FindStringSubmatch(port)
		if g == nil {
			continue
		}
		txCount, err := ReadValue(port + "/counters/port_xmit_data")
		if err != nil {
			return nil, err
		}
		stat[g[1]+"."+g[2]+".transmited"] = float64(txCount)

		rxCount, err := ReadValue(port + "/counters/port_rcv_data")
		if err != nil {
			return nil, err
		}
		stat[g[1]+"."+g[2]+".recieved"] = float64(rxCount)
	}
	return stat, nil
}

func (p InfinibandPlugin) MetricKeyPrefix() string {
	if p.Prefix == "" {
		p.Prefix = "mellanox-infiniband"
	}
	return p.Prefix
}

func ReadValue(path string) (n uint64, err error) {
	_, err = os.Stat(path)
	if err != nil {
		return 0, err
	}

	file, err := os.Open(path)
	if err != nil {
		return 0, err
	}
	defer file.Close()

	cnt := ""
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		cnt = scanner.Text()
	}
	if err := scanner.Err(); err != nil {
		return 0, err
	}

	n, err = strconv.ParseUint(cnt, 10, 64)
	return n, nil
}

func main() {
	optPrefix := flag.String("metrix-key-prefix", "mellanox-infiniband", "Metric key prefix")
	optTempfile := flag.String("tempfile", "", "Temp file name")
	flag.Parse()

	infiniband := InfinibandPlugin{
		Prefix: *optPrefix,
	}
	plugin := mp.NewMackerelPlugin(infiniband)
	plugin.Tempfile = *optTempfile
	plugin.Run()
}