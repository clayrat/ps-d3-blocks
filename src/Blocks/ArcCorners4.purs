module Blocks.ArcCorners4 where

  import Prelude hiding (append, apply)
  import Control.Monad.Eff

  import Math (pi)

  import Graphics.D3.Base
  import Graphics.D3.Layout.Pie
  import Graphics.D3.Scale hiding (range)
  import Graphics.D3.Selection
  import Graphics.D3.SVG.Shape
  import Graphics.D3.Util

-- http://bl.ocks.org/mbostock/c501f6cae402ab5e90c9

{-
var data = [1, 1, 2, 3, 5, 8, 13, 21];

var width = 960,
    height = 500,
    radius = height / 2 - 10;

var arc = d3.svg.arc()
    .innerRadius(radius - 40)
    .outerRadius(radius)
    .cornerRadius(20);

var pie = d3.layout.pie()
    .padAngle(.02);

var color = d3.scale.category10();

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
  .append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

svg.selectAll("path")
    .data(pie(data))
  .enter().append("path")
    .style("fill", function(d, i) { return color(i); })
    .attr("d", arc);
-}

  dataArr = [1.0, 1.0, 2.0, 3.0, 5.0, 8.0, 13.0, 21.0]

  canvasWidth = 960.0
  canvasHeight = 500.0
  radius = canvasHeight / 2.0 - 10.0

  main = do
    arc <- arc
            .. innerRadius (radius - 40.0)
            .. outerRadius radius
            .. cornerRadius 20.0

    pieData <- pieLayout
                .. padAngle 0.02
                .. pie dataArr

    color <- category10 .. toFunction

    svg <- rootSelect "body" .. append "svg"
            .. attr "width" canvasWidth
            .. attr "height" canvasHeight
          .. append "g"
            .. attr "transform" (translateStr (canvasWidth / 2.0) (canvasHeight / 2.0))

    svg ... selectAll "path"
            .. bindData pieData
      .. enter .. append "path"
        .. style'' "fill" (\_ i -> color i)
        .. attr "d" arc
