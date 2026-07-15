exports.decorateConfig = (config) => {
  return Object.assign({}, config, {
    backgroundColor: '#1a2029',
    foregroundColor: '#e2e8f0',
    cursorColor: '#b8c5d4',
    selectionColor: '#e2e8f0',
    borderColor: '#1a2029',
    colors: {
      black: '#1a2029',
      red: '#ff6b7a',
      green: '#69dbaa',
      yellow: '#e5c07b',
      blue: '#7cb8ff',
      magenta: '#b794f4',
      cyan: '#38d2c8',
      white: '#e2e8f0',
      lightBlack: '#5a6577',
      lightRed: '#ff6b7a',
      lightGreen: '#69dbaa',
      lightYellow: '#e5c07b',
      lightBlue: '#7cb8ff',
      lightMagenta: '#b794f4',
      lightCyan: '#38d2c8',
      lightWhite: '#e2e8f0',
    }
  });
};
