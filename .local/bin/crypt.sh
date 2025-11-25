#!/bin/bash

# File encryption/decryption tool using openssl and gum
# Usage: ./crypt.sh [options] [file_path]
# Options: -e (encrypt), -d (decrypt)

set -e  # Exit on any error

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo "Error: 'gum' is not installed. Please install it first."
    echo "Visit: https://github.com/charmbracelet/gum#installation"
    exit 1
fi

# Check if openssl is installed
if ! command -v openssl &> /dev/null; then
    echo "Error: 'openssl' is not installed. Please install it first."
    exit 1
fi

# Initialize variables
ACTION=""
FILE_PATH=""
FORCE_ACTION=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--encrypt)
            ACTION="encrypt"
            FORCE_ACTION=true
            shift
            ;;
        -d|--decrypt)
            ACTION="decrypt"
            FORCE_ACTION=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options] [file_path]"
            echo "Options:"
            echo "  -e, --encrypt    Encrypt the target file"
            echo "  -d, --decrypt    Decrypt the target file"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "If no file path is provided, you'll be prompted to enter one."
            echo "If no action flag is provided, you'll be prompted to choose."
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
        *)
            FILE_PATH="$1"
            shift
            ;;
    esac
done

# Get file path if not provided
if [[ -z "$FILE_PATH" ]]; then
    FILE_PATH=$(gum input --placeholder "Enter file path...")
    if [[ -z "$FILE_PATH" ]]; then
        echo "No file path provided. Exiting."
        exit 1
    fi
fi

# Check if file exists
if [[ ! -f "$FILE_PATH" ]]; then
    echo "Error: File '$FILE_PATH' does not exist."
    exit 1
fi

# Determine action if not forced by flag
if [[ "$FORCE_ACTION" == false ]]; then
    ACTION=$(gum choose "encrypt" "decrypt")
fi

# Get password
echo "Enter password for $ACTION:"
PASSWORD=$(gum input --password)
if [[ -z "$PASSWORD" ]]; then
    echo "No password provided. Exiting."
    exit 1
fi

# Perform the action
case "$ACTION" in
    encrypt)
        OUTPUT_FILE="${FILE_PATH}.enc"
        if [[ -f "$OUTPUT_FILE" ]]; then
            OVERWRITE=$(gum confirm "File '$OUTPUT_FILE' already exists. Overwrite?" && echo "yes" || echo "no")
            if [[ "$OVERWRITE" == "no" ]]; then
                echo "Operation cancelled."
                exit 0
            fi
        fi

        echo "Encrypting '$FILE_PATH'..."
        if openssl enc -aes-256-cbc -salt -pbkdf2 -in "$FILE_PATH" -out "$OUTPUT_FILE" -pass pass:"$PASSWORD"; then
            echo "✅ File encrypted successfully: $OUTPUT_FILE"

            # Ask if user wants to delete original file
            DELETE_ORIGINAL=$(gum confirm "Delete original file '$FILE_PATH'?" && echo "yes" || echo "no")
            if [[ "$DELETE_ORIGINAL" == "yes" ]]; then
                rm "$FILE_PATH"
                echo "🗑️  Original file deleted."
            fi
        else
            echo "❌ Encryption failed."
            exit 1
        fi
        ;;

    decrypt)
        # Check if file has .enc extension
        if [[ "$FILE_PATH" == *.enc ]]; then
            OUTPUT_FILE="${FILE_PATH%.enc}"
        else
            OUTPUT_FILE="${FILE_PATH}.dec"
        fi

        if [[ -f "$OUTPUT_FILE" ]]; then
            OVERWRITE=$(gum confirm "File '$OUTPUT_FILE' already exists. Overwrite?" && echo "yes" || echo "no")
            if [[ "$OVERWRITE" == "no" ]]; then
                echo "Operation cancelled."
                exit 0
            fi
        fi

        echo "Decrypting '$FILE_PATH'..."
        if openssl enc -d -aes-256-cbc -pbkdf2 -in "$FILE_PATH" -out "$OUTPUT_FILE" -pass pass:"$PASSWORD"; then
            echo "✅ File decrypted successfully: $OUTPUT_FILE"

            # Ask if user wants to delete encrypted file
            DELETE_ENCRYPTED=$(gum confirm "Delete encrypted file '$FILE_PATH'?" && echo "yes" || echo "no")
            if [[ "$DELETE_ENCRYPTED" == "yes" ]]; then
                rm "$FILE_PATH"
                echo "🗑️  Encrypted file deleted."
            fi
        else
            echo "❌ Decryption failed. Check your password."
            exit 1
        fi
        ;;

    *)
        echo "Invalid action: $ACTION"
        exit 1
        ;;
esac

echo "Operation completed successfully! 🎉"
