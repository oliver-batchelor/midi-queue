{-# LANGUAGE OverloadedStrings #-}

-- |
-- Module      : Example.SQS
-- Copyright   : (c) 2013-2016 Brendan Hay
-- License     : Mozilla Public License, v. 2.0.
-- Maintainer  : Brendan Hay <brendan.g.hay@gmail.com>
-- Stability   : provisional
-- Portability : non-portable (GHC extensions)
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
  messageConsole Oregon "https://sqs.us-west-2.amazonaws.com/900735812162/midi"


messageConsole :: Region -- ^ Region to operate in.
          -> Text   -- ^ Name of the queue to create.
          -> IO ()
messageConsole r url = do
    lgr <- newLogger Error stdout
    env <- newEnv r (FromKeys access secret) <&> set envLogger lgr

    let say = liftIO . Text.putStrLn

    runResourceT . runAWST env . within r $ forever $ do
      say $ "Enter message:"
      message <- liftIO Text.getLine

      void $ send (sendMessage url message)
      say  $ "Sent '" <> message <> "' to Queue URL: " <> url
