{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module UKB where

import Data.Semigroup
import Data.String
import Control.Monad
import qualified Data.Text as T
import qualified Data.Text.Read as T
import qualified Data.Text.Lazy.Builder as TB
import qualified Data.Text.Lazy.Builder.Int as TB
import qualified Data.Text.Lazy.IO as TLIO
import qualified Data.Text.IO as TIO
import System.Process
import System.IO
import qualified Data.ByteString.Char8 as BS

newtype WordId = WordId Int
               deriving (Eq, Ord, Show)

data InputToken = InputToken !Lemma !POS !WordId
                deriving (Show)
data OutputToken = OutputToken !WordId !ConceptId
                 deriving (Show)

data POS = Noun | Verb | Adj | Adv
         deriving (Eq, Ord, Show, Enum, Bounded)

posChar :: POS -> Char
posChar Noun = 'n'
posChar Verb = 'v'
posChar Adj  = 'a'
posChar Adv  = 'r'

newtype Lemma = Lemma T.Text
              deriving (Eq, Ord, Show, IsString)

newtype ConceptId = ConceptId T.Text
                  deriving (Eq, Ord, Show)

data UKB = UKB Handle Handle -- in out

startUKB :: FilePath -- ^ dictionary
         -> FilePath -- ^ compiled knowledge base
         -> IO UKB
startUKB dictPath kbPath = do
    (Just hIn, Just hOut, _, _) <-
        createProcess (proc "./result/bin/ukb_wsd" args){ std_out = CreatePipe, std_in = CreatePipe }
    hello <- BS.hGetLine hOut
    unless ("!! " `BS.isPrefixOf` hello) $ fail $ "invalid hello sequence: "++show hello
    return $ UKB hIn hOut
  where args = ["--ppr", "-", "-K", kbPath, "-D", dictPath]

closeUKB :: UKB -> IO ()
closeUKB (UKB hIn hOut) = hClose hIn >> hClose hOut

run :: UKB -> [InputToken] -> IO [OutputToken]
run (UKB hIn hOut) toks = do
    TLIO.hPutStr hIn $ TB.toLazyText $ "ctx\n" <> foldMap token toks <> "\n\n\n"
    hFlush hIn
    readResult []
  where
    token (InputToken (Lemma lem) pos (WordId n)) =
        TB.fromText lem <> "#" <> TB.singleton (posChar pos) <> "#" <> TB.decimal n <> "#" <> "1" <> " "

    readResult acc = do
        line <- TIO.hGetLine hOut
        if line == "~~~~~~~~"
            then return $ reverse acc
            else do _:wordId:concept:_ <- pure $ T.words line
                    let Right (n,_) = T.decimal wordId
                    readResult (OutputToken (WordId n) (ConceptId concept) : acc)
