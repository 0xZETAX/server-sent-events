-- Haskell with Scotty
{-# LANGUAGE OverloadedStrings #-}

import Web.Scotty
import Data.Aeson
import Data.Time
import Control.Concurrent (threadDelay)
import Control.Monad.IO.Class (liftIO)
import Network.Wai.Middleware.Cors

data Message = Message
  { message :: String
  , timestamp :: String
  } deriving (Show)

instance ToJSON Message where
  toJSON (Message msg ts) = object
    [ "message" .= msg
    , "timestamp" .= ts
    ]

eventsHandler :: ActionM ()
eventsHandler = do
  setHeader "Content-Type" "text/event-stream"
  setHeader "Cache-Control" "no-cache"
  setHeader "Connection" "keep-alive"
  setHeader "Access-Control-Allow-Origin" "*"
  
  -- Send initial message
  text "data: Connected to Haskell Scotty SSE\n\n"
  
  -- This is a simplified version - in practice you'd need
  -- proper streaming support
  liftIO $ do
    putStrLn "Client connected to Haskell SSE"
    streamMessages

streamMessages :: IO ()
streamMessages = do
  now <- getCurrentTime
  let msg = Message "Hello from Haskell Scotty" (show now)
  putStrLn $ "data: " ++ show (encode msg) ++ "\n\n"
  threadDelay 2000000  -- 2 seconds
  streamMessages

main :: IO ()
main = scotty 3014 $ do
  middleware $ cors $ const $ Just simpleCorsResourcePolicy
    { corsRequestHeaders = ["Content-Type"]
    , corsMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    }
  
  get "/events" eventsHandler
  
  -- Note: This is a basic example. For production SSE in Haskell,
  -- consider using libraries like wai-extra or conduit for proper streaming