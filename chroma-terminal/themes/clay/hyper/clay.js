exports.decorateConfig = (config) => {
  return Object.assign({}, config, {
    backgroundColor: '#241e1a',
    foregroundColor: '#ede0d4',
    cursorColor: '#cdc0b4',
    selectionColor: '#ede0d4',
    borderColor: '#241e1a',
    colors: {
      black: '#241e1a',
      red: '#d46a5a',
      green: '#a3b88a',
      yellow: '#e0b97c',
      blue: '#c2855a',
      magenta: '#b89ab3',
      cyan: '#7ab8a0',
      white: '#ede0d4',
      lightBlack: '#665a50',
      lightRed: '#d46a5a',
      lightGreen: '#a3b88a',
      lightYellow: '#e0b97c',
      lightBlue: '#c2855a',
      lightMagenta: '#b89ab3',
      lightCyan: '#7ab8a0',
      lightWhite: '#ede0d4',
    }
  });
};
