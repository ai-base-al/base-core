package lsp

import (
	"fmt"
	"sync"
)

type Server struct {
	Name     string
	Language string
	Command  string
	Args     []string
	Running  bool
}

type Manager struct {
	servers map[string]*Server
	mu      sync.RWMutex
}

func NewManager() *Manager {
	return &Manager{
		servers: make(map[string]*Server),
	}
}

func (m *Manager) Register(name, language, command string, args []string) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	if _, exists := m.servers[name]; exists {
		return fmt.Errorf("LSP server %s already registered", name)
	}

	m.servers[name] = &Server{
		Name:     name,
		Language: language,
		Command:  command,
		Args:     args,
		Running:  false,
	}

	return nil
}

func (m *Manager) Start(name string) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	server, exists := m.servers[name]
	if !exists {
		return fmt.Errorf("LSP server %s not found", name)
	}

	if server.Running {
		return fmt.Errorf("LSP server %s already running", name)
	}

	server.Running = true
	return nil
}

func (m *Manager) Stop(name string) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	server, exists := m.servers[name]
	if !exists {
		return fmt.Errorf("LSP server %s not found", name)
	}

	server.Running = false
	return nil
}

func (m *Manager) GetByLanguage(language string) *Server {
	m.mu.RLock()
	defer m.mu.RUnlock()

	for _, server := range m.servers {
		if server.Language == language && server.Running {
			return server
		}
	}

	return nil
}

func (m *Manager) ListServers() []*Server {
	m.mu.RLock()
	defer m.mu.RUnlock()

	servers := make([]*Server, 0, len(m.servers))
	for _, server := range m.servers {
		servers = append(servers, server)
	}

	return servers
}
