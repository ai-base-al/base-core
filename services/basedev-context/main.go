package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"basedev-context/framework"
)

type ChatRequest struct {
	Message string                 `json:"message"`
	Context map[string]interface{} `json:"context"`
	History []Message              `json:"history"`
}

type Message struct {
	Role      string    `json:"role"`
	Content   string    `json:"content"`
	Timestamp time.Time `json:"timestamp"`
}

type ChatResponse struct {
	Response string `json:"response"`
}

type ContextResponse struct {
	Mode      string  `json:"mode"`
	Framework *string `json:"framework,omitempty"`
}

var detector *framework.Detector

func main() {
	detector = framework.NewDetector()

	http.HandleFunc("/api/context", handleContext)
	http.HandleFunc("/api/chat", handleChat)
	http.HandleFunc("/health", handleHealth)

	log.Println("BaseRev Context Service starting on :8765")
	if err := http.ListenAndServe(":8765", nil); err != nil {
		log.Fatal(err)
	}
}

func handleContext(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	ctx := ContextResponse{
		Mode: "browser",
	}

	detected := detector.Detect("/tmp")
	if detected != nil {
		ctx.Framework = &detected.Name
		ctx.Mode = "code_editor"
	}

	json.NewEncoder(w).Encode(ctx)
}

func handleChat(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req ChatRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	response := generateResponse(req)

	resp := ChatResponse{
		Response: response,
	}

	json.NewEncoder(w).Encode(resp)
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	json.NewEncoder(w).Encode(map[string]string{
		"status": "healthy",
		"service": "basedev-context",
	})
}

func generateResponse(req ChatRequest) string {
	contextMode := "browser"
	if ctx, ok := req.Context["mode"].(string); ok {
		contextMode = ctx
	}

	responses := map[string]string{
		"hello": "Hello! I'm your AI Assistant. How can I help you today?",
		"hi":    "Hi there! What would you like to know?",
		"help":  "I can help you with various tasks. In browser mode, I can assist with general queries. In code editor mode, I provide framework-specific assistance.",
	}

	if resp, ok := responses[req.Message]; ok {
		return resp
	}

	if contextMode == "code_editor" {
		return fmt.Sprintf("I see you're working in the code editor. I can help with %s development. What would you like to know?", getFrameworkName(req.Context))
	}

	return fmt.Sprintf("I received your message: '%s'. I'm a placeholder AI assistant. Connect me to a real AI model for actual responses!", req.Message)
}

func getFrameworkName(context map[string]interface{}) string {
	if fw, ok := context["framework"].(string); ok {
		return fw
	}
	return "your project"
}
