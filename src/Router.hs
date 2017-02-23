module Router where

import Web.Scotty
import Network.HTTP.Types.Method (StdMethod(..))
import Data.Text.Lazy (pack, intercalate)
import Data.Monoid ((<>))

import Types
import qualified User


routes :: ScottyM ()
routes = do

    -- All userdefined routes
    foldr1 (>>) $ map routeToScotty userdefinedRoutes

    -- Explorable routes
    addroute GET "/" $ text $ 
        intercalate "\n" $ "Explorable endpoints:" : (map (pack . show) userdefinedRoutes)

    -- Fallback on no matched route
    notFound $ text "there is no such route."


exampleRoutes :: [Route]
exampleRoutes =
    [ Route GET "/greeting/:name" (do
        name <- param "name"
        text ("Hello " <> name <> "!"))
    ]


-- Define your routes here.
userdefinedRoutes :: [Route]
userdefinedRoutes = concat [exampleRoutes, User.routes]
