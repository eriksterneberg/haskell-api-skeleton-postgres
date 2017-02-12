{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import GHC.Generics

import Web.Scotty
import Web.Scotty.Internal.Types (ScottyT, RoutePattern(..))
import Network.HTTP.Types.Method (StdMethod(..))

import Data.List (intercalate)
import Data.Text.Lazy (unpack, pack)
import Data.Monoid ((<>))
import Data.Aeson (FromJSON, ToJSON)
data User = User { userId :: Int
                 , userName :: String
                 } deriving (Show, Generic)

instance ToJSON User
instance FromJSON User


routes :: ScottyM ()
routes = do

    -- All userdefined routes
    foldr1 (>>) (map routeToScotty userdefinedRoutes)

    -- Explorable routes
    addroute GET "/" $ do
        text $ pack $ intercalate "\n" $  "Explorable endpoints:" : (map show userdefinedRoutes)

    -- Fallback on no matched route
    notFound $ text "there is no such route."


type Verb = RoutePattern -> ActionM () -> ScottyM ()


data Route = Route { method :: StdMethod
                   , pattern :: RoutePattern
                   , action :: ActionM ()
                   }


instance Show Route where
    show (Route method (Capture pattern) _) =
        (show method) ++ " " ++ unpack pattern


routeToScotty :: Route -> ScottyM ()
routeToScotty (Route method pattern action) = (addroute method) pattern action


main :: IO ()
main = do
    putStrLn "Starting server..."
    scotty 3000 routes


-- Define your routes here.
userdefinedRoutes :: [Route]
userdefinedRoutes = 
    [ Route GET "/test" $ text "test"

    , Route GET "/greeting/:name" (do
        name <- param "name"
        text ("Hello " <> name <> "!"))

    -- User related routes
    , Route GET "/user" $ json allUsers  -- all users
    , Route GET "/user/:id" (do
        id' <- param "id"
        json (filter (matchesId id') allUsers)) -- one user
    , Route POST "/user" (do
        user <- jsonData :: ActionM User
        json user)
    ]


jenny :: User
jenny = User 1 "Jenny Doe"


bob :: User
bob = User 2 "Bob Doe"


allUsers :: [User]
allUsers = [bob, jenny]


matchesId :: Int -> User -> Bool
matchesId id' user = userId user == id'
