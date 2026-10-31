import Foundation

protocol GlyphRepository {
    func glyph(for id: CharacterID) async throws -> CharacterGlyph
    func hasStrokeData(for codepoint: UInt32) -> Bool
}

/// Errors specific to the bundle repository
private enum GlyphBundleError: Error, LocalizedError {
    case missingGlyph(script: Script, codepoint: UInt32)

    var errorDescription: String? {
        switch self {
        case let .missingGlyph(script, codepoint):
            return "No glyph found for script=\(script) codepoint=U+\(String(codepoint, radix: 16).uppercased())"
        }
    }
}

struct GlyphBundleRepository: GlyphRepository {
    // A minimal, embedded bundle of glyph data for the Japanese syllabaries and Chinese numbers.
    // Keyed by Unicode scalar value (codepoint) per script.
    
    // Chinese numbers 0-10, useful additional characters, and 100 common characters
    private static let hanzi: [UInt32: (literal: String, readings: [String], meaning: [String])] = {
        var map: [UInt32: (literal: String, readings: [String], meaning: [String])] = [:]
        let entries: [(UInt32, String, [String], [String])] = [
            // Numbers 0-10
            (0x96F6, "零", ["líng", "ling4"], ["zero"]),
            (0x4E00, "一", ["yī", "jat1"], ["one"]),
            (0x4E8C, "二", ["èr", "ji6"], ["two"]),
            (0x4E09, "三", ["sān", "saam1"], ["three"]),
            (0x56DB, "四", ["sì", "sei3"], ["four"]),
            (0x4E94, "五", ["wǔ", "ng5"], ["five"]),
            (0x516D, "六", ["liù", "luk6"], ["six"]),
            (0x4E03, "七", ["qī", "cat1"], ["seven"]),
            (0x516B, "八", ["bā", "baat3"], ["eight"]),
            (0x4E5D, "九", ["jiǔ", "gau2"], ["nine"]),
            (0x5341, "十", ["shí", "sap6"], ["ten"]),
            // Additional useful characters
            (0x767E, "百", ["bǎi", "baak3"], ["hundred"]),
            (0x5343, "千", ["qiān", "cin1"], ["thousand"]),
            (0x4E07, "万", ["wàn", "maan6"], ["ten thousand"]),
            (0x5104, "億", ["yì", "jik1"], ["hundred million"]),
            
            // 100 COMMON CHARACTERS FOR CHILDREN
            // Body parts & People
            (0x4EBA, "人", ["rén", "jan4"], ["person", "people"]),
            (0x53E3, "口", ["kǒu", "hau2"], ["mouth"]),
            (0x624B, "手", ["shǒu", "sau2"], ["hand"]),
            (0x76EE, "目", ["mù", "muk6"], ["eye"]),
            (0x8033, "耳", ["ěr", "ji5"], ["ear"]),
            (0x5FC3, "心", ["xīn", "sam1"], ["heart"]),
            (0x5973, "女", ["nǚ", "neoi5"], ["woman", "female"]),
            (0x5B50, "子", ["zǐ", "zi2"], ["child"]),
            
            // Nature & Elements
            (0x65E5, "日", ["rì", "jat6"], ["sun", "day"]),
            (0x6708, "月", ["yuè", "jyut6"], ["moon", "month"]),
            (0x6C34, "水", ["shuǐ", "seoi2"], ["water"]),
            (0x706B, "火", ["huǒ", "fo2"], ["fire"]),
            (0x6728, "木", ["mù", "muk6"], ["wood", "tree"]),
            (0x91D1, "金", ["jīn", "gam1"], ["gold", "metal"]),
            (0x571F, "土", ["tǔ", "tou2"], ["earth", "soil"]),
            (0x5929, "天", ["tiān", "tin1"], ["sky", "heaven"]),
            (0x5730, "地", ["dì", "dei6"], ["ground", "earth"]),
            (0x5C71, "山", ["shān", "saan1"], ["mountain"]),
            (0x7530, "田", ["tián", "tin4"], ["field"]),
            (0x77F3, "石", ["shí", "sek6"], ["stone", "rock"]),
            (0x98CE, "风", ["fēng", "fung1"], ["wind"]),
            (0x4E91, "云", ["yún", "wan4"], ["cloud"]),
            (0x96E8, "雨", ["yǔ", "jyu5"], ["rain"]),
            (0x96EA, "雪", ["xuě", "syut3"], ["snow"]),
            (0x7535, "电", ["diàn", "din6"], ["electricity", "lightning"]),
            
            // Size & Direction
            (0x5927, "大", ["dà", "daai6"], ["big", "large"]),
            (0x5C0F, "小", ["xiǎo", "siu2"], ["small", "little"]),
            (0x4E2D, "中", ["zhōng", "zung1"], ["middle", "center"]),
            (0x4E0A, "上", ["shàng", "soeng6"], ["up", "above"]),
            (0x4E0B, "下", ["xià", "haa6"], ["down", "below"]),
            (0x5DE6, "左", ["zuǒ", "zo2"], ["left"]),
            (0x53F3, "右", ["yòu", "jau6"], ["right"]),
            (0x957F, "长", ["cháng", "coeng4"], ["long"]),
            (0x591A, "多", ["duō", "do1"], ["many", "much"]),
            (0x5C11, "少", ["shǎo", "siu2"], ["few", "little"]),
            (0x9AD8, "高", ["gāo", "gou1"], ["tall", "high"]),
            
            // Common Objects & Animals
            (0x95E8, "门", ["mén", "mun4"], ["door", "gate"]),
            (0x9A6C, "马", ["mǎ", "maa5"], ["horse"]),
            (0x725B, "牛", ["niú", "ngau4"], ["ox", "cow"]),
            (0x7F8A, "羊", ["yáng", "joeng4"], ["sheep", "goat"]),
            (0x9E1F, "鸟", ["niǎo", "niu5"], ["bird"]),
            (0x9C7C, "鱼", ["yú", "jyu4"], ["fish"]),
            (0x7C73, "米", ["mǐ", "mai5"], ["rice"]),
            (0x7AF9, "竹", ["zhú", "zuk1"], ["bamboo"]),
            (0x4E1D, "丝", ["sī", "si1"], ["silk", "thread"]),
            (0x866B, "虫", ["chóng", "cung4"], ["insect", "worm"]),
            (0x8D1D, "贝", ["bèi", "bui3"], ["shell"]),
            (0x89C1, "见", ["jiàn", "gin3"], ["see", "meet"]),
            (0x8F66, "车", ["chē", "ce1"], ["vehicle", "car"]),
            (0x5200, "刀", ["dāo", "dou1"], ["knife"]),
            (0x529B, "力", ["lì", "lik6"], ["power", "strength"]),
            (0x53C8, "又", ["yòu", "jau6"], ["again", "also"]),
            (0x6587, "文", ["wén", "man4"], ["language", "culture"]),
            (0x65B9, "方", ["fāng", "fong1"], ["square", "direction"]),
            
            // Pronouns & Common Words
            (0x4E0D, "不", ["bù", "bat1"], ["not", "no"]),
            (0x4E5F, "也", ["yě", "jaa5"], ["also", "too"]),
            (0x4E86, "了", ["le", "liu5"], ["completed action"]),
            (0x5728, "在", ["zài", "zoi6"], ["at", "in", "exist"]),
            (0x6709, "有", ["yǒu", "jau5"], ["have", "exist"]),
            (0x6211, "我", ["wǒ", "ngo5"], ["I", "me"]),
            (0x4F60, "你", ["nǐ", "nei5"], ["you"]),
            (0x4ED6, "他", ["tā", "taa1"], ["he", "him"]),
            (0x5979, "她", ["tā", "taa1"], ["she", "her"]),
            (0x597D, "好", ["hǎo", "hou2"], ["good", "well"]),
            
            // Common Verbs
            (0x6765, "来", ["lái", "loi4"], ["come"]),
            (0x53BB, "去", ["qù", "heoi3"], ["go"]),
            (0x51FA, "出", ["chū", "ceot1"], ["exit", "go out"]),
            (0x5165, "入", ["rù", "jap6"], ["enter"]),
            (0x5403, "吃", ["chī", "hek3"], ["eat"]),
            (0x559D, "喝", ["hē", "hot3"], ["drink"]),
            (0x770B, "看", ["kàn", "hon3"], ["look", "see", "watch"]),
            (0x542C, "听", ["tīng", "teng1"], ["listen", "hear"]),
            (0x8BF4, "说", ["shuō", "syut3"], ["speak", "say"]),
            (0x8BFB, "读", ["dú", "duk6"], ["read"]),
            (0x5199, "写", ["xiě", "se2"], ["write"]),
            (0x8D70, "走", ["zǒu", "zau2"], ["walk", "go"]),
            (0x98DE, "飞", ["fēi", "fei1"], ["fly"]),
            (0x5750, "坐", ["zuò", "co5"], ["sit"]),
            (0x7AD9, "站", ["zhàn", "zaam6"], ["stand", "station"]),
            (0x7231, "爱", ["ài", "oi3"], ["love"]),
            (0x7B11, "笑", ["xiào", "siu3"], ["laugh", "smile"]),
            (0x54ED, "哭", ["kū", "huk1"], ["cry"]),
            
            // More Common Words
            (0x672C, "本", ["běn", "bun2"], ["root", "origin", "book"]),
            (0x767D, "白", ["bái", "baak6"], ["white"]),
            (0x7EA2, "红", ["hóng", "hung4"], ["red"]),
            (0x5F00, "开", ["kāi", "hoi1"], ["open", "start"]),
            (0x751F, "生", ["shēng", "saang1"], ["birth", "life", "grow"]),
            (0x5B66, "学", ["xué", "hok6"], ["study", "learn"]),
            (0x5DE5, "工", ["gōng", "gung1"], ["work", "worker"]),
            (0x7528, "用", ["yòng", "jung6"], ["use"]),
        ]
        for (codepoint, lit, readings, meanings) in entries {
            map[codepoint] = (literal: lit, readings: readings, meaning: meanings)
        }
        return map
    }()
    
//    // 100 First Chinese Characters - Basic learning set for beginners
//    // This is a curated list of the most fundamental characters for learning Chinese
//    // Based on the standard "First 100 Chinese Characters" curriculum
//    private static let firstHundredHanzi: [UInt32: (literal: String, readings: [String], meaning: [String])] = {
//        var map: [UInt32: (literal: String, readings: [String], meaning: [String])] = [:]
//        let entries: [(UInt32, String, [String], [String])] = [
//            // Column 1 (left)
//            (0x4E00, "一", ["yī", "jat1"], ["one"]),
//            (0x4E8C, "二", ["èr", "ji6"], ["two"]),
//            (0x4E09, "三", ["sān", "saam1"], ["three"]),
//            (0x56DB, "四", ["sì", "sei3"], ["four"]),
//            (0x4E94, "五", ["wǔ", "ng5"], ["five"]),
//            (0x516D, "六", ["liù", "luk6"], ["six"]),
//            (0x4E03, "七", ["qī", "cat1"], ["seven"]),
//            (0x516B, "八", ["bā", "baat3"], ["eight"]),
//            (0x4E5D, "九", ["jiǔ", "gau2"], ["nine"]),
//            (0x5341, "十", ["shí", "sap6"], ["ten"]),
//            (0x65E5, "日", ["rì", "jat6"], ["sun", "day"]),
//            (0x6708, "月", ["yuè", "jyut6"], ["moon", "month"]),
//            (0x597D, "好", ["hǎo", "hou2"], ["good", "well"]),
//            (0x9752, "青", ["qīng", "cing1"], ["green", "blue"]),
//            (0x8BF7, "请", ["qǐng", "cing2"], ["please", "request"]),
//            (0x8D35, "贵", ["guì", "gwai3"], ["expensive", "noble"]),
//            (0x5174, "兴", ["xìng", "hing1"], ["interest", "excited"]),
//            (0x4ED6, "他", ["tā", "taa1"], ["he", "him"]),
//            (0x600E, "怎", ["zěn", "zam2"], ["how"]),
//            (0x53EB, "叫", ["jiào", "giu3"], ["call", "be called"]),
//            (0x4EC0, "什", ["shén", "sap6"], ["what"]),
//            (0x4E48, "么", ["me", "mo1"], ["what"]),
//            (0x540D, "名", ["míng", "ming4"], ["name"]),
//            (0x5B57, "字", ["zì", "zi6"], ["character", "word"]),
//            (0x6211, "我", ["wǒ", "ngo5"], ["I", "me"]),
//            (0x5927, "大", ["dà", "daai6"], ["big", "large"]),
//            (0x5B66, "学", ["xué", "hok6"], ["study", "learn"]),
//            (0x4E2D, "中", ["zhōng", "zung1"], ["middle", "center", "China"]),
//            (0x8001, "老", ["lǎo", "lou5"], ["old"]),
//            (0x5E08, "师", ["shī", "si1"], ["teacher"]),
//            (0x7236, "父", ["fù", "fu6"], ["father"]),
//            (0x6BCD, "母", ["mǔ", "mou5"], ["mother"]),
//            (0x6587, "文", ["wén", "man4"], ["language", "culture", "text"]),
//            
//            // Column 2 (middle)
//            (0x5E02, "市", ["shì", "si5"], ["city", "market"]),
//            (0x540C, "同", ["tóng", "tung4"], ["same", "together"]),
//            (0x6821, "校", ["xiào", "haau6"], ["school"]),
//            (0x5C0F, "小", ["xiǎo", "siu2"], ["small", "little"]),
//            (0x6709, "有", ["yǒu", "jau5"], ["have", "exist"]),
//            (0x670B, "朋", ["péng", "pang4"], ["friend"]),
//            (0x53CB, "友", ["yǒu", "jau5"], ["friend"]),
//            (0x95E8, "门", ["mén", "mun4"], ["door", "gate"]),
//            (0x95EE, "问", ["wèn", "man6"], ["ask"]),
//            (0x8C22, "谢", ["xiè", "ze6"], ["thank"]),
//            (0x518D, "再", ["zài", "zoi3"], ["again"]),
//            (0x89C1, "见", ["jiàn", "gin3"], ["see", "meet"]),
//            (0x56FD, "国", ["guó", "gwok3"], ["country", "nation"]),
//            (0x4EBA, "人", ["rén", "jan4"], ["person", "people"]),
//            (0x9A6C, "马", ["mǎ", "maa5"], ["horse"]),
//            (0x4E5F, "也", ["yě", "jaa5"], ["also", "too"]),
//            (0x4E0D, "不", ["bù", "bat1"], ["not", "no"]),
//            (0x8BFB, "读", ["dú", "duk6"], ["read"]),
//            (0x5F97, "得", ["de", "dak1"], ["obtain", "must", "able"]),
//            (0x4ECB, "介", ["jiè", "gaai3"], ["introduce"]),
//            (0x7ECD, "绍", ["shào", "siu6"], ["introduce", "continue"]),
//            (0x4F1F, "伟", ["wěi", "wai5"], ["great", "magnificent"]),
//            (0x5F1F, "弟", ["dì", "dai6"], ["younger brother"]),
//            (0x59B9, "妹", ["mèi", "mui6"], ["younger sister"]),
//            (0x4F4F, "住", ["zhù", "zyu6"], ["live", "reside"]),
//            (0x5728, "在", ["zài", "zoi6"], ["at", "in", "exist"]),
//            (0x54EA, "哪", ["nǎ", "naa5"], ["which", "where"]),
//            (0x5973, "女", ["nǚ", "neoi5"], ["woman", "female"]),
//            (0x513F, "儿", ["ér", "ji4"], ["son", "child"]),
//            (0x5B50, "子", ["zǐ", "zi2"], ["child", "son"]),
//            (0x6D6A, "浪", ["làng", "long6"], ["wave"]),
//            (0x6CA1, "没", ["méi", "mut6"], ["not have", "no"]),
//            (0x4F5C, "作", ["zuò", "zok3"], ["do", "make"]),
//            
//            // Column 3 (right)
//            (0x4E8B, "事", ["shì", "si6"], ["matter", "affair", "thing"]),
//            (0x51C9, "凉", ["liáng", "loeng4"], ["cool", "cold"]),
//            (0x95F2, "闲", ["xián", "haan4"], ["idle", "free time"]),
//            (0x4F2F, "伯", ["bó", "baak3"], ["uncle", "elder"]),
//            (0x591A, "多", ["duō", "do1"], ["many", "much"]),
//            (0x5C11, "少", ["shǎo", "siu2"], ["few", "little"]),
//            (0x4E24, "两", ["liǎng", "loeng5"], ["two", "both"]),
//            (0x4ECA, "今", ["jīn", "gam1"], ["now", "today"]),
//            (0x5929, "天", ["tiān", "tin1"], ["sky", "heaven", "day"]),
//            (0x660E, "明", ["míng", "ming4"], ["bright", "clear"]),
//            (0x5E74, "年", ["nián", "nin4"], ["year"]),
//            (0x661F, "星", ["xīng", "sing1"], ["star"]),
//            (0x671F, "期", ["qī", "kei4"], ["period", "term"]),
//            (0x8349, "草", ["cǎo", "cou2"], ["grass"]),
//            (0x4E0A, "上", ["shàng", "soeng6"], ["up", "above"]),
//            (0x4E0B, "下", ["xià", "haa6"], ["down", "below"]),
//            (0x5348, "午", ["wǔ", "ng5"], ["noon"]),
//            (0x5403, "吃", ["chī", "hek3"], ["eat"]),
//            (0x665A, "晚", ["wǎn", "maan5"], ["evening", "late"]),
//            (0x996D, "饭", ["fàn", "faan6"], ["rice", "meal"]),
//            (0x4E86, "了", ["le", "liu5"], ["completed action"]),
//            (0x5462, "呢", ["ne", "ne1"], ["question particle"]),
//            (0x5427, "吧", ["ba", "baa1"], ["suggestion particle"]),
//            (0x548C, "和", ["hé", "wo4"], ["and", "with"]),
//            (0x5F88, "很", ["hěn", "han2"], ["very"]),
//            (0x559D, "喝", ["hē", "hot3"], ["drink"]),
//            (0x8FD9, "这", ["zhè", "ze5"], ["this"]),
//            (0x90A3, "那", ["nà", "naa5"], ["that"]),
//            (0x52AA, "努", ["nǔ", "nou5"], ["strive", "exert"]),
//            (0x529B, "力", ["lì", "lik6"], ["power", "strength"]),
//            (0x6D77, "海", ["hǎi", "hoi2"], ["sea", "ocean"]),
//            (0x53EF, "可", ["kě", "ho2"], ["can", "may"]),
//            (0x4E50, "乐", ["lè", "lok6"], ["happy", "music"]),
//        ]
//        for (codepoint, lit, readings, meanings) in entries {
//            map[codepoint] = (literal: lit, readings: readings, meaning: meanings)
//        }
//        return map
//    }()
    
    // 100 First Chinese Characters - Basic learning set for beginners
    // This is a curated list of the most fundamental characters for learning Chinese
    // Based on the standard "First 100 Chinese Characters" curriculum
    private static let firstHundredHanzi: [UInt32: (literal: String, readings: [String], meaning: [String])] = {
        var map: [UInt32: (literal: String, readings: [String], meaning: [String])] = [:]
        let entries: [(UInt32, String, [String], [String])] = [
            // Column 1 (left) - Numbers & Foundation
            (0x4E00, "一", ["yī", "jat1"], ["one"]),
            (0x4E8C, "二", ["èr", "ji6"], ["two"]),
            (0x4E09, "三", ["sān", "saam1"], ["three"]),
            (0x56DB, "四", ["sì", "sei3"], ["four"]),
            (0x4E94, "五", ["wǔ", "ng5"], ["five"]),
            (0x516D, "六", ["liù", "luk6"], ["six"]),
            (0x4E03, "七", ["qī", "cat1"], ["seven"]),
            (0x516B, "八", ["bā", "baat3"], ["eight"]),
            (0x4E5D, "九", ["jiǔ", "gau2"], ["nine"]),
            (0x5341, "十", ["shí", "sap6"], ["ten"]),
            (0x65E5, "日", ["rì", "jat6"], ["sun", "day"]),
            (0x6708, "月", ["yuè", "jyut6"], ["moon", "month"]),
            (0x597D, "好", ["hǎo", "hou2"], ["good", "well"]),
            (0x9752, "青", ["qīng", "cing1"], ["green", "blue"]),
            (0x8BF7, "请", ["qǐng", "cing2"], ["please", "request"]),
            (0x8D35, "贵", ["guì", "gwai3"], ["expensive", "noble"]),
            (0x5174, "兴", ["xìng", "hing1"], ["interest", "excited"]),
            (0x4ED6, "他", ["tā", "taa1"], ["he", "him"]),
            (0x600E, "怎", ["zěn", "zam2"], ["how"]),
            (0x53EB, "叫", ["jiào", "giu3"], ["call", "be called"]),
            (0x4EC0, "什", ["shén", "sap6"], ["what"]),
            (0x4E48, "么", ["me", "mo1"], ["what"]),
            (0x540D, "名", ["míng", "ming4"], ["name"]),
            (0x5B57, "字", ["zì", "zi6"], ["character", "word"]),
            (0x6211, "我", ["wǒ", "ngo5"], ["I", "me"]),
            (0x5927, "大", ["dà", "daai6"], ["big", "large"]),
            (0x5B66, "学", ["xué", "hok6"], ["study", "learn"]),
            (0x4E2D, "中", ["zhōng", "zung1"], ["middle", "center", "China"]),
            (0x8001, "老", ["lǎo", "lou5"], ["old"]),
            (0x5E08, "师", ["shī", "si1"], ["teacher"]),
            (0x7236, "父", ["fù", "fu6"], ["father"]),
            (0x6BCD, "母", ["mǔ", "mou5"], ["mother"]),
            (0x6587, "文", ["wén", "man4"], ["language", "culture", "text"]),
            
            // Column 2 (middle) - Social & Daily Life
            (0x5E02, "市", ["shì", "si5"], ["city", "market"]),
            (0x540C, "同", ["tóng", "tung4"], ["same", "together"]),
            (0x6821, "校", ["xiào", "haau6"], ["school"]),
            (0x5C0F, "小", ["xiǎo", "siu2"], ["small", "little"]),
            (0x6709, "有", ["yǒu", "jau5"], ["have", "exist"]),
            (0x670B, "朋", ["péng", "pang4"], ["friend"]),
            (0x53CB, "友", ["yǒu", "jau5"], ["friend"]),
            (0x95E8, "门", ["mén", "mun4"], ["door", "gate"]),
            (0x95EE, "问", ["wèn", "man6"], ["ask"]),
            (0x8C22, "谢", ["xiè", "ze6"], ["thank"]),
            (0x518D, "再", ["zài", "zoi3"], ["again"]),
            (0x89C1, "见", ["jiàn", "gin3"], ["see", "meet"]),
            (0x56FD, "国", ["guó", "gwok3"], ["country", "nation"]),
            (0x4EBA, "人", ["rén", "jan4"], ["person", "people"]),
            (0x9A6C, "马", ["mǎ", "maa5"], ["horse"]),
            (0x4E5F, "也", ["yě", "jaa5"], ["also", "too"]),
            (0x4E0D, "不", ["bù", "bat1"], ["not", "no"]),
            (0x8BFB, "读", ["dú", "duk6"], ["read"]),
            (0x5F97, "得", ["de", "dak1"], ["obtain", "must", "able"]),
            (0x4ECB, "介", ["jiè", "gaai3"], ["introduce"]),
            (0x7ECD, "绍", ["shào", "siu6"], ["introduce", "continue"]),
            (0x4F1F, "伟", ["wěi", "wai5"], ["great", "magnificent"]),
            (0x5F1F, "弟", ["dì", "dai6"], ["younger brother"]),
            (0x59B9, "妹", ["mèi", "mui6"], ["younger sister"]),
            (0x4F4F, "住", ["zhù", "zyu6"], ["live", "reside"]),
            (0x5728, "在", ["zài", "zoi6"], ["at", "in", "exist"]),
            (0x54EA, "哪", ["nǎ", "naa5"], ["which", "where"]),
            (0x5973, "女", ["nǚ", "neoi5"], ["woman", "female"]),
            (0x513F, "儿", ["ér", "ji4"], ["son", "child"]),
            (0x5B50, "子", ["zǐ", "zi2"], ["child", "son"]),
            (0x6D6A, "浪", ["làng", "long6"], ["wave"]),
            (0x6CA1, "没", ["méi", "mut6"], ["not have", "no"]),
            (0x4F5C, "作", ["zuò", "zok3"], ["do", "make"]),
            
            // Column 3 (right) - Time & Actions
            (0x4E8B, "事", ["shì", "si6"], ["matter", "affair", "thing"]),
            (0x51C9, "凉", ["liáng", "loeng4"], ["cool", "cold"]),
            (0x95F2, "闲", ["xián", "haan4"], ["idle", "free time"]),
            (0x4F2F, "伯", ["bó", "baak3"], ["uncle", "elder"]),
            (0x591A, "多", ["duō", "do1"], ["many", "much"]),
            (0x5C11, "少", ["shǎo", "siu2"], ["few", "little"]),
            (0x4E24, "两", ["liǎng", "loeng5"], ["two", "both"]),
            (0x4ECA, "今", ["jīn", "gam1"], ["now", "today"]),
            (0x5929, "天", ["tiān", "tin1"], ["sky", "heaven", "day"]),
            (0x660E, "明", ["míng", "ming4"], ["bright", "clear"]),
            (0x5E74, "年", ["nián", "nin4"], ["year"]),
            (0x661F, "星", ["xīng", "sing1"], ["star"]),
            (0x671F, "期", ["qī", "kei4"], ["period", "term"]),
            (0x8349, "草", ["cǎo", "cou2"], ["grass"]),
            (0x4E0A, "上", ["shàng", "soeng6"], ["up", "above"]),
            (0x4E0B, "下", ["xià", "haa6"], ["down", "below"]),
            (0x5348, "午", ["wǔ", "ng5"], ["noon"]),
            (0x5403, "吃", ["chī", "hek3"], ["eat"]),
            (0x665A, "晚", ["wǎn", "maan5"], ["evening", "late"]),
            (0x996D, "饭", ["fàn", "faan6"], ["rice", "meal"]),
            (0x4E86, "了", ["le", "liu5"], ["completed action"]),
            (0x5462, "呢", ["ne", "ne1"], ["question particle"]),
            (0x5427, "吧", ["ba", "baa1"], ["suggestion particle"]),
            (0x548C, "和", ["hé", "wo4"], ["and", "with"]),
            (0x5F88, "很", ["hěn", "han2"], ["very"]),
            (0x559D, "喝", ["hē", "hot3"], ["drink"]),
            (0x8FD9, "这", ["zhè", "ze5"], ["this"]),
            (0x90A3, "那", ["nà", "naa5"], ["that"]),
            (0x52AA, "努", ["nǔ", "nou5"], ["strive", "exert"]),
            (0x529B, "力", ["lì", "lik6"], ["power", "strength"]),
            (0x6D77, "海", ["hǎi", "hoi2"], ["sea", "ocean"]),
            (0x53EF, "可", ["kě", "ho2"], ["can", "may"]),
            (0x4E50, "乐", ["lè", "lok6"], ["happy", "music"]),
            
            // Family members (Δ-167): pinyin first, Cantonese jyutping second
            (0x7238, "爸", ["bà", "baa1"], ["dad"]),
            (0x5988, "妈", ["mā", "maa1"], ["mom"]),
            (0x54E5, "哥", ["gē", "go1"], ["older brother"]),
            (0x59D0, "姐", ["jiě", "ze2"], ["older sister"]),
            (0x7237, "爷", ["yé", "je4"], ["grandpa (dad's dad)"]),
            (0x5976, "奶", ["nǎi", "naai5"], ["grandma (dad's mom)"]),
            (0x5916, "外", ["wài", "ngoi6"], ["outside", "mom's side (外公, 外婆)"]),
            (0x516C, "公", ["gōng", "gung1"], ["grandpa (外公, mom's dad)"]),
            (0x5A46, "婆", ["pó", "po4"], ["grandma (外婆, mom's mom)"]),
            (0x53D4, "叔", ["shū", "suk1"], ["uncle (dad's younger brother)"]),
            (0x59E8, "姨", ["yí", "ji4"], ["aunt (mom's sister)"]),
            (0x8205, "舅", ["jiù", "kau5"], ["uncle (mom's brother)"]),
            (0x59D1, "姑", ["gū", "gu1"], ["aunt (dad's sister)"]),
        ]
        for (codepoint, lit, readings, meanings) in entries {
            map[codepoint] = (literal: lit, readings: readings, meaning: meanings)
        }
        return map
    }()
    
    // Compound numbers 11-100, generated from the digits.
    // Using negative numbers as keys to distinguish from Unicode codepoints.
    private static let digitNames: [(codepoint: Int, literal: String, pinyin: String, jyutping: String)] = [
        (0x96F6, "零", "líng", "ling4"),
        (0x4E00, "一", "yī", "jat1"),
        (0x4E8C, "二", "èr", "ji6"),
        (0x4E09, "三", "sān", "saam1"),
        (0x56DB, "四", "sì", "sei3"),
        (0x4E94, "五", "wǔ", "ng5"),
        (0x516D, "六", "liù", "luk6"),
        (0x4E03, "七", "qī", "cat1"),
        (0x516B, "八", "bā", "baat3"),
        (0x4E5D, "九", "jiǔ", "gau2")
    ]
    private static let ten = (codepoint: 0x5341, literal: "十", pinyin: "shí", jyutping: "sap6")
    private static let hundred = (codepoint: 0x767E, literal: "百", pinyin: "bǎi", jyutping: "baak3")
    
    /// English words for 11-100 ("eleven", "thirty-one", "one hundred").
    static func englishNumber(_ n: Int) -> String {
        let ones = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
        let teens = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
        let tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
        if n == 100 { return "one hundred" }
        if n < 10 { return ones[n] }
        if n < 20 { return teens[n - 10] }
        return n % 10 == 0 ? tens[n / 10] : "\(tens[n / 10])-\(ones[n % 10])"
    }
    
    private static let compoundNumbers: [Int: (literal: String, readings: [String], meaning: [String], components: [Int])] = {
        var map: [Int: (literal: String, readings: [String], meaning: [String], components: [Int])] = [:]
        for n in 11...100 {
            var parts: [(codepoint: Int, literal: String, pinyin: String, jyutping: String)] = []
            if n == 100 {
                parts = [digitNames[1], hundred]                   // 一百
            } else {
                if n / 10 > 1 { parts.append(digitNames[n / 10]) } // 二十 … 九十 (but 十一, not 一十一)
                parts.append(ten)
                if n % 10 > 0 { parts.append(digitNames[n % 10]) }
            }
            map[n] = (
                literal: parts.map(\.literal).joined(),
                readings: [parts.map(\.pinyin).joined(separator: " "), parts.map(\.jyutping).joined(separator: " ")],
                meaning: [englishNumber(n)],
                components: parts.map(\.codepoint)
            )
        }
        return map
    }()
    
    private static let hiragana: [UInt32: (literal: String, readings: [String])] = {
        var map: [UInt32: (literal: String, readings: [String])] = [:]
        // Core GOJŪON (U+3041..U+3096) including small kana and voiced/p-sounds
        let entries: [(UInt32, String, String)] = [
            (0x3041, "ぁ", "a"), (0x3042, "あ", "a"), (0x3043, "ぃ", "i"), (0x3044, "い", "i"),
            (0x3045, "ぅ", "u"), (0x3046, "う", "u"), (0x3047, "ぇ", "e"), (0x3048, "え", "e"),
            (0x3049, "ぉ", "o"), (0x304A, "お", "o"),
            (0x304B, "か", "ka"), (0x304C, "が", "ga"),
            (0x304D, "き", "ki"), (0x304E, "ぎ", "gi"),
            (0x304F, "く", "ku"), (0x3050, "ぐ", "gu"),
            (0x3051, "け", "ke"), (0x3052, "げ", "ge"),
            (0x3053, "こ", "ko"), (0x3054, "ご", "go"),
            (0x3055, "さ", "sa"), (0x3056, "ざ", "za"),
            (0x3057, "し", "shi"), (0x3058, "じ", "ji"),
            (0x3059, "す", "su"), (0x305A, "ず", "zu"),
            (0x305B, "せ", "se"), (0x305C, "ぜ", "ze"),
            (0x305D, "そ", "so"), (0x305E, "ぞ", "zo"),
            (0x305F, "た", "ta"), (0x3060, "だ", "da"),
            (0x3061, "ち", "chi"), (0x3062, "ぢ", "ji"),
            (0x3064, "つ", "tsu"), (0x3065, "づ", "zu"),
            (0x3063, "っ", "tsu"),
            (0x3066, "て", "te"), (0x3067, "で", "de"),
            (0x3068, "と", "to"), (0x3069, "ど", "do"),
            (0x306A, "な", "na"), (0x306B, "に", "ni"), (0x306C, "ぬ", "nu"), (0x306D, "ね", "ne"), (0x306E, "の", "no"),
            (0x306F, "は", "ha"), (0x3070, "ば", "ba"), (0x3071, "ぱ", "pa"),
            (0x3072, "ひ", "hi"), (0x3073, "び", "bi"), (0x3074, "ぴ", "pi"),
            (0x3075, "ふ", "fu"), (0x3076, "ぶ", "bu"), (0x3077, "ぷ", "pu"),
            (0x3078, "へ", "he"), (0x3079, "べ", "be"), (0x307A, "ぺ", "pe"),
            (0x307B, "ほ", "ho"), (0x307C, "ぼ", "bo"), (0x307D, "ぽ", "po"),
            (0x307E, "ま", "ma"), (0x307F, "み", "mi"), (0x3080, "む", "mu"), (0x3081, "め", "me"), (0x3082, "も", "mo"),
            (0x3083, "ゃ", "ya"), (0x3084, "や", "ya"), (0x3085, "ゅ", "yu"), (0x3086, "ゆ", "yu"), (0x3087, "ょ", "yo"), (0x3088, "よ", "yo"),
            (0x3089, "ら", "ra"), (0x308A, "り", "ri"), (0x308B, "る", "ru"), (0x308C, "れ", "re"), (0x308D, "ろ", "ro"),
            (0x308E, "ゎ", "wa"), (0x308F, "わ", "wa"), (0x3090, "ゐ", "wi"), (0x3091, "ゑ", "we"), (0x3092, "を", "wo"),
            (0x3093, "ん", "n"), (0x3094, "ゔ", "vu"), (0x3095, "ゕ", "ka"), (0x3096, "ゖ", "ke")
        ]
        for (s, lit, rom) in entries {
            map[s] = (literal: lit, readings: [rom])
        }
        return map
    }()

    private static let katakana: [UInt32: (literal: String, readings: [String])] = {
        var map: [UInt32: (literal: String, readings: [String])] = [:]
        let entries: [(UInt32, String, String)] = [
            (0x30A1, "ァ", "a"), (0x30A2, "ア", "a"), (0x30A3, "ィ", "i"), (0x30A4, "イ", "i"),
            (0x30A5, "ゥ", "u"), (0x30A6, "ウ", "u"), (0x30A7, "ェ", "e"), (0x30A8, "エ", "e"),
            (0x30A9, "ォ", "o"), (0x30AA, "オ", "o"),
            (0x30AB, "カ", "ka"), (0x30AC, "ガ", "ga"),
            (0x30AD, "キ", "ki"), (0x30AE, "ギ", "gi"),
            (0x30AF, "ク", "ku"), (0x30B0, "グ", "gu"),
            (0x30B1, "ケ", "ke"), (0x30B2, "ゲ", "ge"),
            (0x30B3, "コ", "ko"), (0x30B4, "ゴ", "go"),
            (0x30B5, "サ", "sa"), (0x30B6, "ザ", "za"),
            (0x30B7, "シ", "shi"), (0x30B8, "ジ", "ji"),
            (0x30B9, "ス", "su"), (0x30BA, "ズ", "zu"),
            (0x30BB, "セ", "se"), (0x30BC, "ゼ", "ze"),
            (0x30BD, "ソ", "so"), (0x30BE, "ゾ", "zo"),
            (0x30BF, "タ", "ta"), (0x30C0, "ダ", "da"),
            (0x30C1, "チ", "chi"), (0x30C2, "ヂ", "ji"),
            (0x30C3, "ッ", "tsu"), (0x30C4, "ツ", "tsu"), (0x30C5, "ヅ", "zu"),
            (0x30C6, "テ", "te"), (0x30C7, "デ", "de"),
            (0x30C8, "ト", "to"), (0x30C9, "ド", "do"),
            (0x30CA, "ナ", "na"), (0x30CB, "ニ", "ni"), (0x30CC, "ヌ", "nu"), (0x30CD, "ネ", "ne"), (0x30CE, "ノ", "no"),
            (0x30CF, "ハ", "ha"), (0x30D0, "バ", "ba"), (0x30D1, "パ", "pa"),
            (0x30D2, "ヒ", "hi"), (0x30D3, "ビ", "bi"), (0x30D4, "ピ", "pi"),
            (0x30D5, "フ", "fu"), (0x30D6, "ブ", "bu"), (0x30D7, "プ", "pu"),
            (0x30D8, "ヘ", "he"), (0x30D9, "ベ", "be"), (0x30DA, "ペ", "pe"),
            (0x30DB, "ホ", "ho"), (0x30DC, "ボ", "bo"), (0x30DD, "ポ", "po"),
            (0x30DE, "マ", "ma"), (0x30DF, "ミ", "mi"), (0x30E0, "ム", "mu"), (0x30E1, "メ", "me"), (0x30E2, "モ", "mo"),
            (0x30E3, "ャ", "ya"), (0x30E4, "ヤ", "ya"), (0x30E5, "ュ", "yu"), (0x30E6, "ユ", "yu"), (0x30E7, "ョ", "yo"), (0x30E8, "ヨ", "yo"),
            (0x30E9, "ラ", "ra"), (0x30EA, "リ", "ri"), (0x30EB, "ル", "ru"), (0x30EC, "レ", "re"), (0x30ED, "ロ", "ro"),
            (0x30EE, "ヮ", "wa"), (0x30EF, "ワ", "wa"), (0x30F0, "ヰ", "wi"), (0x30F1, "ヱ", "we"), (0x30F2, "ヲ", "wo"),
            (0x30F3, "ン", "n"), (0x30F4, "ヴ", "vu"), (0x30F5, "ヵ", "ka"), (0x30F6, "ヶ", "ke")
        ]
        for (s, lit, rom) in entries {
            map[s] = (literal: lit, readings: [rom])
        }
        return map
    }()

    func glyph(for id: CharacterID) async throws -> CharacterGlyph {
        // Check if this is a compound number (negative codepoint)
        if id.codepoint < 0 {
            let number = -id.codepoint
            if let payload = Self.compoundNumbers[number] {
                // Set each component character in its own cell, left to right
                let components = payload.components.map {
                    ChineseStrokeDataLoader.shared.loadNumberStrokes(for: UInt32($0)) ?? []
                }
                let allStrokes = CompoundLayout.sideBySide(components)
                
                return CharacterGlyph(
                    script: id.script,
                    codepoint: id.codepoint,
                    literal: payload.literal,
                    readings: payload.readings,
                    meaning: payload.meaning,
                    strokes: allStrokes,
                    difficulty: payload.components.count, // Difficulty based on number of components
                    components: payload.components
                )
            }
        }
        
        // Look up by codepoint in all available maps
        if let payload = Self.hiragana[UInt32(id.codepoint)] {
            // Load stroke data from JSON on-demand
            let strokes = StrokeDataLoader.loadStrokes(for: UInt32(id.codepoint)) ?? []
            return CharacterGlyph(script: id.script, codepoint: id.codepoint, literal: payload.literal, readings: payload.readings, meaning: [], strokes: strokes, difficulty: 1, components: nil)
        }
        if let payload = Self.katakana[UInt32(id.codepoint)] {
            // Load stroke data from JSON on-demand
            let strokes = StrokeDataLoader.loadStrokes(for: UInt32(id.codepoint)) ?? []
            return CharacterGlyph(script: id.script, codepoint: id.codepoint, literal: payload.literal, readings: payload.readings, meaning: [], strokes: strokes, difficulty: 1, components: nil)
        }
        // Check first hundred hanzi (beginner set) first - takes priority
        if let payload = Self.firstHundredHanzi[UInt32(id.codepoint)] {
            // Load Chinese character stroke data
            let strokes = ChineseStrokeDataLoader.shared.loadStrokes(for: UInt32(id.codepoint)) ?? []
            return CharacterGlyph(script: id.script, codepoint: id.codepoint, literal: payload.literal, readings: payload.readings, meaning: payload.meaning, strokes: strokes, difficulty: 1, components: nil)
        }
        if let payload = Self.hanzi[UInt32(id.codepoint)] {
            // Load Chinese character stroke data
            let strokes = ChineseStrokeDataLoader.shared.loadStrokes(for: UInt32(id.codepoint)) ?? []
            return CharacterGlyph(script: id.script, codepoint: id.codepoint, literal: payload.literal, readings: payload.readings, meaning: payload.meaning, strokes: strokes, difficulty: 1, components: nil)
        }
        throw GlyphBundleError.missingGlyph(script: id.script, codepoint: UInt32(id.codepoint))
    }
    
    /// Check if stroke data is available for a specific codepoint
    func hasStrokeData(for codepoint: UInt32) -> Bool {
        return StrokeDataLoader.loadStrokes(for: codepoint) != nil
    }
//    /// Check if stroke data is available for a specific codepoint
//    func hasStrokeData(for codepoint: UInt32) -> Bool {
//        return StrokeDataLoader.loadStrokes(for: codepoint) != nil
//    }
}

/// Places the characters of a compound (十一, 二十三 …) next to each other.
/// Each component is expected in a 0-1 cell; component i is shifted right by
/// i × (1 + gap). Without this the components were drawn on top of each other.
enum CompoundLayout {
    static let gap: Float = 0.15
    
    static func sideBySide(_ components: [[StrokePath]]) -> [StrokePath] {
        components.enumerated().flatMap { index, strokes in
            let dx = Float(index) * (1 + gap)
            return strokes.map { stroke in
                StrokePath(points: stroke.points.map { StrokePoint(x: $0.x + dx, y: $0.y, t: $0.t) })
            }
        }
    }
}
