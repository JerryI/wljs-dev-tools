
  window.SupportedLanguages.push({
    check: (r) => {return(r[0] === '.master')},
    plugins:  window.EditorMathematicaPlugins,
    legacy: true, 
    name: 'mathematica'
  });

