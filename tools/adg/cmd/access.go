package cmd

import (
	"fmt"

	adguard "github.com/gmichels/adguard-client-go"
	"github.com/gmichels/adguard-client-go/models"
	"github.com/spf13/cobra"
)

var accessCmd = &cobra.Command{
	Use:   "access",
	Short: "Manage allowed clients list",
}

var accessListCmd = &cobra.Command{
	Use:   "list",
	Short: "List allowed clients",
	RunE: func(cmd *cobra.Command, args []string) error {
		client, err := newADGClient()
		if err != nil {
			return err
		}

		accessList, err := client.AccessList()
		if err != nil {
			return fmt.Errorf("failed to get access list: %w", err)
		}

		if len(accessList.AllowedClients) == 0 {
			fmt.Println("No allowed clients configured")
			return nil
		}

		fmt.Println("Allowed clients:")
		for _, c := range accessList.AllowedClients {
			fmt.Printf("  - %s\n", c)
		}

		return nil
	},
}

var accessAddCmd = &cobra.Command{
	Use:   "add <client-id>",
	Short: "Add a client ID to the allowed list",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		clientID := args[0]

		adg, err := newADGClient()
		if err != nil {
			return err
		}

		if err := addToAllowedClients(adg, []string{clientID}); err != nil {
			return err
		}
		fmt.Printf("Client ID %q added to allowed_clients\n", clientID)

		return nil
	},
}

var accessRemoveCmd = &cobra.Command{
	Use:   "remove <client-id>",
	Short: "Remove a client ID from the allowed list",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		clientID := args[0]

		adg, err := newADGClient()
		if err != nil {
			return err
		}

		if err := removeFromAllowedClients(adg, []string{clientID}); err != nil {
			return err
		}
		fmt.Printf("Client ID %q removed from allowed_clients\n", clientID)

		return nil
	},
}

// addToAllowedClients adds the given IDs to the allowed_clients list.
func addToAllowedClients(adg *adguard.ADG, ids []string) error {
	accessList, err := adg.AccessList()
	if err != nil {
		return fmt.Errorf("failed to get access list: %w", err)
	}

	existing := make(map[string]bool)
	for _, c := range accessList.AllowedClients {
		existing[c] = true
	}

	for _, id := range ids {
		if !existing[id] {
			accessList.AllowedClients = append(accessList.AllowedClients, id)
		}
	}

	if err := adg.AccessSet(models.AccessList{
		AllowedClients:    accessList.AllowedClients,
		DisallowedClients: accessList.DisallowedClients,
		BlockedHosts:      accessList.BlockedHosts,
	}); err != nil {
		return fmt.Errorf("failed to update access list: %w", err)
	}

	return nil
}

// removeFromAllowedClients removes the given IDs from the allowed_clients list.
func removeFromAllowedClients(adg *adguard.ADG, ids []string) error {
	accessList, err := adg.AccessList()
	if err != nil {
		return fmt.Errorf("failed to get access list: %w", err)
	}

	toRemove := make(map[string]bool)
	for _, id := range ids {
		toRemove[id] = true
	}

	var filtered []string
	for _, c := range accessList.AllowedClients {
		if !toRemove[c] {
			filtered = append(filtered, c)
		}
	}

	if err := adg.AccessSet(models.AccessList{
		AllowedClients:    filtered,
		DisallowedClients: accessList.DisallowedClients,
		BlockedHosts:      accessList.BlockedHosts,
	}); err != nil {
		return fmt.Errorf("failed to update access list: %w", err)
	}

	return nil
}

func init() {
	accessCmd.AddCommand(accessListCmd)
	accessCmd.AddCommand(accessAddCmd)
	accessCmd.AddCommand(accessRemoveCmd)
	rootCmd.AddCommand(accessCmd)
}
