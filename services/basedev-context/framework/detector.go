package framework

import (
	"encoding/json"
	"os"
	"path/filepath"
)

type Framework struct {
	Name       string   `json:"name"`
	Confidence float64  `json:"confidence"`
	Files      []string `json:"files"`
}

type Detector struct {
	frameworks []FrameworkDefinition
}

type FrameworkDefinition struct {
	Name      string
	Patterns  []Pattern
}

type Pattern struct {
	Type       string
	Path       string
	Confidence float64
}

func NewDetector() *Detector {
	return &Detector{
		frameworks: []FrameworkDefinition{
			{
				Name: "Nuxt",
				Patterns: []Pattern{
					{Type: "file", Path: "nuxt.config.ts", Confidence: 0.9},
					{Type: "file", Path: "nuxt.config.js", Confidence: 0.9},
					{Type: "file", Path: "package.json", Confidence: 0.3},
				},
			},
			{
				Name: "Next.js",
				Patterns: []Pattern{
					{Type: "file", Path: "next.config.js", Confidence: 0.9},
					{Type: "file", Path: "next.config.ts", Confidence: 0.9},
					{Type: "file", Path: "package.json", Confidence: 0.3},
				},
			},
			{
				Name: "Go",
				Patterns: []Pattern{
					{Type: "file", Path: "go.mod", Confidence: 0.95},
					{Type: "file", Path: "main.go", Confidence: 0.5},
				},
			},
			{
				Name: "Flutter",
				Patterns: []Pattern{
					{Type: "file", Path: "pubspec.yaml", Confidence: 0.95},
					{Type: "dir", Path: "lib", Confidence: 0.4},
				},
			},
			{
				Name: "Base Framework",
				Patterns: []Pattern{
					{Type: "file", Path: "base.config.go", Confidence: 0.98},
				},
			},
		},
	}
}

func (d *Detector) Detect(projectPath string) *Framework {
	var bestMatch *Framework

	for _, fw := range d.frameworks {
		score := 0.0
		matchedFiles := []string{}

		for _, pattern := range fw.Patterns {
			path := filepath.Join(projectPath, pattern.Path)

			var exists bool
			if pattern.Type == "file" {
				if _, err := os.Stat(path); err == nil {
					exists = true
				}
			} else if pattern.Type == "dir" {
				if info, err := os.Stat(path); err == nil && info.IsDir() {
					exists = true
				}
			}

			if exists {
				score += pattern.Confidence
				matchedFiles = append(matchedFiles, pattern.Path)
			}
		}

		if score > 0 {
			if bestMatch == nil || score > bestMatch.Confidence {
				bestMatch = &Framework{
					Name:       fw.Name,
					Confidence: score,
					Files:      matchedFiles,
				}
			}
		}
	}

	if bestMatch != nil && bestMatch.Confidence >= 0.5 {
		return bestMatch
	}

	return nil
}

func (d *Detector) DetectFromPackageJSON(projectPath string) *Framework {
	pkgPath := filepath.Join(projectPath, "package.json")

	data, err := os.ReadFile(pkgPath)
	if err != nil {
		return nil
	}

	var pkg map[string]interface{}
	if err := json.Unmarshal(data, &pkg); err != nil {
		return nil
	}

	deps := make(map[string]bool)
	if dependencies, ok := pkg["dependencies"].(map[string]interface{}); ok {
		for dep := range dependencies {
			deps[dep] = true
		}
	}
	if devDeps, ok := pkg["devDependencies"].(map[string]interface{}); ok {
		for dep := range devDeps {
			deps[dep] = true
		}
	}

	if deps["nuxt"] {
		return &Framework{Name: "Nuxt", Confidence: 0.95, Files: []string{"package.json"}}
	}
	if deps["next"] {
		return &Framework{Name: "Next.js", Confidence: 0.95, Files: []string{"package.json"}}
	}

	return nil
}
