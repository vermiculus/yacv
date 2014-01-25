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

\clist_new:N \g_yacv_module_modules_clist

\NewDocumentCommand \yaCV { m } {
  \keys_set:nn { yacv } { #1 }
}

\keys_define:nn { yacv } {
  unknown .code:n =
  \file_if_exist:nTF { \__yacv_module_create_name:V \l_keys_key_tl .sty } {
    \RequirePackage {
      \__yacv_module_create_name:V \l_keys_key_tl
    }
    
    \cs_if_exist_use:c {
      \__yacv_module_create_loader_name:V \l_keys_key_tl
    }
    
    \clist_set:Nn \l_tmpa_clist { #1 }
    \clist_map_inline:Nn \l_tmpa_clist {
      \yacv_module_defer_load_presentation:Vn \l_keys_key_tl { ##1 }
    }

    \clist_gpush:Nx \g_yacv_module_modules_clist {
      \__yacv_module_create_name:V \l_keys_key_tl
    }
  } {
    \msg_error:nnx { yacv } { module-not-found } \l_keys_key_tl
  }
}

\cs_new:Nn \yacv_module_defer_load_presentation:nn {
  \AtBeginDocument{
    \RequirePackage { yacv . #1 . presentation . #2 }
    \cs_if_exist_use:c { \__yacv_module_create_loader_name:nn { #1 } { #2 } }

    \clist_gpush:No \g_yacv_module_modules_clist {
      \__yacv_module_create_name:nn { #1 } { #2 }
    }
  }
}
\cs_generate_variant:Nn \yacv_module_defer_load_presentation:nn { V }

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Creatine Module Names %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\cs_new:Nn \__yacv_module_create_name:n {
  yacv . #1 . logic
}
\cs_generate_variant:Nn \__yacv_module_create_name:n { V }

\cs_new:Nn \__yacv_module_create_name:nn {
  yacv . #1 . presentation . #2
}
\cs_generate_variant:Nn \__yacv_module_create_name:nn { V }

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
