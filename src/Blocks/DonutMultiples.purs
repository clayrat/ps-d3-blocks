module Blocks.DonutMultiples where

  import Prelude hiding (append, apply)
  import Control.Monad.Eff
  import Control.Monad.Eff.Unsafe
  import Control.Monad.Eff.Console
  import Data.Array (filter, reverse)
  import Data.Array.Unsafe
  import Data.Int as Int
  import Data.Foreign
  import Data.Foreign.Keys
  import Data.Foreign.Index
  import Data.Maybe.Unsafe
  import Data.Either
  import Data.Either.Unsafe
  import Data.Traversable

  import Math (pi, min)

  import Graphics.D3.Base
  import Graphics.D3.Layout.Pie
  import Graphics.D3.Request
  import Graphics.D3.Scale
  import Graphics.D3.Selection
  import Graphics.D3.SVG.Shape
  import Graphics.D3.Util hiding (min, range)

  -- http://bl.ocks.org/mbostock/3888852

  {-
  var radius = 74,
      padding = 10;

  var color = d3.scale.ordinal()
      .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

  var arc = d3.svg.arc()
      .outerRadius(radius)
      .innerRadius(radius - 30);

  var pie = d3.layout.pie()
      .sort(null)
      .value(function(d) { return d.population; });

  d3.csv("data.csv", function(error, data) {
    if (error) throw error;

    color.domain(d3.keys(data[0]).filter(function(key) { return key !== "State"; }));

    data.forEach(function(d) {
      d.ages = color.domain().map(function(name) {
        return {name: name, population: +d[name]};
      });
    });

    var legend = d3.select("body").append("svg")
        .attr("class", "legend")
        .attr("width", radius * 2)
        .attr("height", radius * 2)
      .selectAll("g")
        .data(color.domain().slice().reverse())
      .enter().append("g")
        .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

    legend.append("rect")
        .attr("width", 18)
        .attr("height", 18)
        .style("fill", color);

    legend.append("text")
        .attr("x", 24)
        .attr("y", 9)
        .attr("dy", ".35em")
        .text(function(d) { return d; });

    var svg = d3.select("body").selectAll(".pie")
        .data(data)
      .enter().append("svg")
        .attr("class", "pie")
        .attr("width", radius * 2)
        .attr("height", radius * 2)
      .append("g")
        .attr("transform", "translate(" + radius + "," + radius + ")");

    svg.selectAll(".arc")
        .data(function(d) { return pie(d.ages); })
      .enter().append("path")
        .attr("class", "arc")
        .attr("d", arc)
        .style("fill", function(d) { return color(d.data.name); });

    svg.append("text")
        .attr("dy", ".35em")
        .style("text-anchor", "middle")
        .text(function(d) { return d.State; });
  -}

  type AgeAndPopulation = { name :: String, population :: Int }
  type StateAges = { state :: String, ages :: Array AgeAndPopulation }

  extractDatum :: Foreign -> StateAges
  extractDatum r =
  {
    state : fromRight $ readString $ fromRight $ prop "State" r,
    ages : getAge <$> (filter (/= "State") (fromRight $ keys r))
  } where
    getAge k =  {
                  name : k,
                  population : fromJust $ Int.fromString $ fromRight $ readString $ fromRight $ prop k r
                }

  radius = 74.0
  padding = 10.0

  main = do

    color <- ordinalScale
              .. range $ reverse ["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]

    colorF <- color ... toFunction

    arc <- arc
            .. outerRadius radius
            .. innerRadius (radius - 30.0)

    pieL <- pieLayout
            .. noSort
            .. value (_.population)

    csv "data/donutMultiples.csv" \(Right array) -> do

      let typedData = extractDatum <$> array
          ageNames = (_.name) <$> ((head typedData) . ages)

      color ... domain ageNames

      legend <- rootSelect "body" .. append "svg"
          .. attr "class" "legend"
          .. attr "width" (radius * 2.0)
          .. attr "height" (radius * 2.0)
        .. selectAll "g"
          .. bindData $ reverse ageNames
        .. enter .. append "g"
          .. attr'' "transform" (\_ i -> translateStr 0.0 (i * 20.0) )

      legend ... append "rect"
          .. attr "width" 18.0
          .. attr "height" 18.0
          .. style' "fill" colorF

      legend ... append "text"
          .. attr "x" 24.0
          .. attr "y" 9.0
          .. attr "dy" ".35em"
          .. text' id

      svg <- rootSelect "body" .. selectAll ".pie"
             .. bindData typedData
             .. enter .. append "svg"
              .. attr "class" "pie"
              .. attr "width" (radius * 2.0)
              .. attr "height" (radius * 2.0)
             .. append "g"
              .. attr "transform" (translateStr radius radius)

      svg ... selectAll ".arc"
              .. bindData' (\d -> runPure $ unsafeInterleaveEff (pieL ... pie d.ages) )
              .. enter .. append "path"
                .. attr "class" "arc"
                .. attr "d" arc
                .. style' "fill" (\d -> colorF d.data.name)

      svg ... append "text"
              .. attr "dy" ".35em"
              .. style "text-anchor" "middle"
              .. text' (\d -> d.state)
