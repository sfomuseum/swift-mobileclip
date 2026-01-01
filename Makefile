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
	xcrun coremlcompiler compile $(SOURCE)/mobileclip_$(MODEL)_image.mlpackage $(TARGET)
	xcrun coremlcompiler compile $(SOURCE)/mobileclip_$(MODEL)_text.mlpackage $(TARGET)

generate:
	xcrun coremlcompiler generate $(SOURCE)/mobileclip_$(MODEL)_image.mlpackage Sources/MobileCLIP/Models --language Swift
	xcrun coremlcompiler generate $(SOURCE)/mobileclip_$(MODEL)_text.mlpackage Sources/MobileCLIP/Models --language Swift

# https://swiftpackageindex.com/grpc/grpc-swift-protobuf/2.1.2/documentation/grpcprotobuf/code-generation-with-protoc

protoc:
	protoc \
		--swift_out=. \
		--swift_opt=Visibility=Public \
		--grpc-swift-2_out=. \
		--grpc-swift-2_opt=Visibility=Public \
		Sources/Protos/embeddings_service/embeddings_service.proto
