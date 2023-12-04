
  window.SupportedLanguages.push({
    check: (r) => {return(r[0] === '.master')},
    plugins:  window.EditorMathematicaPlugins,
    legacy: true, 
    name: 'mathematica'
  });

  window.SupportedLanguages.push({
    check: (r) => {return(r[0].match(/\w+\.(wl|wls)$/) != null)},
    plugins:  window.EditorMathematicaPlugins,
    legacy: true, 
    name: 'mathematica'
  });

