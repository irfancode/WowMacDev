exports.decorateConfig = (config) => {
  return Object.assign({}, config, {
    backgroundColor: '#1e2229',
    foregroundColor: '#dce3ed',
    cursorColor: '#bac5d1',
    selectionColor: '#dce3ed',
    borderColor: '#1e2229',
    colors: {
      black: '#1e2229',
      red: '#e06c75',
      green: '#7bc99d',
      yellow: '#d4a043',
      blue: '#7ab0d4',
      magenta: '#a990d4',
      cyan: '#6ec4c8',
      white: '#dce3ed',
      lightBlack: '#5d6675',
      lightRed: '#e06c75',
      lightGreen: '#7bc99d',
      lightYellow: '#d4a043',
      lightBlue: '#7ab0d4',
      lightMagenta: '#a990d4',
      lightCyan: '#6ec4c8',
      lightWhite: '#dce3ed',
    }
  });
};
