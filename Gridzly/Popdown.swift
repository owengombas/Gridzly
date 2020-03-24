//
//  Popdown.swift
//  Gridzly
//
//  Created by owen on 24.03.20.
//  Copyright © 2020 ven. All rights reserved.
//

import SwiftUI

struct Popdown: View {
    private var _content: some View 
    
    init(content: some View) {
        self._content = content
    }
    
    var body: some View {
        VStack {
            EmptyView()
        }
    }
}

struct Popdown_Previews: PreviewProvider {
    static var previews: some View {
        Popdown()
    }
}
