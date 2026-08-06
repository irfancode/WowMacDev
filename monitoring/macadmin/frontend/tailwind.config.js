/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // macOS Tahoe/Sequoia Colors
        'macos': {
          // Backgrounds
          'window': '#F5F5F7',
          'sidebar': '#E8E8ED',
          'content': '#FFFFFF',
          'popover': '#FFFFFF',
          
          // Text
          'primary': '#000000',
          'secondary': '#6E6E73',
          'tertiary': '#9E9E9E',
          'quaternary': '#C7C7CC',
          
          // Accents (Dynamic - matches system accent)
          'accent': {
            DEFAULT: '#007AFF',
            'blue': '#007AFF',
            'purple': '#AF52DE',
            'pink': '#FF2D55',
            'red': '#FF3B30',
            'orange': '#FF9500',
            'yellow': '#FFCC00',
            'green': '#34C759',
            'teal': '#5AC8FA',
            'indigo': '#5856D6',
            'gray': '#8E8E93',
          },
          
          // System colors
          'success': '#34C759',
          'warning': '#FF9500',
          'error': '#FF3B30',
          'info': '#007AFF',
          
          // Dark mode
          'dark': {
            'window': '#1C1C1E',
            'sidebar': '#2C2C2E',
            'content': '#1C1C1E',
            'popover': '#2C2C2E',
            'primary': '#FFFFFF',
            'secondary': '#98989D',
            'tertiary': '#636366',
            'quaternary': '#48484A',
          },
          
          // Glass effect
          'glass': {
            'light': 'rgba(255, 255, 255, 0.72)',
            'dark': 'rgba(30, 30, 30, 0.72)',
            'border': 'rgba(255, 255, 255, 0.2)',
          }
        }
      },
      fontFamily: {
        sans: ['-apple-system', 'BlinkMacSystemFont', 'SF Pro Display', 'Segoe UI', 'Roboto', 'sans-serif'],
        mono: ['SF Mono', 'Monaco', 'Consolas', 'monospace'],
      },
      borderRadius: {
        'macos': '10px',
        'macos-lg': '20px',
        'macos-xl': '28px',
      },
      boxShadow: {
        'macos': '0 22px 70px 4px rgba(0, 0, 0, 0.1)',
        'macos-window': '0 0 1px rgba(0, 0, 0, 0.4), 0 22px 70px 4px rgba(0, 0, 0, 0.15)',
        'macos-button': '0 1px 2px rgba(0, 0, 0, 0.1)',
      },
      backdropBlur: {
        'macos': '20px',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'bounce-subtle': 'bounceSubtle 0.2s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        bounceSubtle: {
          '0%': { transform: 'scale(0.95)' },
          '50%': { transform: 'scale(1.02)' },
          '100%': { transform: 'scale(1)' },
        },
      },
    },
  },
  plugins: [],
}
