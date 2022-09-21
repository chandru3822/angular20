<#ftl strip_whitespace=true output_format="HTML">
<#import "blocks.ftlh" as b>
<@compress single_line=true>
  <html lang="en">
  <head>
    <title>BRS Proposal</title>
    <link href="https://fonts.googleapis.com/css?family=Lato" rel="stylesheet">
    <style>
      html, body {
        padding: 0;
        margin: 0;
        font-family: 'Lato', sans-serif;
        font-size: 12pt;
      }

      h1, h2, h3, h4, h5, h6 {
        padding: 0;
        margin: 0;
      }

      table {
        border-collapse: collapse;
        table-layout: fixed;
        width: 100%;
        margin: 0;
        overflow: hidden;
        font-size: inherit;
      }

      table td,
      table th {
        min-width: 1em;
        border: 2px solid transparent;
        padding: 3px 5px;
        vertical-align: top;
        box-sizing: border-box;
        position: relative;
      }

      table td > *,
      table th > * {
        word-break: break-word;
        margin-bottom: 0;
      }
    </style>

    <style media="print">
      @page {
        width: fit-content;
        height: fit-content;
        size: landscape;
        margin: 0;
        padding: 0;
      }

      a {
        page-break-inside: avoid
      }

      blockquote {
        page-break-inside: avoid;
      }

      h1, h2, h3, h4, h5, h6 {
        page-break-after: avoid;
        page-break-inside: avoid
      }

      img {
        page-break-inside: avoid;
        page-break-after: avoid;
      }

      table, pre {
        page-break-inside: avoid
      }

      ul, ol, dl {
        page-break-before: avoid
      }

      table {
        page-break-inside: avoid;
      }

      p {
        margin: 0;
        padding: 0;
        overflow-wrap: break-word;
      }

      .proposal-page {
        page-break-before: auto;
        page-break-inside: avoid;
        box-sizing: border-box;
        height: 100%;
      }

      .proposal-img img {
        max-width: 100%;
        object-fit: contain;
      }

      .placeholder-img {
        background-color: #f0f1f3;
        align-items: center;
        flex-direction: column;
        color: #e0e2e8;
      }
    </style>
      <#-- company specific styles  -->
    <style> <@b.globalStyles styles=theme/></style>
  </head>
  <body>
  <@b.builder blocks=template/>
  </body>
  </html>
</@compress>
