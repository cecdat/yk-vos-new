//go:build !linux

package telemetry

import (
	"runtime"
)

func getPlatformOS() string {
	return runtime.GOOS
}

func getCPULoad() float64 {
	return 0.0
}

func getMemInfo() (int, int) {
	return 0, 0
}

func getDiskInfo() (int, int) {
	return 0, 0
}

func getSystemUptime() int64 {
	return 0
}
