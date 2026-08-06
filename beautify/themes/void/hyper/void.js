exports.decorateConfig = (config) => {
  return Object.assign({}, config, {
    backgroundColor: '#161618',
    foregroundColor: '#ffffff',
    cursorColor: '#cccccc',
    selectionColor: '#ffffff',
    borderColor: '#161618',
    colors: {
      black: '#161618',
      red: '#ff5370',
      green: '#a9dc76',
      yellow: '#ffcb6b',
      blue: '#89ddff',
      magenta: '#c792ea',
      cyan: '#80cbc4',
      white: '#ffffff',
      lightBlack: '#5c5c62',
      lightRed: '#ff5370',
      lightGreen: '#a9dc76',
      lightYellow: '#ffcb6b',
      lightBlue: '#89ddff',
      lightMagenta: '#c792ea',
      lightCyan: '#80cbc4',
      lightWhite: '#ffffff',
    }
  });
};
