{-# LANGUAGE OverloadedStrings #-}


--
module Main where

import           Control.Lens
import           Control.Monad
import           Control.Monad.IO.Class
import           Control.Monad.Trans.AWS
import           Data.Monoid
import           Data.Text               (Text)
import qualified Data.Text               as Text
import qualified Data.Text.IO            as Text
import           Network.AWS.SQS
import           System.IO



access = AccessKey "AKIAJYSWT5EKWOTWTGVA"
secret = SecretKey "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"

main = do
  server Oregon "https://sqs.us-west-2.amazonaws.com/900735812162/midi"


server :: Region -- ^ Region to operate in.
          -> Text   -- ^ Name of the queue to create.
          -> IO ()
server r url  = do
    lgr <- newLogger Debug stdout
    env <- newEnv r (FromKeys access secret) <&> set envLogger lgr

    let say = liftIO . Text.putStrLn

    runResourceT . runAWST env . within r $ forever $ do

        ms  <- send (receiveMessage url & rmMaxNumberOfMessages ?~ 1)
        forM_ (ms ^. rmrsMessages) $ \m ->
            say $ "Received Message: " <> Text.pack (show m)
