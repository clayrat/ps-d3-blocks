module Blocks.CounterclockwiseArc where

  import Prelude hiding (append)
  import Control.Monad.Eff
  import Math (pi)

  import Graphics.D3.Base
  import Graphics.D3.Color
  import Graphics.D3.Selection
  import Graphics.D3.SVG.Shape
  import Graphics.D3.Util

-- http://bl.ocks.org/mbostock/57d620285395dae5a2ff
{-
var width = 960,
    height = 500,
    radius = height / 2 - 20;

var arc = d3.svg.arc()
    .innerRadius(0)
    .outerRadius(radius);

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);

var g = svg.selectAll("g")
    .data([
      {startAngle: Math.PI / 4, endAngle: 3 * Math.PI / 4, text: "This is a clockwise arc."},
      {startAngle: 3 * Math.PI / 4, endAngle: Math.PI / 4, text: "This is a counterclockwise arc."}
    ])
  .enter().append("g")
    .attr("transform", function(d, i) { return "translate(" + ((i + .5) * width / 3) + "," + height / 2 + ")"; });

g.append("path")
    .attr("d", arc)
    .attr("id", function(d, i) { return "arc-" + i; });

g.append("text")
    .attr("dx", 5)
    .attr("dy", -5)
  .append("textPath")
    .attr("xlink:href", function(d, i) { return "#arc-" + i; })
    .text(function(d) { return d.text; });

-}

  canvasWidth = 960.0
  canvasHeight = 500.0
  radius = canvasHeight / 2.0 - 20.0

  main = do
    arc <- arc
            .. innerRadius 0.0
            .. outerRadius radius

    svg <- rootSelect "body" .. append "svg"
            .. attr "width" canvasWidth
            .. attr "height" canvasHeight

    g <- svg ... selectAll "g"
          .. bindData ([
                  {startAngle: pi / 4.0,       endAngle: 3.0 * pi / 4.0, text: "This is a clockwise arc."},
                  {startAngle: 3.0 * pi / 4.0, endAngle: pi / 4.0,       text: "This is a counterclockwise arc."}
                ])
        .. enter .. append "g"
          .. attr'' "transform" (\_ i -> translateStr ((i + 0.5) * canvasWidth / 3.0) (canvasHeight / 2.0))

    g ... append "path"
        .. attr "d" arc
        .. attr'' "id" (\_ i -> "arc-" ++ show i)

    g ... append "text"
        .. attr "dx" "5.0"
        .. attr "dy" "-5.0"
      .. append "textPath"
        .. attr'' "xlink:href" (\_ i -> "#arc-" ++ show i)
        .. text' (\d -> d.text)
