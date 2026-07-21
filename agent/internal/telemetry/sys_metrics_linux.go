//go:build linux

package telemetry

import (
	"fmt"
	"os"
	"strings"
	"syscall"
)

func getPlatformOS() string {
	data, err := os.ReadFile("/etc/os-release")
	if err == nil {
		lines := strings.Split(string(data), "\n")
		for _, line := range lines {
			if strings.HasPrefix(line, "PRETTY_NAME=") {
				name := strings.TrimPrefix(line, "PRETTY_NAME=")
				name = strings.Trim(name, `"`+"\r")
				return name
			}
		}
	}
	return "Linux"
}

func getCPULoad() float64 {
	data, err := os.ReadFile("/proc/loadavg")
	if err != nil {
		return 0.0
	}
	var load float64
	_, err = fmt.Sscanf(string(data), "%f", &load)
	if err != nil {
		return 0.0
	}
	return load
}

func getMemInfo() (int, int) {
	data, err := os.ReadFile("/proc/meminfo")
	if err != nil {
		return 0, 0
	}
	var total, available int
	lines := strings.Split(string(data), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "MemTotal:") {
			fmt.Sscanf(line, "MemTotal: %d", &total)
		} else if strings.HasPrefix(line, "MemAvailable:") {
			fmt.Sscanf(line, "MemAvailable: %d", &available)
		}
	}
	totalMB := total / 1024
	usedMB := (total - available) / 1024
	if usedMB < 0 {
		usedMB = 0
	}
	return totalMB, usedMB
}

func getDiskInfo() (int, int) {
	var stat syscall.Statfs_t
	err := syscall.Statfs("/", &stat)
	if err != nil {
		return 0, 0
	}
	total := (stat.Blocks * uint64(stat.Bsize)) / (1024 * 1024)
	free := (stat.Bfree * uint64(stat.Bsize)) / (1024 * 1024)
	used := total - free
	return int(total), int(used)
}

func getSystemUptime() int64 {
	data, err := os.ReadFile("/proc/uptime")
	if err != nil {
		return 0
	}
	var uptime float64
	_, err = fmt.Sscanf(string(data), "%f", &uptime)
	if err != nil {
		return 0
	}
	return int64(uptime)
}
