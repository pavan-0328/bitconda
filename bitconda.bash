#!/bin/bash
ENV_DIR=$HOME/bitconda
# Function to check and install Python 3 and venv if not already installed
check_python_and_venv() {
    if ! command -v python3 &>/dev/null; then
        echo "Python 3 is not installed. Installing Python 3..."
        # Installation command depends on the system's package manager
        if command -v apt-get &>/dev/null; then
            sudo apt-get update
            sudo apt-get install -y python3
        elif command -v yum &>/dev/null; then
            sudo yum install -y python3
        else
            echo "Unable to install Python 3. Please install it manually."
            exit 1
        fi

        if ! command -v python3 &>/dev/null; then
            echo "Installation of Python 3 failed. Please install it manually."
            exit 1
        fi
        echo "Python 3 installed successfully."
    else
        echo "Python 3 is already installed."
    fi

    # Check if venv module is installed
    if python3 -c 'import venv' &>/dev/null; then
        echo "venv module is already installed."
    else
        echo "venv module is not installed. Installing venv..."
        python3 -m ensurepip --upgrade  # Ensure pip is installed
        python3 -m pip install --upgrade pip
        python3 -m pip install --upgrade virtualenv
        echo "venv module installed successfully."
    fi
}

# Function to create a new environment
create_env() {
    ENV_NAME=$1
    PYTHON_VERSION=$2
    if [ -z "$ENV_NAME" ]; then
        echo "Please provide an environment name."
        return 1
    fi

    if [ -z "$PYTHON_VERSION" ]; then
        PYTHON_VERSION="3.8.12"  # Default Python version
    fi

    
    ENV_PATH=$ENV_DIR/$ENV_NAME

    if [ -d "$ENV_PATH" ]; then
        echo "Environment $ENV_NAME already exists."
    else
        mkdir -p $ENV_PATH
        python3 -m venv $ENV_PATH
        echo "Environment $ENV_NAME with Python $PYTHON_VERSION created."
    fi
}


# Function to activate an environment
activate_env() {
    ENV_NAME=$1
    if [ -z "$ENV_NAME" ]; then
        echo "Please provide an environment name."
        return 1
    fi

    ENV_PATH=$ENV_DIR/$ENV_NAME
   if [ -d "$ENV_PATH" ]; then
        # Check if activate script exists and is executable
        if [ -f "$ENV_PATH/bin/activate" ]; then
            echo "Activating environment $ENV_NAME..."

            # Execute the activate script in a subshell to avoid environment variable contamination
            
            source $ENV_PATH/bin/activate
            echo "Environment $ENV_NAME activated."
            return
           
        else
            echo "Activation script not found for environment $ENV_NAME."
        fi
    else
        echo "Environment $ENV_NAME does not exist."
    fi
    
}
# Function to remove an environment
remove_env() {
    ENV_NAME=$1
    if [ -z "$ENV_NAME" ]; then
        echo "Please provide an environment name."
        return 1
    fi


    ENV_PATH=$ENV_DIR/$ENV_NAME

    if [ -d "$ENV_PATH" ]; then
        rm -rf $ENV_PATH
        echo "Environment $ENV_NAME removed."
    else
        echo "Environment $ENV_NAME does not exist."
    fi
}

# Function to install required libraries if not present


# Check for user input
check_python_and_venv

case $1 in
    create)
        create_env $2 $3
        ;;
    activate)
        activate_env $2
        ;;
    remove)
        remove_env $2
        ;;
    *)
        echo "Usage: $0 {create|activate|remove} [env_name] [python_version]"
        ;;
esac
