\NeedsTeXFormat{LaTeX2e}[1994/06/01]
\RequirePackage{expl3,xparse}
\ProvidesExplClass
{yacv}
{2013/12/23}
{1.0}
{A module-based class for resume/curricula vitae}

\DeclareOption*{\PassOptionToClass{\CurrentOption}{article}}
\ProcessOptions*
\LoadClass{article}

\msg_new:nnnn { yacv } { module-not-found } {
  The ~ `#1` ~ module ~ is ~ not ~ available. ~  ~
  Please ~ install ~ it.
} {
  yaCV ~ looked ~ in ~ the ~ path ~ TeX ~ was ~ given ~ for ~ files ~
  and ~ could ~ not ~ find ~ the ~ file ~ `yacv.#1.logic.sty`. ~  ~
  Please ~ find ~ this ~ file ~ and ~ put ~ it ~ in ~ an ~ appropriate ~ place.
}

\msg_new:nnnn { yacv } { presentation-not-found } {
  The ~ presentation ~ `#2` ~ for ~ the ~ `#1` ~ module ~ is ~ not ~ available. ~  ~
  Please ~ install ~ it.
} {
  yaCV ~ looked ~ in ~ the ~ path ~ TeX ~ was ~ given ~ for ~ files ~
  and ~ could ~ not ~ find ~ the ~ file ~ `yacv.#1.presentation.#2.sty`. ~  ~
  Please ~ find ~ this ~ file ~ and ~ put ~ it ~ in ~ an ~ appropriate ~ place.
}

\msg_new:nnnn { yacv } { module-no-init } {
  The ~ `#1` ~ module ~ has ~ no ~ initialization ~ function. ~  ~
  This ~ should ~ probably ~ be ~ added ~ for ~ the ~ sake ~ of ~ completion.
} {
  The ~ `yacv_#1__load:` ~ function ~ was ~ not ~ defined.
}

\msg_new:nnnn { yacv } { presentation-no-init } {
  The ~ presentation ~ `#2` ~ for ~ the ~ `#1` ~ module  ~ has ~ no ~ initialization ~ function. ~  ~
  This ~ should ~ probably ~ be ~ added ~ for ~ the ~ sake ~ of ~ completion.
} {
  The ~ `yacv_#1__load:` ~ function ~ was ~ not ~ defined.
}

\clist_new:N \g_yacv_module_modules_clist

\NewDocumentCommand \yaCV { m } {
  % the first run loads all of the logical definitions
  \keys_set:nn { yacv } { #1 }
  % where the second run loads all of the presentational definitions
  \keys_set:nn { yacv } { #1 }
}

\keys_define:nn { yacv } {
  unknown .code:n =
    \yacv_module_logic_load:Vn \l_keys_key_tl { #1 }

    % Is there a way to do this that isn't *awful*?
    \clist_set:No \l_tmpa_clist { \l_keys_key_tl }
    \clist_map_inline:Nn \l_tmpa_clist {
      \keys_define:nn { yacv } {
        ##1 .tl_set:c = { l_yacv_##1_logic_options_tl },
      }
    },
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loading Modules %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\cs_new:Nn \yacv_module_logic_load:nn {
  \file_if_exist:nTF { \__yacv_module_create_module_file_name:n { #1 } } {
    \keys_define:nn { yacv } {
      #1 .tl_set:c = { l_yacv_#1_logic_options_tl }
    }
    \keys_set:nn { yacv } { #1 = #2 }

    \RequirePackage {
      \__yacv_module_create_module_name:n { #1 }
    }

    \yacv_module_initialize:n { #1 }

    \clist_set:Nn \l_tmpa_clist { #2 }
    \clist_if_empty:NTF \l_tmpa_clist {
      \AtBeginDocument{
        \yacv_module_load:nn { #1 } { default }
      }
    } {
      \clist_map_inline:Nn \l_tmpa_clist {
        \AtBeginDocument{
          \yacv_module_load:nn { #1 } { ##1 }
        }
      }
    }

    \clist_gpush:Nx \g_yacv_module_modules_clist {
      \__yacv_module_create_module_name:n { #1 }
    }
  } {
    \msg_error:nnn { yacv } { module-not-found } { #1 }
  }
}
\cs_generate_variant:Nn \yacv_module_logic_load:nn { V , VV }

\cs_generate_variant:Nn \file_if_exist:nTF { V }
\cs_new:Nn \yacv_module_load:nn {
  \file_if_exist:nTF { \__yacv_module_create_presentation_file_name:nn { #1 } { #2 } } {
    \RequirePackage { \__yacv_module_create_presentation_name:nn { #1 } { #2 } }
    \yacv_module_initialize:nn { #1 } { #2 }

    \clist_gpush:No \g_yacv_module_modules_clist {
      \__yacv_module_create_presentation_name:nn { #1 } { #2 }
    }
  } {
    \msg_error:nnnn { yacv } { presentation-not-found } { #1 } { #2 }
  }
}
\cs_generate_variant:Nn
  \yacv_module_load:nn { V , VV }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Creating Module Names %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\cs_new:Nn \__yacv_module_create_module_name:n {
  yacv . #1 . logic
}
\cs_generate_variant:Nn \__yacv_module_create_module_name:n { V }

\cs_new:Nn \__yacv_module_create_module_file_name:n {
  \__yacv_module_create_module_name:n { #1 } .sty
}
\cs_generate_variant:Nn \__yacv_module_create_module_file_name:n { V }

\cs_new:Nn \__yacv_module_create_presentation_name:nn {
  yacv . #1 . presentation . #2
}
\cs_generate_variant:Nn \__yacv_module_create_presentation_name:nn { V }

\cs_new:Nn \__yacv_module_create_presentation_file_name:nn {
  \__yacv_module_create_presentation_name:nn { #1 } { #2 } .sty
}
\cs_generate_variant:Nn \__yacv_module_create_presentation_file_name:nn { V }

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Creating Loader Names %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\cs_new:Nn \__yacv_module_create_loader_name:n {
  yacv _ #1 __load:
}
\cs_generate_variant:Nn \__yacv_module_create_loader_name:n { V }

\cs_new:Nn \__yacv_module_create_loader_name:nn {
  yacv _ #1 _ presentation _ #2 __load:
}
\cs_generate_variant:Nn \__yacv_module_create_loader_name:nn { VV }

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Creating Module-Level Loaders %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\cs_new:Nn \yacv_module_define_init:nn {
  \cs_new:cpn { \__yacv_module_create_loader_name:n  { #1 }        } { #2 }
}

\cs_new:Nn \yacv_module_define_init:nnn {
  \cs_new:cpn { \__yacv_module_create_loader_name:nn { #1 } { #2 } } { #3 }
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Using Module-Level Loaders %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\cs_new:Nn \yacv_module_initialize:n {
  \cs_if_exist_use:cF {
    \__yacv_module_create_loader_name:n { #1 }
  } {
    \msg_info:nnn { yacv } { module-no-init } { #1 }
  }
}

\cs_new:Nn \yacv_module_initialize:nn {
  \cs_if_exist_use:cF {
    \__yacv_module_create_loader_name:nn { #1 } { #2 }
  } {
    \msg_info:nnnn { yacv} { presentation-no-init } { #1 } { #2 }
  }
}

\cs_generate_variant:Nn \yacv_module_initialize:n
  { V }
\cs_generate_variant:Nn \yacv_module_initialize:nn
  { V , VV }
