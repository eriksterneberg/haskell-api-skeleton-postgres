{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}
module Main (main) where

import           Test.Hspec
import           Test.Hspec.Wai
-- import           Test.Hspec.Wai.JSON

import           Network.Wai (Application)
import qualified Web.Scotty as S
import           Data.Aeson (Value(..), object, (.=))

import Types
import qualified User

main :: IO ()
main = hspec spec


app :: IO Application
app = S.scottyApp $ do
  foldr1 (>>) $ map routeToScotty User.routes

  -- S.get "/some-json" $ do
    -- S.json $ object ["foo" .= Number 23, "bar" .= Number 42]


spec :: Spec
spec = with app $ do

  describe "GET /" $ do
    it "responds with 200" $ do
      get "/user" `shouldRespondWith` 200

  -- describe "GET /user" $ do
  --   it "responds with 200" $ do
  --     get "/user" `shouldRespondWith` 200
