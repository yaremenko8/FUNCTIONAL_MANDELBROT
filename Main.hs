module Main where

import Mandelbrot
import Data.Complex
import System.Environment

main = do args <- getArgs 
          let {n = read $ args !! 0; m = read $ args !! 1; x = read $ args !! 2; y = read $ args !! 3; a = read $ args !! 4; i = read $ args !! 5} in
             quickBMP $ preset2 (n, m, ((x):+(y)), a) i


