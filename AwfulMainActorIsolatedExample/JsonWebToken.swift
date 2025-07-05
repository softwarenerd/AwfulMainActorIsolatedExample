import Foundation

struct Claims: Codable {
    let sub: UUID
}

struct JsonWebToken: Codable {
    let claims: Claims
    let accountIdentifier1: UUID
    
    // ❗Swift 6 erroneously thinks this is main actor-isolated!!!
    init(claims: Claims) {
        self.claims = claims
        self.accountIdentifier1 = claims.sub
    }

    // ❗Swift 6 erroneously thinks this is main actor-isolated!!!
    var accountIdentifier2: UUID {
        return claims.sub
    }
}

struct Session {
    let jsonWebToken: JsonWebToken
}

actor BackgroundWorker {
    func test1() {
        // ❌ This results in an error in Swift 6:
        // Call to main actor-isolated initializer 'init(claims:)' in a synchronous actor-isolated context; this is an error in the Swift 6 language mode.
        let jsonWebToken = JsonWebToken(claims: Claims(sub: UUID()))
        
        // This is OK.
        print("Account ID:: \(jsonWebToken.accountIdentifier1)")

        // ❌ This results in an error in Swift 6:
        // Main actor-isolated property 'accountIdentifier' can not be referenced on a nonisolated actor instance; this is an error in the Swift 6 language mode.
        print("Account ID:: \(jsonWebToken.accountIdentifier2)")
    }
    
    func test2(session: Session) {
        // This is OK.
        let accountIdentifier1 = session.jsonWebToken.accountIdentifier1
                
        // ❌ This results in an error in Swift 6:
        // Main actor-isolated property 'accountIdentifier' can not be referenced on a nonisolated actor instance; this is an error in the Swift 6 language mode.
        let accountIdentifier2 = session.jsonWebToken.accountIdentifier2
        
        print("Account ID: \(accountIdentifier1)")
        print("Account ID: \(accountIdentifier2)")
    }
}
