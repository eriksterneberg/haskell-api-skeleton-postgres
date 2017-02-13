module Types where

import Web.Scotty
import Web.Scotty.Internal.Types (RoutePattern(..))
import Network.HTTP.Types.Method (StdMethod(..))
import Data.Text.Lazy (unpack)


type Verb = RoutePattern -> ActionM () -> ScottyM ()


data Route = Route { method :: StdMethod
                   , pattern :: RoutePattern
                   , action :: ActionM ()
                   }


instance Show Route where
    show (Route method' (Capture pattern') _) = (show method') ++ " " ++ unpack pattern'
    show (Route method' (Literal pattern') _) = (show method') ++ " " ++ unpack pattern'
    show _ = "<unknown>"


routeToScotty :: Route -> ScottyM ()
routeToScotty (Route method' pattern' action') = (addroute method') pattern' action'
