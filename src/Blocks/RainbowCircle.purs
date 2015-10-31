module Blocks.RainbowCircle where

  import Prelude(return,unit,Unit(),(>>=), bind, id, (++), ($), show, (+), (-), (*), (/))
  import Control.Monad.Eff

  import Math (pi)

  import Graphics.D3.Base
  import Graphics.D3.Color
  import Graphics.D3.Selection
  import Graphics.D3.SVG.Shape
  import Graphics.D3.Util
{-
var π = Math.PI,
    τ = 2 * π,
    n = 500;

var width = 960,
    height = 960,
    outerRadius = width / 2 - 20,
    innerRadius = outerRadius - 80;

d3.select("svg").append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")
  .selectAll("path")
    .data(d3.range(0, τ, τ / n))
  .enter().append("path")
    .attr("d", d3.svg.arc()
        .outerRadius(outerRadius)
        .innerRadius(innerRadius)
        .startAngle(function(d) { return d; })
        .endAngle(function(d) { return d + τ / n * 1.1; }))
    .style("fill", function(d) { return d3.hsl(d * 360 / τ, 1, .5); });

d3.select(self.frameElement).style("height", height + "px");
-}
  

--main :: forall eff. Eff (d3 :: D3 | eff) Unit
  main = do
    let tau = 2.0 * pi
        n = 500.0
        canvasWidth = 960.0
        canvasHeight = 960.0
        outRadius = canvasWidth / 2.0 - 20.0
        inRadius = outRadius - 80.0

    rootSelect "svg" .. append "g"
      .. attr "transform" ("translate(" ++ show (canvasWidth / 2.0) ++ "," ++ show (canvasHeight / 2.0) ++ ")")
      .. selectAll "path"
        .. bindData (range 0.0 tau (tau/n))
      .. enter .. append "path"
        .. (\s -> (arc
                     .. outerRadius outRadius
                     .. innerRadius inRadius
                     .. startAngle' id
                     .. endAngle' (\d -> d + tau / n * 1.1)) .. (\a -> attr "d" a s))
      .. style' "fill" (\d -> hsl (d * 360.0 / tau) 1.0 0.5 ) 
{-
    rootSelect self.frameElement
      .. style "height" show canvasHeight ++ "px"
-}
