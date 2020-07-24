//
//  Created by Nazar Yavornytskyi on 7/24/20.
//  Copyright © 2020 Gluu. All rights reserved.
//

import Foundation

typealias VoidCallback = () -> Void
typealias Action<T> = (T) -> Void
typealias Func<TResult> = () -> TResult
typealias Delegate<T, V> = (T, V) -> Void
