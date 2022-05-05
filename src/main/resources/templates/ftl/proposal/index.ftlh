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

    table {
      page-break-inside: avoid;
    }

    p {
      margin: 0;
      padding: 0;
      overflow-wrap: break-word;
    }

    .proposal-page {
      padding: 20px;
      height: calc(8.5in - 40px);
      page-break-before: auto;
      page-break-inside: avoid;
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
