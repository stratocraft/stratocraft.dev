#!/usr/bin/env bash

# Exit on error, undefined variable, or pipe failure
set -euo pipefail

# Script constants
SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
STYLE_FILE="$PROJECT_ROOT/public/css/style.css"
CONFIG_FILE="$PROJECT_ROOT/tailwind.config.js"

# Function to display usage information
usage() {
    echo "Usage: $SCRIPT_NAME"
    echo
    echo "Set up Tailwind CSS for the project."
    echo "This script should be run from the 'scripts' directory."
    echo "It installs Tailwind CSS, creates a configuration file,"
    echo "and sets up the necessary CSS file with Tailwind directives."
}

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

# Function to handle errors
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Check if we're in the scripts directory
if [[ "$(basename "$PWD")" != "scripts" ]]; then
    error_exit "This script must be run from the 'scripts' directory."
fi

# Check for npm installation
if ! command -v npm &>/dev/null; then
    error_exit "npm could not be found. Please install Node.js and npm first."
fi

# Change to the project root directory
cd "$PROJECT_ROOT" || error_exit "Failed to change to project root directory."

# Install Tailwind CSS as a development dependency
log "Installing Tailwind CSS..."
npm install -D tailwindcss || error_exit "Failed to install Tailwind CSS."

# Initialize Tailwind CSS configuration
log "Initializing Tailwind CSS configuration..."
npx tailwindcss init || error_exit "Failed to initialize Tailwind CSS configuration."

# Generate the Tailwind CSS configuration with custom settings
log "Generating Tailwind CSS configuration file..."
cat > "$CONFIG_FILE" << EOF || error_exit "Failed to create $CONFIG_FILE"
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./**/*.html",
    "./**/*.templ",
    "./**/*.go",
    "./static/js/**/*.js"
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
        },
        gray: {
          50: '#f9fafb',
          100: '#f3f4f6',
          200: '#e5e7eb',
          300: '#d1d5db',
          400: '#9ca3af',
          500: '#6b7280',
          600: '#4b5563',
          700: '#374151',
          800: '#1f2937',
          900: '#111827',
        }
      },
      fontFamily: {
        sans: [
          'Inter',
          '-apple-system',
          'BlinkMacSystemFont',
          '"Segoe UI"',
          'Roboto',
          '"Helvetica Neue"',
          'Arial',
          'sans-serif'
        ],
        mono: [
          '"Fira Code"',
          'Monaco',
          'Consolas',
          '"Liberation Mono"',
          '"Courier New"',
          'monospace'
        ]
      },
      typography: (theme) => ({
        DEFAULT: {
          css: {
            maxWidth: 'none',
            color: theme('colors.gray.700'),
            a: {
              color: theme('colors.blue.600'),
              textDecoration: 'underline',
              '&:hover': {
                color: theme('colors.blue.700'),
              },
            },
            'h1, h2, h3, h4': {
              color: theme('colors.gray.900'),
            },
            code: {
              color: theme('colors.gray.900'),
              backgroundColor: theme('colors.gray.100'),
              paddingLeft: theme('spacing.1'),
              paddingRight: theme('spacing.1'),
              paddingTop: theme('spacing.0.5'),
              paddingBottom: theme('spacing.0.5'),
              borderRadius: theme('borderRadius.sm'),
              fontWeight: theme('fontWeight.normal'),
            },
            'code::before': {
              content: '""',
            },
            'code::after': {
              content: '""',
            },
            pre: {
              backgroundColor: theme('colors.gray.900'),
              color: theme('colors.gray.100'),
            },
            'pre code': {
              backgroundColor: 'transparent',
              color: 'inherit',
            },
            blockquote: {
              borderLeftColor: theme('colors.blue.600'),
              color: theme('colors.gray.700'),
            },
          },
        },
        invert: {
          css: {
            color: theme('colors.gray.300'),
            a: {
              color: theme('colors.blue.400'),
              '&:hover': {
                color: theme('colors.blue.300'),
              },
            },
            'h1, h2, h3, h4': {
              color: theme('colors.gray.100'),
            },
            code: {
              color: theme('colors.gray.100'),
              backgroundColor: theme('colors.gray.800'),
            },
            blockquote: {
              borderLeftColor: theme('colors.blue.400'),
              color: theme('colors.gray.300'),
            },
          },
        },
      }),
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.5s ease-out',
        'slide-down': 'slideDown 0.5s ease-out',
        'bounce-gentle': 'bounceGentle 2s infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        slideDown: {
          '0%': { transform: 'translateY(-20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        bounceGentle: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-10px)' },
        },
      },
      spacing: {
        '72': '18rem',
        '84': '21rem',
        '96': '24rem',
      },
      maxWidth: {
        '8xl': '88rem',
        '9xl': '96rem',
      },
      screens: {
        'xs': '475px',
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    // Custom plugin for focus-visible
    function({ addUtilities }) {
      const newUtilities = {
        '.focus-visible': {
          '&:focus-visible': {
            outline: '2px solid theme("colors.blue.500")',
            'outline-offset': '2px',
          },
        },
      };
      addUtilities(newUtilities);
    },
  ],
};
EOF

# Check if the style.css file already exists
if [ -f "$STYLE_FILE" ]; then
    log "$STYLE_FILE exists. Appending Tailwind directives..."
    # Check if Tailwind directives already exist in the file
    if grep -q "@tailwind" "$STYLE_FILE"; then
        log "Tailwind directives already present in $STYLE_FILE. Skipping append."
    else
        # Append Tailwind directives to the style.css file
        cat << EOF >> "$STYLE_FILE" || error_exit "Failed to append to $STYLE_FILE"

@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
    fi
else
    log "Creating $STYLE_FILE with Tailwind directives..."
    # Create style.css file with Tailwind directives
    mkdir -p "$(dirname "$STYLE_FILE")" || error_exit "Failed to create directory for $STYLE_FILE"
    cat << EOF > "$STYLE_FILE" || error_exit "Failed to create $STYLE_FILE"
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
fi

log "✅ Tailwind CSS installation and configuration completed successfully."