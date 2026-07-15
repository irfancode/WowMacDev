exports.decorateConfig = (config) => {
  return Object.assign({}, config, {
    backgroundColor: '#2d2a2e',
    foregroundColor: '#fcfcfa',
    cursorColor: '#c1c0c0',
    selectionColor: '#fcfcfa',
    borderColor: '#2d2a2e',
    colors: {
      black: '#2d2a2e',
      red: '#ff6188',
      green: '#a9dc76',
      yellow: '#ffd866',
      blue: '#fc9867',
      magenta: '#ab9df2',
      cyan: '#78dce8',
      white: '#fcfcfa',
      lightBlack: '#727072',
      lightRed: '#ff6188',
      lightGreen: '#a9dc76',
      lightYellow: '#ffd866',
      lightBlue: '#fc9867',
      lightMagenta: '#ab9df2',
      lightCyan: '#78dce8',
      lightWhite: '#fcfcfa',
    }
  });
};
