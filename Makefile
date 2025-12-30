all:
	@make model MODEL=s0
	@make model MODEL=s1
	@make model MODEL=s2
	@make model MODEL=blt

model:
	xcrun coremlcompiler compile ~/Desktop/Models/mobileclip_$(MODEL)_image.mlpackage Sources/MobileCLIP/Resources
	# xcrun coremlcompiler compile Models/mobileclip_$(MODEL)_text.mlpackage Sources/MobileCLIP/Resources
	# xcrun coremlcompiler generate Models/mobileclip_$(MODEL)_image.mlpackage Sources/MobileCLIP/Models --language Swift
	#xcrun coremlcompiler generate Models/mobileclip_$(MODEL)_text.mlpackage Sources/MobileCLIP/Models --language Swift
