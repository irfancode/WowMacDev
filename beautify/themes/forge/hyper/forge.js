exports.decorateConfig = (config) => {
  return Object.assign({}, config, {
    backgroundColor: '#221a17',
    foregroundColor: '#f0e6dc',
    cursorColor: '#d0c6bc',
    selectionColor: '#f0e6dc',
    borderColor: '#221a17',
    colors: {
      black: '#221a17',
      red: '#e06c5a',
      green: '#c4a86a',
      yellow: '#e0b04a',
      blue: '#d48a5a',
      magenta: '#c09ab3',
      cyan: '#6ab8a0',
      white: '#f0e6dc',
      lightBlack: '#635548',
      lightRed: '#e06c5a',
      lightGreen: '#c4a86a',
      lightYellow: '#e0b04a',
      lightBlue: '#d48a5a',
      lightMagenta: '#c09ab3',
      lightCyan: '#6ab8a0',
      lightWhite: '#f0e6dc',
    }
  });
};
