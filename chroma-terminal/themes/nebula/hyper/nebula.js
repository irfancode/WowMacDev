exports.decorateConfig = (config) => {
  return Object.assign({}, config, {
    backgroundColor: '#1e1a28',
    foregroundColor: '#e8e0f0',
    cursorColor: '#c8bcd8',
    selectionColor: '#e8e0f0',
    borderColor: '#1e1a28',
    colors: {
      black: '#1e1a28',
      red: '#ff6b8a',
      green: '#7bc99d',
      yellow: '#e5c07b',
      blue: '#8a8aff',
      magenta: '#c792ea',
      cyan: '#6ec4c8',
      white: '#e8e0f0',
      lightBlack: '#5c5570',
      lightRed: '#ff6b8a',
      lightGreen: '#7bc99d',
      lightYellow: '#e5c07b',
      lightBlue: '#8a8aff',
      lightMagenta: '#c792ea',
      lightCyan: '#6ec4c8',
      lightWhite: '#e8e0f0',
    }
  });
};
