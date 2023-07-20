//
//  Fraction.swift
//  ExiFrame
//
//  Created by Shumpei Nagata on 2023/07/20.
//

/// 分数を表現する構造体
struct Fraction {
    /// 分子
    let numerator: Int
    /// 分母
    let denominator: Int
    
    var fractionalExpression: String {
        "\(numerator)/\(denominator)"
    }
}

extension Fraction {
    // NOTE: https://stackoverflow.com/questions/35895154/decimal-to-fraction-conversion-in-swift
    init(number: Double) {
        let precision = 1.0E-6
        var x = number
        var a = x.rounded(.down)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)

        while x - a > precision * Double(k) * Double(k) {
            x = 1.0/(x - a)
            a = x.rounded(.down)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        self.init(numerator: h, denominator: k)
    }
}
