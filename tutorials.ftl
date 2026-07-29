<#--
  tutorials.ftl — Polygon contest-level tutorial (editorial) wrapper.

  The repository previously had no tutorial template at all, so Polygon fell
  back to its unstyled default and editorials looked nothing like the
  statements they accompanied.

  Mirrors statements.ftl. `standalone` is used rather than `booklet`: an
  editorial does not need the cover page or the problem-overview table, which
  would duplicate the statement booklet.
--><#function vnolympLanguage>
  <#if contest.language?? && contest.language == "vietnamese">
    <#return "vietnamese" />
  </#if>
  <#return "english" />
</#function>
\documentclass[11pt, a4paper, oneside]{article}

\usepackage[${vnolympLanguage()}, color, standalone]{vnolymp}
\usepackage{import}

\begin{document}

\contest{${contest.name!}}{${contest.location!}}{${contest.date!}}

<#list tutorials as tutorial>
<#if tutorial.path??>
\graphicspath{{${tutorial.path}}}
\import{${tutorial.path}}{./${tutorial.file}}
<#else>
\input{${tutorial.file}}
</#if>
</#list>

\end{document}
