//
//  FontFamily.swift
//  AuthenticatorApp
//
//  Created by Gideon Thackery on 21/02/2025.
//

import SwiftUI

extension Font {
    
    static func semiBold(size: CGFloat) -> Font {
        Font.custom("BaiJamjuree-SemiBold", size: size)
    }
    
    static func bold(size: CGFloat) -> Font {
        Font.custom("BaiJamjuree-Bold", size: size)
    }
    
    static func extraLight(size: CGFloat) -> Font {
        Font.custom("BaiJamjuree-ExtraLight", size: size)
    }
    
    static func regular(size: CGFloat) -> Font {
        Font.custom("BaiJamjuree-Regular", size: size)
    }
    
    static func medium(size: CGFloat) -> Font {
        Font.custom("BaiJamjuree-Medium", size: size)
    }
    
    static func light(size: CGFloat) -> Font {
        Font.custom("BaiJamjuree-Light", size: size)
    }
}
