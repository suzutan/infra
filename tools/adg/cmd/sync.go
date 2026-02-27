package cmd

import (
	"fmt"
	"os"

	"github.com/gmichels/adguard-client-go/models"
	"github.com/spf13/cobra"
	"gopkg.in/yaml.v3"
)

type syncConfig struct {
	Clients []syncClient `yaml:"clients"`
}

type syncClient struct {
	Name string   `yaml:"name"`
	IDs  []string `yaml:"ids"`
	Tags []string `yaml:"tags"`
}

var pruneFlag bool

var syncCmd = &cobra.Command{
	Use:   "sync <clients.yaml>",
	Short: "Sync clients from a YAML definition file",
	Long: `Declaratively sync AdGuard Home clients from a YAML file.

Clients defined in the YAML will be added or updated.
Use --prune to remove clients not in the YAML file.
The allowed_clients list is synced to include all IDs from the YAML.`,
	Args: cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		filePath := args[0]

		data, err := os.ReadFile(filePath)
		if err != nil {
			return fmt.Errorf("failed to read file: %w", err)
		}

		var config syncConfig
		if err := yaml.Unmarshal(data, &config); err != nil {
			return fmt.Errorf("failed to parse YAML: %w", err)
		}

		adg, err := newADGClient()
		if err != nil {
			return err
		}

		// Get current state
		currentClients, err := adg.Clients()
		if err != nil {
			return fmt.Errorf("failed to list clients: %w", err)
		}

		currentAccessList, err := adg.AccessList()
		if err != nil {
			return fmt.Errorf("failed to get access list: %w", err)
		}

		// Build lookup of current clients
		existingClients := make(map[string]models.Client)
		for _, c := range currentClients.Clients {
			existingClients[c.Name] = c
		}

		// Build desired state from YAML
		desiredNames := make(map[string]bool)
		var allDesiredIDs []string

		for _, sc := range config.Clients {
			desiredNames[sc.Name] = true
			allDesiredIDs = append(allDesiredIDs, sc.IDs...)

			existing, exists := existingClients[sc.Name]
			if exists {
				// Update if changed
				if !sliceEqual(existing.Ids, sc.IDs) || !sliceEqual(existing.Tags, sc.Tags) {
					update := models.ClientUpdate{
						Name: sc.Name,
						Data: models.Client{
							Name:              sc.Name,
							Ids:               sc.IDs,
							Tags:              sc.Tags,
							UseGlobalSettings: true,
						},
					}
					if err := adg.ClientsUpdate(update); err != nil {
						return fmt.Errorf("failed to update client %q: %w", sc.Name, err)
					}
					fmt.Printf("Updated client %q\n", sc.Name)
				} else {
					fmt.Printf("Client %q is up to date\n", sc.Name)
				}
			} else {
				// Add new client
				newClient := models.Client{
					Name:              sc.Name,
					Ids:               sc.IDs,
					Tags:              sc.Tags,
					UseGlobalSettings: true,
				}
				if err := adg.ClientsAdd(newClient); err != nil {
					return fmt.Errorf("failed to add client %q: %w", sc.Name, err)
				}
				fmt.Printf("Added client %q\n", sc.Name)
			}
		}

		// Prune clients not in YAML (only with --prune flag)
		if pruneFlag {
			for name := range existingClients {
				if !desiredNames[name] {
					if err := adg.ClientsDelete(models.ClientDelete{Name: name}); err != nil {
						return fmt.Errorf("failed to delete client %q: %w", name, err)
					}
					fmt.Printf("Pruned client %q\n", name)
				}
			}
		}

		// Sync allowed_clients
		desiredIDSet := make(map[string]bool)
		for _, id := range allDesiredIDs {
			desiredIDSet[id] = true
		}

		// Keep existing allowed_clients that are not managed by YAML (IPs, CIDRs, etc.)
		// but remove any that belong to clients managed by YAML
		managedIDs := make(map[string]bool)
		for _, c := range currentClients.Clients {
			if desiredNames[c.Name] {
				for _, id := range c.Ids {
					managedIDs[id] = true
				}
			}
		}
		// Also add all desired IDs to managed set
		for _, id := range allDesiredIDs {
			managedIDs[id] = true
		}

		var newAllowed []string
		// Keep unmanaged entries
		for _, c := range currentAccessList.AllowedClients {
			if !managedIDs[c] {
				newAllowed = append(newAllowed, c)
			}
		}
		// Add all desired IDs
		newAllowed = append(newAllowed, allDesiredIDs...)

		if err := adg.AccessSet(models.AccessList{
			AllowedClients:    newAllowed,
			DisallowedClients: currentAccessList.DisallowedClients,
			BlockedHosts:      currentAccessList.BlockedHosts,
		}); err != nil {
			return fmt.Errorf("failed to sync allowed_clients: %w", err)
		}
		fmt.Println("Synced allowed_clients list")

		return nil
	},
}

func sliceEqual(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	m := make(map[string]int)
	for _, v := range a {
		m[v]++
	}
	for _, v := range b {
		m[v]--
		if m[v] < 0 {
			return false
		}
	}
	return true
}

func init() {
	syncCmd.Flags().BoolVar(&pruneFlag, "prune", false, "Remove clients not defined in the YAML file")
	rootCmd.AddCommand(syncCmd)
}
