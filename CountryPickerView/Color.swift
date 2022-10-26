//
//  Color.swift
//  CountryPickerView
//
//  Created by Ahmed Amr on 26/10/2022.
//  Copyright © 2022 Kizito Nwose. All rights reserved.
//

import UIKit

private enum SystemColor {
    case background
    case background2
    case brand
    case brandSecondary
    case overlay
    case overlayInverted
    case primary
    case inverted
    case dim
    case dim2
    case dim3
    case active
    case success
    case warning
    case error

    var value: UIColor {
        switch self {
        case .background:
            return UIColor(hex: "#1B1B1B")
        case .background2:
            return .black.withAlphaComponent(0.35)
        case .brand:
            return UIColor(hex: "#26203E")
        case .brandSecondary:
            return UIColor(hex: "#684E5B")
        case .overlay:
            return .black.withAlphaComponent(0.5)
        case .overlayInverted:
            return .white.withAlphaComponent(0.5)
        case .primary:
            return UIColor(hex: "#FFFFFF")
        case .inverted:
            return UIColor(hex: "#000000")
        case .dim:
            return UIColor(hex: "#494949")
        case .dim2:
            return UIColor(hex: "#A4A4A4")
        case .dim3:
            return UIColor(hex: "#B9B9B9")
        case .active:
            return UIColor(hex: "#48FF70")
        case .success:
            return UIColor(hex: "#48FF70")
        case .warning:
            return UIColor(hex: "#F7403F")
        case .error:
            return UIColor(hex: "#FF3058")
        }
    }

}

struct Color {
    struct Brand {
        static let primary = SystemColor.primary.value
        static let accent = SystemColor.active.value
        static let dim = SystemColor.dim.value
    }

    struct Common {
        static let error = SystemColor.error.value
        static let warning = SystemColor.warning.value
        static let success = SystemColor.success.value
    }

    struct Background {
        static let primary = SystemColor.background.value
        static let secondary = SystemColor.background2.value
        static let accent = SystemColor.active.value
        static let brand = SystemColor.brand.value
        static let brandSecondary = SystemColor.brandSecondary.value
        static let dim = SystemColor.dim.value
        static let dim2 = SystemColor.dim2.value
        static let dim3 = SystemColor.dim3.value
        static let error = SystemColor.error.value
        static let success = SystemColor.success.value
        static let blank = SystemColor.primary.value
        static let overlay = SystemColor.overlay.value
        static let overlayInverted = SystemColor.overlayInverted.value
    }

    struct Text {
        static let primary = SystemColor.primary.value
        static let inverted = SystemColor.inverted.value
        static let dim = SystemColor.dim.value
        static let dim2 = SystemColor.dim3.value
    }

    struct Button {

    }

    struct Border {
        static let primary = SystemColor.dim.value
        static let light = SystemColor.primary.value
    }
}
