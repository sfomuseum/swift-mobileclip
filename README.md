# swift-mobileclip

Swift package to use the MobileCLIP CoreML models in library code and command line applications.

## Motivation

This is a refactoring of the code in the example iOS application provided by the [apple/ml-mobileclip](https://github.com/apple/ml-mobileclip/tree/main) package such that it can be used as standalone library code and in command-line applications.

Currently this code targets the [apple/coreml-mobileclip](https://huggingface.co/apple/coreml-mobileclip) encoders. [mobileclip2](https://huggingface.co/collections/apple/mobileclip2) support is planned but I haven't gotten around to [figuring out how to do that](https://huggingface.co/blog/fguzman82/frompytorch-to-coreml#case-study-clip-finder-image-encoder-conversion) yet.

There is a short list of "known knowns" or "gotchas" at the end of this document. Overall this package works as expected but there are a few circumstances where it won't (yet).

## Models

The MobileCLIP models weigh in at about ~750MB so they are NOT bundled with this package. The idea is that you will download them locally to the same host that is running the applications provided by this package.

For example, following the [download instructions](https://huggingface.co/apple/coreml-mobileclip#download) from Apple's HuggingFace account:

```
$> mkdir -p /usr/local/data/mobileclip
$> huggingface-cli download --local-dir /usr/local/data/mobileclip apple/coreml-mobileclip
```

This will store the MobileCLIP `.mlpackage` files in the `/usr/local/data/mobileclip` folder. At this point these files need to be compiled in to `.modelc` files. The easiest way to do this is using the handy `compile-all` Makefile target provided by this package. For example:

```
$> make complile-all SOURCE=/usr/local/data/mobileclip TARGET=/usr/local/data/mobileclip
```

To load a specific model compile its URI scheme (`s0`, `s1`, `s2` or `blt`) along with the path to the folder where your models are stored. For example:

```
import MobileCLIP
import Foundation

let models = URL(string: "s0:///usr/local/data/mobileclip")
let encoder = try NewCLIPEncoder(models!)
```

_Error handling removed for the sake of brevity._

If you pass in a model URI without specifying a path to a local model directory then the code will assume the models have been embedded as a "resource" in the application's main "Bundle". To be honest, I haven't figured out how to make this work. I am assuming it has something to do with how things are referenced in `Package.swift` but I never manage to compile an executable with the models _bundled_ in to the application itself.

### Model Swift wrappers

Auto-generated Swift code to work with the models is included by default in [Sources/MobileCLIP/Models](Sources/MobileCLIP/Models). If you need or want to recompile that code from the source models the easiest way is to use the handy `generate-all` Makefile target provided by this package. For example:

```
$> make generate-all SOURCE=/usr/local/data/mobileclip
```

## Usage

The easiest way to use this package in library code is to use the public `ComputeTextEmbeddings` and `ComputeImageEmbeddings` methods which have modest signatures:

```
ComputeTextEmbeddings(encoder: CLIPEncoder, tokenizer: CLIPTokenizer, text: String) async -> Result<Embeddings, Error>

ComputeImageEmbeddings(encoder: CLIPEncoder, image: CGImage) async -> Result<Embeddings, Error>
```

For example:

```
import MobileCLIP
import Foundation

let models = URL(string: "s0:///usr/local/data/mobileclip")
let encoder = try NewCLIPEncoder(models!)
let tokenizer = CLIPTokenizer()

let rsp = await ComputeTextEmbeddings(encoder: encoder, tokenizer: tokenizer, text: "Hello world")
```

_Error handling removed for the sake of brevity._

Both methods return a Swift `Result` instance which, if successful, will yield an `Embeddings` struct:

```
public struct Embeddings: Codable {
    var embeddings: [Double] 
    var dimensions: Int
    var model: String
    var type: String
    var created: Int64
}
```

## Tools

```
$> swift package clean && swift build -c release
...
Building for production...
[21/21] Linking embeddings
Build complete! (11.74s)
```

### embeddings

```
$> embeddings --help
USAGE: embeddings <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  text (default)          Derive vector embeddings for a text.
  image                   Derive vector embeddings for an image.

  See 'embeddings help <subcommand>' for detailed help.
```

#### embeddings text

```
$> embeddings text --help
OVERVIEW: Derive vector embeddings for a text.

USAGE: embeddings text [--encoder_uri <encoder_uri>] [--verbose <verbose>] <args> ...

ARGUMENTS:
  <args>                  The text to generate embeddings for. If "-" then data is read from STDIN. If the first argument is a valid path to a local file then the text of that file will be used.
                          Otherwise all remaining arguments will be concatenated (with a space) and used as the text to generate embeddings for.

OPTIONS:
  --encoder_uri <encoder_uri>
                          The URI for MobileCLIP encoder to use. URIs take the form of {SCHEME}://{OPTIONAL_PATH} where {SCHEME} is one of s0,s1,s2 or blt and {OPTIONAL_PATH} is the path to a local
                          directory containing compiled MobileCLIP CoreML model files. If {OPTIONAL_PATH} is empty then models will loaded from the application's default Bundle. (default: s0://)
  --verbose <verbose>     Enable verbose logging (default: false)
  -h, --help              Show help information.
```

For example:

```
$> echo "foo bar" | ~/Desktop/embeddings text --encoder_uri=blt:///Users/asc/Desktop/Models -

{"created":1767126705,"dimensions":512,"embeddings":[0.3380882441997528,0.0016204193234443665,0.29400724172592163,0.04641421139240265,0.44203507900238037,0.2812459170818329,0.39650189876556396,0.8364536762237549,0.15395629405975342,0.5167428255081177,-0.05710022896528244,0.009208053350448608,-0.16449031233787537,-0.7388787269592285,0.5633238554000854,0.11071761697530746,-0.046208396553993225,0.03453977406024933,0.030106760561466217,-0.3305387794971466,0.0020788758993148804,-0.3... and so on
```

#### embeddings image

```
$> embeddings image --help
OVERVIEW: Derive vector embeddings for an image.

USAGE: embeddings image [--encoder_uri <encoder_uri>] --path <path> [--verbose <verbose>]

OPTIONS:
  --encoder_uri <encoder_uri>
                          The URI for MobileCLIP encoder to use. URIs take the form of {SCHEME}://{OPTIONAL_PATH} where {SCHEME} is one of s0,s1,s2 or blt and {OPTIONAL_PATH} is the path to a local
                          directory containing compiled MobileCLIP CoreML model files. If {OPTIONAL_PATH} is empty then models will loaded from the application's default Bundle. (default: s0://)
  --path <path>           The path to the image to derive embeddings from.
  --verbose <verbose>     Enable verbose logging (default: false)
  -h, --help              Show help information.
```

For example:

```
$> embeddings image --encoder_uri=blt:///path/to/Models --path test21.png
	
{"created":1767126429,"dimensions":512,"embeddings":[0.052520751953125,-0.127685546875,-0.34765625,0.23779296875,0.409912109375,0.023956298828125,0.62109375,-0.141845703125,-0.0167388916015625,-0.0132293701171875,-0.0684814453125,0.48583984375,-0.29931640625,0.184326171875,-0.0176544189453125,-0.196533203125,0.431884765625,-0.254638671875,0.02398681640625,-0.1324462890625,0.260986328125,0.36669921875,0.1402587890625,-0.390625,0.69970703125,-0.44189453125,-0.1728515625,-0.137451171875,0.35302734375,0.174 ... and so on
```

### embeddings-grpcd

```
$> embeddings-grpcd -h
USAGE: server <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  serve (default)         gRPC server for deriving vector embeddings from an image or text.
  image                   gRPC client to derive vector embeddings for an image.
  text                    gRPC client to derive vector embeddings for a text.

  See 'server help <subcommand>' for detailed help.
```

#### embeddings-grpcd serve

```
$> embeddings-grpcd serve -h
OVERVIEW: gRPC server for deriving vector embeddings from an image or text.

USAGE: server serve [--models <models>] [--host <host>] [--port <port>] [--max_receive_message_length <max_receive_message_length>] [--tls_certificate <tls_certificate>] [--tls_key <tls_key>] [--verbose <verbose>]

OPTIONS:
  --models <models>       The path to the directory containing the MobileCLIP ".modelc" files. If empty then it will be assumed that those models have been bundled as application resources and will
                          be available from the main "Bundle".
  --host <host>           The host name to listen for new connections (default: 127.0.0.1)
  --port <port>           The port to listen on (default: 8080)
  --max_receive_message_length <max_receive_message_length>
                          Sets the maximum message size in bytes the server may receive. If 0 then the swift-grpc defaults will be used. (default: 0)
  --tls_certificate <tls_certificate>
                          The TLS certificate chain to use for encrypted connections
  --tls_key <tls_key>     The TLS private key to use for encrypted connections
  --verbose <verbose>     Enable verbose logging (default: false)
  -h, --help              Show help information.
```

#### embeddings-grpcd text

```
$> embeddings-grpcd text -h
OVERVIEW: gRPC client to derive vector embeddings for a text.

USAGE: server text [--host <host>] [--port <port>] [--model <model>] [--verbose <verbose>] <args> ...

ARGUMENTS:
  <args>                  The text to generate embeddings for. If "-" then data is read from STDIN. If the first argument is a valid path to a local file then the text of that file will be used.
                          Otherwise all remaining arguments will be concatenated (with a space) and used as the text to generate embeddings for.

OPTIONS:
  --host <host>           The host name for the gRPC server. (default: 127.0.0.1)
  --port <port>           The port for the gRPC server. (default: 8080)
  --model <model>         The name of the model to use when generating embeddings. Valid options are: s0, s1, s2, blt. (default: s0)
  --verbose <verbose>     Enable verbose logging (default: false)
  -h, --help              Show help information.
```

#### embeddings-grpcd image

```
$> embeddings-grpcd image -h
OVERVIEW: gRPC client to derive vector embeddings for an image.

USAGE: server image [--host <host>] [--port <port>] [--model <model>] [--verbose <verbose>] --image <image>

OPTIONS:
  --host <host>           The host name for the gRPC server. (default: 127.0.0.1)
  --port <port>           The port for the gRPC server. (default: 8080)
  --model <model>         The name of the model to use when generating embeddings. Valid options are: s0, s1, s2, blt. (default: s0)
  --verbose <verbose>     Enable verbose logging (default: false)
  --image <image>         The image file to derive embeddings for.
  -h, --help              Show help information.
```

## Known-knowns

### Text inputs have a hard limit of 77 characters

The length of texts used to generate text embeddings is capped at 77. This number _appears_ to be hardcoded in the MobileCLIP models themselves. I don't know why. I would like this number to be configurable but haven't figured out how yet.

### The `mobileclip_*` packages are not "Sendable"

The `Models/mobileclip_*.swift` packages autogenerated by the `xcrun coremlcompiler generate` command produce code which is not "Sendable".

This means it is not yet possible to store cached instances of `CLIPEncoder` implementations which means that the models themselves are instantiated each time a set of embeddings is calculated.

This is not great from a performance perspective but after a number of attempts at finding ways to cache those implementations while making the compiler happy I have set the problem aside for the time being. Any pointers or suggestions would be greatly appreciated.

### No support for MobileCLIP2

As mentioned above there is not support for the MobileCLIP2 models yet. I would like to add them but I need to figure out how to convert in to CoreML models. Again, any pointers or suggestions would be greatly appreciated.

## Clients

* Go – [sfomuseum/go-mobileclip](https://github.com/sfomuseum/go-mobileclip)

## See also

* https://github.com/apple/ml-mobileclip
* https://huggingface.co/apple/coreml-mobileclip
* https://huggingface.co/apple/MobileCLIP2-B
