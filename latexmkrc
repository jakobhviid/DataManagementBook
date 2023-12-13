$pdf_mode = 1; # Set to 1 to use pdflatex

$lualatex = 'lualatex -shell-escape';
$pdflatex = 'pdflatex -shell-escape';
@default_files = ('book.tex');

ensure_path( 'TEXINPUTS', './modernthesis/' );

# Run makeglossaries
add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');

sub run_makeglossaries {
  if ( $silent ) {
    system "makeglossaries", "-q", $_[0];
  }
  else {
    system "makeglossaries", $_[0];
  };
}

# Add generated files from glossaries
push @generated_exts, 'glo', 'gls', 'glg';
push @generated_exts, 'acn', 'acr', 'alg';
$clean_ext .= ' %R.ist %R.xdy';


# Add generated files for biblatex to clean extensions
push @generated_exts, 'oai';
$clean_ext .= ' %R.bbl';

# Add generated files to clean extensions
$clean_ext .= ' %R.run.xml %R.synctex.gz';

# Add generated files for custom floats to clean extensions
$clean_ext .= ' %R.lol';
