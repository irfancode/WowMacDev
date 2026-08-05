exports.decorateConfig = (config) => {
  return Object.assign({}, config, {
    backgroundColor: '#1e2630',
    foregroundColor: '#e8eff5',
    cursorColor: '#bccbd8',
    selectionColor: '#e8eff5',
    borderColor: '#1e2630',
    colors: {
      black: '#1e2630',
      red: '#ff6b7a',
      green: '#7bc99d',
      yellow: '#e5c07b',
      blue: '#6cb6eb',
      magenta: '#ab9df2',
      cyan: '#56d4dd',
      white: '#e8eff5',
      lightBlack: '#5b6a7a',
      lightRed: '#ff6b7a',
      lightGreen: '#7bc99d',
      lightYellow: '#e5c07b',
      lightBlue: '#6cb6eb',
      lightMagenta: '#ab9df2',
      lightCyan: '#56d4dd',
      lightWhite: '#e8eff5',
    }
  });
};
