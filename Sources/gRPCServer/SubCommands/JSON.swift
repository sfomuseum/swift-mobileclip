import Foundation
import MobileCLIP
import SwiftProtobuf

func writeResponseAsJSON(rsp: OrgSfomuseumEmbeddingsService_EmbeddingsResponse) throws -> Void {
    
    do {
        var opts = JSONEncodingOptions()
        opts.alwaysPrintInt64sAsNumbers = true
        opts.preserveProtoFieldNames = true
        
        let json = try rsp.jsonString(options: opts)
        let data = json.data(using: .utf8)
        FileHandle.standardOutput.write(data!)
    } catch {
        throw error
    }
}

