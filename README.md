# swift-mobileclip

## Motivation

This is a refactoring of the code in the example iOS application provided by the [apple/ml-mobileclip](https://github.com/apple/ml-mobileclip/tree/main) package such that it can be used as standalone library code and in command-line applications.

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
  text (default)          Parse the text of a wall label in to JSON-encoded structured data.
  image                   Parse the text of a wall label in to JSON-encoded structured data.

  See 'embeddings help <subcommand>' for detailed help
```

#### embeddings text

```
$> embeddings text --help
OVERVIEW: Parse the text of a wall label in to JSON-encoded structured data.

USAGE: embeddings text [--encoder_uri <encoder_uri>] [--verbose <verbose>] <args> ...

ARGUMENTS:
  <args>                  The text to generate embeddings for. If "-" then data is read from STDIN. If the first argument is a valid path to a local file then the text of that file will be used.
                          Otherwise all remaining arguments will be concatenated (with a space) and used as the text to generate embeddings for.

OPTIONS:
  --encoder_uri <encoder_uri>
                          The parser scheme is to use for parsing wall label text. (default: s0://)
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
OVERVIEW: Parse the text of a wall label in to JSON-encoded structured data.

USAGE: embeddings image [--encoder_uri <encoder_uri>] --path <path> [--verbose <verbose>]

OPTIONS:
  --encoder_uri <encoder_uri>
                          The parser scheme is to use for parsing wall label text. (default: s0://)
  --path <path>           The path to the image to derive embeddings for.
  --verbose <verbose>     Enable verbose logging (default: false)
  -h, --help              Show help information.
```

For example:

```
$> embeddings image --encoder_uri=blt:///path/to/Models --path test21.png
	
{"created":1767126429,"dimensions":512,"embeddings":[0.052520751953125,-0.127685546875,-0.34765625,0.23779296875,0.409912109375,0.023956298828125,0.62109375,-0.141845703125,-0.0167388916015625,-0.0132293701171875,-0.0684814453125,0.48583984375,-0.29931640625,0.184326171875,-0.0176544189453125,-0.196533203125,0.431884765625,-0.254638671875,0.02398681640625,-0.1324462890625,0.260986328125,0.36669921875,0.1402587890625,-0.390625,0.69970703125,-0.44189453125,-0.1728515625,-0.137451171875,0.35302734375,0.174 ... and so on
```

## See also

* https://github.com/apple/ml-mobileclip/tree/main
* https://huggingface.co/apple/MobileCLIP2-B