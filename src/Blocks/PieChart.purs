module Blocks.PieChart where

  import Prelude hiding (append, apply)
  import Control.Monad.Eff

  import Math (pi, min)
  import Data.Foreign.EasyFFI
  import Data.Either
  import Data.Traversable

  import Graphics.D3.Base
  import Graphics.D3.Layout.Pie
  import Graphics.D3.Request
  import Graphics.D3.Scale
  import Graphics.D3.Selection
  import Graphics.D3.SVG.Shape
  import Graphics.D3.Util hiding (min, range)

-- http://bl.ocks.org/mbostock/3887235

{-

var width = 960,
    height = 500,
    radius = Math.min(width, height) / 2;

var color = d3.scale.ordinal()
    .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

var arc = d3.svg.arc()
    .outerRadius(radius - 10)
    .innerRadius(0);

var pie = d3.layout.pie()
    .sort(null)
    .value(function(d) { return d.population; });

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
  .append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

d3.csv("data.csv", function(error, data) {

  data.forEach(function(d) {
    d.population = +d.population;
  });

  var g = svg.selectAll(".arc")
      .data(pie(data))
    .enter().append("g")
      .attr("class", "arc");

  g.append("path")
      .attr("d", arc)
      .style("fill", function(d) { return color(d.data.age); });

  g.append("text")
      .attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
      .attr("dy", ".35em")
      .style("text-anchor", "middle")
      .text(function(d) { return d.data.age; });

});
-}
  type AgeAndPopulation = { age :: String, population :: Number }

  coerceDatum :: forall a. a -> D3Eff AgeAndPopulation
  coerceDatum = unsafeForeignFunction ["x", ""] "{ age: x.age, population: Number(x.population) }"

  canvasWidth = 960.0
  canvasHeight = 500.0
  radius = (min canvasWidth canvasHeight) / 2.0

  main = do

    color <- ordinalScale
              .. range ["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]
              .. toFunction

    arc <- arc
            .. outerRadius (radius - 10.0)
            .. innerRadius 0.0   -- replace with (radius - 70.0) to get donut

    pieL <- pieLayout
            .. noSort
            .. value (_.population)

    svg <- rootSelect "body" .. append "svg"
              .. attr "width" canvasWidth
              .. attr "height" canvasHeight
            .. append "g"
              .. attr "transform" (translateStr (canvasWidth / 2.0) (canvasHeight / 2.0))

    csv "data/pieChart.csv" \(Right array) -> do
      typedData <- traverse coerceDatum array

      pieData <- pieL ... pie typedData

      g <- svg ... selectAll ".arc"
              .. bindData pieData
              .. enter .. append "g"
                .. attr "class" "arc"

      g ... append "path"
            .. attr "d" arc
            .. style' "fill" (\d -> color d."data".age )

      g ... append "text"
            .. attr' "transform" (\d -> "translate(" ++ (arc ... centroid d) ++ ")")
            .. attr "dy" ".35em"
            .. style "text-anchor" "middle"
            .. text' (\d -> d."data".age)
