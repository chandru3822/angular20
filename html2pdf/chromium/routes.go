package chromium

import (
	"github.com/7oaksgroup/html2pdf/v1/api"
	"github.com/labstack/echo/v4"
	"net/http"
)

var htmlConvertRoute = api.Route{
	Path:   "/api/convert",
	Method: "GET",
	Handler: func(c echo.Context) error {
		var ret []byte
		html := `
<html>
<head>
  <style>
@import url('https://fonts.googleapis.com/css2?family=Festive&display=swap');

@media print {
  @page {
    size: landscape;

  @bottom-center {
      content: counter(page);
      text-align: center;
  }
  }
}

      h1 {
        color: red;
font-family: 'Festive', cursive;      }

body {
  margin: 40px;
}

  .wrapper {
    display: grid;
    gap: 10px;
    grid-template-columns: 150px 100px 150px 100px ;
    grid-template-rows: repeat(3,minmax(100px,auto));
    background-color: #fff;
    color: #444;
  }

  .box {
    background-color: #444;
    color: #fff;
    border-radius: 5px;
    padding: 20px;
    font-size: 150%;

  }

  .box .box {
    background-color: #ccc;
    color: #444;
  }

  .a {
    grid-column: 1 / 3;
  }

  .b {
    grid-column: 4 ;
  }

  .c {
    grid-column: 1;
    grid-row: 2 / 4;
  }

  .d{
    grid-column: 2 / 5;
    grid-row: 2 / 4;
    display: grid;
    grid-template-columns: subgrid;
  }
  </style>
</head>
<body>
<h1>hello</h1>
<div class="wrapper">
  <div class="box a">A</div>
  <div class="box b">B</div>
  <div class="box c">C</div>
  <div class="box d">
    <div class="box e">E</div>
    <div class="box f">F</div>
    <div class="box g">G</div>
    <div class="box h">H</div>
    <div class="box i">I</div>
    <div class="box j">J</div>
    <div class="box k">K</div>
  </div>

</div>
  <div style="break-inside: avoid;">
    <img style="height: 250px; width: auto;" src="https://images.unsplash.com/photo-1523906834658-6e24ef2386f9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=683&q=80"/>
  </div>
</body>
</html>
`
		_ = Chromium{}.Convert(html, &ret)
		return c.Blob(http.StatusOK, "application/pdf", ret)
	},
}
