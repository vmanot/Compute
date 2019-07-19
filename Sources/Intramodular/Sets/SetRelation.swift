//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

protocol SetRelation: AnyProtocol {

}

protocol Injective: SetRelation {

}

protocol NonInjective: SetRelation {

}

protocol Surjective: SetRelation {

}

protocol NonSurjective: SetRelation {

}

/// A perfect one-to-one correspondence.
protocol Bijective: Injective, Surjective {

}

protocol InjectiveOnly: Injective, NonSurjective {

}
