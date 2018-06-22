{-# LANGUAGE OverloadedStrings #-}

import Control.Monad
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified POS
import UKB

main :: IO ()
main = do
    tagger <- POS.startTagger
    ukb <- startUKB "wnet30_dict.txt" "wn30+gloss.bin"
    forever $ do
        test <- TIO.getLine
        tags <- POS.posTag tagger test
        print tags
        let tokens =
                [ UKB.InputToken (Lemma tok) pos' (WordId n)
                | (n, (tok, pos)) <- zip [0..] tags
                , Just pos' <- pure $ toUkbPos pos
                ]

        res <- run ukb tokens
        print res

toUkbPos :: POS.POS -> Maybe UKB.POS
toUkbPos pos =
    case pos of
      POS.Noun      -> Just UKB.Noun
      POS.Verb      -> Just UKB.Verb
      POS.Adjective -> Just UKB.Adj
      POS.Adverb    -> Just UKB.Adv
      _             -> Nothing

testTokens :: [InputToken]
testTokens =
    [ InputToken "man" Noun (WordId 1)
    , InputToken "kill" Verb (WordId 2)
    , InputToken "cat" Noun (WordId 3)
    , InputToken "hammer" Noun (WordId 4)
    ]
