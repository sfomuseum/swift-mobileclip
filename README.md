# swift-mobileclip

Swift package to use the MobileCLIP CoreML models in library code and command line applications.

## Motivation

This is a refactoring of the code in the example iOS application provided by the [apple/ml-mobileclip](https://github.com/apple/ml-mobileclip/tree/main) package such that it can be used as standalone library code and in command-line applications.

Currently this code targets the [apple/coreml-mobileclip](https://huggingface.co/apple/coreml-mobileclip) encoders. [mobileclip2](https://huggingface.co/collections/apple/mobileclip2) support is planned but I haven't gotten around to [figuring out how to do that](https://huggingface.co/blog/fguzman82/frompytorch-to-coreml#case-study-clip-finder-image-encoder-conversion) yet.

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

## See also

* https://github.com/apple/ml-mobileclip
* https://huggingface.co/apple/coreml-mobileclip
* https://huggingface.co/apple/MobileCLIP2-B
