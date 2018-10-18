{-# LANGUAGE FlexibleContexts #-}

import Text.Parsec
import System.Environment (getArgs)

data Tree a = InnerNode a [Tree a] | Leaf a
  deriving Show
  
json:: Show a => Tree a -> String
json (Leaf a) = "{ \"value\": " ++ show a ++ " }"
json (InnerNode a as) = 
  "{ \"value\": " ++ show a ++ ",\"children\": [" ++ showChildren as ++ "] }"
  where showChildren [b]    = json b
        showChildren (b:bs) = json b ++ "," ++ showChildren bs

leaf:: Parsec String st (Tree String)
leaf = Leaf <$> many (noneOf "[.] ")

node:: Parsec String st (Tree String)
node = do
   string "[."
   lhs <- many (noneOf "[.] ")
   char ' '
   rhs <- tree `sepBy` char ' '
   char ']'
   return $ InnerNode lhs (helper rhs)
   where helper [Leaf ""] = []
         helper []        = []
         helper (t:ts)    = t : helper ts
         

tree:: Parsec String st (Tree String)
tree = node <|> leaf

parseTree:: String -> Either ParseError (Tree String)
parseTree = parse tree ""

example:: String
example = "[.Cm7 [.G7 [.Gsus Cm7 [.Gsus [.Fsus [.Ebsus Bbm7 [.Ebsus Dbsus Ebsus ] ] Fsus ] Gsus ] ] [.G7 Cm7 [.G7 [.Ab^7 [.Eb7 Bbm7 Eb7 ] Ab^7 ] [.G7 D%7 G7 ] ] ] ] Cm7 ]"

main = do
  [treeString] <- getArgs
  let (Right tree) = parseTree treeString
  putStr (json tree)