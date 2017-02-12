{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import Web.Scotty
import Network.HTTP.Types.Method (StdMethod(..))
import Data.List (intercalate)
import Data.Text.Lazy (pack)
import Data.Monoid ((<>))

import Types
import qualified User


routes :: ScottyM ()
routes = do

    -- All userdefined routes
    foldr1 (>>) (map routeToScotty userdefinedRoutes)

    -- Explorable routes
    addroute GET "/" $ do
        text $ pack $ intercalate "\n" $  "Explorable endpoints:" : (map show allRoutes)

    -- Fallback on no matched route
    notFound $ text "there is no such route."


exampleRoutes :: [Route]
exampleRoutes =
    [ Route GET "/greeting/:name" (do
        name <- param "name"
        text ("Hello " <> name <> "!"))
    ]


-- Define your routes here.
allRoutes :: [Route]
allRoutes = concat [ exampleRoutes
                   , User.routes
                   ] -- Add routes from other modules here


main :: IO ()
main = do
    putStrLn "Starting server..."
    scotty 3000 routes
