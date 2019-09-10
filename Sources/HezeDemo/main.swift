//
//  main.swift
//  HezeDemo
//
//  Created by Yuu Zheng on 2019/9/10.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import Heze

HezeLogger.shared.debugOutput = true

HezeEnv.configEnv(
    HezeEnvConfig(username: "yuuzheng",
                  xcodeFolderName: "Virgo-faemuiddvcujvxcghlkvoydqwoaq",
                  macSourcePath: "/Users/yuuzheng/Developer/Heze",
                  linuxSourcePath: "")
)

HezeApp.createAndBoot(with: AppDelegate())
