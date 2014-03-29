{-# LANGUAGE OverloadedStrings #-}
module UnitTests where

import Test.Tasty
import Test.Tasty.HUnit

import qualified Data.ByteString as B
import qualified Network.HTTP.Types as H
import Network.Wai

import Network.Wai.OAuth
import Network.Wai.OAuth.Types

tests :: TestTree
tests = testGroup "HUnit tests" [
    mkHmacSha1SignatureTest, mkPlainTextSignatureTest, extractOAuthParametersTests
    ]

mkHmacSha1SignatureTest :: TestTree
mkHmacSha1SignatureTest = testCase "HMAC-SHA1 signature" $
    mkSignature HMAC_SHA1 ("kd94hf93k423kf44", "pfkkdhi9sl3r4s00") baseString @?= "QnAoyJcVeC9988ZnawQI+K6XrRA="

mkPlainTextSignatureTest :: TestTree
mkPlainTextSignatureTest = testCase "PLAINTEXT signature" $
    mkSignature Plaintext ("foo", "bar") undefined @?= "foo&bar"

extractOAuthParametersTests :: TestTree
extractOAuthParametersTests = testGroup "OAuth param extraction tests" [
        oauthParameterConsistency
    ]
  where
    duplicateParamsTest = testCase "duplicate parameters"

oauthParameterConsistency :: TestTree
oauthParameterConsistency = testGroup "OAuth parameter consistency" $
    [ testCase "multiple oauth parameter locations" $ tryInOrder params1 params2 [] @?= Left MultipleOAuthParamLocations
    , testCase "detect duplicate parameters" $ tryInOrder params3 [] [] @?= Left (DuplicateParameter "oauth_nonce")
    , testCase "detect unsupported parameters" $ tryInOrder params4 [] [] @?= Left (UnsupportedParameter "oauth_foo")
    ]
  where
    params1 = [("oauth_nonce", "abc123")]
    params2 = [("oauth_timestamp", "1234567")]
    params3 = [("oauth_nonce", "xyz789"), ("oauth_nonce", "abc123")]
    params4 = [("oauth_foo", "bar")]

generateBaseString = undefined
  where
    request = defaultRequest 
        { requestMethod = H.methodGet
        , rawPathInfo = "/"
        , rawQueryString = "?size-original&file=vacation&oauth_consumer_key=dpf43f3p2l4k3l03&oauth_token=nnch734d00sl2jdk&oauth_nonce=kllo9940pd9333jh&oauth_timestamp=1191242096&oauth_signature_method=HMAC-SHA1&oauth_version=1.0&oauth_signature=QnAoyJcVeC9988ZnawQI%2BK6XrRA%3D"
        , isSecure = False
        , requestHeaders = []
        , requestBody = return ()
        , requestHeaderHost = Just "localhost:3000"
        }

baseString :: B.ByteString
baseString = "GET&http%3A%2F%2Flocalhost%3A3000%2F&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_token%3Dnnch734d00sl2jdk%26oauth_version%3D1.0%26size%3Doriginal"


