module Mandelbrot where

import Codec.Picture
import Control.Parallel.Strategies
import Control.DeepSeq
import Data.Complex
import Data.Fixed
import Data.Word


firstMatch :: (a -> Bool) -> [a] -> Maybe (Int, a) 
firstMatch _    [] = Nothing
firstMatch cond (x:xs)
    | cond x    = Just (0, x)
    | otherwise = do {(a, b) <- firstMatch cond xs; Just (a + 1, b)} 

absSqr :: (RealFloat a) => Complex a -> a
absSqr x = ((realPart x) ** 2) + ((imagPart x) ** 2)

thrldsqr :: (RealFloat a) => a
thrldsqr = 16

mandelbrot :: (RealFloat a) => Int -> Complex a -> Maybe (Int, Complex a)
mandelbrot i a = firstMatch (\x -> absSqr x > thrldsqr) $ take (i + 1) $ iterate (\z -> z^2 + a) 0


type SubSampling a = Int -> a -> Complex a -> Maybe (Int, a)

ssSingle :: (RealFloat a) => SubSampling a
ssSingle i _ node = do {(a, b) <- mandelbrot i node; Just (a, magnitude b)}


type Smoothing a = Maybe (Int, a) -> Maybe a

smLog :: (RealFloat a) => Smoothing a
smLog Nothing       = Nothing
smLog (Just (n, a)) = Just $ (fromIntegral $ n + 1) - (log (log a) / log 2)


type ColorScheme a = Maybe a -> PixelRGB8

-- Hue is to be expressed in degrees
-- All other values are normalised by 1
hsv2rgb :: (RealFloat a) => (a, a, a) -> PixelRGB8
hsv2rgb (h0, s, v) = PixelRGB8 (nrm r') (nrm g') (nrm b') where
    h     = h0 `mod'` 360
    c     = v * s
    x     = c * (1 - abs (((h / 60) `mod'` 2) - 1))
    m     = v - c
    nrm p = floor $ (p + m) * 255
    (r', g', b')
        | h < 60  = (c, x, 0)
        | h < 120 = (x, c, 0)
        | h < 180 = (0, c, x)
        | h < 240 = (0, x, c)
        | h < 300 = (x, 0, c)
        | h < 360 = (c, 0, x)

csHue1 :: (RealFloat a) => ColorScheme a
csHue1 Nothing   = PixelRGB8 0 0 0
csHue1 (Just a)  = hsv2rgb (a * 100, 1, 0.7)

csHue2 :: (RealFloat a) => ColorScheme a
csHue2 Nothing  = PixelRGB8 0 0 0
csHue2 (Just a) = hsv2rgb (a * 17, 1, 0.5 + ((1 + sin a) / 4)) 

type Grid a = (Int, Int, (Complex a), a)

compGrid :: (RealFloat a) => Grid a -> [[Complex a]]
compGrid (n, m, tlp, xlen) = take m $ iterate (map $ (+) (0:+(-r))) frow where
    r    = xlen / (fromIntegral (n - 1))
    frow = take n $ iterate ((+) (r:+0)) tlp 


type Generator a = Grid a -> Int -> Image PixelRGB8

toW8 :: Pixel8 -> Word8
toW8 x = x

instance NFData PixelRGB8 where 
    rnf a = seq a ()

genRGBMtx :: (RealFloat a) => SubSampling a -> Smoothing a -> ColorScheme a -> Generator a
genRGBMtx ss sm cs grid@(n, m, _, xlen) i = generateImage (\y x -> mtx !! x !! y) n m where
    mtx = parMap rdeepseq (map $ cs . sm . (ss i r)) $ compGrid grid
    r   = xlen / (fromIntegral (n - 1))
    
preset1 :: (RealFloat a) => Generator a
preset1 = genRGBMtx ssSingle smLog csHue1 

preset2 :: (RealFloat a) => Generator a
preset2 = genRGBMtx ssSingle smLog csHue2

defFN = "mb.bmp"

quickBMP :: Image PixelRGB8 -> IO ()
quickBMP img = saveBmpImage defFN (ImageRGB8 img)

defFNGIF = "mb.gif"

quickGIF :: Image PixelRGB8 -> IO ()
quickGIF img = case saveGifImage defFNGIF (ImageRGB8 img) of
    Left  a -> putStr a
    Right b -> b


