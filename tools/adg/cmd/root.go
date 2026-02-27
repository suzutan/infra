package cmd

import (
	"fmt"
	"os"

	adguard "github.com/gmichels/adguard-client-go"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "adg",
	Short: "AdGuard Home client management CLI",
	Long:  "CLI tool for managing AdGuard Home clients and access lists via the API.",
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

func newADGClient() (*adguard.ADG, error) {
	host := os.Getenv("ADGUARD_HOST")
	username := os.Getenv("ADGUARD_USERNAME")
	password := os.Getenv("ADGUARD_PASSWORD")
	scheme := os.Getenv("ADGUARD_SCHEME")

	if host == "" {
		return nil, fmt.Errorf("ADGUARD_HOST environment variable is required")
	}
	if username == "" {
		return nil, fmt.Errorf("ADGUARD_USERNAME environment variable is required")
	}
	if password == "" {
		return nil, fmt.Errorf("ADGUARD_PASSWORD environment variable is required")
	}
	if scheme == "" {
		scheme = "https"
	}

	timeout := 10

	client, err := adguard.NewClient(&host, &username, &password, &scheme, &timeout)
	if err != nil {
		return nil, fmt.Errorf("failed to create AdGuard Home client: %w", err)
	}

	return client, nil
}
