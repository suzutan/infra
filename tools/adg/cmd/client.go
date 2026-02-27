package cmd

import (
	"fmt"
	"os"
	"text/tabwriter"

	"github.com/gmichels/adguard-client-go/models"
	"github.com/spf13/cobra"
)

var clientCmd = &cobra.Command{
	Use:   "client",
	Short: "Manage AdGuard Home clients",
}

var clientListCmd = &cobra.Command{
	Use:   "list",
	Short: "List all configured clients",
	RunE: func(cmd *cobra.Command, args []string) error {
		client, err := newADGClient()
		if err != nil {
			return err
		}

		clients, err := client.Clients()
		if err != nil {
			return fmt.Errorf("failed to list clients: %w", err)
		}

		w := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
		fmt.Fprintln(w, "NAME\tIDS\tTAGS")
		for _, c := range clients.Clients {
			fmt.Fprintf(w, "%s\t%v\t%v\n", c.Name, c.Ids, c.Tags)
		}
		w.Flush()

		return nil
	},
}

var (
	clientAddID   string
	clientAddTags []string
)

var clientAddCmd = &cobra.Command{
	Use:   "add <name>",
	Short: "Add a new client (also adds to allowed_clients)",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		name := args[0]

		adg, err := newADGClient()
		if err != nil {
			return err
		}

		if clientAddID == "" {
			return fmt.Errorf("--id flag is required")
		}

		// Create client
		newClient := models.Client{
			Name:              name,
			Ids:               []string{clientAddID},
			Tags:              clientAddTags,
			UseGlobalSettings: true,
		}

		if err := adg.ClientsAdd(newClient); err != nil {
			return fmt.Errorf("failed to add client: %w", err)
		}
		fmt.Printf("Client %q added successfully\n", name)

		// Add to allowed_clients
		if err := addToAllowedClients(adg, []string{clientAddID}); err != nil {
			return fmt.Errorf("client added but failed to update allowed_clients: %w", err)
		}
		fmt.Printf("Client ID %q added to allowed_clients\n", clientAddID)

		return nil
	},
}

var clientRemoveCmd = &cobra.Command{
	Use:   "remove <name>",
	Short: "Remove a client (also removes from allowed_clients)",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		name := args[0]

		adg, err := newADGClient()
		if err != nil {
			return err
		}

		// Get client IDs before deletion
		clients, err := adg.Clients()
		if err != nil {
			return fmt.Errorf("failed to list clients: %w", err)
		}

		var idsToRemove []string
		for _, c := range clients.Clients {
			if c.Name == name {
				idsToRemove = c.Ids
				break
			}
		}

		if len(idsToRemove) == 0 {
			return fmt.Errorf("client %q not found", name)
		}

		// Delete client
		if err := adg.ClientsDelete(models.ClientDelete{Name: name}); err != nil {
			return fmt.Errorf("failed to delete client: %w", err)
		}
		fmt.Printf("Client %q removed successfully\n", name)

		// Remove from allowed_clients
		if err := removeFromAllowedClients(adg, idsToRemove); err != nil {
			return fmt.Errorf("client removed but failed to update allowed_clients: %w", err)
		}
		fmt.Printf("Client IDs %v removed from allowed_clients\n", idsToRemove)

		return nil
	},
}

func init() {
	clientAddCmd.Flags().StringVar(&clientAddID, "id", "", "Client ID for DNS-over-HTTPS identification")
	clientAddCmd.Flags().StringSliceVar(&clientAddTags, "tag", nil, "Client tags (can be specified multiple times)")

	clientCmd.AddCommand(clientListCmd)
	clientCmd.AddCommand(clientAddCmd)
	clientCmd.AddCommand(clientRemoveCmd)
	rootCmd.AddCommand(clientCmd)
}
