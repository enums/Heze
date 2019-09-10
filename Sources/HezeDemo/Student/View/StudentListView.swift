//
//  StudentListView.swift
//  HezeDemo
//
//  Created by Yuu Zheng on 2019/9/10.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import Heze

class StudentListView: HezeListView {

    override var view: String? {
        return "student_list.html"
    }

    override func customFields(in set: String, for model: HezeModel) -> HezeViewParam? {
        return [
            "QUERY_DATE": Date().stringValue
        ]
    }

    override var modelSet: HezeModelSet {
        return [
            "student_list": StudentModel.query() ?? []
        ]
    }

}
