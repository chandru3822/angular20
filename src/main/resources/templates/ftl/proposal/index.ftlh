<#ftl strip_whitespace=true output_format="HTML">
<#import "blocks.ftlh" as b>
<html lang="en">
<head>
  <link href="https://fonts.googleapis.com/css?family=Lato" rel="stylesheet">
  <style>
    html,body {
      padding: 0;
      margin: 0;
      font-family: 'Lato', sans-serif;
    }
  </style>

  <style media="print">
    @page {
      width:  fit-content;
      height: fit-content;
      size: landscape;
      margin: 0;
      padding: 0;
    }

    table {page-break-inside: avoid;}
    p {margin: 0; padding: 0; overflow-wrap: break-word;}

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
  </style>
    <#-- company specific styles  -->
  <style> <@b.globalStyles styles=theme/></style>
</head>
<body>
<#--TODO: need to get global proposal css working -->
<@b.builder blocks=template/>
</body>
</html>

