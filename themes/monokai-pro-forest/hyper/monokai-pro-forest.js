exports.decorateConfig = (config) => {
  return Object.assign({}, config, {
    backgroundColor: '#1e2822',
    foregroundColor: '#e8f0ea',
    cursorColor: '#bccfc4',
    selectionColor: '#e8f0ea',
    borderColor: '#1e2822',
    colors: {
      black: '#1e2822',
      red: '#e06c75',
      green: '#98c379',
      yellow: '#d4a043',
      blue: '#6cb6eb',
      magenta: '#b39df2',
      cyan: '#56c8a4',
      white: '#e8f0ea',
      lightBlack: '#5a6b60',
      lightRed: '#e06c75',
      lightGreen: '#98c379',
      lightYellow: '#d4a043',
      lightBlue: '#6cb6eb',
      lightMagenta: '#b39df2',
      lightCyan: '#56c8a4',
      lightWhite: '#e8f0ea',
    }
  });
};
