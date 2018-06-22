{-# LANGUAGE OverloadedStrings #-}

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

posTag :: Tagger -> T.Text -> IO [(T.Text, POS)]
posTag (Tagger hIn hOut) text = do
    TIO.hPutStrLn hIn text
    hFlush hIn
    out <- BS.hGetLine hOut
    Just tokens <- pure $ decode $ BSL.fromStrict out
    return $ map (second toPOS) tokens

toPOS :: T.Text -> POS
toPOS "NN"   = Noun
toPOS "NNS"  = Noun
toPOS "NNP"  = Noun
toPOS "VB"   = Verb
toPOS "VBZ"  = Verb
toPOS "VBP"  = Verb
toPOS "VBD"  = Verb
toPOS "PRP"  = Preposition
toPOS "PRP$" = Preposition
toPOS "JJ"   = Adjective
toPOS "EX"   = Other  -- existential?
toPOS "LS"   = Other
toPOS "IN"   = Other  -- "in"
toPOS "POS"  = Other  -- possessive
toPOS "DT"   = Other  -- determiner
toPOS "WDT"  = Other
toPOS "RB"   = Other
toPOS "CC"   = Other
toPOS "TO"   = Other
toPOS "."    = Other
toPOS ","    = Other
toPOS other  = error $ "unknown POS: "++show other

startTagger :: IO Tagger
startTagger = do
    (Just hIn, Just hOut, _, _) <-
        createProcess $ (proc "./pos-tag.py" []){ std_out = CreatePipe, std_in = CreatePipe }
    return $ Tagger hIn hOut

closeTagger :: Tagger -> IO ()
closeTagger (Tagger hIn hOut) = hClose hIn >> hClose hOut
