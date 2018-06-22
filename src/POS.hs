{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}

#ifndef POS_TAG_PATH
#define POS_TAG_PATH "pos-tag.py"
#endif

module POS
    ( Tagger
    , POS(..)
    , startTagger
    , closeTagger
    , posTag
    ) where

import Data.Bifunctor
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy.Char8 as BSL
import Data.Aeson
import System.Process
import System.IO

data POS = Noun | Verb | Adjective | Adverb | Preposition | Other
         deriving (Eq, Ord, Show, Bounded, Enum)
data Tagger = Tagger Handle Handle

newtype Request = Request T.Text

instance ToJSON Request where
    toJSON (Request s) = object [ "text" .= s ]

posTag :: Tagger -> T.Text -> IO [(T.Text, POS)]
posTag (Tagger hIn hOut) text = do
    BSL.hPutStrLn hIn $ encode $ Request text
    hFlush hIn
    out <- BS.hGetLine hOut
    Just tokens <- pure $ decode $ BSL.fromStrict out
    return $ map (second toPOS) tokens

-- | See
-- https://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html
toPOS :: T.Text -> POS
toPOS x =
    case T.head x of
      'N' -> Noun
      'V' -> Verb
      'J' -> Adjective
      'R' -> Adverb
      _   -> Other

startTagger :: IO Tagger
startTagger = do
    (Just hIn, Just hOut, _, _) <-
        createProcess $ (proc POS_TAG_PATH []){ std_out = CreatePipe, std_in = CreatePipe }
    return $ Tagger hIn hOut

closeTagger :: Tagger -> IO ()
closeTagger (Tagger hIn hOut) = hClose hIn >> hClose hOut
