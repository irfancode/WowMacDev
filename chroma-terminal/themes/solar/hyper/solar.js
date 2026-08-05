exports.decorateConfig = (config) => {
  return Object.assign({}, config, {
    backgroundColor: '#2b2820',
    foregroundColor: '#faf6eb',
    cursorColor: '#c4bfb0',
    selectionColor: '#faf6eb',
    borderColor: '#2b2820',
    colors: {
      black: '#2b2820',
      red: '#ff6b5c',
      green: '#e5c07b',
      yellow: '#ffd700',
      blue: '#d4a043',
      magenta: '#c9a0dc',
      cyan: '#7bc8a4',
      white: '#faf6eb',
      lightBlack: '#6b6655',
      lightRed: '#ff6b5c',
      lightGreen: '#e5c07b',
      lightYellow: '#ffd700',
      lightBlue: '#d4a043',
      lightMagenta: '#c9a0dc',
      lightCyan: '#7bc8a4',
      lightWhite: '#faf6eb',
    }
  });
};
