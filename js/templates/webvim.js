// This file was automatically generated from webvim.soy.
// Please don't edit this file by hand.

if (typeof webvim == 'undefined') { var webvim = {}; }


webvim.viewport = function(opt_data, opt_sb) {
  var output = opt_sb || new soy.StringBuilder();
  var iLimit3 = opt_data.rows;
  for (var i3 = 0; i3 < iLimit3; i3++) {
    output.append('<div id="', soy.$$escapeHtml(opt_data.idPrefix), '-line-', soy.$$escapeHtml(i3), '" class="line">');
    var jLimit9 = opt_data.columns;
    for (var j9 = 0; j9 < jLimit9; j9++) {
      output.append('<span id="', soy.$$escapeHtml(opt_data.idPrefix), '-character-', soy.$$escapeHtml(i3), '-', soy.$$escapeHtml(j9), '" class="char">&nbsp</span>');
    }
    output.append('</div>');
  }
  output.append('<span id="', soy.$$escapeHtml(opt_data.idPrefix), '-command-line">Test</span>');
  return opt_sb ? '' : output.toString();
};
