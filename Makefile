compile-all:
	@make compile MODEL=s0
	@make compile MODEL=s1
	@make compile MODEL=s2
	@make compile MODEL=blt

generate-all:
	@make generate MODEL=s0
	@make generate MODEL=s1
	@make generate MODEL=s2
	@make generate MODEL=blt

compile:
	xcrun coremlcompiler compile ~/Desktop/Models/mobileclip_$(MODEL)_image.mlpackage Sources/MobileCLIP/Resources
	xcrun coremlcompiler compile ~/Desktop/Models/mobileclip_$(MODEL)_text.mlpackage Sources/MobileCLIP/Resources

generate:
	xcrun coremlcompiler generate ~/Desktop/Models/mobileclip_$(MODEL)_image.mlpackage Sources/MobileCLIP/Models --language Swift
	xcrun coremlcompiler generate ~/Desktop/Models/mobileclip_$(MODEL)_text.mlpackage Sources/MobileCLIP/Models --language Swift
