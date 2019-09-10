//
//  IndexView.swift
//  HezeDemo
//
//  Created by Yuu Zheng on 2019/9/10.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import Heze

class IndexView: HezeView {

    override var view: String? {
        return "index.html"
    }

    override var param: HezeViewParam {
        return [
            "name": "Heze",
            "sec": sec
        ]
    }

}
