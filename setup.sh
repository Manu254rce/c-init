#!/bin/bash

# C Project Generator - Setup Script
# This script helps initialize a new C project with customizable options
# Can be run directly or installed globally as 'c-init'

set -e  # Exit on any error

# Version and metadata
VERSION="1.0.0"
SCRIPT_NAME="c-init"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_PROJECT_NAME="my-c-project"
DEFAULT_AUTHOR="Your Name"
DEFAULT_EMAIL="your.email@example.com"
DEFAULT_COMPILER="gcc"
DEFAULT_C_STANDARD="c11"

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Function to prompt for input with default
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    read -p "$prompt [$default]: " input
    if [[ -z "$input" ]]; then
        eval "$var_name=\"$default\""
    else
        eval "$var_name=\"$input\""
    fi
}

# Function to prompt for yes/no with default
prompt_yes_no() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$prompt [Y/n]: " yn
            yn=${yn:-y}
        else
            read -p "$prompt [y/N]: " yn
            yn=${yn:-n}
        fi
        
        case $yn in
            [Yy]* ) eval "$var_name=true"; break;;
            [Nn]* ) eval "$var_name=false"; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to show help
show_help() {
    echo "C Project Generator v${VERSION}"
    echo "Creates a new C project with proper structure and build system"
    echo
    echo "Usage: ${SCRIPT_NAME} [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help       Show this help message"
    echo "  -v, --version    Show version information"
    echo "  -q, --quick      Quick setup with defaults (non-interactive)"
    echo "  -n, --name NAME  Set project name (for quick mode)"
    echo
    echo "Examples:"
    echo "  ${SCRIPT_NAME}                    # Interactive setup"
    echo "  ${SCRIPT_NAME} --quick            # Quick setup with defaults"
    echo "  ${SCRIPT_NAME} -q -n my-project  # Quick setup with custom name"
    echo
}

# Function to show version
show_version() {
    echo "C Project Generator v${VERSION}"
}

# Function for quick setup (non-interactive)
quick_setup() {
    print_info "Running quick setup with defaults..."
    
    PROJECT_NAME="${QUICK_PROJECT_NAME:-my-c-project}"
    AUTHOR="Developer"
    EMAIL="dev@example.com"
    PROJECT_DESCRIPTION="A C project created with the boilerplate generator"
    COMPILER="gcc"
    C_STANDARD="c11"
    INCLUDE_TESTS=true
    INCLUDE_LIB_DIR=false
    INCLUDE_CONFIG_DIR=false
    INIT_GIT=true
    TEST_BUILD=true
    
    print_info "Project: $PROJECT_NAME"
    print_info "Compiler: $COMPILER ($C_STANDARD)"
}

# Function to validate project name
validate_project_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Project name can only contain letters, numbers, hyphens, and underscores"
        return 1
    fi
    return 0
}

# Function to check required tools
check_dependencies() {
    print_header "Checking Dependencies"
    
    local missing_tools=()
    
    if ! command_exists "$COMPILER"; then
        missing_tools+=("$COMPILER")
    fi
    
    if ! command_exists "make"; then
        missing_tools+=("make")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo "Please install the missing tools and run this script again."
        exit 1
    fi
    
    print_success "All required tools are available"
    print_info "Compiler: $($COMPILER --version | head -n1)"
    print_info "Make: $(make --version | head -n1)"
}

# Function to create project structure
create_project_structure() {
    print_header "Creating Project Structure"
    
    # Create directories if they don't exist
    mkdir -p build/{bin,obj}
    mkdir -p include
    mkdir -p src
    mkdir -p tests/{src,include}
    mkdir -p scripts
    mkdir -p docs
    
    if [[ "$INCLUDE_LIB_DIR" == true ]]; then
        mkdir -p lib
        print_info "Created lib/ directory for external dependencies"
    fi
    
    if [[ "$INCLUDE_CONFIG_DIR" == true ]]; then
        mkdir -p config
        print_info "Created config/ directory for configuration files"
    fi
    
    print_success "Project structure created"
}

# Function to generate main.c
generate_main_c() {
    cat > src/main.c << EOF
/*
 * ${PROJECT_NAME}
 * 
 * Author: ${AUTHOR} <${EMAIL}>
 * Created: $(date +"%Y-%m-%d")
 * 
 * Description: Main entry point for ${PROJECT_NAME}
 */

#include <stdio.h>
#include <stdlib.h>
#include "main.h"

int main(int argc, char *argv[]) {
    printf("Hello from %s!\\n", "${PROJECT_NAME}");
    printf("This project was created by ${AUTHOR}\\n");
    
    return EXIT_SUCCESS;
}
EOF
}

# Function to generate main.h
generate_main_h() {
    local header_guard=$(echo "${PROJECT_NAME}" | tr '[:lower:]' '[:upper:]' | tr '-' '_')_H
    
    cat > include/main.h << EOF
/*
 * ${PROJECT_NAME}
 * 
 * Author: ${AUTHOR} <${EMAIL}>
 * Created: $(date +"%Y-%m-%d")
 */

#ifndef ${header_guard}
#define ${header_guard}

// Function declarations go here

#endif /* ${header_guard} */
EOF
}

# Function to generate Makefile
generate_makefile() {
    cat > Makefile << EOF
# Makefile for ${PROJECT_NAME}
# Generated by setup script on $(date +"%Y-%m-%d")

# Project settings
PROJECT_NAME = ${PROJECT_NAME}
CC = ${COMPILER}
CFLAGS = -std=${C_STANDARD} -Wall -Wextra -Wpedantic
CFLAGS_DEBUG = -g -O0 -DDEBUG
CFLAGS_RELEASE = -O2 -DNDEBUG

# Directories
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build
OBJ_DIR = \$(BUILD_DIR)/obj
BIN_DIR = \$(BUILD_DIR)/bin
TEST_DIR = tests

# Files
SOURCES = \$(wildcard \$(SRC_DIR)/*.c)
OBJECTS = \$(SOURCES:\$(SRC_DIR)/%.c=\$(OBJ_DIR)/%.o)
TARGET = \$(BIN_DIR)/\$(PROJECT_NAME)

# Default target
all: \$(TARGET)

# Debug build
debug: CFLAGS += \$(CFLAGS_DEBUG)
debug: \$(TARGET)

# Release build
release: CFLAGS += \$(CFLAGS_RELEASE)
release: \$(TARGET)

# Build target
\$(TARGET): \$(OBJECTS) | \$(BIN_DIR)
	\$(CC) \$(OBJECTS) -o \$@

# Compile source files
\$(OBJ_DIR)/%.o: \$(SRC_DIR)/%.c | \$(OBJ_DIR)
	\$(CC) \$(CFLAGS) -I\$(INCLUDE_DIR) -c \$< -o \$@

# Create directories
\$(OBJ_DIR):
	mkdir -p \$(OBJ_DIR)

\$(BIN_DIR):
	mkdir -p \$(BIN_DIR)

# Clean build files
clean:
	rm -rf \$(BUILD_DIR)/*

# Run the program
run: \$(TARGET)
	./\$(TARGET)

# Install (you may want to customize this)
install: \$(TARGET)
	cp \$(TARGET) /usr/local/bin/

# Uninstall
uninstall:
	rm -f /usr/local/bin/\$(PROJECT_NAME)

EOF

    if [[ "$INCLUDE_TESTS" == true ]]; then
        cat >> Makefile << EOF
# Test settings
TEST_SOURCES = \$(wildcard \$(TEST_DIR)/src/*.c)
TEST_OBJECTS = \$(TEST_SOURCES:\$(TEST_DIR)/src/%.c=\$(OBJ_DIR)/test_%.o)
TEST_TARGET = \$(BIN_DIR)/test_\$(PROJECT_NAME)

# Build tests
test: \$(TEST_TARGET)
	./\$(TEST_TARGET)

\$(TEST_TARGET): \$(TEST_OBJECTS) | \$(BIN_DIR)
	\$(CC) \$(TEST_OBJECTS) -o \$@

\$(OBJ_DIR)/test_%.o: \$(TEST_DIR)/src/%.c | \$(OBJ_DIR)
	\$(CC) \$(CFLAGS) -I\$(INCLUDE_DIR) -I\$(TEST_DIR)/include -c \$< -o \$@

EOF
    fi

    cat >> Makefile << EOF
# Phony targets
.PHONY: all debug release clean run install uninstall test

EOF
}

# Function to generate .gitignore
generate_gitignore() {
    cat > .gitignore << EOF
# Build artifacts
build/bin/*
build/obj/*
!build/bin/.gitkeep
!build/obj/.gitkeep

# Compiled Object files
*.o
*.obj

# Executables
*.exe
*.out
*.app

# Debug files
*.dSYM/
*.su
*.idb
*.pdb

# Editor files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Dependency directories
lib/
vendor/

# Log files
*.log

EOF
}

# Function to generate README
generate_readme() {
    cat > README.md << EOF
# ${PROJECT_NAME}

${PROJECT_DESCRIPTION}

## Author

**${AUTHOR}** <${EMAIL}>

## Building

\`\`\`bash
# Debug build
make debug

# Release build
make release

# Or just
make
\`\`\`

## Running

\`\`\`bash
# Run directly
make run

# Or run the executable
./build/bin/${PROJECT_NAME}
\`\`\`

EOF

    if [[ "$INCLUDE_TESTS" == true ]]; then
        cat >> README.md << EOF
## Testing

\`\`\`bash
make test
\`\`\`

EOF
    fi

    cat >> README.md << EOF
## Cleaning

\`\`\`bash
make clean
\`\`\`

## Installation

\`\`\`bash
# Install to /usr/local/bin
sudo make install

# Uninstall
sudo make uninstall
\`\`\`

## Project Structure

\`\`\`
.
├── Makefile          # Build configuration
├── README.md         # This file
├── .gitignore        # Git ignore rules
├── build/            # Build output directory
│   ├── bin/          # Final executables
│   └── obj/          # Object files
├── include/          # Header files
├── src/              # Source files
├── tests/            # Test files
├── scripts/          # Build and utility scripts
└── docs/             # Documentation
\`\`\`

## License

[Specify your license here]

EOF
}

# Function to generate test file
generate_test_files() {
    if [[ "$INCLUDE_TESTS" == true ]]; then
        # Create basic test
        cat > tests/src/test_main.c << EOF
/*
 * Basic tests for ${PROJECT_NAME}
 * 
 * Author: ${AUTHOR}
 * Created: $(date +"%Y-%m-%d")
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

// Simple test framework
#define TEST(name) void test_##name()
#define RUN_TEST(name) do { \\
    printf("Running test_%s... ", #name); \\
    test_##name(); \\
    printf("PASSED\\n"); \\
} while(0)

TEST(example) {
    // Example test - replace with your actual tests
    assert(1 + 1 == 2);
    assert(2 * 2 == 4);
}

int main() {
    printf("Running tests for ${PROJECT_NAME}\\n");
    printf("================================\\n");
    
    RUN_TEST(example);
    
    printf("================================\\n");
    printf("All tests passed!\\n");
    
    return EXIT_SUCCESS;
}
EOF

        # Create test header
        cat > tests/include/test.h << EOF
/*
 * Test utilities for ${PROJECT_NAME}
 */

#ifndef TEST_H
#define TEST_H

// Test utilities and macros can go here

#endif /* TEST_H */
EOF
    fi
}

# Function to create .gitkeep files
create_gitkeep_files() {
    touch build/bin/.gitkeep
    touch build/obj/.gitkeep
    touch docs/.gitkeep
}

# Function to initialize git repository
init_git() {
    if [[ "$INIT_GIT" == true ]]; then
        print_header "Initializing Git Repository"
        
        if [[ -d ".git" ]]; then
            print_warning "Git repository already exists"
        else
            git init
            git add .
            git commit -m "Initial commit: ${PROJECT_NAME} boilerplate"
            print_success "Git repository initialized with initial commit"
        fi
    fi
}

# Function to run test build
test_build() {
    if [[ "$TEST_BUILD" == true ]]; then
        print_header "Testing Build"
        
        if make debug > /dev/null 2>&1; then
            print_success "Debug build successful"
            
            if [[ -x "build/bin/${PROJECT_NAME}" ]]; then
                print_info "Running test execution:"
                ./build/bin/${PROJECT_NAME}
            fi
        else
            print_error "Build failed. Please check your setup."
            return 1
        fi
    fi
}

# Main setup function
main() {
    # Parse command line arguments first
    parse_args "$@"
    
    # Check if we're in an empty-ish directory (safety check)
    if [[ -f "main.c" || -f "Makefile" || -f "CMakeLists.txt" ]]; then
        print_warning "This directory appears to contain a project already"
        prompt_yes_no "Continue anyway" "n" "CONTINUE"
        if [[ "$CONTINUE" != true ]]; then
            print_info "Setup cancelled. Consider running in an empty directory."
            exit 0
        fi
    fi
    
    if [[ "$QUICK_MODE" == true ]]; then
        quick_setup
    else
        clear
        echo -e "${BLUE}"
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║                   C Project Generator v${VERSION}                   ║"
        echo "║                                                              ║"
        echo "║  This script will help you set up a new C project with      ║"
        echo "║  a proper directory structure and build system.             ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo -e "${NC}\n"
        
        # Collect project information
        print_header "Project Configuration"
        
        # Project name validation loop
        while true; do
            prompt_with_default "Enter project name" "$DEFAULT_PROJECT_NAME" "PROJECT_NAME"
            if validate_project_name "$PROJECT_NAME"; then
                break
            fi
        done
        
        prompt_with_default "Enter author name" "$DEFAULT_AUTHOR" "AUTHOR"
        prompt_with_default "Enter author email" "$DEFAULT_EMAIL" "EMAIL"
        prompt_with_default "Enter project description" "A C project created with the boilerplate generator" "PROJECT_DESCRIPTION"
        
        # Build configuration
        print_header "Build Configuration"
        prompt_with_default "Preferred compiler" "$DEFAULT_COMPILER" "COMPILER"
        
        # C standard selection
        echo "Available C standards:"
        echo "  1) c99"
        echo "  2) c11 (recommended)"
        echo "  3) c17"
        echo "  4) c23"
        read -p "Select C standard [2]: " std_choice
        case ${std_choice:-2} in
            1) C_STANDARD="c99" ;;
            2) C_STANDARD="c11" ;;
            3) C_STANDARD="c17" ;;
            4) C_STANDARD="c23" ;;
            *) C_STANDARD="c11" ;;
        esac
        
        # Additional options
        print_header "Additional Options"
        prompt_yes_no "Include testing framework setup" "y" "INCLUDE_TESTS"
        prompt_yes_no "Include lib/ directory for dependencies" "n" "INCLUDE_LIB_DIR"
        prompt_yes_no "Include config/ directory" "n" "INCLUDE_CONFIG_DIR"
        prompt_yes_no "Initialize git repository" "y" "INIT_GIT"
        prompt_yes_no "Test build after setup" "y" "TEST_BUILD"
        
        # Summary
        print_header "Configuration Summary"
        echo "Project Name: $PROJECT_NAME"
        echo "Author: $AUTHOR <$EMAIL>"
        echo "Compiler: $COMPILER"
        echo "C Standard: $C_STANDARD"
        echo "Include Tests: $INCLUDE_TESTS"
        echo "Include lib/: $INCLUDE_LIB_DIR"
        echo "Include config/: $INCLUDE_CONFIG_DIR"
        echo "Initialize Git: $INIT_GIT"
        echo "Test Build: $TEST_BUILD"
        
        echo
        prompt_yes_no "Proceed with setup" "y" "PROCEED"
        
        if [[ "$PROCEED" != true ]]; then
            print_info "Setup cancelled."
            exit 0
        fi
    fi
    
    # Check dependencies
    check_dependencies
    
    # Create project
    create_project_structure
    generate_main_c
    generate_main_h
    generate_makefile
    generate_gitignore
    generate_readme
    generate_test_files
    create_gitkeep_files
    
    # Initialize git if requested
    init_git
    
    # Test build if requested
    test_build
    
    # Final message
    print_header "Setup Complete!"
    print_success "Your C project '$PROJECT_NAME' has been set up successfully!"
    echo
    print_info "Next steps:"
    echo "  1. Start coding in src/main.c"
    echo "  2. Add header files to include/"
    echo "  3. Build with: make debug (or make release)"
    echo "  4. Run with: make run"
    if [[ "$INCLUDE_TESTS" == true ]]; then
        echo "  5. Add tests in tests/src/ and run with: make test"
    fi
    echo
    print_info "Happy coding! 🚀"
}

# Run main function
main "$@"