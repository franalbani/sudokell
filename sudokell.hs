import Debug.Trace (trace)
import Control.Parallel.Strategies (parMap, rdeepseq)
import Control.Monad (guard, liftM)
import Data.List (sort)
import Data.List.Split (chunksOf)
import System.Environment (getArgs)


type Grilla = [[Int]]

-- i, p: filas
-- j, q: columnas

-- Extraer el bloque al que pertenece la celda i j
-- Esta función tiene a su tercer argumento implícito
bloque :: Int -> Int -> Grilla -> Grilla
bloque i j = map (take 3 . drop (3*q)) . take 3 . drop (3*p)
    where
          p = div i 3
          q = div j 3

-- ¿Tiene sentido poner 'n' en la posición i, j?
tieneSentido :: Grilla -> Int -> Int -> Int -> Bool
tieneSentido g i j n = all (/=n) (fila ++ colu ++ bloq)
    where fila = g !! i
          colu = map (!! j) g
          bloq = concat $ bloque i j g

-- Obtener nueva grilla poniendo 'n' en la posición 'i' 'j' de 'g'
nuevo :: Grilla -> Int -> Int -> Int -> Grilla
nuevo g i j n = take i g ++
                [take j (g !! i) ++ [n] ++ drop (j + 1) (g !! i)] ++
                drop (i + 1) g

-- Obtener lista de celdas vacías:
huecos :: Grilla -> [(Int, Int)]
huecos g = [(i, j) | i <- [0..8], j <- [0..8], (g !! i) !! j == 0]

-- Buscar por fuerza bruta recursiva y paralelamente
-- soluciones a partir de una grilla g incompleta.
soluciones :: Grilla -> [Grilla]
soluciones g =
    case hs of
        [] -> if chequear g then [g] else []
        ((i, j):_) -> do concat $ parMap rdeepseq soluciones [nuevo g i j n | n <- [1..9], tieneSentido g i j n]
    where hs = huecos g -- (mytrace g)

-- Chequear si la grilla g es una solución válida
chequear :: Grilla -> Bool
chequear g = all (==[1..9]) $ map sort $ (filas ++ columnas ++ bloques)
    where filas = g
          columnas = [map (!! j) filas | j <- [0..8]]
          bloques = map concat [bloque i j g | i <- [0, 3, 6], j <- [0, 3, 6]]

-- Recibe 81 números desde la terminal ordenados
-- por filas y muestra todas las soluciones encontradas
main = do   input <- liftM (map (read :: String -> Int)) getArgs
            if (length input /= 9*9) then
                putStrLn "ERROR: Faltan números"
            else do
                mapM_ guard tests
                let sols = soluciones (chunksOf 9 input)
                mapM_ (putStr . pp) sols
                putStr $ "Soluciones: " ++ (show $ length sols)


 -- Ejemplos para ejecutar tests:
sudoku :: Grilla
sudoku = [[1, 0, 0,  0, 0, 0,  0, 4, 5],
          [4, 0, 0,  7, 0, 0,  0, 0, 0],
          [0, 5, 7,  0, 0, 0,  3, 8, 0],

          [8, 0, 0,  5, 9, 0,  4, 0, 0],
          [0, 0, 6,  0, 2, 0,  5, 0, 0],
          [0, 0, 9,  0, 7, 3,  0, 0, 8],

          [0, 1, 5,  0, 0, 0,  8, 6, 0],
          [0, 0, 0,  0, 0, 8,  0, 0, 7],
          [9, 7, 0,  0, 0, 0,  0, 0, 4]]

sudoku2 = foldl (\s (i, j, n) -> nuevo s i j n) sudoku
          [(8, 2, 8), (0, 6, 7), (6, 5, 7), (4, 0, 7), (3, 2, 1), (7, 2, 4), (5, 0, 5),
           (2, 0, 6), (7, 1, 6)]

sudoku3 = foldl (\s (i, j, n) -> nuevo s i j n) sudoku
          [(0, 0, 0), (0, 7, 0), (1, 0, 0)] -- , (1, 3, 0)]
--, (3, 2, 1), (7, 2, 4), (5, 0, 5),
  --         (2, 0, 6), (7, 1, 6)]

tests = [
    (bloque 7 4 sudoku) == [[0, 0, 0], [0, 0, 8], [0, 0, 0]],
    (bloque 4 3 sudoku) == [[5, 9, 0], [0, 2, 0], [0, 7, 3]],
    (huecos sudoku) == [(0,1),(0,2),(0,3),(0,4),(0,5),(0,6),(1,1),(1,2),(1,4),(1,5),(1,6),(1,7),(1,8),(2,0),(2,3),(2,4),(2,5),(2,8),(3,1),(3,2),(3,5),(3,7),(3,8),(4,0),(4,1),(4,3),(4,5),(4,7),(4,8),(5,0),(5,1),(5,3),(5,6),(5,7),(6,0),(6,3),(6,4),(6,5),(6,8),(7,0),(7,1),(7,2),(7,3),(7,4),(7,6),(7,7),(8,2),(8,3),(8,4),(8,5),(8,6),(8,7)],
    not $ tieneSentido sudoku 2 5 3,
    ((nuevo sudoku 6 8 5) !! 6) !! 8 == 5]

-- Pretty Print
pp = map (\c -> if elem c "," then ' ' else c) . concat . map ((++ "\n") . show)
mytrace g = trace (pp g ++ "huecos: " ++ (show $ length $ huecos g)) g

