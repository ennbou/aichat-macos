# AIChat Project Makefile
# This Makefile automates common tasks for the AIChat Tuist project

# Variables
SHELL := /bin/zsh
PROJECT_NAME := AIChat
NETWORKING_MODULE := Networking
STORAGE_MODULE := Storage

# Colors for output
GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[1;33m
NC := \033[0m # No Color

# Default target
.PHONY: all
all: prepare install generate

# Help target
.PHONY: help
help:
	@echo "$(GREEN)AIChat Project Makefile$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo "  $(YELLOW)prepare$(NC)     - Prepare environment (install mise, tuist, periphery, swiftlint)"
	@echo "  $(YELLOW)install$(NC)     - Run tuist install"
	@echo "  $(YELLOW)generate$(NC)    - Generate project without opening"
	@echo "  $(YELLOW)cache$(NC)       - Run tuist cache"
	@echo "  $(YELLOW)graph$(NC)       - Generate dependency graph"
	@echo "  $(YELLOW)test$(NC)        - Run tests for all modules and main target"
	@echo "  $(YELLOW)test-networking$(NC) - Run tests for Networking module"
	@echo "  $(YELLOW)test-storage$(NC)    - Run tests for Storage module"
	@echo "  $(YELLOW)test-aichat$(NC)     - Run tests for AIChat target"
	@echo "  $(YELLOW)clean$(NC)       - Clean build artifacts"
	@echo "  $(YELLOW)rebuild$(NC)     - Full rebuild (clean + install + generate)"
	@echo "  $(YELLOW)quality$(NC)     - Run code quality checks"
	@echo "  $(YELLOW)status$(NC)      - Show project status and tool versions"
	@echo "  $(YELLOW)dev$(NC)         - Complete development setup workflow"
	@echo "  $(YELLOW)all$(NC)         - Run prepare, install, and generate"

# Prepare environment
.PHONY: prepare
prepare: check-mise install-tuist check-periphery check-swiftlint
	@echo "$(GREEN)Environment preparation completed!$(NC)"

# Check if mise is installed, install if not
.PHONY: check-mise
check-mise:
	@echo "$(YELLOW)Checking mise installation...$(NC)"
	@if command -v mise >/dev/null 2>&1; then \
		echo "$(GREEN)mise is already installed$(NC)"; \
		mise --version; \
	else \
		echo "$(RED)mise not found. Installing mise...$(NC)"; \
		curl https://mise.run | sh; \
		echo 'eval "$$($${HOME}/.local/bin/mise activate zsh)"' >> ~/.zshrc; \
		export PATH="$$HOME/.local/bin:$$PATH"; \
		echo "$(GREEN)mise installed successfully$(NC)"; \
	fi

# Install tuist using mise
.PHONY: install-tuist
install-tuist:
	@echo "$(YELLOW)Installing tuist using mise...$(NC)"
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	eval "$$($$HOME/.local/bin/mise activate zsh)"; \
	if ! mise list tuist 2>/dev/null | grep -q "tuist"; then \
		mise install tuist; \
		echo "$(GREEN)tuist installed successfully$(NC)"; \
	else \
		echo "$(GREEN)tuist is already installed$(NC)"; \
	fi; \
	mise use tuist

# Check if periphery is installed
.PHONY: check-periphery
check-periphery:
	@echo "$(YELLOW)Checking periphery installation...$(NC)"
	@if command -v periphery >/dev/null 2>&1; then \
		echo "$(GREEN)periphery is already installed$(NC)"; \
		periphery version; \
	else \
		echo "$(RED)periphery not found. Installing periphery...$(NC)"; \
		if command -v brew >/dev/null 2>&1; then \
			brew install peripheryapp/periphery/periphery; \
			echo "$(GREEN)periphery installed successfully via Homebrew$(NC)"; \
		else \
			echo "$(RED)Homebrew not found. Please install periphery manually:$(NC)"; \
			echo "Visit: https://github.com/peripheryapp/periphery#installation"; \
		fi; \
	fi

# Check if swiftlint is installed
.PHONY: check-swiftlint
check-swiftlint:
	@echo "$(YELLOW)Checking swiftlint installation...$(NC)"
	@if command -v swiftlint >/dev/null 2>&1; then \
		echo "$(GREEN)swiftlint is already installed$(NC)"; \
		swiftlint version; \
	else \
		echo "$(RED)swiftlint not found. Installing swiftlint...$(NC)"; \
		if command -v brew >/dev/null 2>&1; then \
			brew install swiftlint; \
			echo "$(GREEN)swiftlint installed successfully via Homebrew$(NC)"; \
		else \
			echo "$(RED)Homebrew not found. Please install swiftlint manually:$(NC)"; \
			echo "Visit: https://github.com/realm/SwiftLint#installation"; \
		fi; \
	fi

# Tuist install
.PHONY: install
install:
	@echo "$(YELLOW)Running tuist install...$(NC)"
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	eval "$$($$HOME/.local/bin/mise activate zsh)"; \
	tuist install
	@echo "$(GREEN)tuist install completed$(NC)"

# Generate project without opening
.PHONY: generate
generate:
	@echo "$(YELLOW)Generating project without opening...$(NC)"
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	eval "$$($$HOME/.local/bin/mise activate zsh)"; \
	tuist generate --no-open
	@echo "$(GREEN)Project generated successfully$(NC)"

# Tuist cache
.PHONY: cache
cache:
	@echo "$(YELLOW)Running tuist cache...$(NC)"
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	eval "$$($$HOME/.local/bin/mise activate zsh)"; \
	tuist cache
	@echo "$(GREEN)tuist cache completed$(NC)"

# Generate dependency graph
.PHONY: graph
graph:
	@echo "$(YELLOW)Generating dependency graph...$(NC)"
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	eval "$$($$HOME/.local/bin/mise activate zsh)"; \
	tuist graph --format png --output-path graph.png --no-open
	@echo "$(GREEN)Dependency graph generated: graph.png$(NC)"

# Run all tests
.PHONY: test
test: test-networking test-storage test-aichat
	@echo "$(GREEN)All tests completed!$(NC)"

# Test Networking module
.PHONY: test-networking
test-networking:
	@echo "$(YELLOW)Running tests for Networking module...$(NC)"
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	# rm -rf ./build/$(NETWORKING_MODULE)/test || true; \
	tuist test $(NETWORKING_MODULE) --result-bundle-path ./build/$(NETWORKING_MODULE)/test
	@echo "$(YELLOW)Extracting code coverage for Networking...$(NC)"
	@XCRESULT="./build/$(NETWORKING_MODULE)/test.xcresult"; \
	if [ -n "$$XCRESULT" ]; then \
		echo "Found xcresult at $$XCRESULT"; \
		CC=$$(xcrun xccov view --report "$$XCRESULT" | grep "Networking.framework" | awk "{print \$$2}" | sed 's/%//'); \
		echo "$(GREEN)Networking Code Coverage: $$CC%$(NC)"; \
		if [ -f "$(NETWORKING_MODULE)/README.md" ]; then \
			sed -i '' "s/-[0-9][0-9]*\.*[0-9]*%25/-$$CC%25/" $(NETWORKING_MODULE)/README.md; \
		fi; \
		echo "$(GREEN)Code coverage updated in README.md$(NC)"; \
	else \
		echo "$(RED)No xcresult bundle found in build directory$(NC)"; \
	fi
	@echo "$(GREEN)Networking tests completed$(NC)"

# Test Storage module
.PHONY: test-storage
test-storage:
	@echo "$(YELLOW)Running tests for Storage module...$(NC)"
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	rm -rf ./build/$(STORAGE_MODULE)/test || true; \
	tuist test $(STORAGE_MODULE) --result-bundle-path ./build/$(STORAGE_MODULE)/test
	@echo "$(YELLOW)Extracting code coverage for Storage...$(NC)"
	@XCRESULT="./build/$(STORAGE_MODULE)/test.xcresult"; \
	if [ -n "$$XCRESULT" ]; then \
		echo "Found xcresult at $$XCRESULT"; \
		CC=$$(xcrun xccov view --report "$$XCRESULT" | grep "Storage.framework" | awk "{print \$$2}" | sed 's/%//'); \
		echo "$(GREEN)Storage Code Coverage: $$CC%$(NC)"; \
		if [ -f "$(STORAGE_MODULE)/README.md" ]; then \
			sed -i '' "s/-[0-9][0-9]*\.*[0-9]*%25/-$$CC%25/" $(STORAGE_MODULE)/README.md; \
		fi; \
		echo "$(GREEN)Code coverage updated in README.md$(NC)"; \
	else \
		echo "$(RED)No xcresult bundle found in build directory$(NC)"; \
	fi
	@echo "$(GREEN)Networking tests completed$(NC)"

# Test AIChat target
.PHONY: test-aichat
test-aichat:
	@echo "$(YELLOW)Running tests for AIChat target...$(NC)"
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	eval "$$($$HOME/.local/bin/mise activate zsh)"; \
	tuist test $(PROJECT_NAME)
	@echo "$(GREEN)AIChat tests completed$(NC)"

# Clean build artifacts
.PHONY: clean
clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	eval "$$($$HOME/.local/bin/mise activate zsh)"; \
	tuist clean
	rm -rf build/
	rm -rf Derived/
	rm -rf .build/
	rm -rf $(NETWORKING_MODULE)/Derived/
	rm -rf $(STORAGE_MODULE)/Derived/
	@echo "$(GREEN)Clean completed$(NC)"

# Full rebuild
.PHONY: rebuild
rebuild: clean install generate
	@echo "$(GREEN)Full rebuild completed!$(NC)"

# Code quality checks
.PHONY: quality
quality:
	@echo "$(YELLOW)Running code quality checks...$(NC)"
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	eval "$$($$HOME/.local/bin/mise activate zsh)"; \
	tuist build Code_Quality
	@echo "$(GREEN)Code quality checks completed$(NC)"

# Show project status
.PHONY: status
status:
	@echo "$(YELLOW)Project Status:$(NC)"
	@echo "Project Name: $(PROJECT_NAME)"
	@echo "Modules: $(NETWORKING_MODULE), $(STORAGE_MODULE)"
	@echo ""
	@echo "$(YELLOW)Tool Versions:$(NC)"
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	eval "$$($$HOME/.local/bin/mise activate zsh)"; \
	if command -v tuist >/dev/null 2>&1; then \
		echo "tuist: $$(tuist version)"; \
	else \
		echo "tuist: $(RED)not installed$(NC)"; \
	fi; \
	if command -v swiftlint >/dev/null 2>&1; then \
		echo "swiftlint: $$(swiftlint version)"; \
	else \
		echo "swiftlint: $(RED)not installed$(NC)"; \
	fi; \
	if command -v periphery >/dev/null 2>&1; then \
		echo "periphery: $$(periphery version)"; \
	else \
		echo "periphery: $(RED)not installed$(NC)"; \
	fi; \
	if command -v mise >/dev/null 2>&1; then \
		echo "mise: $$(mise --version)"; \
	else \
		echo "mise: $(RED)not installed$(NC)"; \
	fi

# Development workflow
.PHONY: dev
dev: prepare install generate graph
	@echo "$(GREEN)Development environment ready!$(NC)"
	@echo "You can now open the project in Xcode or continue with make commands."

# DEBUGGING
.PHONY: clean-and-retest-networking
clean-and-retest-networking: clean install generate test-networking
	@echo "$(YELLOW)Cleaning and re-testing the networking...$(NC)"


# Formatting
.PHONY: format-aichat
format-aichat:
	@echo "$(YELLOW)Running code formatting...$(NC)"
	@echo "Formatting AIChat..."
	@find AIChat -name '*.swift' | xargs -n1 xcrun swift-format format -i
	@echo "$(GREEN)AIChat formatted successfully$(NC)"
	@echo "Formatting AIChat module Done"

.PHONY: format-networking
format-networking:
	@echo "$(YELLOW)Running code formatting...$(NC)"
	@echo "Formatting Networking module sources..."
	@find Networking/Sources -name '*.swift' | xargs -n1 xcrun swift-format format -i
	@find Networking/Tests -name '*.swift' | xargs -n1 xcrun swift-format format -i
	@echo "$(GREEN)Networking module formatted successfully$(NC)"

.PHONY: format-storage
format-storage:
	@echo "$(YELLOW)Running code formatting...$(NC)"
	@echo "Formatting Storage module ..."
	@find Storage/Sources -name '*.swift' | xargs -n1 xcrun swift-format format -i
	@find Storage/Tests -name '*.swift' | xargs -n1 xcrun swift-format format -i
	@echo "$(GREEN)Storage module formatted successfully$(NC)"

# Format all modules
.PHONY: format-all
format-all: format-aichat format-networking format-storage
	@echo "$(GREEN)All modules formatted successfully$(NC)"