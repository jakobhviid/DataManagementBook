\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{modernthesis}[2019/03/14 Modern Thesis]

\newcommand\modernthesistemplatename{\texttt{modernthesis}}

\LoadClass{scrbook}

\RequirePackage{etoolbox}
\newtoggle{c5}
\newtoggle{separatebibliography}

\RequirePackage{ifluatex}


%%%%%%%%%%%%%%%%%%%%%%%%
% Options
%%%%%%%%%%%%%%%%%%%%%%%%

% 'patch' options is necessary to handle options enclosed by braces
\RequirePackage[patch]{kvoptions}
\RequirePackage{expl3}

% Passing long options (i.e., containing spaces, like the title) as class
% options breaks some packages, therefore, it is necessary to use a "setup"
% macro.
% After loading the class with \documentclass{modernthesis}, the following
% macro handles the rest of the configuration.
\newcommand*{\modernthesissetup}[1]{
    % First populate the key/value namespace
    \setkeys{modernthesis}{#1}

    % Then read paper size
    \ifmodernthesis@cfivepaper
        \toggletrue{c5}
        \newcommand{\modernthesis@paper}{C5}
        \newcommand{\modernthesis@DIV}{calc}
    \else
        \togglefalse{c5}
        \newcommand{\modernthesis@paper}{A4}
        \newcommand{\modernthesis@DIV}{14}
    \fi

    % Then configure the parent class
    \KOMAoptions{
        fontsize=11pt, %original 12pt
        twoside,
        paper=\modernthesis@paper,
        pagesize=luatex,
        DIV=\modernthesis@DIV,
        BCOR=\modernthesis@BCOR,
        chapterprefix=false,
        numbers=noenddot,
        captions=tableheading,
        headinclude=true,
        % headheight=1.5cm,
        % footheight=0.5cm,
    }
    % \recalctypearea


    % Then set up document metadata
    \title{\modernthesis@title}
    \subtitle{\modernthesis@subtitle}
    \author{\modernthesis@author}
    \date{\modernthesis@month \modernthesis@year}

    % Define macros to print glossary and acronyms list
    % These macro do nothing unless 'glossary' or 'acronym' options were passed
    \newcommand{\modernthesisprintglossary}{%
        \ifmodernthesis@glossary
            \cleardoublepage\printglossary[type=main]
            \addcontentsline{toc}{chapter}{Glossary}
        \else
            % do nothing
        \fi
    }

    \newcommand{\modernthesisprintacronyms}{%
        \ifmodernthesis@acronyms
            \cleardoublepage\printglossary[type=\acronymtype, nonumberlist]
            \addcontentsline{toc}{chapter}{Acronyms}
        \else
            % do nothing
        \fi
    }

    % Set up PDF file metadata
    \hypersetup{
        pdftitle={\modernthesis@title},
        pdfauthor={\modernthesis@author},
    }

    % Exports main and co-author publications as macro
    \newcommand{\modernthesismainauthorpublications}{\modernthesis@mainauthorpublications}
    \newcommand{\modernthesiscoauthorpublications}{\modernthesis@coauthorpublications}

    % Optionally, load package to query Unpaywall API
    \ifmodernthesis@doiapi
        \ExecuteBibliographyOptions{openaccess=doiapi}
        \SetDOIAPIMail{\modernthesis@email}
    \fi

    % Enable bibliographies in each paper
    \ifmodernthesis@separatebibliography
        \toggletrue{separatebibliography}
    \else
        \togglefalse{separatebibliography}
    \fi

    % Setup automatic landscape orientation for marked sideways floats
    \ifmodernthesis@rotatesidewaysfloats
        \newcommand\rotatesidewayslabel{%
            \stepcounter{cntsideways}%
            \zlabel{tmp\thecntsideways}%
            \zlabel{rotate\zref@extractdefault{tmp\thecntsideways}{page}{0}}%
        }
    \else
        \newcommand\rotatesidewayslabel{}%
    \fi

    % Highlight annotated authors in bibliography
    %
    % Authors should be annotated in the .bib file, like this:
    % @article{
    %   author = {Surname1, Name1 and Surname2, Name2},
    %   author+an = {2=highlight},
    % }
    \ifmodernthesis@highlightannotatedauthors
        \renewcommand*{\mkbibnamegiven}[1]{%
            \ifitemannotation{highlight}
            {\textbf{##1}}
            {##1}}
        \renewcommand*{\mkbibnamefamily}[1]{%
            \ifitemannotation{highlight}
            {\textbf{##1}}
            {##1}}
    \fi

    % Define colours
    \ifmodernthesis@blackwhite
        \definecolor{CiteColor}{HTML}{000000}
        \definecolor{UrlColor}{HTML}{000000}
        \definecolor{ChapterColor}{HTML}{000000}
        \definecolor{FancyRed}{HTML}{000000}
        \definecolor{FancyBlue}{HTML}{000000}
        \definecolor{FancyGreen}{HTML}{000000}
        \definecolor{FancyPurple}{HTML}{000000}
        \definecolor{FancyOrange}{HTML}{000000}
        \definecolor{OrcidGreen}{HTML}{000000}
        \definecolor{LinkedinBlue}{HTML}{000000}
        \definecolor{GoogleBlue}{HTML}{000000}
        \definecolor{OpenAccessOrange}{HTML}{000000}
    \else
        \definecolor{CiteColor}{RGB}{33,113,181}
        \definecolor{UrlColor}{RGB}{33,113,181}
        \definecolor{ChapterColor}{RGB}{67,107,149}
        \definecolor{FancyRed}{RGB}{228,26,28}
        \definecolor{FancyBlue}{RGB}{55,126,184}
        \definecolor{FancyGreen}{RGB}{77,175,74}
        \definecolor{FancyPurple}{RGB}{152,78,163}
        \definecolor{FancyOrange}{RGB}{255,127,0}
        \definecolor{OrcidGreen}{HTML}{A6CE39}
        \definecolor{LinkedinBlue}{HTML}{0077B5}
        \definecolor{GoogleBlue}{HTML}{4285F4}
        \definecolor{OpenAccessOrange}{HTML}{f68212}
    \fi

    % Highlight pubstate
    \ifmodernthesis@highlightpubstate
        \xpretofieldformat{pubstate}{\bfseries}{}{}
    \fi

    % Highlight underfull boxes in the document
    \ifmodernthesis@highlightunderfullvboxes
        \directlua{dofile(kpse.find_file("DetectUnderfull.lua"))}
    \fi

    \ifluatex
        \ifmodernthesis@showopenaccess
            % The following code checks which entries are open access, and adds the
            % corresponding symbol to the bibliography

            \RequirePackage[doiapi=true,tikzsymbol=false]{biblatex-ext-oa}

            % By default, read Open Access information from the .bib file
            % If option 'doiapi' was specified, an online service will be queried.
            \ExecuteBibliographyOptions{openaccess=auto}

            % Define Open Access symbol
            \newcommand\oasymbol{\textcolor{OpenAccessOrange}{\aiOpenAccess}}

            % Define eprint open access status for EU documents
            \DeclareOpenAccessEprintUrl[always]{eudirective}{%
            http://eur-lex.europa.eu/eli/dir/\thefield{eprint}/oj}
            \DeclareOpenAccessEprintAlias{EUDIRECTIVE}{eudirective}

            \DeclareOpenAccessEprintUrl[always]{euregulation}{%
            http://eur-lex.europa.eu/eli/reg/\thefield{eprint}/oj}
            \DeclareOpenAccessEprintAlias{EUREGULATION}{euregulation}

            \DeclareOpenAccessEprintUrl[always]{eudocument}{%
            http://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:\thefield{eprint}}
            \DeclareOpenAccessEprintAlias{EUDOCUMENT}{eudocument}
        \fi
    \fi
}

%%%%%%%%%%%%%% End of setup command %%%%%%%%%%%%%%

% Set up namespace and options
\SetupKeyvalOptions{
    family=modernthesis,
    prefix=modernthesis@
}
\DeclareStringOption[Thesis Title]{title}
\DeclareStringOption[Thesis Subtitle]{subtitle}
\DeclareStringOption[Author's Name]{author}
\DeclareStringOption[]{email}
\DeclareStringOption[2]{month}
\DeclareStringOption[2019]{year}
\DeclareStringOption[Ponder Stibbons (chair), UU, Head of Inadvisably Applied Magic]{firstcommittee}
\DeclareStringOption[Rincewind, UU, Egregious Professor of Cruel and Unusual Geography]{secondcommittee}
\DeclareStringOption[Ipslore the Red]{thirdcommittee}
\DeclareStringOption[Mustrum Ridcully, UU, Archchancellor]{principalsupervisor}
\DeclareStringOption[Horace Worblehat, UU, Librarian]{cosupervisor}
\DeclareStringOption[]{center}
\DeclareStringOption[Department of L-Space Studies]{department}
\DeclareStringOption[Magical Faculty]{faculty}
\DeclareStringOption[Unseen University]{university}
\DeclareStringOption[the author]{printer}
\DeclareStringOption{version}
\DeclareStringOption{linkedin}
\DeclareStringOption{orcid}
\DeclareStringOption{googlescholar}
\DeclareStringOption{researcherid}
\DeclareStringOption{additionalcolophon}

\DeclareStringOption{mainauthorpublications}
\DeclareStringOption{coauthorpublications}

\DeclareStringOption[0cm]{BCOR}

\DeclareBoolOption{glossary}
\DeclareComplementaryOption{noglossary}{glossary}
\DeclareBoolOption{acronyms}
\DeclareComplementaryOption{noacronyms}{acronyms}
\DeclareBoolOption{doiapi}
\DeclareComplementaryOption{nodoiapi}{doiapi}
\DeclareBoolOption{cfivepaper}
\DeclareComplementaryOption{nocfivepaper}{cfivepaper}
\DeclareBoolOption{separatebibliography}
\DeclareComplementaryOption{noseparatebibliography}{separatebibliography}
\DeclareBoolOption{highlightannotatedauthors}
\DeclareComplementaryOption{nohighlightannotatedauthors}{highlightannotatedauthors}
\DeclareBoolOption{showprinter}
\DeclareComplementaryOption{noshowprinter}{showprinter}
\DeclareBoolOption{rotatesidewaysfloats}
\DeclareComplementaryOption{norotatesidewaysfloats}{rotatesidewaysfloats}
\DeclareBoolOption{blackwhite}
\DeclareComplementaryOption{noblackwhite}{blackwhite}
\DeclareBoolOption{highlightpubstate}
\DeclareComplementaryOption{nohighlightpubstate}{highlightpubstate}
\DeclareBoolOption{highlightunderfullvboxes}
\DeclareComplementaryOption{nohighlightunderfullvboxes}{highlightunderfullvboxes}
\DeclareBoolOption{showopenaccess}
\DeclareComplementaryOption{noshowopenaccess}{showopenaccess}

\ProcessKeyvalOptions*




%%%%%%%%%%%%%%%%%%%%%%%%
% Quality
%%%%%%%%%%%%%%%%%%%%%%%%

% nag will raise warnings when using obsolete Latex idioms
\RequirePackage[l2tabu]{nag}




%%%%%%%%%%%%%%%%%%%%%%%%
% Fonts
%%%%%%%%%%%%%%%%%%%%%%%%

\ifluatex

    % amsmath must be loaded before unicode-math
    \RequirePackage{amsmath}

    \RequirePackage{fontspec}
    \RequirePackage{unicode-math}

    \defaultfontfeatures{Ligatures={TeX}}

    \newcommand{\modernthesis@mainfontname}{TeX Gyre Pagella}
    \setmainfont{TeX Gyre Pagella}[
        Extension      = .otf,
        % Path           = ./fonts/,
        UprightFont    = texgyrepagella-regular,
        BoldFont       = texgyrepagella-bold,
        ItalicFont     = texgyrepagella-italic,
        BoldItalicFont = texgyrepagella-bolditalic
    ]

    \newcommand{\modernthesis@scriptfontname}{TeX Gyre Chorus}
    \newfontfamily{\scriptfamily}{TeX Gyre Chorus}[
        Extension      = .otf,
        % Path           = ./fonts/,
        UprightFont     = texgyrechorus-mediumitalic
    ]

    \newcommand{\modernthesis@monofontname}{Hasklig}
    \setmonofont[Contextuals={Alternate}]{Hasklig}[
        Extension      = .otf,
        % Path           = ./fonts/,
        UprightFont    = *-Regular,
        BoldFont       = *-Bold,
        ItalicFont     = *-It,
        BoldItalicFont = *-BoldIt
    ]

    \newcommand{\modernthesis@sansfontname}{CABIN}
    \setsansfont{Cabin}[
        Extension      = .ttf,
        % Path           = ./fonts/,
        UprightFont    = *-Regular,
        BoldFont       = *-Bold,
        ItalicFont     = *-Italic,
        BoldItalicFont = *-BoldItalic
    ]

    \setmathfont{texgyrepagella-math}[
        Extension      = .otf,
        % Path           = ./fonts/,
    ]
    % % The following is necessary for command \boldmath
    % \setmathfont[range=\mathup,
    %     BoldFont=texgyrepagella-bold,
    %     BoldItalicFont=texgyrepagella-bolditalic]
    %     {TeX Gyre Pagella}
    % \setmathfont[range=\mathit,
    %     BoldFont=texgyrepagella-bolditalic]
    %     {TeX Gyre Pagella Italic}
    % \setmathfont[range=\mathbfup]{texgyrepagella-bold}
    % \setmathfont[range=\mathbfit]{texgyrepagella-bolditalic}

    % Fix a microtype bug in the frozen release of TeXLive 2018
    \RequirePackage{luatexbase}

\else % Not LuaLaTeX
    \PackageWarning{modernthesis}{Using T1 fonts with pdflatex. Check that non-ASCII characters are correctly typeset, or switch to lualatex}

    \RequirePackage{cabin}
    \RequirePackage{tgchorus}
    \RequirePackage{lmodern}
    \RequirePackage{tgpagella}

    \newcommand{\scriptfamily}{\fontfamily{qzc}\selectfont} % TeX Gyre Chorus

    \newcommand{\modernthesis@mainfontname}{TeX Gyre Pagella}
    \newcommand{\modernthesis@scriptfontname}{TeX Gyre Chorus}
    \newcommand{\modernthesis@monofontname}{Inconsolata}
    \newcommand{\modernthesis@sansfontname}{CABIN}
\fi

% Microtype to fix all the small things (kerning, space...)
\RequirePackage{microtype}




%%%%%%%%%%%%%%%%%%%%%%%%
% Colors
%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{xcolor}




%%%%%%%%%%%%%%%%%%%%%%%%
% Language
%%%%%%%%%%%%%%%%%%%%%%%%

% The last language is the default one
\RequirePackage[danish,main=british]{babel}

\selectlanguage{british}




%%%%%%%%%%%%%%%%%%%%%%%%
% Hyperref
%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[
    unicode=true,
    bookmarks=true,
    bookmarksnumbered=false,
    bookmarksopen=false,
    breaklinks=true,
    pdfborder={0 0 0},
    pdfborderstyle={},
    colorlinks=true,
    linkcolor=black,
    citecolor=CiteColor,
    urlcolor=UrlColor,
]{hyperref}




%%%%%%%%%%%%%%%%%%%%%%%%
% Bibliography
%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[
    isbn=true,
    doi=true,
    url=true,
    maxcitenames=1,  % Print exactly one name in inline citations
    mincitenames=1,
    maxbibnames=99,  % Print all names in the bibliography
    sorting=none,  % This sorts by citation order
    backref=true,
    date=comp,
    urldate=comp,
    citestyle=numeric,
    bibstyle=numeric,
    autolang=other,
    block=ragged,
]{biblatex}

% Enable URLs breaking at any point
\setcounter{biburllcpenalty}{8000}
\setcounter{biburlucpenalty}{8000}
\setcounter{biburlnumpenalty}{8000}

% Enable a bit extra spacing to avoid overfull boxes
\appto{\bibsetup}{\emergencystretch=1em}

% Declare two secondary categories, main author and co-author,
% and add references to them
\DeclareBibliographyCategory{mainauthor}
\DeclareBibliographyCategory{coauthor}

\ExplSyntaxOn
\clist_map_inline:nn{\modernthesis@mainauthorpublications}
{
    \addtocategory{mainauthor}{#1}
}

\clist_map_inline:nn{\modernthesis@coauthorpublications}
{
    \addtocategory{coauthor}{#1}
}
\ExplSyntaxOff


% Define helpful macros to cite in various formats

% Replicate the entire citation from bibliography
\DeclareCiteCommand{\longfullcite}
    {\usebibmacro{prenote}}
    {\usedriver
        {\c@maxnames\blx@maxbibnames\relax
          \DeclareNameAlias{sortname}{default}}
        {\thefield{entrytype}}}
    {\multicitedelim}
    {\usebibmacro{postnote}}

% Print all authors (up to 99, actually)
\DeclareCiteCommand{\citeallauthors}%
{\usebibmacro{prenote}}% prenote
{\defcounter{maxnames}{99}\printnames{author}}
{\multicitedelim}% sepcode
{\usebibmacro{postnote}}

% Print the journal name
\DeclareCiteCommand{\citejournal}
    {\usebibmacro{prenote}}
    {\usebibmacro{citeindex}%
        \usebibmacro{journal}}
    {\multicitedelim}
    {\usebibmacro{postnote}}

% Print the book title (or conference name)
\DeclareCiteCommand{\citebooktitle}
    {\usebibmacro{prenote}}
    {\usebibmacro{citeindex}%
        \usebibmacro{booktitle}}
    {\multicitedelim}
    {\usebibmacro{postnote}}


% The following code filters fields from bibliography entries

% Remove ISBN if DOI is defined
\DeclareSourcemap{
    \maps[datatype=bibtex]{
        \map{
            \step[fieldsource=doi,final]
            \step[fieldset=isbn,null]
        }
    }
}
% Remove URL if DOI is defined
\DeclareSourcemap{
    \maps[datatype=bibtex]{
        \map{
            \step[fieldsource=doi,final]
            \step[fieldset=url,null]
        }
    }
}
% Remove URL if eprint is defined
\DeclareSourcemap{
    \maps[datatype=bibtex]{
        \map{
            \step[fieldsource=eprint,final]
            \step[fieldset=url,null]
        }
    }
}

% Disable back references.
% Back references will not be printed in bibliographies through the text.
% Enable before the last bibliography with
% \AtNextBibliography{\restorebibmacro{pageref}}
\savebibmacro{pageref}
\renewbibmacro*{pageref}{}


% Define eprint types for EU documents
% EU Directives
\newcommand*{\eudirectiveurl}[1]{http://eur-lex.europa.eu/eli/dir/#1/oj}
\DeclareFieldFormat{eprint:eudirective}{%
    \ifhyperref
        {\textsc{eu directive}:~\href{\eudirectiveurl{#1}}{#1}}
        {\textsc{eu directive}:~#1}}
\DeclareFieldAlias{eprint:EUDIRECTIVE}{eprint:eudirective}

% EU Regulations
\newcommand*{\euregulationurl}[1]{http://eur-lex.europa.eu/eli/reg/#1/oj}
\DeclareFieldFormat{eprint:euregulation}{%
    \ifhyperref
        {\textsc{eu regulation}:~\href{\euregulationurl{#1}}{#1}}
        {\textsc{eu regulation}:~#1}}
\DeclareFieldAlias{eprint:EUREGULATION}{eprint:euregulation}

% EU generic documents
\newcommand*{\eudocumenturl}[1]{http://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:#1}
\DeclareFieldFormat{eprint:eudocument}{%
    \ifhyperref
        {\textsc{eu document}:~\href{\eudocumenturl{#1}}{\nolinkurl{#1}}}
        {\textsc{eu document}:~\nolinkurl{#1}}}
\DeclareFieldAlias{eprint:EUDOCUMENT}{eprint:eudocument}


% Define bibliography notes
\defbibnote{mainauthor}{The following are the publications, written as first author, included in this thesis.}
\defbibnote{coauthor}{The following are secondary publications, contributed as co-author during the \phd project. These are not included as a part of the \phd thesis.}

\defbibnote{openaccess}{%
\ifluatex%
    \ifmodernthesis@showopenaccess%
        Open Access publications are identified by the icon \oasymbol.%
    \fi%
\fi%
}




%%%%%%%%%%%%%%%%%%%%%%%%
% Acronyms
%%%%%%%%%%%%%%%%%%%%%%%%

% Use like this:
% \acrshort{fdd} for just FDD
% \acrlong{fdd} for Fault Detection and Diagnostics
% \acrfull{fdd} for Fault Detection and Diagnostics (FDD)
% \ac{fdd} for either short or full, depending if it is the first time

\RequirePackage[
    acronyms,
    xindy,
    style=index,
    shortcuts,
]{glossaries}

\renewcommand{\glstreenamefmt}[1]{\textsc{#1}}
\renewcommand{\glstreepredesc}{\space\space\space}
\renewcommand{\glstreechildpredesc}{\space\space\space}

\makeglossaries


% Reset all acronyms at the beginning of each part and chapter
\pretocmd{\@part}{\glsresetall}{}{}
\pretocmd{\@spart}{\glsresetall}{}{}
\pretocmd{\@chapter}{\glsresetall}{}{}
\pretocmd{\@schapter}{\glsresetall}{}{}




%%%%%%%%%%%%%%%%%%%%%%%%
% Define Chapter Style
%%%%%%%%%%%%%%%%%%%%%%%%

\renewcommand*{\chapterformat}{%
    \textcolor{ChapterColor}{%
        \fontsize{40pt}{50pt}\selectfont\rlap{\mdseries\thechapter\autodot}%
    }%
}

\renewcommand*\chapterlinesformat[3]{%
    \mbox{}\hfill
    \IfArgIsEmpty{#2}{%
        \phantom{\textcolor{ChapterColor}{\large\scshape\MakeLowercase{\chapapp}}}~\mbox{}%
    }{%
        \textcolor{ChapterColor}{\large\scshape\MakeLowercase{\chapapp}}~\mbox{}
    }
    \smash{\raisebox{-\dimexpr\baselineskip+\parskip\relax}{\rlap{~#2}}}%
    \par
    \mbox{}\hfill
    \llap{\parbox{\dimexpr\textwidth-1em\relax}{\vspace{10pt}\raggedleft\MakeLowercase{#3}}}~\mbox{}~\mbox{}%
    \IfArgIsEmpty{#2}{%
    }{%
        \smash{\textcolor{ChapterColor}{\rule[-5pt]{2pt}{130pt}}}%
    }
}




%%%%%%%%%%%%%%%%%%%%%%%%
% Define headings style
%%%%%%%%%%%%%%%%%%%%%%%%

% Set every heading to roman and smallcaps
\setkomafont{disposition}{\rmfamily\scshape}


% Redefine commands to convert all headings to lowercase, except in table
% of contents.
% Adapted from https://tex.stackexchange.com/a/99324
% This looks good with smallcaps, but not otherwise
\newcommand*{\Section}{}
\let\Section\section
\renewcommand*{\section}{%
  \@ifstar {\star@section}{\@dblarg\nonstar@section}%
}
\newcommand*{\star@section}[1]{%
  \Section*{\MakeLowercase{#1}}%
}
\newcommand*{\nonstar@section}[2][]{%
  \Section[{#1}]{\MakeLowercase{#2}}%
}
\let\Subsection\subsection
\renewcommand*{\subsection}{%
  \@ifstar {\star@subsection}{\@dblarg\nonstar@subsection}%
}
\newcommand*{\star@subsection}[1]{%
  \Subsection*{\MakeLowercase{#1}}%
}
\newcommand*{\nonstar@subsection}[2][]{%
  \Subsection[{#1}]{\MakeLowercase{#2}}%
}
\let\Subsubsection\subsubsection
\renewcommand*{\subsubsection}{%
  \@ifstar {\star@subsubsection}{\@dblarg\nonstar@subsubsection}%
}
\newcommand*{\star@subsubsection}[1]{%
  \Subsubsection*{\MakeLowercase{#1}}%
}
\newcommand*{\nonstar@subsubsection}[2][]{%
  \Subsubsection[{#1}]{\MakeLowercase{#2}}%
}




%%%%%%%%%%%%%%%%%%%%%%%%
% Define running headers
%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{scrlayer-scrpage}




%%%%%%%%%%%%%%%%%%%%%%%%
% Format tables of contents
%%%%%%%%%%%%%%%%%%%%%%%%

\addtokomafont{partentry}{\normalfont}
\addtokomafont{chapterentry}{\normalfont}

% Enlarge the box for page numbers
% (the front matter reaches page xviii, which is too long for the default
% value and results in a overfull hbox warning)
\renewcommand\@pnumwidth{1.1cm}



%%%%%%%%%%%%%%%%%%%%%%%%
% Format captions
%%%%%%%%%%%%%%%%%%%%%%%%

\addtokomafont{caption}{\small}
\setkomafont{captionlabel}{\bfseries}
\setcapindent{1cm}

\RequirePackage[
    textformat=period,
]{caption}

\DeclareCaptionLabelFormat{continued}{#1~#2 (\ifnum\value{ContinuedFloat}>1{continued}\else{first}\fi)}
\captionsetup[ContinuedFloat]{labelformat=continued}




%%%%%%%%%%%%%%%%%%%%%%%%
% Typesetting Dates
%%%%%%%%%%%%%%%%%%%%%%%%

% Use like this:
% \DTMdisplaydate{2016}{9}{1}{3}
% where the last "3" is the weekday (0 is Monday, -1 to avoid
% displaying the week day)

\RequirePackage[useregional=text,showdow]{datetime2}
\DTMusemodule{english}{en-GB}
% \RequirePackage[en-GB,useregional=false,showseconds=false,showdow]{datetime2}
\DTMlangsetup[en-GB]{ord=omit, monthyearsep={\space}}
\DTMsettimestyle{iso}
% \DTMsetdatestyle{en-GB}




%%%%%%%%%%%%%%%%%%%%%%%%
% Clever References
%%%%%%%%%%%%%%%%%%%%%%%%

% Use like this:
% \cref{fig:somefig} becomes figure~3.1
% \Cref{fig:somefig} becomes Figure~3.1

\RequirePackage[capitalise,noabbrev]{cleveref}




%%%%%%%%%%%%%%%%%%%%%%%%
% Landscape floats
%%%%%%%%%%%%%%%%%%%%%%%%

% For rotating pages
\RequirePackage[figuresright]{rotating}

% For landscape pages
\RequirePackage{pdflscape}
\RequirePackage{eso-pic}
\RequirePackage{zref-user}

\newcounter{cntsideways}
\AddToShipoutPictureBG{%
    \if@mainmatter
        \ifnum\zref@extractdefault{rotate\number\value{page}}{page}{0}=0
            \PLS@RemoveRotate
        \else
            \PLS@AddRotate{90}%
        \fi
    \fi
}

% To rotate a float, use the environment `sidewaysfigure` or `sidewaystable`
% and use the command `\rotatesidewayslabel` inside it.

% This is defined above, depending on a class option
%
% \newcommand\rotatesidewayslabel{%
%     \stepcounter{cntsideways}%
%     \zlabel{tmp\thecntsideways}%
%     \zlabel{rotate\zref@extractdefault{tmp\thecntsideways}{page}{0}}%
% }




%%%%%%%%%%%%%%%%%%%%%%%%
% Miscellaneous
%%%%%%%%%%%%%%%%%%%%%%%%

% Fancy icons
\ifluatex
    \RequirePackage{fontawesome}
    \RequirePackage{academicons}

    \newcommand{\modernthesis@contacticonswidth}{1em}
\else
    \PackageWarningNoLine{modernthesis}{Special icons in the colophon are not supported with pdflatex, using text replacements. Either switch to lualatex or define your own icons}

    \newcommand\faEnvelopeO{Email:~}
    \newcommand\faLinkedinSquare{LinkedIn:~}
    \newcommand\aiOrcid{ORCID:~}
    \newcommand\aiResearcherID{Res.\ ID:~}
    \newcommand\aiGoogleScholar{G.\ Scholar:~}

    \newcommand{\modernthesis@contacticonswidth}{2cm}
\fi

% Foreign expressions such as \eg, \ie
\RequirePackage[abbreviations,british]{foreign}

\renewcommand\foreignabbrfont{\normalfont}

\DeclareRobustCommand\phd{%
    {\foreignabbrfont{Ph}}.\ \xperiodafter{{\foreignabbrfont{D}}}}

% Commands patching helpers
\RequirePackage{xpatch}




%%%%%%%%%%%%%%%%%%%%%%%%
% Front Page
%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand{\modernthesisfrontpage}{
    \hypersetup{pageanchor=false}
    \pagestyle{empty}
    \begingroup
    \centering
    \vfill
    {\Huge\sffamily\bfseries\modernthesis@title}\\[\baselineskip]
    {\Large \modernthesis@subtitle{}}\\[0.1\textheight]
    {\small \modernthesis@version{}}\\[0.1\textheight]
    \vfill
    \vfill
    % {\Huge\sffamily\bfseries\MakeUppercase{\modernthesis@title}}\\[\baselineskip]
    {\Large \modernthesis@author{}}\\[0.1\textheight]
    \vfill
    \vfill
    {\Large \modernthesis@center}\par
    {\Large \modernthesis@department}\par
    {\Large \modernthesis@faculty}\par
    {\Large \modernthesis@university}\\[\baselineskip]
    \par\vspace*{\fill}
    \includegraphics[width=4cm]{figures/logo}
    \par\vspace*{\fill}
    {\large\scshape \DTMMonthname{\modernthesis@month} \modernthesis@year{}\hfill}
    \endgroup
    \normalfont
    \newpage
    \begingroup
    \small
    \strut\vfill
    \begin{flushleft}
    %\section*{supervision}
    %Principal supervisor: \modernthesis@principalsupervisor \par%
    %Co-supervisor: \modernthesis@cosupervisor
    % \section*{evaluation committee}
    % \modernthesis@firstcommittee \par%
    % \modernthesis@secondcommittee \par%
    % \modernthesis@thirdcommittee
    \section*{colophon}
    \copyright{} \modernthesis@author{} \modernthesis@year{}

    \medskip

    \begin{tabular}{ll}
        \makebox[\modernthesis@contacticonswidth]{\faEnvelopeO}~%
        \href{mailto:\modernthesis@email}%
            {\nolinkurl{\modernthesis@email}}
            &
        \makebox[\modernthesis@contacticonswidth]{\textcolor{LinkedinBlue}{\faLinkedinSquare}}~%
        \href{https://www.linkedin.com/in/\modernthesis@linkedin/}%
            {\nolinkurl{\modernthesis@linkedin}}
            \\
        \makebox[\modernthesis@contacticonswidth]{\textcolor{OrcidGreen}{\aiOrcid}}~%
        \href{https://orcid.org/\modernthesis@orcid}%
            {\nolinkurl{\modernthesis@orcid}}
            &
        \makebox[\modernthesis@contacticonswidth]{\aiResearcherID}~%
        \href{http://www.researcherid.com/rid/\modernthesis@researcherid}%
            {\nolinkurl{\modernthesis@researcherid}}
            \\
        \makebox[\modernthesis@contacticonswidth]{\textcolor{GoogleBlue}{\aiGoogleScholar}}~%
        \href{https://scholar.google.com/citations?user=\modernthesis@googlescholar}%
            {\nolinkurl{\modernthesis@googlescholar}}
    \end{tabular}

    \medskip

    Typeset by the author in \modernthesis@mainfontname{} 11pt, %
      {\sffamily \modernthesis@sansfontname{}}, %
      \texttt{\modernthesis@monofontname{}} and %
      {\scriptfamily\modernthesis@scriptfontname}, %
      using \ifluatex Lua\else\fi\LaTeX{} and the \modernthesistemplatename{} template created by Claudio Mattera.
    \modernthesis@additionalcolophon{}
    \ifmodernthesis@showprinter%
    \\
    Printed by \modernthesis@printer.%
    \fi%
    \end{flushleft}
    \normalfont
    \endgroup
    \cleardoublepage
    % Reset page count
    \setcounter{page}{1}
    \pagestyle{scrheadings}
    \hypersetup{pageanchor=true}
}
