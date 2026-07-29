<#--
  statements.ftl — Polygon contest-level statement wrapper.

  Deliberately thin. Fonts, encoding, colours, geometry and hyphenation all
  belong to vnolymp.sty, so this file chooses a document class, selects
  package options, and lists the problems.

  What is NOT here, and why:

    * \usepackage[T2A]{fontenc} — T2A is Cyrillic. The old version declared it
      while claiming Vietnamese support, and the local entry point declared T5
      instead, so the two paths disagreed on encoding. A Unicode engine makes
      the question moot.
    * \usepackage[utf8]{inputenc} — meaningless under LuaLaTeX.
    * \renewcommand{\t}{\texttt} — \t is LaTeX's tie accent. The old olymp.sty
      redefined it with one argument and this file then redefined it again
      with none.

  Requires LuaLaTeX. Polygon's own "In PDF" preview button will not render
  this, which is a deliberate consequence of building locally — see §8 of the
  design spec.
--><#function vnolympLanguage>
  <#if contest.language?? && contest.language == "vietnamese">
    <#return "vietnamese" />
  </#if>
  <#return "english" />
</#function>
\documentclass[11pt, a4paper, oneside]{article}

\usepackage[${vnolympLanguage()}, color, booklet]{vnolymp}
\usepackage{import}

\begin{document}

\contest{${contest.name!}}{${contest.location!}}{${contest.date!}}

<#list statements as statement>
<#if statement.path??>
\graphicspath{{${statement.path}}}
<#if statement.index??>
\def\ProblemIndex{${statement.index}}
</#if>
\import{${statement.path}}{./${statement.file}}
<#else>
\input{${statement.file}}
</#if>
</#list>

\end{document}
